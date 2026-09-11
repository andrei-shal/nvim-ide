-- Панель «Проблемы» в стиле VS Code: все диагностики проекта одним списком.
return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    focus = true,
    win = { size = 0.3 },
    modes = {
      diagnostics = { auto_open = false },
    },
  },
}
