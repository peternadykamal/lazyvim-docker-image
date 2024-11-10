-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- File Save and Quit
vim.keymap.set("n", "<leader>w", ":w<CR>", { silent = true })
vim.keymap.set("n", "<leader>q", ":q!<CR>", { silent = true })

vim.keymap.set("n", "K", "O<Esc>", { silent = true }) -- Insert line before
vim.keymap.set("n", "J", "o<Esc>", { silent = true }) -- Insert line after

vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", { silent = true }) -- Move selected lines down
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", { silent = true }) -- Move selected lines up
vim.keymap.set("v", "<C-h>", "<gv", { silent = true }) -- Outdent selected lines
vim.keymap.set("v", "<C-l>", ">gv", { silent = true }) -- Indent selected lines
vim.keymap.set("v", "K", "5k", { silent = true }) -- Move 5 lines up
vim.keymap.set("v", "J", "5j", { silent = true }) -- Move 5 lines down

-- Move to the end of the line in visual and operator-pending mode
vim.keymap.set({ "v", "o" }, "L", "g_", { silent = true })
-- Move to the beginning of the line in visual and operator-pending mode
vim.keymap.set({ "v", "o" }, "H", "^", { silent = true })
-- Paste over the selection, reselect the pasted text, and yank it
vim.keymap.set("v", "p", "pgvy", { noremap = true, silent = true })
