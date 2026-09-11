-- Форматирование по сохранению.
-- Java намеренно исключена: форматирование через jdtls медленное и требует
-- отдельного профиля. Тумблер <leader>uf выключает автоформат на лету —
-- нужен, чтобы форматтер не подмешивал свои правки в дифф, который ревьюишь.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      lua              = { "stylua" },
      python           = { "ruff_format", "ruff_organize_imports" },
      rust             = { "rustfmt" },
      c                = { "clang_format" },
      cpp              = { "clang_format" },
      javascript       = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact  = { "prettierd", "prettier", stop_after_first = true },
      typescript       = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact  = { "prettierd", "prettier", stop_after_first = true },
      json             = { "prettierd", "prettier", stop_after_first = true },
      jsonc            = { "prettierd", "prettier", stop_after_first = true },
      css              = { "prettierd", "prettier", stop_after_first = true },
      scss             = { "prettierd", "prettier", stop_after_first = true },
      html             = { "prettierd", "prettier", stop_after_first = true },
      yaml             = { "prettierd", "prettier", stop_after_first = true },
      markdown         = { "prettierd", "prettier", stop_after_first = true },
      java             = {},
    },

    default_format_opts = { lsp_format = "fallback" },

    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      if vim.bo[bufnr].filetype == "java" then
        return
      end
      return { timeout_ms = 1500, lsp_format = "fallback" }
    end,
  },
}
