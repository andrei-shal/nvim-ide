return {
  "akinsho/bufferline.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    options = {
      offsets = {
        {
          filetype = "neo-tree",
          text = "Проводник",
          highlight = "Directory",
          separator = true,
          padding = 1,
        }
      }
    }
  }
}
