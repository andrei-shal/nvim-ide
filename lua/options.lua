local opt = vim.opt

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

-- Колонка состояния строки
opt.signcolumn = "yes"

-- Системный буфер обмена
opt.clipboard = "unnamedplus"

-- Русская раскладка (ЙЦУКЕН → QWERTY)
opt.langmap = "йq,цw,уe,кr,еt,нy,гu,шi,щo,зp,х[,ъ],фa,ыs,вd,аf,пg,рh,оj,лk,дl,э;,ж',яz,чx,сc,мv,иb,тn,ьm,б<,,ю.,ё`ЙQ,ЦW,УE,КR,ЕT,НY,ГU,ШI,ЩO,ЗP,Х{,Ъ},ФA,ЫS,ВD,АF,ПG,РH,ОJ,ЛK,ДL,Э:,Ж\",ЯZ,ЧX,СC,МV,ИB,ТN,ЬM,Б<,,Ю>,Ё~"
