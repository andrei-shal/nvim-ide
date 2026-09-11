-- Панель диффа по всему changeset'у: список изменённых файлов слева,
-- side-by-side дифф справа. Главный инструмент ревью работы агента целиком.

-- Цвет git-статуса из темы. Тематические diffAdded/diffRemoved есть не везде
-- (в cyberdream пустые, в rose-pine только фон), поэтому запасной вариант —
-- штатные Added/Changed/Removed из Neovim 0.10+, они заданы во всех темах.
local function git_color(theme_group, nvim_group, fallback)
  for _, name in ipairs({ theme_group, nvim_group }) do
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    if hl.fg then
      return hl.fg
    end
  end
  return fallback
end

local function apply_highlights()
  local add = git_color("diffAdded", "Added", 0x9ece6a)
  local change = git_color("diffChanged", "Changed", 0xe0af68)
  local del = git_color("diffRemoved", "Removed", 0xf7768e)
  local set = vim.api.nvim_set_hl

  -- Буквы статусов. Раньше они ссылались на пустые группы темы и оставались
  -- бесцветными — в том числе D у удалённых файлов.
  for _, g in ipairs({ "Added", "Untracked" }) do
    set(0, "DiffviewStatus" .. g, { fg = add, bold = true })
  end
  for _, g in ipairs({ "Modified", "Renamed", "Copied", "TypeChange", "TypeChanged", "Unmerged" }) do
    set(0, "DiffviewStatus" .. g, { fg = change, bold = true })
  end
  for _, g in ipairs({ "Deleted", "Broken", "Unknown" }) do
    set(0, "DiffviewStatus" .. g, { fg = del, bold = true })
  end
  set(0, "DiffviewFilePanelInsertions", { fg = add })
  set(0, "DiffviewFilePanelDeletions", { fg = del })

  -- Удалённый файл: вся строка красная и зачёркнутая, как в VS Code
  set(0, "NvimIdeDiffviewDeletedFile", { fg = del, strikethrough = true })
end

-- diffview рисует имя файла одним цветом при любом статусе (render_file —
-- локальная функция, её не переопределить), поэтому строки удалённых файлов
-- перекрашиваются поверх при отрисовке. Статус всегда стоит в первой колонке.
local function highlight_deleted_rows()
  local ns = vim.api.nvim_create_namespace("nvim_ide_diffview_deleted")
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, _, buf)
      return vim.bo[buf].filetype == "DiffviewFiles"
    end,
    on_line = function(_, _, buf, row)
      local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
      if line and line:match("^D%s") then
        vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
          end_row = row,
          end_col = #line,
          hl_group = "NvimIdeDiffviewDeletedFile",
          -- выше подсветки самого diffview (nvim_buf_add_highlight, 4096)
          priority = 10000,
          ephemeral = true,
        })
      end
    end,
  })
end

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
  opts = {
    enhanced_diff_hl = true,

    view = {
      default = { winbar_info = true },
      merge_tool = {
        layout = "diff3_mixed",
        disable_diagnostics = true,
      },
    },

    file_panel = {
      listing_style = "tree",
      win_config = { position = "left", width = 34 },
    },

    file_history_panel = {
      win_config = { position = "bottom", height = 14 },
    },

    keymaps = {
      view = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Закрыть дифф" } },
        { "n", "<leader>e", "<cmd>DiffviewToggleFiles<cr>", { desc = "Список файлов" } },
      },
      file_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Закрыть дифф" } },
      },
      file_history_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Закрыть историю" } },
      },
    },
  },
  config = function(_, opts)
    require("diffview").setup(opts)

    apply_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("nvim_ide_diffview_hl", { clear = true }),
      callback = apply_highlights,
    })

    highlight_deleted_rows()
  end,
}
