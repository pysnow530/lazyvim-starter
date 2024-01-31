local editor = {}

-- 获取选择范围及文本
-- 参考: https://github.com/neovim/neovim/pull/21115
function editor.get_selected_lines()
  local _, ls, _ = unpack(vim.fn.getpos("v"))
  local _, le, _ = unpack(vim.fn.getpos("."))
  local l1 = math.min(ls, le)
  local l2 = math.max(ls, le)
  local lines = vim.api.nvim_buf_get_lines(0, l1 - 1, l2, true)
  return lines
end

function editor.append_lines(lines)
  if type(lines) == "string" then
    lines = { lines }
  end

  local _, ls, _ = unpack(vim.fn.getpos("v"))
  local _, le, _ = unpack(vim.fn.getpos("."))
  local l1 = math.min(ls, le)
  local l2 = math.max(ls, le)

  local selected_lines = vim.api.nvim_buf_get_lines(0, l1 - 1, l2, true)

  for _, v in ipairs(lines) do
    table.insert(selected_lines, v)
  end

  vim.api.nvim_buf_set_lines(0, l1 - 1, l2, true, selected_lines)
end

return editor
