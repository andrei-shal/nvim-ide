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

    -- Корневая строка показывала обрезанный абсолютный путь и занимала место.
    -- Имя проекта теперь выводится в панели вкладок над деревом.
    hide_root_node = true,
    retain_hidden_root_indent = false,

    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      use_libuv_file_watcher = true,
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = { "node_modules", "__pycache__", ".git" },
      },
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
