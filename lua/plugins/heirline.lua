-- Статуслайн и панель вкладок.
--
-- Статуслайн глобальный (laststatus = 3): один на всё окно. Раньше каждое
-- окно рисовало свой, и рядом со статуслайном файла висел ещё один — от
-- проводника, с режимом, позицией курсора и «NEO-TREE».
--
-- Цвета берутся из активной темы, а не задаются константами: тему можно
-- менять на лету через <leader>ut.
return {
  "rebelot/heirline.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "lewis6991/gitsigns.nvim",
  },
  config = function()
    local utils = require("heirline.utils")
    local conditions = require("heirline.conditions")

    local function get(group, attr, fallback)
      local hl = utils.get_highlight(group)
      return hl and hl[attr] or fallback
    end

    local function setup_colors()
      return {
        fg = get("Normal", "fg", "#c0caf5"),
        dim = get("Comment", "fg", "#565f89"),
        gray = get("NonText", "fg", "#414868"),
        red = get("DiagnosticError", "fg", "#f7768e"),
        yellow = get("DiagnosticWarn", "fg", "#e0af68"),
        blue = get("DiagnosticInfo", "fg", "#7aa2f7"),
        hint = get("DiagnosticHint", "fg", "#1abc9c"),
        green = get("String", "fg", "#9ece6a"),
        cyan = get("Special", "fg", "#2ac3de"),
        magenta = get("Statement", "fg", "#bb9af7"),
        orange = get("Constant", "fg", "#ff9e64"),
        sel_bg = get("TabLineSel", "bg") or get("Visual", "bg", "#283457"),
        sel_fg = get("TabLineSel", "fg") or get("Normal", "fg", "#c0caf5"),
        git_add = get("Added", "fg") or get("DiffAdd", "fg", "#9ece6a"),
        git_change = get("Changed", "fg") or get("DiffChange", "fg", "#e0af68"),
        git_del = get("Removed", "fg") or get("DiffDelete", "fg", "#f7768e"),
      }
    end

    -- Тонкий разделитель вместо тяжёлого ▐
    local Sep = { provider = " │ ", hl = { fg = "gray" } }
    local Space = { provider = " " }

    ------------------------------------------------------------------
    -- Статуслайн
    ------------------------------------------------------------------

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
        return " " .. (self.mode_names[self.mode] or self.mode) .. " "
      end,
      hl = function(self)
        return { fg = self.mode_colors[self.mode:sub(1, 1)] or "fg", bold = true }
      end,
      update = {
        "ModeChanged",
        pattern = "*:*",
        callback = vim.schedule_wrap(function()
          vim.cmd("redrawstatus")
        end),
      },
    }

    -- Что показывать вместо имени файла в служебных окнах
    local special_names = {
      ["neo-tree"] = "  Проводник",
      ["trouble"] = "  Проблемы",
      ["TelescopePrompt"] = "  Поиск",
      ["lazy"] = " 󰒲 Плагины",
      ["mason"] = "  Mason",
      ["help"] = "  Справка",
      ["toggleterm"] = "  Терминал",
      ["DiffviewFiles"] = "  Дифф",
      ["DiffviewFileHistory"] = "  История",
    }

    local FileIcon = {
      condition = function()
        return not special_names[vim.bo.filetype]
      end,
      init = function(self)
        local filename = vim.api.nvim_buf_get_name(0)
        local ext = vim.fn.fnamemodify(filename, ":e")
        local ok, devicons = pcall(require, "nvim-web-devicons")
        if ok then
          self.icon, self.icon_color = devicons.get_icon_color(filename, ext, { default = true })
        end
      end,
      provider = function(self)
        return self.icon and (" " .. self.icon .. " ") or " "
      end,
      hl = function(self)
        return self.icon_color and { fg = self.icon_color } or {}
      end,
    }

    local FileName = {
      provider = function()
        local special = special_names[vim.bo.filetype]
        if special then
          return special .. " "
        end
        local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
        if name == "" then
          return "[Без имени] "
        end
        -- длинные пути ужимаем до последних двух сегментов
        local parts = vim.split(name, "/")
        if #parts > 2 then
          name = "…/" .. parts[#parts - 1] .. "/" .. parts[#parts]
        end
        return name .. " "
      end,
      hl = { bold = true },
    }

    local FileFlags = {
      {
        condition = function()
          return vim.bo.modified
        end,
        provider = "● ",
        hl = { fg = "green" },
      },
      {
        condition = function()
          return not vim.bo.modifiable or vim.bo.readonly
        end,
        provider = " ",
        hl = { fg = "orange" },
      },
    }

    local GitBranch = {
      condition = conditions.is_git_repo,
      provider = function()
        local head = vim.b.gitsigns_head
        return (head and head ~= "") and ("  " .. head) or ""
      end,
      hl = { fg = "magenta" },
    }

    -- Объём правок относительно git: сразу видно, сколько тронул агент
    local GitDiff = {
      condition = function()
        local d = vim.b.gitsigns_status_dict
        return d and ((d.added or 0) + (d.changed or 0) + (d.removed or 0)) > 0
      end,
      init = function(self)
        self.status = vim.b.gitsigns_status_dict or {}
      end,
      update = {
        "User",
        pattern = "GitSignsUpdate",
        callback = vim.schedule_wrap(function()
          vim.cmd("redrawstatus")
        end),
      },
      {
        provider = function(self)
          local n = self.status.added or 0
          return n > 0 and (" +" .. n) or ""
        end,
        hl = { fg = "git_add" },
      },
      {
        provider = function(self)
          local n = self.status.changed or 0
          return n > 0 and (" ~" .. n) or ""
        end,
        hl = { fg = "git_change" },
      },
      {
        provider = function(self)
          local n = self.status.removed or 0
          return n > 0 and (" -" .. n) or ""
        end,
        hl = { fg = "git_del" },
      },
    }

    local Git = {
      condition = conditions.is_git_repo,
      Sep,
      GitBranch,
      GitDiff,
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
      Sep,
      {
        provider = function()
          local names = {}
          for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
            table.insert(names, client.name)
          end
          return "  " .. table.concat(names, " ")
        end,
        hl = { fg = "green" },
      },
    }

    local Diagnostics = {
      condition = conditions.has_diagnostics,
      static = {
        icons = { error = " ", warn = " ", info = " ", hint = " " },
      },
      init = function(self)
        local d = vim.diagnostic.get(0)
        local sev = vim.diagnostic.severity
        local function count(s)
          return #vim.tbl_filter(function(x)
            return x.severity == s
          end, d)
        end
        self.errors = count(sev.ERROR)
        self.warns = count(sev.WARN)
        self.infos = count(sev.INFO)
        self.hints = count(sev.HINT)
      end,
      update = { "DiagnosticChanged", "BufEnter" },
      Sep,
      {
        provider = function(self)
          return self.errors > 0 and (self.icons.error .. self.errors .. " ") or ""
        end,
        hl = { fg = "red" },
      },
      {
        provider = function(self)
          return self.warns > 0 and (self.icons.warn .. self.warns .. " ") or ""
        end,
        hl = { fg = "yellow" },
      },
      {
        provider = function(self)
          return self.infos > 0 and (self.icons.info .. self.infos .. " ") or ""
        end,
        hl = { fg = "blue" },
      },
      {
        provider = function(self)
          return self.hints > 0 and (self.icons.hint .. self.hints .. " ") or ""
        end,
        hl = { fg = "hint" },
      },
    }

    local Ruler = {
      provider = " %l:%c ",
      hl = { fg = "dim" },
    }

    local FileType = {
      provider = function()
        local ft = vim.bo.filetype
        return ft ~= "" and (" " .. ft:upper() .. " ") or ""
      end,
      hl = { fg = "dim" },
    }

    local StatusLine = {
      ViMode,
      Sep,
      FileIcon,
      FileName,
      FileFlags,
      Git,
      LSPActive,
      Diagnostics,
      { provider = "%=" },
      Ruler,
      Sep,
      FileType,
    }

    ------------------------------------------------------------------
    -- Панель вкладок
    ------------------------------------------------------------------

    -- Активная вкладка выделена полоской и фоном, у остальных только текст
    local TabAccent = {
      provider = function(self)
        return self.is_active and "▎" or " "
      end,
      hl = function(self)
        return { fg = self.is_active and "cyan" or "gray" }
      end,
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
        return self.icon and (self.icon .. " ") or ""
      end,
      hl = function(self)
        if not self.is_active then
          return { fg = "dim" }
        end
        return self.icon_color and { fg = self.icon_color } or {}
      end,
    }

    local TablineFileName = {
      provider = function(self)
        local name = vim.api.nvim_buf_get_name(self.bufnr)
        name = name == "" and "[Без имени]" or vim.fn.fnamemodify(name, ":t")
        return name .. " "
      end,
      hl = function(self)
        return { bold = self.is_active, fg = self.is_active and "sel_fg" or "dim" }
      end,
    }

    -- Количество ошибок прямо на вкладке: видно, какой файл агент сломал
    local TablineDiagnostics = {
      provider = function(self)
        local n = #vim.diagnostic.get(self.bufnr, { severity = vim.diagnostic.severity.ERROR })
        return n > 0 and (" " .. n .. " ") or ""
      end,
      hl = { fg = "red" },
      update = { "DiagnosticChanged", "BufEnter" },
    }

    local TablineFileFlags = {
      {
        condition = function(self)
          return vim.bo[self.bufnr].modified
        end,
        provider = "● ",
        hl = { fg = "green" },
      },
      {
        condition = function(self)
          return not vim.bo[self.bufnr].modifiable or vim.bo[self.bufnr].readonly
        end,
        provider = " ",
        hl = { fg = "orange" },
      },
    }

    local TablineBufferBlock = {
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(self.bufnr)
      end,
      hl = function(self)
        if self.is_active then
          return { bg = "sel_bg" }
        end
        return "TabLine"
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
        minwid = function(self)
          return self.bufnr
        end,
        name = "heirline_tabline_buffer_callback",
      },
      TabAccent,
      Space,
      TablineFileIcon,
      TablineFileName,
      TablineDiagnostics,
      TablineFileFlags,
      Space,
    }

    local BufferLine = utils.make_buflist(
      TablineBufferBlock,
      { provider = " ", hl = { fg = "gray" } },
      { provider = " ", hl = { fg = "gray" } }
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
          for i, v in ipairs(bufs) do
            buflist_cache[i] = v
          end
          for i = #bufs + 1, #buflist_cache do
            buflist_cache[i] = nil
          end
          if #buflist_cache > 1 then
            vim.o.showtabline = 2
          elseif vim.o.showtabline ~= 1 then
            vim.o.showtabline = 1
          end
        end)
      end,
    })

    -- Над проводником — имя проекта, а не «Проводник»: корневая строка
    -- дерева скрыта, и это единственное место, где видно, где ты находишься
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
        local project = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        local title = "  " .. project:upper() .. " "
        local tw = vim.fn.strwidth(title)
        local width = vim.api.nvim_win_get_width(self.winid)
        if tw > width then
          return title:sub(1, width)
        end
        local left = math.floor((width - tw) / 2)
        return string.rep(" ", left) .. title .. string.rep(" ", width - tw - left)
      end,
      hl = function(self)
        if vim.api.nvim_get_current_win() == self.winid then
          return { fg = "cyan", bold = true }
        end
        return { fg = "dim" }
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
      condition = function()
        return #vim.api.nvim_list_tabpages() >= 2
      end,
      { provider = "%=" },
      utils.make_tablist(Tabpage),
    }

    local TabLine = { TabLineOffset, BufferLine, TabPages }

    require("heirline").setup({
      statusline = StatusLine,
      tabline = TabLine,
      opts = { colors = setup_colors() },
    })

    -- Перекрасить статуслайн под новую тему сразу после её смены
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("heirline_colors", { clear = true }),
      callback = function()
        utils.on_colorscheme(setup_colors)
      end,
    })

    vim.o.showtabline = 2
  end,
}
