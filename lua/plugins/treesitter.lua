-- Парсеры подсветки. diff/gitcommit/git_rebase здесь не для галочки:
-- они красят буферы диффов и коммит-сообщений при ревью правок агента.
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({
      -- Конфиг и справка
      "lua", "vim", "vimdoc", "query",
      -- Системные языки
      "c", "cpp", "rust",
      -- Скриптовые
      "python", "bash",
      -- JVM
      "java",
      -- Веб
      "javascript", "typescript", "tsx", "html", "css",
      -- Данные и разметка
      "json", "yaml", "toml", "markdown", "markdown_inline",
      -- Git и диффы
      "diff", "gitcommit", "git_rebase",
      -- Прочее
      "regex", "dockerfile",
    })
  end,
}
