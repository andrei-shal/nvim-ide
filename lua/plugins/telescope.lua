return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    defaults = {
      -- Без этого live_grep по проекту на Next.js тонет в node_modules
      file_ignore_patterns = {
        "^%.git/",
        "node_modules/",
        "target/",
        "dist/",
        "build/",
        "%.next/",
        "__pycache__/",
        "%.lock$",
      },
      layout_strategy = "flex",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      path_display = { "truncate" },
    },
    pickers = {
      find_files = { hidden = true },
    },
  },
}
