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
      { "<leader>g", group = "Git и диффы", icon = icons.get({ desc = "git" }) },
      { "<leader>f", group = "Файлы", icon = icons.get({ desc = "telescope" }) },
      { "<leader>s", group = "Поиск и символы", icon = icons.get({ desc = "search" }) },
      { "<leader>c", group = "Код", icon = icons.get({ desc = "format" }) },
      { "<leader>x", group = "Проблемы", icon = icons.get({ desc = "diagnostics" }) },
      { "<leader>b", group = "Буферы", icon = icons.get({ desc = "window" }) },
      { "<leader>t", group = "Терминал", icon = icons.get({ desc = "terminal" }) },
      { "<leader>u", group = "Тумблеры", icon = icons.get({ desc = "toggle" }) },
      { "<leader>e", desc = "Проводник", icon = icons.get({ desc = "file" }) },
    })
  end
}
