-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local Util = require("lazyvim.util")

vim.keymap.set("i", "jk", "<esc>")

vim.keymap.set("n", "<leader>j", ":w<cr>")
vim.keymap.set("n", "<leader>k", ":q<cr>")
vim.keymap.set("n", "<leader>b", ":b#<cr>")

-- system clipboard (for neovide)
-- ref: https://github.com/neovide/neovide/issues/113
vim.keymap.set("v", "<C-c>", '"+y')
vim.keymap.set({ "i", "c" }, "<C-v>", "<c-r>+")

-- git version manager
vim.keymap.set("n", "<leader>v", function()
  Util.terminal({ "lazygit" }, { cwd = Util.root(), esc_esc = false, ctrl_hjkl = false })
end)

-- python
vim.keymap.set("n", "<localleader>r", ":!python3 %<cr>")
vim.keymap.set("v", "<localleader>r", ":!python3<cr>")
