local augroup = function(name)
  return vim.api.nvim_create_augroup("nvim_ide_" .. name, { clear = true })
end

-- Подсветка treesitter для всех поддерживаемых файлов
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("treesitter"),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end
})

-- Автооткрытие проводника.
-- При запуске без аргументов проводник не открывается: там показывается
-- стартовый экран, и дерево рядом с ним только зажимает его. Дерево
-- появляется, как только открыт первый настоящий файл.
local function show_tree()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
      return
    end
  end
  pcall(vim.cmd, "Neotree show")
end

vim.api.nvim_create_autocmd("UIEnter", {
  group = augroup("neotree_start"),
  once = true,
  callback = function()
    if vim.fn.argc() > 0 then
      show_tree()
    end
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("neotree_on_file"),
  once = true,
  callback = function(args)
    if vim.bo[args.buf].buftype == "" and vim.api.nvim_buf_get_name(args.buf) ~= "" then
      vim.schedule(show_tree)
    end
  end,
})

--------------------------------------------------------------------------
-- Перечитывание файлов, изменённых снаружи
--
-- Ключевое для работы с ИИ-агентами: агент правит файлы на диске, пока они
-- открыты в буферах. Без этого буфер показывает устаревший текст, а дифф
-- относительно git считается по старому содержимому и попросту врёт.
--------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype == "" and vim.fn.getcmdwintype() == "" then
      pcall(vim.cmd.checktime)
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = augroup("file_changed"),
  callback = function()
    vim.notify("Файл изменён на диске, буфер перезагружен", vim.log.levels.WARN)
  end,
})

--------------------------------------------------------------------------
-- Локальные настройки по типам файлов
--------------------------------------------------------------------------

-- Перенос строк для текстовых форматов
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_text"),
  pattern = { "markdown", "markdown_inline", "text", "gitcommit", "typst", "tex" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = false
  end,
})

-- Закрытие служебных окон по q
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help", "qf", "checkhealth", "lspinfo", "man", "notify",
    "startuptime", "gitsigns-blame", "grug-far-help",
  },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true })
  end,
})

--------------------------------------------------------------------------
-- Мелочи
--------------------------------------------------------------------------

-- Подсветка скопированного фрагмента
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank_highlight"),
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- Восстановление позиции курсора при открытии файла
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("restore_cursor"),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

--------------------------------------------------------------------------
-- Подписи «было / стало» над окнами диффа
--
-- Строка хлебных крошек dropbar есть только у рабочей копии, а у версии из
-- git её нет. Из-за этого половины диффа сдвигались на одну строку, и
-- одинаковые строки никогда не стояли рядом: прокрутка связана, но выглядит
-- рассинхронизированной. Даём winbar обоим окнам — высоты равны, а заодно
-- видно, где старая версия, а где новая.
-- diffview подписывает свои окна сам, его вкладки не трогаем.
--------------------------------------------------------------------------

local function diff_label(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name:match("^gitsigns://") then
    -- имя вида ".../.git//HEAD:path" или ".../.git//:0:path" (индекс)
    local tail = name:match("//([^/]*:.*)$") or vim.fn.fnamemodify(name, ":t")
    local rev, file = tail:match("^:0:(.*)$"), nil
    if rev then
      rev, file = "индекс", rev
    else
      rev, file = tail:match("^(.-):(.*)$")
    end
    return "%#DiffDelete#  было %*  " .. (rev or "git") .. " · " .. (file or tail)
  end
  return "%#DiffAdd#  стало %*  " .. vim.fn.fnamemodify(name, ":.")
end

local function is_diffview_tab(wins)
  for _, w in ipairs(wins) do
    local b = vim.api.nvim_win_get_buf(w)
    if vim.api.nvim_buf_get_name(b):match("^diffview://") or vim.bo[b].filetype:match("^Diffview") then
      return true
    end
  end
  return false
end

local function sync_diff_winbars()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  if is_diffview_tab(wins) then
    return
  end
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == "" then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.wo[win].diff then
        if vim.w[win].pre_diff_winbar == nil then
          vim.w[win].pre_diff_winbar = vim.wo[win].winbar
        end
        local label = diff_label(buf)
        if vim.wo[win].winbar ~= label then
          vim.wo[win].winbar = label
        end
        -- служебный буфер с версией из git не должен висеть во вкладках
        if vim.api.nvim_buf_get_name(buf):match("^gitsigns://") and vim.bo[buf].buflisted then
          vim.bo[buf].buflisted = false
          vim.cmd.redrawtabline()
        end
      elseif vim.w[win].pre_diff_winbar ~= nil then
        -- дифф выключен — вернуть то, что было (крошки dropbar)
        vim.wo[win].winbar = vim.w[win].pre_diff_winbar
        vim.w[win].pre_diff_winbar = nil
      end
    end
  end
end

vim.api.nvim_create_autocmd("OptionSet", {
  group = augroup("diff_winbar_opt"),
  pattern = "diff",
  callback = function()
    vim.schedule(sync_diff_winbars)
  end,
})

vim.api.nvim_create_autocmd({ "DiffUpdated", "WinClosed", "BufWinEnter" }, {
  group = augroup("diff_winbar_events"),
  callback = function()
    vim.schedule(sync_diff_winbars)
  end,
})
