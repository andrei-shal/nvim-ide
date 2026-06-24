return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  init = function()
    require("nvim-treesitter").install({
      "lua",
      "vim",
      "vimdoc"
    })
  end
}
