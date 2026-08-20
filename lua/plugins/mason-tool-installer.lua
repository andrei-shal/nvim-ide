-- mason.nvim v2 не умеет ensure_installed для не-LSP-инструментов,
-- поэтому форматтеры ставим отдельно. Здесь же определяется :MasonInstallAll —
-- одна команда, которая доустанавливает и серверы, и форматтеры.
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "mason-org/mason.nvim" },
  -- cmd, а не только event: :MasonInstallAll должна существовать сразу после
  -- установки конфига, до того как что-либо успеет прогреться
  cmd = { "MasonInstallAll", "MasonToolsInstall", "MasonToolsUpdate" },
  event = "VeryLazy",
  opts = {
    ensure_installed = {
      "stylua",
      "prettierd",
      "prettier",
      "ruff",
      "clang-format",
    },
    run_on_start = false,
    auto_update = false,
  },
  config = function(_, opts)
    require("mason-tool-installer").setup(opts)

    vim.api.nvim_create_user_command("MasonInstallAll", function()
      -- LSP-серверы из ensure_installed в mason-lspconfig
      local ok, ensure = pcall(require, "mason-lspconfig.features.ensure_installed")
      if ok then
        require("mason-registry").refresh(vim.schedule_wrap(ensure))
      end
      -- Форматтеры из ensure_installed выше
      vim.cmd("MasonToolsInstall")
      vim.notify("Установка LSP-серверов и форматтеров запущена, прогресс — в :Mason", vim.log.levels.INFO)
    end, { desc = "Установить все LSP-серверы и форматтеры" })
  end,
}
