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

-- Прокрутка длинных строк (для markdown/text включается локально в autocmds)
opt.wrap = false
opt.linebreak = true
opt.breakindent = true

-- Отступ от курсора до края экрана
opt.scrolloff = 8
opt.sidescrolloff = 8

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

-- Мышь: клик по вкладкам, выделение, ресайз окон
opt.mouse = "a"

-- Новые окна открываются справа и снизу
opt.splitright = true
opt.splitbelow = true

-- Постоянная история отмен между сессиями
opt.undofile = true

-- Отзывчивость CursorHold (подсветка ссылок, checktime, blame)
opt.updatetime = 250

-- Пауза перед показом which-key
opt.timeoutlen = 400

-- Спрашивать про несохранённые изменения вместо ошибки
opt.confirm = true

-- Перечитывать файлы, изменённые снаружи (агентом) — работает в паре
-- с checktime-автокомандой в lua/autocmds.lua
opt.autoread = true

-- Единая рамка для всех плавающих окон (Neovim 0.11+)
vim.o.winborder = "rounded"

-- Качество диффов.
-- linematch выравнивает изменённые строки внутри ханка и включает посимвольную
-- подсветку — на правках агента разница в читаемости огромная.
-- Влияет и на :Gitsigns diffthis, и на diffview.
-- Neovim 0.12 уже даёт inline:char, indent-heuristic и linematch:40 —
-- поднимаем порог linematch и ставим histogram, не плодя дублей в списке
opt.diffopt:remove({ "linematch:40" })
opt.diffopt:append({ "linematch:60", "algorithm:histogram" })
opt.fillchars:append({ diff = "╱" })

-- Динамическое обновление ошибок
vim.diagnostic.config({
  update_in_insert = true
})
