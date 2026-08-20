-- Видимые уведомления и прогресс LSP.
-- В конфиге cmdheight = 0, поэтому обычные сообщения мелькают и пропадают —
-- а именно сообщениями объясняется, почему git-команда не сработала.
-- Заодно видно, что rust-analyzer или jdtls ещё индексируют проект, а не
-- «не работают».
return {
  "j-hui/fidget.nvim",
  event = "VeryLazy",
  opts = {
    progress = {
      display = {
        done_icon = "✓",
        progress_icon = { pattern = "dots" },
      },
    },
    notification = {
      override_vim_notify = true,
      window = {
        winblend = 0,
        border = "rounded",
        align = "bottom",
      },
    },
  },
}
