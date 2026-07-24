local M = {}

local VIDEO_EXT = {
  mp4 = true,
  mkv = true,
  webm = true,
  mov = true,
  avi = true,
  m4v = true,
  wmv = true,
  flv = true,
  mpeg = true,
  mpg = true,
  ts = true,
  m3u8 = true,
  gif = true,
}

local URL_RE = "https?://[%w%-%._~:/%?#%[%]@!$&'()*+,;=%%]+"
local MD_LINK_RE = "%[.-%]%((https?://[^%s%)]+)%)"
local MD_PATH_RE = "!?%[.-%]%(([^%s%)]+)%)"

local function have(bin)
  return vim.fn.executable(bin) == 1
end

local function in_kitty()
  return vim.env.KITTY_WINDOW_ID ~= nil
    or vim.env.TERM == "xterm-kitty"
    or (vim.env.TERM_PROGRAM or ""):lower() == "kitty"
end

local function is_video_path(path)
  if not path or path == "" then
    return false
  end
  local ext = path:match("%.([%w]+)$")
  return ext and VIDEO_EXT[ext:lower()] or false
end

local function is_media_target(s)
  if not s or s == "" then
    return false
  end
  if s:match("^https?://") then
    return true
  end
  return is_video_path(s)
end

local function expand_path(p)
  if not p or p == "" or p:match("^https?://") then
    return p
  end
  if p:sub(1, 1) == "~" then
    p = vim.fn.expand(p)
  elseif p:sub(1, 1) ~= "/" then
    local dir = vim.fn.expand("%:p:h")
    if dir ~= "" and dir ~= "." then
      p = dir .. "/" .. p
    else
      p = vim.fn.fnamemodify(p, ":p")
    end
  end
  return p
end

function M.resolve_target(arg)
  if arg and vim.trim(arg) ~= "" then
    return expand_path(vim.trim(arg))
  end

  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local ok, selection = pcall(function()
      return table.concat(vim.fn.getregion(vim.fn.getpos "v", vim.fn.getpos ".", { type = mode }), "")
    end)
    if ok and selection and selection ~= "" then
      local t = vim.trim(selection)
      local url = t:match(URL_RE)
      if url then
        return url
      end
      if is_media_target(t) then
        return expand_path(t)
      end
    end
  end

  local line = vim.api.nvim_get_current_line()
  local md_url = line:match(MD_LINK_RE)
  if md_url then
    return md_url
  end
  local md_path = line:match(MD_PATH_RE)
  if md_path and is_media_target(md_path) then
    return expand_path(md_path)
  end

  local url_on_line = line:match(URL_RE)
  if url_on_line then
    return url_on_line
  end

  local cfile = vim.fn.expand("<cfile>")
  if cfile ~= "" and is_media_target(cfile) then
    return expand_path(cfile)
  end

  local buf = vim.fn.expand("%:p")
  if is_video_path(buf) and vim.fn.filereadable(buf) == 1 then
    return buf
  end

  return nil
end

local function mpv_argv(target)
  return {
    "mpv",
    "--profile=sw-fast",
    "--vo=kitty",
    "--vo-kitty-use-shm=yes",
    "--keep-open=yes",
    "--force-window=immediate",
    target,
  }
end

local function play_in_nvim_terminal(target)
  local prev = vim.api.nvim_get_current_win()
  vim.cmd "botright 18split"
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  vim.bo[buf].bufhidden = "wipe"
  vim.fn.termopen(mpv_argv(target), {
    on_exit = function(_, code)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
        if code ~= 0 then
          vim.notify("mpv exited with code " .. tostring(code), vim.log.levels.WARN)
        end
        if vim.api.nvim_win_is_valid(prev) then
          vim.api.nvim_set_current_win(prev)
        end
      end)
    end,
  })
  vim.cmd "startinsert"
end

local function play_in_kitty_window(target)
  local argv = { "kitty", "--title", "mpv", "--" }
  vim.list_extend(argv, mpv_argv(target))
  local ok = pcall(vim.fn.jobstart, argv, { detach = true })
  if not ok then
    play_in_nvim_terminal(target)
  end
end

function M.play(arg)
  if not have "mpv" then
    vim.notify("mpv not found in PATH", vim.log.levels.ERROR)
    return
  end

  local target = M.resolve_target(arg)
  if not target then
    vim.notify(
      "No video/URL found (cursor, selection, markdown link, or video buffer)",
      vim.log.levels.WARN
    )
    return
  end

  if not target:match("^https?://") and vim.fn.filereadable(target) ~= 1 then
    vim.notify("File not found: " .. target, vim.log.levels.ERROR)
    return
  end

  if target:match("^https?://") and not have "yt-dlp" then
    vim.notify("yt-dlp not found; YouTube/stream URLs may fail", vim.log.levels.WARN)
  end

  if not in_kitty() then
    vim.notify("Not in Kitty; mpv --vo=kitty may fail", vim.log.levels.WARN)
  end

  if have "kitty" and in_kitty() then
    play_in_kitty_window(target)
    vim.notify("mpv: " .. target, vim.log.levels.INFO)
    return
  end

  play_in_nvim_terminal(target)
end

return M
