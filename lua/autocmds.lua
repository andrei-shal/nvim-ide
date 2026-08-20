local augroup = function(name)
  return vim.api.nvim_create_augroup("nvim_ide_" .. name, { clear = true })
end

-- Подсветка treesitter для всех поддерживаемых файлов
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("treesitter"),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end
})

-- Автооткрытие проводника при старте
vim.api.nvim_create_autocmd("UIEnter", {
  group = augroup("neotree_start"),
  once = true,
  callback = function()
    vim.cmd("Neotree show")
  end
})

--------------------------------------------------------------------------
-- Перечитывание файлов, изменённых снаружи
--
-- Ключевое для работы с ИИ-агентами: агент правит файлы на диске, пока они
-- открыты в буферах. Без этого буфер показывает устаревший текст, а дифф
-- относительно git считается по старому содержимому и попросту врёт.
--------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype == "" and vim.fn.getcmdwintype() == "" then
      pcall(vim.cmd.checktime)
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = augroup("file_changed"),
  callback = function()
    vim.notify("Файл изменён на диске, буфер перезагружен", vim.log.levels.WARN)
  end,
})

--------------------------------------------------------------------------
-- Локальные настройки по типам файлов
--------------------------------------------------------------------------

-- Перенос строк для текстовых форматов
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_text"),
  pattern = { "markdown", "markdown_inline", "text", "gitcommit", "typst", "tex" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = false
  end,
})

-- Закрытие служебных окон по q
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help", "qf", "checkhealth", "lspinfo", "man", "notify",
    "startuptime", "gitsigns-blame", "grug-far-help",
  },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true })
  end,
})

--------------------------------------------------------------------------
-- Мелочи
--------------------------------------------------------------------------

-- Подсветка скопированного фрагмента
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank_highlight"),
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- Восстановление позиции курсора при открытии файла
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("restore_cursor"),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
