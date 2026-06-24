-- Лидер клавиша
vim.g.mapleader = " "

local map = vim.keymap.set

local blink = require("blink.cmp")
local telescope_builtin = require("telescope.builtin")
local gitsigns = require("gitsigns")

-- Сохранить файл
map("n", "<leader>w", "<cmd>w<cr>")

-- Выйти
map("n", "<leader>q", "<cmd>q<cr>")

-- Языковой сервер LSP

-- Найти определение элемента
map("n", "<leader>gd", vim.lsp.buf.definition)

-- Найти использование элемента
map("n", "<leader>gr", vim.lsp.buf.references)

-- Открыть документацию
map("n", "<leader>K", vim.lsp.buf.hover)

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

map("i", "<Enter>", function()
  if blink.is_visible() then
    blink.accept()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Enter>", true, true, true), "n", false)
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

-- Поиск telescope

-- По названию файла
map("n", "<leader>ff", telescope_builtin.find_files)

-- В проекте
map("n", "<leader>fg", telescope_builtin.live_grep)

-- В открытых файлах
map("n", "<leader>fb", telescope_builtin.buffers)

-- Помощь
map("n", "<leader>fh", telescope_builtin.help_tags)

-- Git gitsigns

-- Добавить изменение в git
map("n", "<leader>hs", gitsigns.stage_hunk)

-- Откатить изменение
map("n", "<leader>hr", gitsigns.reset_hunk)

-- Добавить файл в git
map("n", "<leader>hS", gitsigns.stage_buffer)

-- Откатить файл
map("n", "<leader>hR", gitsigns.reset_buffer)

-- Показать разницу
map("n", "<leader>hp", gitsigns.preview_hunk)

-- Перейти к следующему изменению
map("n", "<leader>h<Down>", gitsigns.next_hunk)

-- Перейти к прошлому изменению
map("n", "<leader>h<Up>", gitsigns.prev_hunk)
