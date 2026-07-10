return {
  "scottmckendry/cyberdream.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("cyberdream").setup({
      transparent = true,
      saturation = 0.9,
      italic_comments = true,
      hide_fillchars = false,
      cache = true,
    })
    vim.cmd.colorscheme("cyberdream")
  end
}
