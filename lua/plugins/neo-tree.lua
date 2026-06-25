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
        enable = true,
        leave_dirs_open = false,
      },
      use_libuv_file_watcher = true,
    },
    buffers = {
      follow_current_file = {
        enable = true
      }
    },
    event_handlers = {
      {
        event = "file_opened",
        handler = function()
          require("neo-tree.command").execute({ action = "show", reveal = true })
        end
      }
    }
  }
}
