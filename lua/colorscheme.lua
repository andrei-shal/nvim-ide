-- Выбор темы с сохранением между сессиями.
--
-- Сохраняется имя, переданное в :colorscheme (<amatch> события ColorScheme),
-- а не vim.g.colors_name: rose-pine и kanagawa пишут туда имя без варианта,
-- и выбранная rose-pine-moon после перезапуска превращалась в rose-pine.
--
-- Пишется только при смене темы уже после старта, а не на выходе. Иначе
-- любой запуск, где сохранённая тема не применилась и сработал откат на
-- cyberdream, молча затирал выбор пользователя.
local M = {}

local state_file = vim.fn.stdpath("state") .. "/colorscheme"
local fallback = "cyberdream"

--- Тема, выбранная в прошлый раз.
--- @return string
function M.saved()
  local ok, lines = pcall(vim.fn.readfile, state_file)
  if ok and lines[1] and lines[1] ~= "" then
    return lines[1]
  end
  return fallback
end

--- Применить тему, с откатом на cyberdream, если её нет.
--- @param name string|nil
function M.apply(name)
  name = name or M.saved()
  if not pcall(vim.cmd.colorscheme, name) then
    pcall(vim.cmd.colorscheme, fallback)
  end
end

--- Выбор темы с живым предпросмотром.
function M.pick()
  require("telescope.builtin").colorscheme({ enable_preview = true })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("colorscheme_persist", { clear = true }),
  callback = function(args)
    -- тема, применённая при старте, — это уже сохранённая (или откат)
    if vim.v.vim_did_enter ~= 1 or not args.match or args.match == "" then
      return
    end
    pcall(vim.fn.writefile, { args.match }, state_file)
  end,
})

return M
