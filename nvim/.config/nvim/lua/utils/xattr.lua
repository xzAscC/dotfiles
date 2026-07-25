-- xattr.lua: read/write KDE Dolphin-compatible extended attributes.
--
-- Dolphin stores tags/comments/rating on the filesystem via xattr:
--   user.xdg.tags    "tag1, tag2, ..."   (comma-separated)
--   user.xdg.comment "free-form text"
--   user.baloo.rating "1".."5"           (star rating)
--
-- Baloo indexes these for fast desktop search (baloosearch tag:X).
-- This module talks to xattr directly via getfattr/setfattr, so it works
-- on ANY file type (pdf, epub, mp3, m4a, md, ...) as long as the
-- underlying filesystem supports xattr (ext4 default user.* namespace).
--
-- Depends on: getfattr, setfattr (Arch package: attr).
-- Telescope is required lazily only when a picker is invoked.
--
-- ---------------------------------------------------------------------------
-- User workflow (keymaps live in mappings.lua)
-- ---------------------------------------------------------------------------
-- Buffer-local (current file):
--   <leader>xt  edit tags          :XattrTags [path]
--   <leader>xc  edit comment       :XattrComment [path]
--   <leader>xr  edit rating 0-5    :XattrRating [path]
--   <leader>xs  show float info    :XattrShow [path]
--
-- Browse / inventory (cwd tree):
--   <leader>fx  or  :XattrFind
--     1) Tag picker: nested tags + counts; "(untagged)" pinned first.
--        <CR>  drill into files for that tag / untagged set.
--     2) File picker (after drill-down): path + [tags] + stars, with preview.
--        Title bar hints:  <C-t> tag  <A-c> comment  <A-r> rating
--
--        Key          Mode        Action
--        ------------ ----------- ------------------------------------------
--        <CR>         i/n         open file in current window
--        <C-t>        i/n         edit tags (picker stays open)
--        t            n           same as <C-t>
--        <C-e>        i/n         same as <C-t> (legacy)
--        <A-c>        i/n         edit comment (picker stays open)
--        c            n           same as <A-c>
--        <A-r>        i/n         edit rating (picker stays open)
--        r            n           same as <A-r>
--
--        In-place edit behavior:
--        - vim.ui.input stacks above Telescope; list is NOT closed.
--        - After a successful write, the row refreshes (tags/comment/rating).
--        - When title is "untagged" (or opts.drop_when_tagged = true), a file
--          that gains one or more tags is removed from the list so you can
--          walk the inventory without reopening <leader>fx.
--        - When the list becomes empty, the picker closes.
--        - Drill-down into a real tag only updates the row display; it does
--          not remove the file from that tag's file list.

local M = {}

-- xattr keys used by Dolphin/Baloo (KDE semantic desktop spec).
M.KEYS = {
  tags = "user.xdg.tags",
  comment = "user.xdg.comment",
  rating = "user.baloo.rating",
}

-- Optional: restrict recursive scans to a sane default scope.
M.config = {
  -- Where M.collect() walks if no path is given.
  default_root = nil, -- populated lazily from cwd in M.collect()
  -- Only collect attributes under the user.* namespace to skip system/security noise.
  user_only = true,
}

-- Run a shell command, returning stdout lines + success flag.
-- Uses vim.fn.systemlist with a list-form argv to avoid shell-quoting issues
-- (important for filenames containing spaces, quotes, or backslashes).
local function run_list(argv)
  local out = vim.fn.systemlist(argv)
  local ok = vim.v.shell_error == 0
  return out, ok
end

-- Run a shell command joining output into a single string.
local function run_string(argv)
  local out = vim.fn.system(argv)
  local ok = vim.v.shell_error == 0
  -- system() appends a trailing newline; strip it for value reads.
  return out, ok
end

-- Read a single xattr value for a path. Returns nil if the attribute is absent.
function M.get(path, key)
  if not path or path == "" then
    return nil
  end
  local out, ok = run_string({
    "getfattr",
    "-n",
    key,
    "--only-values",
    "--absolute-names",
    path,
  })
  if not ok then
    return nil
  end
  -- Strip a single trailing newline that getfattr emits.
  return (out:gsub("\n$", ""))
end

-- Set a single xattr value. Pass nil/empty value to remove the attribute.
function M.set(path, key, value)
  if not path or path == "" then
    return false
  end
  if value == nil or value == "" then
    return M.remove(path, key)
  end
  run_list({ "setfattr", "-n", key, "-v", tostring(value), path })
  return vim.v.shell_error == 0
end

-- Remove an xattr key from path. Succeeds even if the key was absent.
function M.remove(path, key)
  if not path or path == "" then
    return false
  end
  run_list({ "setfattr", "-x", key, path })
  -- setfattr -x exits non-zero if the attribute is absent; treat as success.
  return true
end

-- --------------------------------------------------------------------------- --
-- Typed accessors for the three Dolphin keys                                   --
-- --------------------------------------------------------------------------- --

-- Returns tags as an ordered list (deduplicated, trimmed).
-- Nested tags preserve the '/' separator (e.g. "diary/daily").
function M.get_tags(path)
  local v = M.get(path, M.KEYS.tags)
  if not v or v == "" then
    return {}
  end
  local seen = {}
  local tags = {}
  for t in vim.gsplit(v, ",") do
    t = vim.trim(t)
    if t ~= "" and not seen[t] then
      seen[t] = true
      tags[#tags + 1] = t
    end
  end
  return tags
end

-- Writes the tag list back. Empty list removes the attribute.
function M.set_tags(path, tags)
  if not tags or #tags == 0 then
    return M.remove(path, M.KEYS.tags)
  end
  -- Deduplicate while preserving order.
  local seen, clean = {}, {}
  for _, t in ipairs(tags) do
    t = vim.trim(t)
    if t ~= "" and not seen[t] then
      seen[t] = true
      clean[#clean + 1] = t
    end
  end
  if #clean == 0 then
    return M.remove(path, M.KEYS.tags)
  end
  return M.set(path, M.KEYS.tags, table.concat(clean, ", "))
end

function M.get_comment(path)
  return M.get(path, M.KEYS.comment) or ""
end

function M.set_comment(path, comment)
  return M.set(path, M.KEYS.comment, comment or "")
end

-- Rating: 0-5 stars. 0 means "remove" (Dolphin convention).
function M.get_rating(path)
  local v = M.get(path, M.KEYS.rating)
  local n = tonumber(v)
  if not n then
    return 0
  end
  return math.max(0, math.min(5, math.floor(n)))
end

function M.set_rating(path, n)
  n = tonumber(n) or 0
  n = math.max(0, math.min(5, math.floor(n)))
  if n == 0 then
    return M.remove(path, M.KEYS.rating)
  end
  return M.set(path, M.KEYS.rating, tostring(n))
end

-- Returns a human-readable star string ("★★★★☆") for a rating.
function M.stars(n)
  n = tonumber(n) or 0
  n = math.max(0, math.min(5, math.floor(n)))
  return string.rep("★", n) .. string.rep("☆", 5 - n)
end

-- --------------------------------------------------------------------------- --
-- Directory walking: collect all user.* attrs across a tree                    --
-- --------------------------------------------------------------------------- --

-- Unescape getfattr's C-style quoted value. Handles common cases:
--   \"  "      \\  \     \'  '
--   \n  LF     \t  TAB   \r  CR
--   \NNN octal (3 digits)
local function unescape_value(s)
  if not s then
    return ""
  end
  -- Strip surrounding quotes if present.
  s = s:gsub("^%s*\"(.-)\"%s*$", "%1")
  return (s:gsub("\\(%d%d%d)", function(o)
    return string.char(tonumber(o, 8) or 0)
  end):gsub('\\(.)', function(c)
    if c == "n" then
      return "\n"
    elseif c == "t" then
      return "\t"
    elseif c == "r" then
      return "\r"
    else
      return c -- covers \" \\ \' and any others -> literal char
    end
  end))
end

-- Parse `getfattr -R -d` dump output into a structured table.
-- Returns: { files = { [path] = { tags={...}, comment=..., rating=N, raw={} } },
--            tags  = { [tag] = { path1, path2, ... } } }
local function parse_dump(lines, opts)
  opts = opts or {}
  local collect_tags = opts.collect_tags ~= false

  local result = { files = {}, tags = {} }
  local current_path = nil
  local current_raw = {}

  -- Pattern: "# file: <path>" possibly without leading slash (getfattr strips
  -- it unless --absolute-names is used; we always pass --absolute-names).
  local file_pattern = "^# file: (.+)$"
  -- Pattern: 'key="value"' where value may contain escaped chars.
  local attr_pattern = "^(user%.[%w%.%-]+)=(.*)$"

  local function flush()
    if not current_path then
      return
    end
    result.files[current_path] = { raw = current_raw }
    local entry = result.files[current_path]
    entry.tags = {}
    entry.comment = ""
    entry.rating = 0
    if current_raw[M.KEYS.tags] then
      for t in vim.gsplit(current_raw[M.KEYS.tags], ",") do
        t = vim.trim(t)
        if t ~= "" then
          entry.tags[#entry.tags + 1] = t
          if collect_tags then
            result.tags[t] = result.tags[t] or {}
            table.insert(result.tags[t], current_path)
          end
        end
      end
    end
    if current_raw[M.KEYS.comment] then
      entry.comment = current_raw[M.KEYS.comment]
    end
    if current_raw[M.KEYS.rating] then
      entry.rating = tonumber(current_raw[M.KEYS.rating]) or 0
    end
    current_path = nil
    current_raw = {}
  end

  for _, line in ipairs(lines) do
    local fp = line:match(file_pattern)
    if fp then
      flush()
      current_path = fp
      current_raw = {}
    else
      local k, v = line:match(attr_pattern)
      if k and v and current_path then
        current_raw[k] = unescape_value(v)
      elseif line == "" then
        flush()
      end
    end
  end
  flush()

  return result
end

-- Walk a directory tree and collect all user.* xattrs.
-- @param root string?  directory to scan (defaults to cwd)
-- @param opts table?    { collect_tags = true }
-- @return table  see parse_dump
function M.collect(root, opts)
  root = root or M.config.default_root or vim.fn.getcwd()
  local argv = { "getfattr", "-R", "-d" }
  if M.config.user_only then
    table.insert(argv, "-m")
    table.insert(argv, "user\\.")
  end
  table.insert(argv, "--absolute-names")
  table.insert(argv, root)
  local out, ok = run_list(argv)
  if not ok and #out == 0 then
    vim.notify(
      string.format("xattr: getfattr failed on %s", root),
      vim.log.levels.WARN
    )
    return { files = {}, tags = {} }
  end
  return parse_dump(out, opts)
end

local function abs_path(path)
  return vim.fn.fnamemodify(path, ":p")
end

-- Regular files under root. Prefer fd/rg so .gitignore is honored; find is last resort.
-- @param root string?
-- @return string[] absolute paths
function M.list_files(root)
  root = root or M.config.default_root or vim.fn.getcwd()
  root = abs_path(root):gsub("/+$", "")
  if root == "" then
    root = "/"
  end

  local paths = {}

  if vim.fn.executable("fd") == 1 then
    local out, ok = run_list({
      "fd",
      "--type",
      "f",
      "--absolute-path",
      "--base-directory",
      root,
      ".",
    })
    if ok then
      for _, p in ipairs(out) do
        if p ~= "" then
          paths[#paths + 1] = abs_path(p)
        end
      end
      return paths
    end
  end

  if vim.fn.executable("rg") == 1 then
    local out, ok = run_list({ "rg", "--files", "--", root })
    if ok then
      for _, p in ipairs(out) do
        if p ~= "" then
          if p:sub(1, 1) == "/" then
            paths[#paths + 1] = abs_path(p)
          else
            paths[#paths + 1] = abs_path(root .. "/" .. p)
          end
        end
      end
      return paths
    end
  end

  local out, ok = run_list({
    "find",
    root,
    "-type",
    "f",
    "-print",
  })
  if ok then
    vim.notify(
      "xattr: fd/rg unavailable; untagged scan ignores .gitignore",
      vim.log.levels.WARN
    )
    for _, p in ipairs(out) do
      if p ~= "" then
        paths[#paths + 1] = abs_path(p)
      end
    end
  else
    vim.notify("xattr: failed to enumerate files under " .. root, vim.log.levels.WARN)
  end
  return paths
end

-- Paths with empty/missing user.xdg.tags (inventory via list_files / .gitignore).
-- @param root string?
-- @param data table? optional M.collect(root) result to reuse
-- @return string[] sorted absolute paths
function M.list_untagged(root, data)
  root = root or M.config.default_root or vim.fn.getcwd()
  data = data or M.collect(root)

  local tagged = {}
  for path, info in pairs(data.files) do
    if info.tags and #info.tags > 0 then
      tagged[abs_path(path)] = true
    end
  end

  local untagged = {}
  for _, p in ipairs(M.list_files(root)) do
    if not tagged[p] then
      untagged[#untagged + 1] = p
    end
  end
  table.sort(untagged)
  return untagged
end

-- --------------------------------------------------------------------------- --
-- Display: floating window showing all xattr for current file                  --
-- --------------------------------------------------------------------------- --

-- Resolve the path to operate on: explicit arg, or current buffer's file.
-- Returns nil and notifies the user if no usable path can be determined.
local function resolve_path(path)
  path = path or vim.api.nvim_buf_get_name(0)
  if path == "" then
    -- Try the buftype-specific file (e.g. some plugin buffers expose a name).
    path = vim.fn.expand("%:p")
  end
  if path == "" or vim.fn.filereadable(path) ~= 1 then
    return nil
  end
  return vim.fn.fnamemodify(path, ":p")
end

-- Open a small centered floating window with the given lines.
local function float(lines, title)
  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, #l)
  end
  width = math.min(math.max(width, #title + 4) + 2, vim.o.columns - 4)
  local height = math.min(#lines + 1, math.floor(vim.o.lines * 0.6))

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "xattr")

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  })
  -- Close on q / <Esc>.
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "<ESC>", "<cmd>close<CR>", { buffer = buf, nowait = true, silent = true })
  return buf, win
end

-- Pretty-print the full xattr info for a path.
function M.show(path)
  path = resolve_path(path)
  if not path then
    vim.notify("xattr: no readable file for current buffer", vim.log.levels.WARN)
    return
  end

  local tags = M.get_tags(path)
  local comment = M.get_comment(path)
  local rating = M.get_rating(path)
  local rel = vim.fn.fnamemodify(path, ":~")

  local lines = {}
  table.insert(lines, "File:  " .. rel)
  table.insert(lines, "Tags:  " .. (#tags > 0 and table.concat(tags, ", ") or "(none)"))
  table.insert(lines, "Rating:" .. M.stars(rating) .. string.format("  (%d/5)", rating))
  table.insert(lines, "")
  table.insert(lines, "Comment:")
  if comment == "" then
    table.insert(lines, "  (none)")
  else
    for line in vim.gsplit(comment, "\n") do
      table.insert(lines, "  " .. line)
    end
  end
  float(lines, "xattr: " .. vim.fn.fnamemodify(path, ":t"))
end

-- --------------------------------------------------------------------------- --
-- Edit: vim.ui.input-based editors                                             --
-- --------------------------------------------------------------------------- --

-- Edit the tag list for a path. Prefilled with current tags as CSV.
-- Optional on_done(tags) runs after a successful write (not on cancel).
function M.edit_tags(path, on_done)
  path = resolve_path(path)
  if not path then
    vim.notify("xattr: no readable file for current buffer", vim.log.levels.WARN)
    return
  end
  local current = M.get_tags(path)
  local prefilled = table.concat(current, ", ")
  vim.ui.input({
    prompt = "Tags (comma-separated): ",
    default = prefilled,
  }, function(input)
    if input == nil then
      return -- cancelled
    end
    local tags = {}
    for t in vim.gsplit(input, ",") do
      t = vim.trim(t)
      if t ~= "" then
        tags[#tags + 1] = t
      end
    end
    if M.set_tags(path, tags) then
      vim.notify(
        string.format("xattr: set %d tag(s) on %s", #tags, vim.fn.fnamemodify(path, ":t")),
        vim.log.levels.INFO
      )
      if on_done then
        on_done(tags)
      end
    else
      vim.notify("xattr: failed to write tags", vim.log.levels.ERROR)
    end
  end)
end

-- Edit the comment for a path. Single-line input; for multi-line, user can
-- embed \n literally (or extend later with a buffer editor).
-- Optional on_done(comment) runs after a successful write.
function M.edit_comment(path, on_done)
  path = resolve_path(path)
  if not path then
    vim.notify("xattr: no readable file for current buffer", vim.log.levels.WARN)
    return
  end
  local current = M.get_comment(path)
  vim.ui.input({
    prompt = "Comment: ",
    default = current,
  }, function(input)
    if input == nil then
      return
    end
    if M.set_comment(path, input) then
      vim.notify("xattr: comment updated for " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
      if on_done then
        on_done(input)
      end
    else
      vim.notify("xattr: failed to write comment", vim.log.levels.ERROR)
    end
  end)
end

-- Edit the star rating for a path (0-5, 0 removes).
-- Optional on_done(n) runs after a successful write.
function M.edit_rating(path, on_done)
  path = resolve_path(path)
  if not path then
    vim.notify("xattr: no readable file for current buffer", vim.log.levels.WARN)
    return
  end
  local current = M.get_rating(path)
  vim.ui.input({
    prompt = "Rating (0-5, 0 to remove): ",
    default = tostring(current),
  }, function(input)
    if input == nil then
      return
    end
    local n = tonumber(vim.trim(input))
    if not n then
      vim.notify("xattr: invalid rating", vim.log.levels.WARN)
      return
    end
    if M.set_rating(path, n) then
      vim.notify(
        string.format("xattr: rating set to %s for %s", M.stars(n), vim.fn.fnamemodify(path, ":t")),
        vim.log.levels.INFO
      )
      if on_done then
        on_done(n)
      end
    else
      vim.notify("xattr: failed to write rating", vim.log.levels.ERROR)
    end
  end)
end

-- --------------------------------------------------------------------------- --
-- Telescope pickers                                                            --
-- --------------------------------------------------------------------------- --

-- Flatten nested "a/b/c" tags into indented rows. Parents aggregate unique
-- descendant paths (plus any files tagged with the parent itself).
-- @param tags table  { [tag] = { path, ... } } from M.collect
-- @return table[]    rows: tag, label, depth, count, paths, untagged=false
local function build_nested_tag_rows(tags)
  local function new_node(name, full)
    return { name = name, full = full, children = {}, own_paths = {} }
  end

  local roots = {}
  for tag, paths in pairs(tags) do
    local parts = vim.split(tag, "/", { plain = true, trimempty = true })
    if #parts > 0 then
      local map = roots
      local full_parts = {}
      local node
      for i, seg in ipairs(parts) do
        full_parts[#full_parts + 1] = seg
        local full = table.concat(full_parts, "/")
        if not map[seg] then
          map[seg] = new_node(seg, full)
        end
        node = map[seg]
        map = node.children
        if i == #parts then
          for _, p in ipairs(paths) do
            node.own_paths[#node.own_paths + 1] = p
          end
        end
      end
    end
  end

  local function collect_unique(node)
    local seen, list = {}, {}
    local function add(p)
      if p and p ~= "" and not seen[p] then
        seen[p] = true
        list[#list + 1] = p
      end
    end
    for _, p in ipairs(node.own_paths) do
      add(p)
    end
    for _, child in pairs(node.children) do
      for _, p in ipairs(collect_unique(child)) do
        add(p)
      end
    end
    node.paths = list
    node.count = #list
    return list
  end

  for _, node in pairs(roots) do
    collect_unique(node)
  end

  local function sorted_children(node)
    local kids = {}
    for _, c in pairs(node.children) do
      kids[#kids + 1] = c
    end
    table.sort(kids, function(a, b)
      if a.count ~= b.count then
        return a.count > b.count
      end
      return a.name < b.name
    end)
    return kids
  end

  local rows = {}
  local function flatten(node, depth)
    rows[#rows + 1] = {
      tag = node.full,
      label = node.name,
      depth = depth,
      count = node.count,
      paths = node.paths,
      untagged = false,
    }
    for _, child in ipairs(sorted_children(node)) do
      flatten(child, depth + 1)
    end
  end

  local root_list = {}
  for _, node in pairs(roots) do
    root_list[#root_list + 1] = node
  end
  table.sort(root_list, function(a, b)
    if a.count ~= b.count then
      return a.count > b.count
    end
    return a.name < b.name
  end)
  for _, node in ipairs(root_list) do
    flatten(node, 0)
  end
  return rows
end

-- Picker: nested tags with counts; "(untagged)" pinned first.
-- Entry point for <leader>fx / :XattrFind.
-- <CR> closes this picker and opens pick_files for that tag or untagged set.
function M.pick_tags(opts)
  opts = opts or {}
  local root = opts.root or vim.fn.getcwd()
  local ok_tel = pcall(require, "telescope")
  if not ok_tel then
    vim.notify("xattr: telescope.nvim not installed", vim.log.levels.ERROR)
    return
  end
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  vim.notify("xattr: scanning " .. root .. " ...", vim.log.levels.INFO)
  local data = M.collect(root)
  local untagged_paths = M.list_untagged(root, data)

  local tag_list = build_nested_tag_rows(data.tags)
  table.insert(tag_list, 1, {
    tag = "(untagged)",
    label = "(untagged)",
    depth = 0,
    count = #untagged_paths,
    paths = untagged_paths,
    untagged = true,
  })

  if #tag_list == 1 and #untagged_paths == 0 then
    vim.notify("xattr: no files found under " .. root, vim.log.levels.WARN)
    return
  end

  pickers.new({}, {
    prompt_title = "xattr Tags (" .. root .. ")",
    finder = finders.new_table({
      results = tag_list,
      entry_maker = function(e)
        local left = string.rep("  ", e.depth or 0) .. (e.label or e.tag)
        return {
          value = e,
          display = string.format("%-32s %3d files", left, e.count),
          ordinal = (e.tag or "") .. " " .. tostring(e.count),
          tag = e.tag,
          paths = e.paths,
          untagged = e.untagged,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local sel = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not sel or not sel.value then
          return
        end
        local entry = sel.value
        local title = entry.untagged and "untagged" or ("tag: " .. entry.tag)
        M.pick_files({ paths = entry.paths, title = title })
      end)
      return true
    end,
  }):find()
end

local function file_row(path, info)
  info = info or {
    tags = M.get_tags(path),
    comment = M.get_comment(path),
    rating = M.get_rating(path),
  }
  local rel = vim.fn.fnamemodify(path, ":~")
  local tag_str = #info.tags > 0 and table.concat(info.tags, ", ") or "(none)"
  local rating_str = info.rating > 0 and " " .. M.stars(info.rating) or ""
  local display = string.format("%-50s  [%s]%s", rel, tag_str, rating_str)
  return { path = path, display = display, info = info }
end

local function file_entry_maker(r)
  return {
    value = r.path,
    display = r.display,
    ordinal = r.display,
    path = r.path,
    filename = r.path,
  }
end

-- Picker: list files (optionally pre-scoped). Shows each file's tags + preview.
--
-- opts:
--   root              scan root when opts.paths is nil (default: cwd)
--   paths             absolute paths to list (from pick_tags drill-down)
--   title             prompt base title; "untagged" enables drop_when_tagged
--   drop_when_tagged  if true, remove row after it gains tags (default: title
--                     == "untagged")
--
-- Bindings (also shown in prompt_title; full table in file header):
--   <CR> open | <C-t>/t/<C-e> tags | <A-c>/c comment | <A-r>/r rating
-- Edits keep the picker open and refresh via telescope :refresh.
function M.pick_files(opts)
  opts = opts or {}
  local root = opts.root or vim.fn.getcwd()
  local ok = pcall(require, "telescope")
  if not ok then
    vim.notify("xattr: telescope.nvim not installed", vim.log.levels.ERROR)
    return
  end
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  local drop_when_tagged = opts.drop_when_tagged
  if drop_when_tagged == nil then
    drop_when_tagged = opts.title == "untagged"
  end

  local data
  local file_paths
  if opts.paths then
    file_paths = opts.paths
  else
    data = M.collect(root)
    file_paths = {}
    for path, info in pairs(data.files) do
      if info.tags and #info.tags > 0 then
        file_paths[#file_paths + 1] = path
      end
    end
  end
  table.sort(file_paths)

  if #file_paths == 0 then
    vim.notify(
      opts.title and ("xattr: no files for " .. opts.title) or "xattr: no files found",
      vim.log.levels.WARN
    )
    return
  end

  local results = {}
  for _, p in ipairs(file_paths) do
    local info = nil
    if data then
      info = data.files[p] or data.files[abs_path(p)]
    end
    results[#results + 1] = file_row(p, info)
  end

  local base_title = opts.title or ("xattr Files (" .. root .. ")")
  local prompt_title = base_title .. "  <C-t> tag  <A-c> comment  <A-r> rating"

  local function make_finder(rows)
    return finders.new_table({
      results = rows,
      entry_maker = file_entry_maker,
    })
  end

  local function refresh_picker(prompt_bufnr, rows)
    local picker = action_state.get_current_picker(prompt_bufnr)
    if not picker then
      return
    end
    results = rows
    picker:refresh(make_finder(rows), { reset_prompt = false })
  end

  local function selected_path()
    local sel = action_state.get_selected_entry()
    if not sel or not sel.path then
      return nil
    end
    return sel.path
  end

  local function after_meta_edit(prompt_bufnr, path)
    local tags = M.get_tags(path)
    local info = {
      tags = tags,
      comment = M.get_comment(path),
      rating = M.get_rating(path),
    }

    local new_rows = {}
    for _, row in ipairs(results) do
      if row.path ~= path then
        new_rows[#new_rows + 1] = row
      elseif not (drop_when_tagged and #tags > 0) then
        new_rows[#new_rows + 1] = file_row(path, info)
      end
    end

    if #new_rows == 0 then
      actions.close(prompt_bufnr)
      vim.notify("xattr: no files left in " .. base_title, vim.log.levels.INFO)
      return
    end
    refresh_picker(prompt_bufnr, new_rows)
  end

  local function map_both(map, lhs, fn)
    map("i", lhs, fn)
    map("n", lhs, fn)
  end

  pickers.new({}, {
    prompt_title = prompt_title,
    finder = make_finder(results),
    sorter = conf.generic_sorter({}),
    previewer = conf.file_previewer({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local path = selected_path()
        actions.close(prompt_bufnr)
        if not path then
          return
        end
        vim.schedule(function()
          vim.cmd("edit " .. vim.fn.fnameescape(path))
        end)
      end)

      local function edit_tags_inplace()
        local path = selected_path()
        if not path then
          return
        end
        M.edit_tags(path, function()
          after_meta_edit(prompt_bufnr, path)
        end)
      end

      local function edit_comment_inplace()
        local path = selected_path()
        if not path then
          return
        end
        M.edit_comment(path, function()
          after_meta_edit(prompt_bufnr, path)
        end)
      end

      local function edit_rating_inplace()
        local path = selected_path()
        if not path then
          return
        end
        M.edit_rating(path, function()
          after_meta_edit(prompt_bufnr, path)
        end)
      end

      map_both(map, "<C-t>", edit_tags_inplace)
      map_both(map, "<C-e>", edit_tags_inplace)
      map("n", "t", edit_tags_inplace)

      map_both(map, "<A-c>", edit_comment_inplace)
      map("n", "c", edit_comment_inplace)

      map_both(map, "<A-r>", edit_rating_inplace)
      map("n", "r", edit_rating_inplace)

      return true
    end,
  }):find()
end

return M
