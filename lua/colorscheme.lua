-- Выбор темы с сохранением между сессиями.
-- Выбранная тема пишется в stdpath("state")/colorscheme при выходе и
-- применяется при следующем запуске.
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

function M.save()
  pcall(vim.fn.writefile, { vim.g.colors_name or fallback }, state_file)
end

--- Выбор темы с живым предпросмотром.
function M.pick()
  require("telescope.builtin").colorscheme({ enable_preview = true })
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("colorscheme_persist", { clear = true }),
  callback = M.save,
})

return M
