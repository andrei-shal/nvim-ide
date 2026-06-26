return {
  "rebelot/heirline.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "lewis6991/gitsigns.nvim",
  },
  config = function()
    local utils = require("heirline.utils")
    local conditions = require("heirline.conditions")

    local Sep = { provider = " ▐ " }

    local ViMode = {
      static = {
        mode_names = {
          n = vim.fn.nr2char(0xe62b) .. " НАВИГАЦИЯ",
          i = vim.fn.nr2char(0xf040) .. " РЕДАКТИР",
          c = vim.fn.nr2char(0xf120) .. " КОМАНДА",
          v = vim.fn.nr2char(0xf14a) .. " ВЫДЕЛЕНИЕ",
          V = vim.fn.nr2char(0xf0db) .. " ВЫД-СТРОК",
          ["\22"] = vim.fn.nr2char(0xf0c8) .. " ВЫД-БЛОК",
          s = vim.fn.nr2char(0xf27a) .. " ВЫБОР",
          S = vim.fn.nr2char(0xf27a) .. " ВЫБ-СТРОК",
          ["\19"] = vim.fn.nr2char(0xf27a) .. " ВЫБ-БЛОК",
          R = vim.fn.nr2char(0xf01e) .. " ЗАМЕНА",
          r = vim.fn.nr2char(0xf01e) .. " ЗАМЕНА",
          t = vim.fn.nr2char(0xf489) .. " ТЕРМИНАЛ",
        },
        mode_colors = {
          n = "green", i = "blue", v = "cyan", V = "cyan",
          ["\22"] = "cyan", c = "orange", s = "magenta", S = "magenta",
          ["\19"] = "magenta", R = "red", r = "red", t = "green",
        },
      },
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      provider = function(self)
        return " %2(" .. self.mode_names[self.mode] .. "%) "
      end,
      hl = function(self)
        return { fg = self.mode_colors[self.mode:sub(1, 1)], bold = true }
      end,
      update = { "ModeChanged", pattern = "*:*", callback = vim.schedule_wrap(function()
        vim.cmd("redrawstatus")
      end) },
    }

    local FileIcon = {
      init = function(self)
        local filename = vim.api.nvim_buf_get_name(0)
        local ext = vim.fn.fnamemodify(filename, ":e")
        local ok, devicons = pcall(require, "nvim-web-devicons")
        if ok then
          self.icon, self.icon_color = devicons.get_icon_color(filename, ext, { default = true })
        end
      end,
      provider = function(self)
        return self.icon and (self.icon .. " ") or ""
      end,
      hl = function(self)
        return self.icon_color and { fg = self.icon_color } or {}
      end,
    }

    local FileName = {
      provider = function()
        local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
        if name == "" then return "[No Name] " end
        return name .. " "
      end,
      hl = { bold = true },
    }

    local FileFlags = {
      {
        condition = function() return vim.bo.modified end,
        provider = "[+] ",
        hl = { fg = "green" },
      },
      {
        condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
        provider = " ",
        hl = { fg = "orange" },
      },
    }

    local GitBranch = {
      condition = conditions.is_git_repo,
      provider = function()
        local head = vim.b.gitsigns_head
        if head and head ~= "" then
          return "  " .. head .. " "
        end
        return ""
      end,
      hl = { fg = "red" },
    }

    local LSPActive = {
      condition = function()
        return #vim.lsp.get_clients({ bufnr = 0 }) > 0
      end,
      update = {
        "LspAttach",
        "LspDetach",
        callback = vim.schedule_wrap(function()
          vim.cmd("redrawstatus")
        end),
      },
      provider = function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        local names = {}
        for _, client in ipairs(clients) do
          table.insert(names, client.name)
        end
        return "  [" .. table.concat(names, " ") .. "] "
      end,
      hl = { fg = "green", bold = true },
    }

    local Diagnostics = {
      condition = conditions.has_diagnostics,
      static = {
        error_icon = "  ",
        warn_icon = "  ",
      },
      init = function(self)
        local d = vim.diagnostic.get(0)
        self.errors = #vim.tbl_filter(function(s) return s.severity == vim.diagnostic.severity.ERROR end, d)
        self.warns = #vim.tbl_filter(function(s) return s.severity == vim.diagnostic.severity.WARN end, d)
      end,
      {
        provider = function(self) return self.errors > 0 and (self.error_icon .. self.errors) end,
        hl = { fg = "red" },
      },
      {
        provider = function(self) return self.warns > 0 and (self.warn_icon .. self.warns) end,
        hl = { fg = "yellow" },
      },
    }

    local Ruler = {
      provider = " %l:%c ",
      hl = { bold = true },
    }

    local FileType = {
      provider = function()
        local ft = vim.bo.filetype
        return ft ~= "" and " " .. ft:upper() .. " "
      end,
      hl = { fg = "gray" },
    }

    local StatusLine = {
      ViMode,
      Sep,
      FileIcon,
      FileName,
      FileFlags,
      Sep,
      GitBranch,
      {
        condition = conditions.lsp_attached,
        provider = " ▐ ",
      },
      LSPActive,
      Diagnostics,
      { provider = "%=" },
      Ruler,
      Sep,
      FileType,
    }

    local TablineFileIcon = {
      init = function(self)
        local filename = vim.api.nvim_buf_get_name(self.bufnr)
        local ext = vim.fn.fnamemodify(filename, ":e")
        local ok, devicons = pcall(require, "nvim-web-devicons")
        if ok then
          self.icon, self.icon_color = devicons.get_icon_color(filename, ext, { default = true })
        end
      end,
      provider = function(self)
        return "  " .. (self.icon and (self.icon .. " ") or "")
      end,
      hl = function(self)
        return self.icon_color and { fg = self.icon_color } or {}
      end,
    }

    local TablineFileName = {
      provider = function(self)
        local name = vim.api.nvim_buf_get_name(self.bufnr)
        name = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")
        return name .. "  "
      end,
      hl = function(self)
        return { bold = self.is_active or self.is_visible }
      end,
    }

    local TablineFileFlags = {
      {
        condition = function(self) return vim.bo[self.bufnr].modified end,
        provider = " [+]",
        hl = { fg = "green" },
      },
      {
        condition = function(self)
          return not vim.bo[self.bufnr].modifiable or vim.bo[self.bufnr].readonly
        end,
        provider = " ",
        hl = { fg = "orange" },
      },
    }

    local TablineFileNameBlock = {
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(self.bufnr)
      end,
      hl = function(self)
        if self.is_active then return "TabLineSel"
        else return "TabLine" end
      end,
      on_click = {
        callback = function(_, minwid, _, button)
          if button == "m" then
            vim.schedule(function()
              vim.api.nvim_buf_delete(minwid, { force = false })
              vim.cmd.redrawtabline()
            end)
          else
            vim.api.nvim_win_set_buf(0, minwid)
          end
        end,
        minwid = function(self) return self.bufnr end,
        name = "heirline_tabline_buffer_callback",
      },
      TablineFileIcon,
      TablineFileName,
      TablineFileFlags,
    }

    local TablineBufferBlock = TablineFileNameBlock

    local BufferLine = utils.make_buflist(
      TablineBufferBlock,
      { provider = "  ", hl = { fg = "gray" } },
      { provider = "  ", hl = { fg = "gray" } }
    )

    local buflist_cache = {}
    local function get_bufs()
      return vim.tbl_filter(function(bufnr)
        return vim.bo[bufnr].buflisted
      end, vim.api.nvim_list_bufs())
    end
    vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufAdd", "BufDelete" }, {
      callback = function()
        vim.schedule(function()
          local bufs = get_bufs()
          for i, v in ipairs(bufs) do buflist_cache[i] = v end
          for i = #bufs + 1, #buflist_cache do buflist_cache[i] = nil end
          if #buflist_cache > 1 then
            vim.o.showtabline = 2
          elseif vim.o.showtabline ~= 1 then
            vim.o.showtabline = 1
          end
        end)
      end,
    })

    local TabLineOffset = {
      condition = function(self)
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local bufnr = vim.api.nvim_win_get_buf(win)
          if vim.bo[bufnr].filetype == "neo-tree" then
            self.winid = win
            return true
          end
        end
        return false
      end,
      provider = function(self)
        local title = "  Проводник  "
        local tw = vim.fn.strwidth(title)
        local width = vim.api.nvim_win_get_width(self.winid)
        local left_pad = math.floor((width - tw) / 2)
        local right_pad = width - tw - left_pad
        return string.rep(" ", left_pad) .. title .. string.rep(" ", right_pad)
      end,
      hl = function(self)
        if vim.api.nvim_get_current_win() == self.winid then
          return "TablineSel"
        end
        return "Tabline"
      end,
    }

    local Tabpage = {
      provider = function(self)
        return "%" .. self.tabnr .. "T " .. self.tabnr .. " %T"
      end,
      hl = function(self)
        return self.is_active and "TabLineSel" or "TabLine"
      end,
    }
    local TabPages = {
      condition = function() return #vim.api.nvim_list_tabpages() >= 2 end,
      { provider = "%=" },
      utils.make_tablist(Tabpage),
    }

    local TabLine = { TabLineOffset, BufferLine, TabPages }

    require("heirline").setup({
      statusline = StatusLine,
      tabline = TabLine,
    })

    vim.o.showtabline = 2
  end,
}
