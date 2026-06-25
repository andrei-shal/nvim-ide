return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  lazy = false,
  opts = {
    close_if_last_window = true,
    filesystem = {
      follow_current_file = {
        enabled = true
      },
      use_libuv_file_watcher = true
    },

    default_component_configs = {
      git_status = {
        symbols = {
          added = "+",
          modified = "~",
          deleted = "-",
          renamed = ">",
          untracked = "?",
          ignored = "!",
          unstaged = "*",
          staged = "✓",
          conflict = "x"
        }
      }
    }
  }
}
