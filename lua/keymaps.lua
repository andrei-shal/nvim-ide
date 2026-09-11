-- Лидер клавиши
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local map = vim.keymap.set

-- Плагины подключаются внутри замыканий, а не на верхнем уровне: иначе
-- ленивая загрузка ломается и всё тянется на старте.
local function gs()
  return require("gitsigns")
end

-- База сравнения. По умолчанию — индекс: только при нём git позволяет
-- применять и откатывать отдельные ханки.
local bases = { nil, "HEAD", "HEAD~1" }
local base_names = { "индекс", "HEAD", "HEAD~1" }
local base_idx = 1

-- Возвращает gitsigns, только если он следит за текущим буфером.
-- Без этой проверки нажатие в окне проводника, в пустом буфере или в файле
-- вне git просто ничего не делало — молча, и выглядело как «git сломан».
local function gs_buf()
  if vim.b.gitsigns_status_dict ~= nil or vim.b.gitsigns_head ~= nil then
    return require("gitsigns")
  end

  local ft = vim.bo.filetype
  if ft == "neo-tree" then
    vim.notify("Это окно проводника — git-команды работают в окне файла (<leader>e вернёт в редактор)",
      vim.log.levels.WARN)
  elseif vim.bo.buftype ~= "" then
    vim.notify("Это служебное окно, а не файл", vim.log.levels.WARN)
  elseif vim.api.nvim_buf_get_name(0) == "" then
    vim.notify("Буфер без файла — открой файл", vim.log.levels.WARN)
  else
    vim.notify("Файл вне git-репозитория либо ещё не проиндексирован", vim.log.levels.WARN)
  end
  return nil
end

-- Применение и откат ханков требуют, чтобы базой был индекс.
local function stageable()
  if base_idx ~= 1 then
    vim.notify(
      "База диффа — " .. base_names[base_idx] .. ", при ней git не даёт менять ханки.\n"
        .. "Верни базу на «индекс» через <leader>gB",
      vim.log.levels.WARN
    )
    return false
  end
  return true
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
  local g = gs_buf()
  if g then g.diffthis("HEAD") end
end, { desc = "Дифф файла vs HEAD" })

-- Дифф относительно индекса: что ещё не застейджено
map("n", "<leader>gi", function()
  local g = gs_buf()
  if g then g.diffthis() end
end, { desc = "Дифф файла vs индекс" })

-- Панель со всеми изменёнными файлами: полный changeset агента.
-- Работает из любого окна — буфер не нужен.
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
    local g = gs_buf()
    if g then g.nav_hunk(direction, { wrap = true, preview = false }) end
  end
end

map("n", "]h", nav_hunk("next"), { desc = "Следующее изменение" })
map("n", "[h", nav_hunk("prev"), { desc = "Предыдущее изменение" })
map("n", "]c", nav_hunk("next"), { desc = "Следующее изменение" })
map("n", "[c", nav_hunk("prev"), { desc = "Предыдущее изменение" })

-- Превью ханка прямо в буфере, без отдельного окна
map("n", "<leader>gp", function()
  local g = gs_buf()
  if g then g.preview_hunk_inline() end
end, { desc = "Превью изменения инлайн" })

-- Применить / откатить ханк. В visual-режиме — только выделенные строки.
map("n", "<leader>gs", function()
  local g = gs_buf()
  if g and stageable() then g.stage_hunk() end
end, { desc = "Применить изменение (stage)" })

map("v", "<leader>gs", function()
  local g = gs_buf()
  if g and stageable() then g.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end
end, { desc = "Применить выделенное (stage)" })

map("n", "<leader>gr", function()
  local g = gs_buf()
  if g and stageable() then g.reset_hunk() end
end, { desc = "Откатить изменение" })

map("v", "<leader>gr", function()
  local g = gs_buf()
  if g and stageable() then g.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end
end, { desc = "Откатить выделенное" })

map("n", "<leader>gu", function()
  local g = gs_buf()
  if g and stageable() then g.undo_stage_hunk() end
end, { desc = "Отменить stage" })

map("n", "<leader>gS", function()
  local g = gs_buf()
  if g and stageable() then g.stage_buffer() end
end, { desc = "Применить весь файл" })

map("n", "<leader>gR", function()
  local g = gs_buf()
  if g and stageable() then g.reset_buffer() end
end, { desc = "Откатить весь файл" })

-- Режим ревью: подсветка изменённых строк целиком + посимвольная разница
-- + удалённые строки поверх буфера. Одной клавишей, потому что постоянно
-- держать это включённым в переписанном агентом файле нечитаемо.
local review_mode = false
map("n", "<leader>gv", function()
  local g = gs_buf()
  if not g then return end
  review_mode = not review_mode
  pcall(g.toggle_linehl, review_mode)
  pcall(g.toggle_word_diff, review_mode)
  pcall(g.toggle_deleted, review_mode)
  vim.notify("Режим ревью: " .. (review_mode and "включён" or "выключен"))
end, { desc = "Режим ревью (подсветка правок)" })

-- Смена базы. HEAD нужен, когда агент уже сделал git add и хочется видеть
-- всё разом; при этом ханки становятся доступны только для чтения.
map("n", "<leader>gB", function()
  local g = gs_buf()
  if not g then return end
  base_idx = base_idx % #base_names + 1
  g.change_base(bases[base_idx], true)
  if base_idx == 1 then
    vim.notify("База диффа: индекс — применение и откат ханков снова доступны")
  else
    vim.notify(
      "База диффа: " .. base_names[base_idx] .. " — только просмотр, ханки менять нельзя",
      vim.log.levels.WARN
    )
  end
end, { desc = "Сменить базу диффа" })

-- Blame
map("n", "<leader>gl", function()
  local g = gs_buf()
  if g then g.blame_line({ full = true }) end
end, { desc = "Blame строки" })

map("n", "<leader>gL", function()
  local g = gs_buf()
  if g then g.blame() end
end, { desc = "Blame всего файла" })

-- Все ханки репозитория одним списком: полный перечень того, что тронул агент
map("n", "<leader>gQ", function()
  local g = gs_buf()
  if not g then return end
  g.setqflist("all", { open = false }, function()
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

-- Переход в проводник и обратно.
-- Именно focus, а не toggle: проводник открыт почти всегда, и toggle из окна
-- файла его закрывал вместо того, чтобы перейти в него.
map("n", "<leader>e", function()
  if vim.bo.filetype == "neo-tree" then
    vim.cmd("wincmd p")
  else
    vim.cmd("Neotree focus")
  end
end, { desc = "Проводник (туда и обратно)" })

map("n", "<leader>E", "<cmd>Neotree reveal<cr>", { desc = "Показать файл в проводнике" })
-- Закрыть проводник — q внутри самого проводника (штатный хоткей neo-tree).
-- Отдельный <leader>e* здесь не вешаем: он сделал бы <leader>e тормозящим
-- на timeoutlen из-за общего префикса.

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

-- Выбор темы с живым предпросмотром, выбранная запоминается между сессиями
map("n", "<leader>ut", function()
  require("colorscheme").pick()
end, { desc = "Выбрать тему" })

map("n", "<leader>ug", function()
  -- enable()/disable() сами ведут поле enabled, выставлять его руками нельзя:
  -- enable() выходит сразу, если считает себя уже включённым
  local indent = require("snacks").indent
  if indent.enabled then
    indent.disable()
  else
    indent.enable()
  end
  vim.notify("Отступные линии: " .. (indent.enabled and "включены" or "выключены"))
end, { desc = "Тумблер отступных линий" })

--------------------------------------------------------------------------
-- Markdown, yaml, LaTeX превью (Markview)
--------------------------------------------------------------------------

map("n", "<leader>m", "<cmd>Markview toggle<cr>", { desc = "Переключить режим Markview" })
