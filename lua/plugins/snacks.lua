-- Стартовый экран и отступные линии.
-- Включены только нужные модули — snacks модульный, остальное не грузится.
return {
  "folke/snacks.nvim",
  priority = 900,
  lazy = false,
  opts = {
    -- Отступные линии + подсветка текущего блока.
    -- Читать сгенерированный агентом код заметно легче, когда видно структуру.
    indent = {
      enabled = true,
      indent = { char = "│" },
      scope = { char = "│", hl = "SnacksIndentScope" },
      animate = { enabled = false },
    },

    -- Большие файлы: отключить подсветку и LSP, чтобы не подвешивало
    bigfile = { enabled = true, size = 1.5 * 1024 * 1024 },

    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = " ", key = "f", desc = "Найти файл", action = ":lua require('telescope.builtin').find_files()" },
          { icon = " ", key = "n", desc = "Новый файл", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Поиск по тексту", action = ":lua require('telescope.builtin').live_grep()" },
          { icon = " ", key = "r", desc = "Недавние файлы", action = ":lua require('telescope.builtin').oldfiles()" },
          { icon = " ", key = "d", desc = "Дифф изменений", action = ":DiffviewOpen" },
          { icon = " ", key = "c", desc = "Конфиг", action = ":lua require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })" },
          { icon = "󰒲 ", key = "l", desc = "Плагины", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Выход", action = ":qa" },
        },
        header = [[
██╗██████╗ ███████╗
██║██╔══██╗██╔════╝
██║██║  ██║█████╗  
██║██║  ██║██╔══╝  
██║██████╔╝███████╗
╚═╝╚═════╝ ╚══════╝]],
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
  },
}
