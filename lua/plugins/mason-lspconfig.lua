-- Связка Mason и nvim-lspconfig: доустанавливает серверы и переводит
-- имена lspconfig в имена пакетов Mason.
-- automatic_enable = false — серверы включаются явно в lua/plugins/lspconfig.lua.
return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    automatic_enable = false,
    ensure_installed = {
      "rust_analyzer",
      "clangd",
      "pyright",
      "ts_ls",
      "eslint",
      "jdtls",
      "html",
      "cssls",
      "tailwindcss",
      "jsonls",
      "marksman",
      "lua_ls",
    },
  },
  dependencies = {
    "mason-org/mason.nvim",
    "neovim/nvim-lspconfig",
  },
}
