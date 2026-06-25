return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {},
  dependencies = {
    "nvim-tree/nvim-web-devicons"
  },
  config = function(_, opts)
    local which_key = require("which-key")
    local icons = require("which-key.icons")
    which_key.setup(opts)

    which_key.add({
      { "<leader>h", group = "Git", icon = icons.get({ desc = "git" }) },
      { "<leader>f", group = "Поиск", icon = icons.get({ desc = "telescope" }) },
      { "<leader>l", group = "LSP", icon = icons.get({ desc = "format" }) },
      { "<leader>x", group = "Вкладки", icon = icons.get({ desc = "close" }) },
    })
  end
}
