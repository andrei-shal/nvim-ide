return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "clangd",
      "pyright",
      "jdtls"
    }
  },
  dependencies = {
    "mason-org/mason.nvim",
    "neovim/nvim-lspconfig"
  }
}
