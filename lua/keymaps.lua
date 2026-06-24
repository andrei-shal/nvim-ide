-- Лидер клавиша
vim.g.mapleader = " "

local map = vim.keymap.set

local blink = require("blink.cmp")

-- Сохранить файл
map("n", "<leader>w", "<cmd>w<cr>")

-- Выйти
map("n", "<leader>q", "<cmd>q<cr>")

-- Языковой сервер LSP

-- Найти определение элемента
map("n", "gd", vim.lsp.buf.definition)

-- Найти использование элемента
map("n", "gr", vim.lsp.buf.references)

-- Открыть документацию
map("n", "K", vim.lsp.buf.hover)

-- Переименовать элемент
map("n", "<leader>rn", vim.lsp.buf.rename)

-- Действия с кодом
map("n", "<leader>ca", vim.lsp.buf.code_action)

-- Автодополнение blink

-- Выбрать
map("i", "<Tab>", function()
  if blink.is_visible() then
    blink.accept()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", false)
  end
end)

-- Следующий
map("i", "<Down>", function()
  if blink.is_visible() then
    blink.select_next()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down>", true, true, true), "n", false)
  end
end)

-- Предыдущий
map("i", "<Up>", function()
  if blink.is_visible() then
    blink.select_prev()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Up>", true, true, true), "n", false)
  end
end)
