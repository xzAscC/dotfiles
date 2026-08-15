local vim = rawget(_G, "vim")
local M = {}

local excluded_decks = {
  ["readme.md"] = true,
  ["todo.md"] = true,
  ["inbox.md"] = true,
}

local function notify(message, level)
  vim.notify(message, level, { title = "FlashcardAdd" })
end

local function close_with_error(file, message)
  local closed, close_err = file:close()
  if not closed then
    message = message .. "; also failed to close file: " .. tostring(close_err)
  end

  return nil, message
end

local function load_telescope()
  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then
    local lazy_ok, lazy = pcall(require, "lazy")
    if not lazy_ok then
      return nil, "Telescope is unavailable and lazy.nvim could not be loaded; run :Lazy sync"
    end

    local loaded, load_err = pcall(function()
      lazy.load({ plugins = { "telescope.nvim" } })
    end)
    if not loaded then
      return nil, "Could not load telescope.nvim: " .. tostring(load_err) .. "; run :Lazy sync"
    end

    ok, pickers = pcall(require, "telescope.pickers")
    if not ok then
      return nil, "telescope.nvim did not become available after lazy loading; run :Lazy sync"
    end
  end

  local modules = {}
  local required = {
    actions = "telescope.actions",
    action_state = "telescope.actions.state",
    conf = "telescope.config",
    finders = "telescope.finders",
  }

  for name, module_name in pairs(required) do
    local module_ok, module = pcall(require, module_name)
    if not module_ok then
      return nil, "Telescope module " .. module_name .. " is unavailable; run :Lazy sync"
    end
    modules[name] = module
  end

  modules.pickers = pickers
  modules.conf = modules.conf.values
  return modules
end

function M.parse_input(input)
  local separator_start = input:find("::", 1, true)
  if not separator_start then
    return nil, nil, "Use front :: back"
  end

  local front = vim.trim(input:sub(1, separator_start - 1))
  local back = vim.trim(input:sub(separator_start + 2))
  if front == "" then
    return nil, nil, "Front cannot be empty"
  end
  if back == "" then
    return nil, nil, "Back cannot be empty"
  end

  if front == "?" or front == "---" then
    return nil, nil, "Front cannot be a standalone structural delimiter"
  end
  if back == "?" or back == "---" then
    return nil, nil, "Back cannot be a standalone structural delimiter"
  end

  return front, back
end

function M.list_decks(decks_dir)
  local stat, stat_err = vim.uv.fs_stat(decks_dir)
  if not stat then
    return nil, "Cannot read deck directory " .. decks_dir .. ": " .. tostring(stat_err)
  end
  if stat.type ~= "directory" then
    return nil, "Configured deck path is not a directory: " .. decks_dir
  end

  local decks = {}
  local scanned, scan_err = pcall(function()
    for name, entry_type in vim.fs.dir(decks_dir) do
      if entry_type == "file" and name:match("%.md$") and not excluded_decks[name:lower()] then
        decks[#decks + 1] = vim.fs.joinpath(decks_dir, name)
      end
    end
  end)
  if not scanned then
    return nil, "Could not scan deck directory " .. decks_dir .. ": " .. tostring(scan_err)
  end

  table.sort(decks, function(left, right)
    return left:lower() < right:lower()
  end)
  return decks
end

function M.build_targets(decks_dir, deck_paths)
  local targets = {}
  for _, path in ipairs(deck_paths) do
    targets[#targets + 1] = {
      kind = "deck",
      path = path,
      display = vim.fs.basename(path),
    }
  end

  table.sort(targets, function(left, right)
    return left.display:lower() < right.display:lower()
  end)

  local normalized_dir = vim.fs.normalize(decks_dir)
  targets[#targets + 1] = {
    kind = "inbox",
    path = vim.fs.joinpath(vim.fs.dirname(normalized_dir), "inbox.md"),
    display = "inbox.md",
  }
  return targets
end

function M.normalize_inbox_input(input)
  local text = vim.trim(input:gsub("[\r\n]+", " "))
  if text == "" then
    return nil, "Inbox entry cannot be empty"
  end

  return text
end

local function ensure_parent_directory(path)
  local parent = vim.fs.dirname(path)
  local stat, stat_err = vim.uv.fs_stat(parent)
  if stat then
    if stat.type ~= "directory" then
      return nil, "Inbox parent is not a directory: " .. parent
    end
    return true
  end

  vim.fn.mkdir(parent, "p")
  if vim.fn.isdirectory(parent) ~= 1 then
    return nil, "Could not create inbox directory " .. parent .. ": " .. tostring(stat_err)
  end
  return true
end

function M.append_card(deck_path, front, back)
  local file, open_err = io.open(deck_path, "a+b")
  if not file then
    return nil, "Could not open deck " .. deck_path .. ": " .. tostring(open_err)
  end

  local size, seek_err = file:seek("end")
  if not size then
    return close_with_error(file, "Could not inspect deck " .. deck_path .. ": " .. tostring(seek_err))
  end

  local prefix = ""
  if size > 0 then
    local position, rewind_err = file:seek("set", size - 1)
    if not position then
      return close_with_error(file, "Could not inspect deck " .. deck_path .. ": " .. tostring(rewind_err))
    end

    local last_byte, read_err = file:read(1)
    if not last_byte then
      return close_with_error(file, "Could not read deck " .. deck_path .. ": " .. tostring(read_err))
    end

    prefix = last_byte == "\n" and "\n---\n\n" or "\n\n---\n\n"
    local end_position, end_err = file:seek("end")
    if not end_position then
      return close_with_error(file, "Could not append to deck " .. deck_path .. ": " .. tostring(end_err))
    end
  end

  local payload = prefix .. front .. "\n?\n" .. back .. "\n"
  local written, write_err = file:write(payload)
  if not written then
    return close_with_error(file, "Could not write deck " .. deck_path .. ": " .. tostring(write_err))
  end

  local closed, close_err = file:close()
  if not closed then
    return nil, "Could not close deck " .. deck_path .. " after writing: " .. tostring(close_err)
  end

  return true
end

function M.append_inbox(inbox_path, input, timestamp)
  local text, input_err = M.normalize_inbox_input(input)
  if not text then
    return nil, input_err
  end

  local parent_ok, parent_err = ensure_parent_directory(inbox_path)
  if not parent_ok then
    return nil, parent_err
  end

  local file, open_err = io.open(inbox_path, "a+b")
  if not file then
    return nil, "Could not open inbox " .. inbox_path .. ": " .. tostring(open_err)
  end

  local size, seek_err = file:seek("end")
  if not size then
    return close_with_error(file, "Could not inspect inbox " .. inbox_path .. ": " .. tostring(seek_err))
  end

  local prefix = "# Reading Inbox\n\n"
  if size > 0 then
    local suffix_size = math.min(size, 2)
    local position, rewind_err = file:seek("set", size - suffix_size)
    if not position then
      return close_with_error(file, "Could not inspect inbox " .. inbox_path .. ": " .. tostring(rewind_err))
    end

    local suffix, read_err = file:read(suffix_size)
    if not suffix then
      return close_with_error(file, "Could not read inbox " .. inbox_path .. ": " .. tostring(read_err))
    end

    if suffix:sub(-2) == "\n\n" then
      prefix = ""
    elseif suffix:sub(-1) == "\n" then
      prefix = "\n"
    else
      prefix = "\n\n"
    end

    local end_position, end_err = file:seek("end")
    if not end_position then
      return close_with_error(file, "Could not append to inbox " .. inbox_path .. ": " .. tostring(end_err))
    end
  end

  local entry_time = timestamp or os.date("%Y-%m-%d %H:%M")
  local payload = prefix .. "- **" .. entry_time .. "** · `word` · " .. text .. "\n\n"
  local written, write_err = file:write(payload)
  if not written then
    return close_with_error(file, "Could not write inbox " .. inbox_path .. ": " .. tostring(write_err))
  end

  local closed, close_err = file:close()
  if not closed then
    return nil, "Could not close inbox " .. inbox_path .. " after writing: " .. tostring(close_err)
  end

  return true
end

function M.open_card_prompt(deck_path)
  local telescope, telescope_err = load_telescope()
  if not telescope then
    notify(telescope_err, vim.log.levels.ERROR)
    return
  end

  telescope.pickers
    .new({}, {
      prompt_title = "Add card | front :: back",
      finder = telescope.finders.new_table({ results = {} }),
      sorter = telescope.conf.generic_sorter({}),
      previewer = false,
      sorting_strategy = "ascending",
      layout_strategy = "center",
      layout_config = {
        width = 0.7,
        height = 0.25,
        prompt_position = "top",
      },
      attach_mappings = function(prompt_bufnr, map)
        map("i", "<Esc>", function()
          telescope.actions.close(prompt_bufnr)
        end)
        map("n", "<Esc>", function()
          telescope.actions.close(prompt_bufnr)
        end)

        telescope.actions.select_default:replace(function()
          local input = telescope.action_state.get_current_line()
          local front, back, parse_err = M.parse_input(input)
          if not front then
            notify(parse_err, vim.log.levels.WARN)
            return
          end

          local appended, append_err = M.append_card(deck_path, front, back)
          if not appended then
            notify(append_err, vim.log.levels.ERROR)
            return
          end

          telescope.actions.close(prompt_bufnr)
          notify("Added card to " .. vim.fs.basename(deck_path), vim.log.levels.INFO)
          vim.schedule(function()
            M.open_card_prompt(deck_path)
          end)
        end)
        return true
      end,
    })
    :find()
end

function M.open_inbox_prompt(inbox_path)
  local telescope, telescope_err = load_telescope()
  if not telescope then
    notify(telescope_err, vim.log.levels.ERROR)
    return
  end

  telescope.pickers
    .new({}, {
      prompt_title = "Add inbox word or phrase",
      finder = telescope.finders.new_table({ results = {} }),
      sorter = telescope.conf.generic_sorter({}),
      previewer = false,
      sorting_strategy = "ascending",
      layout_strategy = "center",
      layout_config = {
        width = 0.7,
        height = 0.25,
        prompt_position = "top",
      },
      attach_mappings = function(prompt_bufnr, map)
        map("i", "<Esc>", function()
          telescope.actions.close(prompt_bufnr)
        end)
        map("n", "<Esc>", function()
          telescope.actions.close(prompt_bufnr)
        end)

        telescope.actions.select_default:replace(function()
          local input = telescope.action_state.get_current_line()
          local text, input_err = M.normalize_inbox_input(input)
          if not text then
            notify(input_err, vim.log.levels.WARN)
            return
          end

          local appended, append_err = M.append_inbox(inbox_path, text)
          if not appended then
            notify(append_err, vim.log.levels.ERROR)
            return
          end

          telescope.actions.close(prompt_bufnr)
          notify("Added word to " .. vim.fs.basename(inbox_path), vim.log.levels.INFO)
          vim.schedule(function()
            M.open_inbox_prompt(inbox_path)
          end)
        end)
        return true
      end,
    })
    :find()
end

function M.open_deck_picker()
  local decks, deck_err = M.list_decks(M.decks_dir)
  if not decks then
    notify(deck_err, vim.log.levels.ERROR)
    return
  end

  local targets = M.build_targets(M.decks_dir, decks)

  local telescope, telescope_err = load_telescope()
  if not telescope then
    notify(telescope_err, vim.log.levels.ERROR)
    return
  end

  telescope.pickers
    .new({}, {
      prompt_title = "Select flashcard target",
      finder = telescope.finders.new_table({
        results = targets,
        entry_maker = function(target)
          return {
            value = target,
            display = target.display,
            ordinal = target.display,
          }
        end,
      }),
      sorter = telescope.conf.generic_sorter({}),
      previewer = false,
      sorting_strategy = "ascending",
      layout_strategy = "center",
      layout_config = {
        width = 0.6,
        height = 0.45,
        prompt_position = "top",
      },
      attach_mappings = function(prompt_bufnr, _)
        telescope.actions.select_default:replace(function()
          local selected = telescope.action_state.get_selected_entry()
          if not selected then
            notify("Select a target before adding entries", vim.log.levels.WARN)
            return
          end

          local target = selected.value
          telescope.actions.close(prompt_bufnr)
          vim.schedule(function()
            if target.kind == "inbox" then
              M.open_inbox_prompt(target.path)
            else
              M.open_card_prompt(target.path)
            end
          end)
        end)
        return true
      end,
    })
    :find()
end

function M.setup(opts)
  if type(opts) ~= "table" or type(opts.decks_dir) ~= "string" or opts.decks_dir == "" then
    notify("FlashcardAdd requires opts.decks_dir to be a non-empty path", vim.log.levels.ERROR)
    return
  end

  M.decks_dir = opts.decks_dir
  vim.api.nvim_create_user_command("FlashcardAdd", M.open_deck_picker, {
    desc = "Add flashcards with Telescope",
    force = true,
  })
end

return M
