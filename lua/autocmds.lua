vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end
})


vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.cmd("Neotree show")
  end
})
