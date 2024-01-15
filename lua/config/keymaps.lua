-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local Util = require("lazyvim.util")

vim.keymap.set("i", "jk", "<esc>")

vim.keymap.set("n", "<leader>j", ":w<esc>")
vim.keymap.set("n", "<leader>k", ":q<esc>")

-- git version manager
vim.keymap.set("n", "<leader>v", function()
  Util.terminal({ "lazygit" }, { cwd = Util.root(), esc_esc = false, ctrl_hjkl = false })
end)

-- python
vim.keymap.set("n", "<localleader>r", ":!python3 %<cr>")
vim.keymap.set("v", "<localleader>r", ":!python3<cr>")
