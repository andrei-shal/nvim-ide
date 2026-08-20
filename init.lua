vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
})

require("options")
require("keymaps")
require("autocmds")

-- Тема применяется после загрузки плагинов: берётся та, что была выбрана
-- в прошлый раз через <leader>ut
require("colorscheme").apply()
