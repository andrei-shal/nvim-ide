return {
  "Saghen/blink.cmp",
  build = function()
    require("blink.cmp").build():pwait()
  end,
  dependencies = {
    "Saghen/blink.lib",
    "rafamadriz/friendly-snippets"
  },
  opts = {
    keymap = {
      preset = "none"
    },
    appearance = {
      nerd_font_variant = "mono"
    },
    completion = {
      documentation = {
        auto_show = true
      }
    },
    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer"
      }
    }
  }
}
