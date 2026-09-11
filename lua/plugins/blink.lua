-- Автодополнение. Клавиши описаны здесь, а не в lua/keymaps.lua: раньше там
-- был require("blink.cmp") на верхнем уровне и ручной feedkeys — blink умеет
-- то же самое штатно через fallback.
return {
  "Saghen/blink.cmp",
  build = function()
    require("blink.cmp").build():pwait()
  end,
  dependencies = {
    "Saghen/blink.lib",
    "rafamadriz/friendly-snippets",
  },
  opts = {
    keymap = {
      preset = "none",
      ["<Tab>"] = { "accept", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Esc>"] = { "cancel", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 150,
        window = { border = "rounded" },
      },
      menu = {
        border = "rounded",
        draw = { treesitter = { "lsp" } },
      },
      ghost_text = { enabled = false },
    },
    signature = {
      enabled = true,
      window = { border = "rounded" },
    },
    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
      },
    },
  },
}
