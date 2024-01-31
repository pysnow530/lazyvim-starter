-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local Util = require("lazyvim.util")
local ticket = require("my.ticket")
local sre = require("my.sre")
local editor = require("my.editor")

vim.keymap.set("i", "jk", "<esc>")

vim.keymap.set("n", "<leader>j", ":w<cr>")
vim.keymap.set("n", "<leader>k", ":q<cr>")
vim.keymap.set("n", "<leader>b", ":b#<cr>")

-- 剪切板操作 (for neovide)
-- 参考: https://github.com/neovide/neovide/issues/113
vim.keymap.set("v", "<C-c>", '"+y')
vim.keymap.set({ "i", "c" }, "<C-v>", "<c-r>+")

-- 版本管理
vim.keymap.set("n", "<leader>v", function()
  Util.terminal({ "lazygit" }, { cwd = Util.root(), esc_esc = false, ctrl_hjkl = false })
end)

-- 运行当前文件
vim.keymap.set("n", "<localleader>r", function()
  if vim.bo.filetype == "python" then
    vim.api.nvim_command("!python3 %")
  elseif vim.bo.filetype == "lua" then
    vim.api.nvim_command("luafile %")
  end
end)

-- 尝试文本转换
vim.keymap.set("v", "<leader>|", function()
  local lines = editor.get_selected_lines()

  -- 尝试解析为数据库连接
  local res = sre.try_parse_mysql(lines)
  if res then
    editor.append_lines(res)
    return
  end

  -- 尝试解析为工单复盘结果写入sql
  local sql = ticket.try_parse_ticket_review(lines)
  if sql then
    editor.append_lines(sql)
    return
  end

  -- 尝试解析为工具建设规则
  local rules = ticket.try_parse_ticket_rules(lines)
  if rules then
    editor.append_lines(rules)
    return
  end

  editor.append_lines("Not recognized!")
end)
