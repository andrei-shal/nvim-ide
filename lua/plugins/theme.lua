-- Набор тем. Активная выбирается через <leader>ut с живым предпросмотром
-- и запоминается между сессиями (см. lua/colorscheme.lua).
-- Все с прозрачным фоном, чтобы поведение при переключении не менялось.
return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      saturation = 0.9,
      italic_comments = true,
      hide_fillchars = false,
      cache = true,
    },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        neotree = true,
        telescope = true,
        treesitter = true,
        which_key = true,
        fidget = true,
        mason = true,
        native_lsp = { enabled = true },
        indent_blankline = { enabled = true },
      },
    },
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
        comments = { italic = true },
      },
    },
  },

  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      commentStyle = { italic = true },
    },
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      styles = { transparency = true, italic = true },
    },
  },
}
