return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "clangd"
    }
  },
  dependencies = {
    "mason-org/mason.nvim",
    "neovim/nvim-lspconfig"
  }
}
