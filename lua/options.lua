local opt = vim.opt

-- Прятать буферы вместо закрытия (нужно для нормальной работы с вкладками)
opt.hidden = true

-- Номера строк
opt.number = true

-- Табуляция
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Прокрутка длинных строк
opt.wrap = false

-- Отступ от курсора до края экрана
opt.scrolloff = 8

-- Настройки поиска
opt.ignorecase = true
opt.smartcase = true

-- 24-битные цвета
opt.termguicolors = true

-- Прятать командную строку когда неактивна
opt.cmdheight = 0

-- Колонка состояния строки
opt.signcolumn = "yes"

-- Системный буфер обмена
opt.clipboard = "unnamedplus"

-- Динамическое обновление ошибок
vim.diagnostic.config({
  update_in_insert = true
})
