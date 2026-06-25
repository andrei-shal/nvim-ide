-- Лидер клавиша
vim.g.mapleader = " "

local map = vim.keymap.set

local blink = require("blink.cmp")
local telescope_builtin = require("telescope.builtin")
local gitsigns = require("gitsigns")

-- Сохранить файл
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Сохранить файл" })

-- Выйти
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Закрыть окно" })

-- Языковой сервер LSP

-- Найти определение элемента
map("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Перейти к определению" })

-- Найти использование элемента
map("n", "<leader>lr", vim.lsp.buf.references, { desc = "Найти использования" })

-- Открыть документацию
map("n", "<leader>d", vim.lsp.buf.hover, { desc = "Показать документацию" })

-- Переименовать элемент
map("n", "<leader>ln", vim.lsp.buf.rename, { desc = "Переименовать элемент" })

-- Действия с кодом
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Действия с кодом" })

-- Автодополнение blink

-- Выбрать
map("i", "<Tab>", function()
  if blink.is_visible() then
    blink.accept()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", false)
  end
end, { desc = "Принять автодополнение" })

-- Выбрать Enter
map("i", "<Enter>", function()
  if blink.is_visible() then
    blink.accept()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Enter>", true, true, true), "n", false)
  end
end, { desc = "Принять автодополнение" })

-- Следующий
map("i", "<Down>", function()
  if blink.is_visible() then
    blink.select_next()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down>", true, true, true), "n", false)
  end
end, { desc = "Следующий вариант" })

-- Предыдущий
map("i", "<Up>", function()
  if blink.is_visible() then
    blink.select_prev()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Up>", true, true, true), "n", false)
  end
end, { desc = "Предыдущий вариант" })

-- Закрыть автодополнение
map("i", "<Esc>", function()
  if blink.is_visible() then
    blink.cancel()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true), "n", false)
  end
end, { desc = "Закрыть автодополнение" })

-- Поиск telescope

-- По названию файла
map("n", "<leader>ff", telescope_builtin.find_files, { desc = "Найти файл" })

-- В проекте
map("n", "<leader>fg", telescope_builtin.live_grep, { desc = "Поиск по тексту" })

-- В открытых файлах
map("n", "<leader>fb", telescope_builtin.buffers, { desc = "Открытые буферы" })

-- Помощь
map("n", "<leader>fh", telescope_builtin.help_tags, { desc = "Справка" })

-- Git gitsigns

-- Добавить изменение в git
map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Добавить изменение" })

-- Откатить изменение
map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Откатить изменение" })

-- Добавить файл в git
map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Добавить весь файл" })

-- Откатить файл
map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Откатить весь файл" })

-- Показать разницу
map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Показать изменения" })

-- Перейти к следующему изменению
map("n", "<leader>h<Down>", gitsigns.next_hunk, { desc = "Следующее изменение" })

-- Перейти к прошлому изменению
map("n", "<leader>h<Up>", gitsigns.prev_hunk, { desc = "Предыдущее изменение" })

-- Файловое дерево neo-tree

-- Открыть
map("n", "<leader>e", "<cmd>Neotree focus<cr>", { desc = "Проводник" })

-- Закрыть
map("n", "<leader>ec", "<cmd>Neotree close<cr>", { desc = "Закрыть" })

-- Вкладки bufferline

-- Открыть вкладку левее
map("n", "<leader><Left>", "<cmd>BufferLineCyclePrev<cr>")

-- Открыть вкладку правее
map("n", "<leader><Right>", "<cmd>BufferLineCycleNext<cr>")

-- Закрыть вкладку
map("n", "<leader>x", "<cmd>bdelete<cr>")

-- Закрыть все вкладки
map("n", "<leader>xa", function()
  vim.cmd("silent! %bd|e#|bd#")
end, { desc = "Закрыть все вкладки" })

-- Закрыть все вкладки кроме выбранной
map("n", "<leader>xo", "<cmd>BufferLineCloseOthers<cr>")
