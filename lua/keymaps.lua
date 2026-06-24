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
map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Перейти к определению" })

-- Найти использование элемента
map("n", "<leader>gr", vim.lsp.buf.references, { desc = "Найти использования" })

-- Открыть документацию
map("n", "<leader>K", vim.lsp.buf.hover, { desc = "Показать документацию" })

-- Переименовать элемент
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Переименовать" })

-- Действия с кодом
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Действия с кодом" })

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
map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Добавить ханк" })

-- Откатить изменение
map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Откатить ханк" })

-- Добавить файл в git
map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Добавить весь файл" })

-- Откатить файл
map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Откатить весь файл" })

-- Показать разницу
map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Показать изменения" })

-- Перейти к следующему изменению
map("n", "<leader>h<Down>", gitsigns.next_hunk, { desc = "Следующий ханк" })

-- Перейти к прошлому изменению
map("n", "<leader>h<Up>", gitsigns.prev_hunk, { desc = "Предыдущий ханк" })

-- Группы для which-key
local wk = require("which-key")
wk.add({
  { "<leader>f", group = "🔍 Поиск" },
  { "<leader>h", group = "Git" },
})
