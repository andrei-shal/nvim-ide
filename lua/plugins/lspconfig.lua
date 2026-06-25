local lombok_jar = vim.fn.stdpath("data") .. "/mason/packages/jdtls/lombok.jar"

return {
  "neovim/nvim-lspconfig",
  config = function()
    vim.env.JDTLS_JVM_ARGS = "-javaagent:" .. lombok_jar

    vim.lsp.enable("jdtls")
    vim.lsp.enable("clangd")
    vim.lsp.enable("pyright")
  end,
}
