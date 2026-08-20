-- Панель диффа по всему changeset'у: список изменённых файлов слева,
-- side-by-side дифф справа. Главный инструмент ревью работы агента целиком.
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
  opts = {
    enhanced_diff_hl = true,

    view = {
      default = { winbar_info = true },
      merge_tool = {
        layout = "diff3_mixed",
        disable_diagnostics = true,
      },
    },

    file_panel = {
      listing_style = "tree",
      win_config = { position = "left", width = 34 },
    },

    file_history_panel = {
      win_config = { position = "bottom", height = 14 },
    },

    keymaps = {
      view = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Закрыть дифф" } },
        { "n", "<leader>e", "<cmd>DiffviewToggleFiles<cr>", { desc = "Список файлов" } },
      },
      file_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Закрыть дифф" } },
      },
      file_history_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Закрыть историю" } },
      },
    },
  },
}
