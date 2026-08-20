-- Глобальный поиск и замена на ripgrep, с живым превью диффа замены.
return {
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar", "GrugFarWithin" },
  opts = {
    headerMaxWidth = 80,
    keymaps = {
      replace = { n = "<localleader>r" },
      qflist = { n = "<localleader>q" },
      close = { n = "q" },
    },
  },
}
