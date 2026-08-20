-- Лидер клавиши
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local map = vim.keymap.set

-- Плагины подключаются внутри замыканий, а не на верхнем уровне: иначе
-- ленивая загрузка ломается и всё тянется на старте.
local function gs()
  return require("gitsigns")
end

--------------------------------------------------------------------------
-- Файлы и окна
--------------------------------------------------------------------------

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Сохранить файл" })
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Сохранить файл" })
map("n", "<leader>W", "<cmd>wa<cr>", { desc = "Сохранить все" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Закрыть окно" })

-- Перемещение между окнами
map("n", "<C-h>", "<C-w>h", { desc = "Окно слева" })
map("n", "<C-j>", "<C-w>j", { desc = "Окно снизу" })
map("n", "<C-k>", "<C-w>k", { desc = "Окно сверху" })
map("n", "<C-l>", "<C-w>l", { desc = "Окно справа" })

-- Снять подсветку поиска
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Снять подсветку поиска" })

--------------------------------------------------------------------------
-- ДИФФЫ И GIT  —  основа ревью правок ИИ-агента
--
-- Слои:
--   знаки в gutter           — всегда, что тронуто (в т.ч. staged отдельно)
--   <leader>gd               — дифф текущего файла в сплите
--   <leader>gD               — панель всего changeset'а
--   ]h / [h + <leader>gs/gr  — ханк за ханком: посмотреть, принять, откатить
--------------------------------------------------------------------------

-- Дифф текущего файла относительно HEAD, вертикальным сплитом.
-- Именно HEAD, а не индекс: если агент уже сделал git add, дифф всё равно виден.
map("n", "<leader>gd", function()
  gs().diffthis("HEAD")
end, { desc = "Дифф файла vs HEAD" })

-- Дифф относительно индекса: что ещё не застейджено
map("n", "<leader>gi", function()
  gs().diffthis()
end, { desc = "Дифф файла vs индекс" })

-- Панель со всеми изменёнными файлами: полный changeset агента
map("n", "<leader>gD", "<cmd>DiffviewOpen<cr>", { desc = "Панель диффа (все файлы)" })

-- Дифф всей ветки относительно main/master: ревью работы агента целиком
map("n", "<leader>gm", function()
  local base
  for _, branch in ipairs({ "origin/main", "origin/master", "main", "master" }) do
    local out = vim.fn.systemlist({ "git", "merge-base", "HEAD", branch })
    if vim.v.shell_error == 0 and out[1] and out[1] ~= "" then
      base = out[1]
      break
    end
  end
  if not base then
    vim.notify("Не найдена ветка main/master для сравнения", vim.log.levels.WARN)
    return
  end
  vim.cmd("DiffviewOpen " .. base .. "...HEAD")
end, { desc = "Дифф ветки vs main" })

map("n", "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", { desc = "История файла" })
map("n", "<leader>gF", "<cmd>DiffviewFileHistory<cr>", { desc = "История репозитория" })

-- Навигация по ханкам
local function nav_hunk(direction)
  return function()
    if vim.wo.diff then
      vim.cmd.normal({ direction == "next" and "]c" or "[c", bang = true })
      return
    end
    gs().nav_hunk(direction, { wrap = true, preview = false })
  end
end

map("n", "]h", nav_hunk("next"), { desc = "Следующее изменение" })
map("n", "[h", nav_hunk("prev"), { desc = "Предыдущее изменение" })
map("n", "]c", nav_hunk("next"), { desc = "Следующее изменение" })
map("n", "[c", nav_hunk("prev"), { desc = "Предыдущее изменение" })

-- Превью ханка прямо в буфере, без отдельного окна
map("n", "<leader>gp", function()
  gs().preview_hunk_inline()
end, { desc = "Превью изменения инлайн" })

-- Применить / откатить ханк. В visual-режиме — только выделенные строки.
map("n", "<leader>gs", function()
  gs().stage_hunk()
end, { desc = "Применить изменение (stage)" })

map("v", "<leader>gs", function()
  gs().stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Применить выделенное (stage)" })

map("n", "<leader>gr", function()
  gs().reset_hunk()
end, { desc = "Откатить изменение" })

map("v", "<leader>gr", function()
  gs().reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Откатить выделенное" })

map("n", "<leader>gu", function()
  gs().undo_stage_hunk()
end, { desc = "Отменить stage" })

map("n", "<leader>gS", function()
  gs().stage_buffer()
end, { desc = "Применить весь файл" })

map("n", "<leader>gR", function()
  gs().reset_buffer()
end, { desc = "Откатить весь файл" })

-- Режим ревью: подсветка изменённых строк целиком + посимвольная разница
-- + удалённые строки поверх буфера. Одной клавишей, потому что постоянно
-- держать это включённым в переписанном агентом файле нечитаемо.
local review_mode = false
map("n", "<leader>gv", function()
  review_mode = not review_mode
  local g = gs()
  pcall(g.toggle_linehl, review_mode)
  pcall(g.toggle_word_diff, review_mode)
  pcall(g.toggle_deleted, review_mode)
  vim.notify("Режим ревью: " .. (review_mode and "включён" or "выключен"))
end, { desc = "Режим ревью (подсветка правок)" })

-- База сравнения. По умолчанию — индекс (только так работает stage_hunk).
-- HEAD нужен, когда агент уже сделал git add и хочется видеть всё разом.
local bases = { nil, "HEAD", "HEAD~1" }
local base_names = { "индекс", "HEAD", "HEAD~1" }
local base_idx = 1
map("n", "<leader>gB", function()
  base_idx = base_idx % #base_names + 1
  gs().change_base(bases[base_idx], true)
  local hint = base_idx == 1 and "" or " (stage/reset ханков недоступны)"
  vim.notify("База диффа: " .. base_names[base_idx] .. hint)
end, { desc = "Сменить базу диффа" })

-- Blame
map("n", "<leader>gl", function()
  gs().blame_line({ full = true })
end, { desc = "Blame строки" })

map("n", "<leader>gL", function()
  gs().blame()
end, { desc = "Blame всего файла" })

-- Все ханки репозитория одним списком: полный перечень того, что тронул агент
map("n", "<leader>gQ", function()
  gs().setqflist("all", { open = false }, function()
    vim.cmd("Trouble qflist open")
  end)
end, { desc = "Все изменения репозитория списком" })

-- lazygit во float-окне
local lazygit_term
map("n", "<leader>gg", function()
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("lazygit не установлен (sudo pacman -S lazygit)", vim.log.levels.WARN)
    return
  end
  if not lazygit_term then
    lazygit_term = require("toggleterm.terminal").Terminal:new({
      cmd = "lazygit",
      direction = "float",
      hidden = true,
      float_opts = { border = "rounded" },
      -- lazygit меняет файлы на диске — перечитываем буферы после выхода
      on_close = function()
        vim.schedule(function()
          vim.cmd("checktime")
        end)
      end,
    })
  end
  lazygit_term:toggle()
end, { desc = "lazygit" })

--------------------------------------------------------------------------
-- Код (LSP-хоткеи буфер-локальные, см. lua/plugins/lspconfig.lua)
--------------------------------------------------------------------------

map("n", "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Форматировать файл" })

map("n", "<leader>cd", function()
  vim.diagnostic.open_float({ border = "rounded" })
end, { desc = "Диагностика строки" })

map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = false })
end, { desc = "Следующая проблема" })

map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = false })
end, { desc = "Предыдущая проблема" })

map("n", "]e", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = false })
end, { desc = "Следующая ошибка" })

map("n", "[e", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = false })
end, { desc = "Предыдущая ошибка" })

--------------------------------------------------------------------------
-- Панель «Проблемы»
--------------------------------------------------------------------------

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Проблемы проекта" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Проблемы файла" })
map("n", "<leader>xs", "<cmd>Trouble symbols toggle<cr>", { desc = "Структура файла" })
map("n", "<leader>xl", "<cmd>Trouble lsp toggle<cr>", { desc = "Ссылки и определения" })
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Loclist" })

--------------------------------------------------------------------------
-- Поиск по файлам (Telescope)
--------------------------------------------------------------------------

local function tb(picker, opts)
  return function()
    require("telescope.builtin")[picker](opts)
  end
end

map("n", "<leader>ff", tb("find_files"), { desc = "Найти файл" })
map("n", "<leader>fg", tb("live_grep"), { desc = "Поиск по тексту" })
map("n", "<leader>fb", tb("buffers"), { desc = "Открытые буферы" })
map("n", "<leader>fh", tb("help_tags"), { desc = "Справка" })
map("n", "<leader>fr", tb("oldfiles"), { desc = "Недавние файлы" })
map("n", "<leader>fd", tb("diagnostics"), { desc = "Диагностика" })

--------------------------------------------------------------------------
-- Глобальный поиск и замена (grug-far)
--------------------------------------------------------------------------

map("n", "<leader>sr", function()
  require("grug-far").open()
end, { desc = "Найти и заменить в проекте" })

map("v", "<leader>sr", function()
  require("grug-far").with_visual_selection()
end, { desc = "Заменить выделенное в проекте" })

map("n", "<leader>sw", function()
  require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Заменить слово под курсором" })

map("n", "<leader>sf", function()
  require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Найти и заменить в файле" })

--------------------------------------------------------------------------
-- Буферы
--------------------------------------------------------------------------

map("n", "<leader>bd", function()
  local bufnr = vim.api.nvim_get_current_buf()

  local listed = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.buflisted(b) == 1 then
      table.insert(listed, b)
    end
  end

  if #listed <= 1 then
    vim.cmd("enew")
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
    return
  end

  for _, b in ipairs(listed) do
    if b ~= bufnr then
      vim.api.nvim_set_current_buf(b)
      break
    end
  end

  pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
end, { desc = "Закрыть буфер" })

map("n", "<leader>bo", function()
  local cur = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= cur and vim.bo[buf].buflisted then
      vim.api.nvim_buf_delete(buf, { force = false })
    end
  end
end, { desc = "Закрыть все кроме текущего" })

map("n", "<leader>bb", tb("buffers"), { desc = "Список буферов" })

map("n", "<leader><Left>", "<cmd>bprevious<cr>", { desc = "Предыдущий буфер" })
map("n", "<leader><Right>", "<cmd>bnext<cr>", { desc = "Следующий буфер" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Предыдущий буфер" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Следующий буфер" })

--------------------------------------------------------------------------
-- Терминал
--------------------------------------------------------------------------

map("n", "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", { desc = "Терминал (float)" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Терминал снизу" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Терминал справа" })

--------------------------------------------------------------------------
-- Файловое дерево
--------------------------------------------------------------------------

map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Проводник" })
map("n", "<leader>E", "<cmd>Neotree reveal<cr>", { desc = "Показать файл в проводнике" })

--------------------------------------------------------------------------
-- Тумблеры
--------------------------------------------------------------------------

-- Выключить перед чтением диффа агента, чтобы правки форматтера
-- не подмешивались в то, что ревьюишь
map("n", "<leader>uf", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  vim.notify("Автоформат: " .. (vim.g.disable_autoformat and "выключен" or "включён"))
end, { desc = "Тумблер автоформата" })

map("n", "<leader>ud", function()
  local enabled = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not enabled)
  vim.notify("Диагностика: " .. (enabled and "выключена" or "включена"))
end, { desc = "Тумблер диагностики" })

map("n", "<leader>ui", function()
  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
end, { desc = "Тумблер inlay hints" })

map("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify("Перенос строк: " .. (vim.wo.wrap and "включён" or "выключен"))
end, { desc = "Тумблер переноса строк" })

map("n", "<leader>ub", function()
  gs().toggle_current_line_blame()
end, { desc = "Тумблер blame строки" })

--------------------------------------------------------------------------
-- Markdown, yaml, LaTeX превью (Markview)
--------------------------------------------------------------------------

map("n", "<leader>m", "<cmd>Markview toggle<cr>", { desc = "Переключить режим Markview" })
