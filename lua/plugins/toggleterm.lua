-- Встроенный терминал + lazygit во float-окне (без отдельного плагина под lazygit).
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm", "TermExec" },
  keys = { [[<C-\>]] },
  opts = {
    open_mapping = [[<C-\>]],
    direction = "float",
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
    float_opts = { border = "rounded" },
    shade_terminals = false,
    start_in_insert = true,
    persist_size = true,
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    -- Выход из terminal-mode двойным Esc
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*toggleterm#*",
      callback = function(args)
        local o = { buffer = args.buf, silent = true }
        vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], o)
        vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], o)
        vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], o)
        vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], o)
        vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], o)
      end,
    })
  end,
}
