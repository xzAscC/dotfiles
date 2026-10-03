-- Markdown 任务：状态 + 优先级
--
-- 状态写在复选框里（render-markdown 的 checkbox.custom 负责渲染，见 plugins/init.lua）：
--   [ ] 待办  [/] 进行中  [r] 审核中  [w] 等待  [>] 推迟  [x] 完成  [-] 取消
--
-- 优先级写在复选框行末尾：!1 / !2 / !3 只定级别，!12 = 一级里的第 2 位。
-- 数字越小越先做，渲染成徽章 P1·2；完成 / 取消 / 推迟的事项徽章变灰。
--
-- M.parse     render-markdown 自定义 handler（光标所在行自动显示原文）
-- M.set_status / M.set_priority / M.sort  供 mappings.lua 的快捷键调用（sort 作用于整个文件）
local M = {}

local ITEM = "^(%s*[-*+]%s+)%[(.)%](%s)"
local PRIO = "()%s+!([1-3][1-9]?)%s*$"
local DONE = { x = true, X = true, ["-"] = true, [">"] = true }

local item_query = vim.treesitter.query.parse("markdown", "(list_item) @item")

---@param ctx { buf: integer, root: TSNode }
---@return table[] render-markdown 的 mark 列表
function M.parse(ctx)
  local marks = {}
  for _, node in item_query:iter_captures(ctx.root, ctx.buf) do
    local row = node:start()
    local line = vim.api.nvim_buf_get_lines(ctx.buf, row, row + 1, false)[1] or ""
    local _, status = line:match(ITEM)
    local col, code = line:match(PRIO)
    if status and col then
      local hl = DONE[status] and "RenderMarkdownTaskPrioDone" or ("RenderMarkdownTaskPrio" .. code:sub(1, 1))
      local label = " P" .. code:sub(1, 1) .. (code:sub(2) ~= "" and "·" .. code:sub(2) or "") .. " "
      marks[#marks + 1] = {
        conceal = true,
        start_row = row,
        start_col = col - 1,
        opts = {
          end_col = #line,
          conceal = "",
          virt_text = { { " ", "Normal" }, { label, hl } },
          virt_text_pos = "inline",
        },
      }
    end
  end
  return marks
end

-- 普通模式作用于当前行，可视模式作用于选中的所有行
local function line_range()
  local a, b = vim.fn.line ".", vim.fn.line "v"
  if a > b then
    a, b = b, a
  end
  return a - 1, b
end

local function map_lines(fn)
  local s, e = line_range()
  local lines = vim.api.nvim_buf_get_lines(0, s, e, false)
  for i, line in ipairs(lines) do
    lines[i] = fn(line)
  end
  vim.api.nvim_buf_set_lines(0, s, e, false, lines)
end

---@param ch string 状态字符，如 " " "/" "x"
function M.set_status(ch)
  map_lines(function(line)
    if line:match(ITEM) then
      return (line:gsub("^(%s*[-*+]%s+)%[.%]", "%1[" .. ch .. "]", 1))
    end
    -- 普通列表项 / 普通文本也能直接变成任务
    local indent, bullet, rest = line:match "^(%s*)([-*+]%s+)(.*)$"
    if bullet then
      return indent .. bullet .. "[" .. ch .. "] " .. rest
    end
    indent, rest = line:match "^(%s*)(.-)$"
    if rest == "" then
      return line
    end
    return indent .. "- [" .. ch .. "] " .. rest
  end)
end

---@param code? string 如 "1" "12"；nil 表示清除
function M.set_priority(code)
  map_lines(function(line)
    if not line:match(ITEM) then
      return line
    end
    line = line:gsub("%s+![1-3][1-9]?%s*$", "")
    return code and (line .. " !" .. code) or line
  end)
end

-- <leader>p1 之后再按一位 1-9 细分；按回车 / 空格只定级别；其他键取消
function M.prompt_priority(level)
  local ok, ch = pcall(vim.fn.getcharstr)
  if not ok then
    return
  end
  if ch:match "^[1-9]$" then
    M.set_priority(level .. ch)
  elseif ch == "\r" or ch == " " then
    M.set_priority(level)
  end
end

local function sort_key(line)
  local code = line:match "%s!([1-3][1-9]?)%s*$"
  if not (code and line:match(ITEM)) then
    return 100
  end
  return tonumber(code:sub(1, 1)) * 10 + (tonumber(code:sub(2)) or 0)
end

local function indent_of(line)
  return #line:match "^%s*"
end

local function is_bullet(line)
  return line:match "^%s*[-*+]%s" ~= nil
end

-- 对一组连续的列表行排序：同级事项按优先级稳定排序，子项（缩进更深的行）跟随父项并递归排序
local function sort_lines(lines)
  local base = math.huge
  for _, line in ipairs(lines) do
    if is_bullet(line) then
      base = math.min(base, indent_of(line))
    end
  end

  local head, items = {}, {}
  for _, line in ipairs(lines) do
    if is_bullet(line) and indent_of(line) <= base then
      items[#items + 1] = { first = line, children = {}, key = sort_key(line), idx = #items + 1 }
    elseif #items == 0 then
      head[#head + 1] = line
    else
      table.insert(items[#items].children, line)
    end
  end

  table.sort(items, function(a, b)
    if a.key ~= b.key then
      return a.key < b.key
    end
    return a.idx < b.idx
  end)

  local out = vim.list_slice(head)
  for _, item in ipairs(items) do
    out[#out + 1] = item.first
    vim.list_extend(out, #item.children > 0 and sort_lines(item.children) or {})
  end
  return out
end

-- 把整个文件里的每个列表各自按优先级排序。
-- 一个列表 = 连续的列表行及其缩进子行；空行、顶格普通文字、代码块都会切断列表，
-- 所以事项不会跨分类移动
function M.sort()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local blocks, cur, fence = {}, nil, false
  for i, line in ipairs(lines) do
    if line:match "^%s*```" or line:match "^%s*~~~" then
      fence = not fence
      cur = nil
    elseif fence or line:match "^%s*$" then
      cur = nil
    elseif is_bullet(line) and (not cur or indent_of(line) >= cur.indent) then
      if not cur then
        cur = { s = i, e = i, indent = indent_of(line) }
        blocks[#blocks + 1] = cur
      end
      cur.e = i
    elseif cur and indent_of(line) > cur.indent then
      cur.e = i
    else
      cur = nil
    end
  end

  local count = 0
  for b = #blocks, 1, -1 do
    local blk = blocks[b]
    local old = vim.list_slice(lines, blk.s, blk.e)
    local new = sort_lines(old)
    if not vim.deep_equal(old, new) then
      vim.api.nvim_buf_set_lines(0, blk.s - 1, blk.e, false, new)
      count = count + 1
    end
  end
  vim.notify(count > 0 and ("已排序 " .. count .. " 个列表") or "所有列表都已按优先级排好")
end

return M
