-- Git-декорации в gutter + инлайн-дифф.
-- Основа ревью правок, сделанных ИИ-агентом: знаки показывают тронутые строки,
-- отдельные "staged"-знаки — то, что агент уже добавил через git add.
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add          = { text = "┃" },
      change       = { text = "┃" },
      delete       = { text = "▁" },
      topdelete    = { text = "▔" },
      changedelete = { text = "~" },
      untracked    = { text = "┆" },
    },

    -- Знаки для уже застейдженных изменений: агент сделал git add — правки
    -- всё равно видны, просто другим символом
    signs_staged = {
      add          = { text = "┋" },
      change       = { text = "┋" },
      delete       = { text = "▁" },
      topdelete    = { text = "▔" },
      changedelete = { text = "~" },
    },
    signs_staged_enable = true,

    -- Новые файлы, созданные агентом, тоже получают знаки
    attach_to_untracked = true,

    watch_gitdir = { follow_files = true },

    preview_config = { border = "rounded" },

    current_line_blame = false,
    current_line_blame_opts = {
      delay = 300,
      virt_text_pos = "eol",
    },
  },
}
