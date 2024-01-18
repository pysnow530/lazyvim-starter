-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local Util = require("lazyvim.util")

vim.keymap.set("i", "jk", "<esc>")

vim.keymap.set("n", "<leader>j", ":w<cr>")
vim.keymap.set("n", "<leader>k", ":q<cr>")
vim.keymap.set("n", "<leader>b", ":b#<cr>")

-- 剪切板操作 (for neovide)
-- ref: https://github.com/neovide/neovide/issues/113
vim.keymap.set("v", "<C-c>", '"+y')
vim.keymap.set({ "i", "c" }, "<C-v>", "<c-r>+")

-- 版本管理
vim.keymap.set("n", "<leader>v", function()
  Util.terminal({ "lazygit" }, { cwd = Util.root(), esc_esc = false, ctrl_hjkl = false })
end)

-- python
vim.keymap.set("n", "<localleader>r", ":!python3 %<cr>")
vim.keymap.set("v", "<localleader>r", ":!python3<cr>")

-- 解析配置格式的字典（支持toml和python字典）
-- host = "host1"\nport = 8888 转换为 { host = "host1", port = "8888"}
local function parse_toml_table(lines)
  local tb = {}

  for _, line in ipairs(lines) do
    -- toml
    local k1, v1 = string.match(line, '%s*([%w_]+)%s*=%s*"(.*)"')
    local k2, v2 = string.match(line, "%s*([%w_]+)%s*=%s*'(.*)'")
    local k3, v3 = string.match(line, "%s*([%w_]+)%s*=%s*(.*)")
    -- python
    local k4, v4 = string.match(line, "%s*'([%w_]+)'%s*:%s*'(.*)',")
    local k5, v5 = string.match(line, "%s*'([%w_]+)'%s*:%s*(.*),")
    if k1 and v1 then
      tb[k1] = v1
    elseif k2 and v2 then
      tb[k2] = v2
    elseif k3 and v3 then
      tb[k3] = v3
    elseif k4 and v4 then
      tb[k4] = v4
    elseif k5 and v5 then
      tb[k5] = v5
    end
  end

  return tb
end

-- 尝试文本转换
vim.keymap.set("v", "<leader>|", function()
  -- 获取选择范围及文本
  -- 参考: https://github.com/neovim/neovim/pull/21115
  local _, ls, _ = unpack(vim.fn.getpos("v"))
  local _, le, _ = unpack(vim.fn.getpos("."))
  local l1 = math.min(ls, le)
  local l2 = math.max(ls, le)
  local lines = vim.api.nvim_buf_get_lines(0, l1 - 1, l2, true)

  -- 尝试解析为数据库连接
  local tb = parse_toml_table(lines)
  if tb.host and tb.port and tb.user and tb.passwd and (tb.db or tb.db_name) then
    table.insert(
      lines,
      "mysql -h"
        .. tb.host
        .. " -P"
        .. tb.port
        .. " -u"
        .. tb.user
        .. " -p'"
        .. tb.passwd
        .. "' "
        .. (tb.db and tb.db or tb.db_name)
        .. " -Nse 'select 1'"
    )
    vim.api.nvim_buf_set_lines(0, l1 - 1, l2, true, lines)
  end
end)
