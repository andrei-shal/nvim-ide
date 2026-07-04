return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "LspAttach",
  priority = 1000,
  opts = {
    preset = "powerline",
    options = {
      throttle = 0,
      enable_on_insert = true,
      enable_on_select = true,
      show_all_diags_on_cursorline = true,
      severity = {
        vim.diagnostic.severity.ERROR,
        vim.diagnostic.severity.WARN,
        vim.diagnostic.severity.INFO,
        vim.diagnostic.severity.HINT,
      },
      add_messages = {
        messages = true,
        use_max_severity = false,
        show_multiple_glyphs = true
      },
      multilines = {
        enabled = true,
        always_show = true
      }
    }
  }
}
