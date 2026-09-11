-- Хлебные крошки над файлом: путь плюс символ под курсором.
-- В деревьях Next.js, где десяток page.tsx, только по имени файла
-- не понять, где ты находишься.
return {
  "Bekaboo/dropbar.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    bar = {
      enable = function(buf, win, _)
        if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
          return false
        end
        -- только обычные файловые окна: без плавающих, проводника и панелей
        if vim.api.nvim_win_get_config(win).relative ~= "" or vim.fn.win_gettype(win) ~= "" then
          return false
        end
        -- Не лезть в окна диффа и туда, где winbar уже занят (diffview,
        -- подписи «было / стало»). Иначе в диффе строка крошек оказывалась
        -- только над рабочей копией, и половины сдвигались на строку.
        if vim.wo[win].diff or vim.wo[win].winbar ~= "" then
          return false
        end
        if vim.bo[buf].buftype ~= "" then
          return false
        end
        local ft = vim.bo[buf].filetype
        local skip = { "neo-tree", "trouble", "DiffviewFiles", "DiffviewFileHistory", "snacks_dashboard" }
        if vim.tbl_contains(skip, ft) then
          return false
        end
        return vim.api.nvim_buf_get_name(buf) ~= ""
      end,
    },
    icons = {
      ui = { bar = { separator = " › ", extends = "…" } },
    },
  },
}
