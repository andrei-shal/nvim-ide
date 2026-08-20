-- LSP-пайплайн на современном API Neovim 0.11+:
--   vim.lsp.config(name, {...})  — настройки сервера
--   vim.lsp.enable({...})        — включение
--   LspAttach                    — единые хоткеи для всех серверов
--
-- ВАЖНО: настройки серверов задаются ТОЛЬКО вызовами vim.lsp.config.
-- Файлы ~/.config/nvim/lsp/<name>.lua здесь не сработали бы: Neovim мержит все
-- lsp/<name>.lua по runtimepath через tbl_deep_extend("force", ...), где побеждает
-- ПОСЛЕДНИЙ, а каталог конфига идёт в rtp раньше плагинов — то есть версия из
-- nvim-lspconfig перезатёрла бы нашу. Вызов vim.lsp.config кладётся в отдельную
-- таблицу и применяется после всего (:h vim.lsp.config).
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- mason должен успеть прописать свой bin в $PATH до vim.lsp.enable
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    "b0o/SchemaStore.nvim",
  },
  config = function()
    local mason_root = vim.fn.stdpath("data") .. "/mason"

    ------------------------------------------------------------------
    -- Диагностика
    ------------------------------------------------------------------
    vim.diagnostic.config({
      -- virtual_text выключен: за инлайн-отображение отвечает
      -- tiny-inline-diagnostic.nvim
      virtual_text = false,
      severity_sort = true,
      underline = true,
      update_in_insert = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN]  = " ",
          [vim.diagnostic.severity.INFO]  = " ",
          [vim.diagnostic.severity.HINT]  = " ",
        },
      },
      float = {
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
      },
    })

    ------------------------------------------------------------------
    -- Java: jdtls
    -- Собственный cmd вместо встроенного, чтобы:
    --   * не зависеть от $PATH (абсолютный путь к бинарю Mason)
    --   * держать отдельный workspace на каждый проект
    --   * подключать lombok ТОЛЬКО если jar реально скачан — иначе JVM
    --     с несуществующим -javaagent не стартует вообще
    ------------------------------------------------------------------
    local jdtls_bin = mason_root .. "/bin/jdtls"
    local lombok_jar = mason_root .. "/packages/jdtls/lombok.jar"

    vim.lsp.config("jdtls", {
      cmd = function(dispatchers, config)
        local root = config.root_dir or vim.fn.getcwd()
        local workspace = vim.fn.stdpath("cache")
          .. "/jdtls/"
          .. vim.fn.fnamemodify(root, ":p:h:t")

        local cmd = {
          vim.uv.fs_stat(jdtls_bin) and jdtls_bin or "jdtls",
          "-data",
          workspace,
          "--jvm-arg=-Xmx2g",
          "--jvm-arg=-XX:+UseParallelGC",
        }

        if vim.uv.fs_stat(lombok_jar) then
          table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok_jar)
        end

        return vim.lsp.rpc.start(cmd, dispatchers, {
          cwd = config.cmd_cwd,
          env = config.cmd_env,
          detached = config.detached,
        })
      end,
      settings = {
        java = {
          signatureHelp = { enabled = true },
          contentProvider = { preferred = "fernflower" },
          format = { enabled = true },
          completion = {
            favoriteStaticMembers = {
              "org.junit.Assert.*",
              "org.junit.jupiter.api.Assertions.*",
              "org.mockito.Mockito.*",
              "java.util.Objects.requireNonNull",
            },
          },
          sources = {
            organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
          },
          inlayHints = { parameterNames = { enabled = "all" } },
          configuration = { updateBuildConfiguration = "interactive" },
        },
      },
      init_options = { bundles = {} },
    })

    ------------------------------------------------------------------
    -- TypeScript / JavaScript / React / Next.js
    ------------------------------------------------------------------
    local ts_inlay_hints = {
      includeInlayParameterNameHints = "literal",
      includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = false,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    }

    vim.lsp.config("ts_ls", {
      settings = {
        typescript = {
          inlayHints = ts_inlay_hints,
          preferences = { importModuleSpecifier = "non-relative" },
        },
        javascript = {
          inlayHints = ts_inlay_hints,
        },
      },
    })

    -- eslint отдельным сервером поверх ts_ls: правила проекта видны как
    -- диагностика. Автофикс на сохранение не вешаем — конфликтует с prettier
    -- в conform.nvim. Правится вручную через :EslintFixAll.
    vim.lsp.config("eslint", {
      settings = {
        workingDirectories = { mode = "auto" },
      },
    })

    ------------------------------------------------------------------
    -- Rust
    ------------------------------------------------------------------
    vim.lsp.config("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true, buildScripts = { enable = true } },
          procMacro = { enable = true },
          check = { command = "clippy" },
          inlayHints = {
            parameterHints = { enable = true },
            typeHints = { enable = true },
          },
        },
      },
    })

    ------------------------------------------------------------------
    -- C / C++
    ------------------------------------------------------------------
    vim.lsp.config("clangd", {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders=1",
      },
    })

    ------------------------------------------------------------------
    -- Tailwind CSS
    -- Встроенный root_dir считает корнем в том числе .git (фолбэк под
    -- Tailwind v4), из-за чего сервер поднимается в КАЖДОМ git-репозитории.
    -- Требуем настоящий признак Tailwind.
    ------------------------------------------------------------------
    vim.lsp.config("tailwindcss", {
      root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        if fname == "" then
          return
        end

        local markers = {
          "tailwind.config.js", "tailwind.config.cjs",
          "tailwind.config.mjs", "tailwind.config.ts",
          "postcss.config.js", "postcss.config.cjs",
          "postcss.config.mjs", "postcss.config.ts",
        }

        local found = vim.fs.find(markers, { path = fname, upward = true })[1]
        if found then
          on_dir(vim.fs.dirname(found))
          return
        end

        -- Tailwind v4 обходится без конфига — ищем зависимость в package.json
        local pkg = vim.fs.find("package.json", { path = fname, upward = true })[1]
        if pkg then
          local ok, content = pcall(vim.fn.readfile, pkg)
          if ok and table.concat(content, "\n"):find("tailwindcss", 1, true) then
            on_dir(vim.fs.dirname(pkg))
          end
        end
      end,
    })

    ------------------------------------------------------------------
    -- JSON: схемы для package.json, tsconfig.json, .eslintrc и ~1000 других
    ------------------------------------------------------------------
    vim.lsp.config("jsonls", {
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    })

    ------------------------------------------------------------------
    -- Lua: для правки самого этого конфига
    ------------------------------------------------------------------
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
          hint = { enable = true },
        },
      },
    })

    ------------------------------------------------------------------
    -- Включение
    ------------------------------------------------------------------
    vim.lsp.enable({
      "rust_analyzer",   -- Rust
      "clangd",          -- C / C++
      "pyright",         -- Python
      "ts_ls",           -- TypeScript / JavaScript / JSX / TSX
      "eslint",          -- линтер для JS/TS-проектов
      "jdtls",           -- Java
      "html",            -- HTML
      "cssls",           -- CSS
      "tailwindcss",     -- Tailwind (подключается только в проектах с конфигом)
      "jsonls",          -- JSON
      "marksman",        -- Markdown
      "lua_ls",          -- Lua
    })

    ------------------------------------------------------------------
    -- Единые хоткеи в стиле VS Code — на любой прикреплённый сервер
    ------------------------------------------------------------------
    local hl_group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = true })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("LspAttachKeymaps", { clear = true }),
      callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end

        -- Neovim 0.11 по умолчанию занимает префикс gr (grn, gra, grr, gri,
        -- grt, grx). Наш `gr` из-за этого ждал бы timeoutlen на каждое
        -- нажатие. Снимаем дефолты — их функции покрыты хоткеями ниже.
        for _, lhs in ipairs({ "grn", "gra", "grr", "gri", "grt", "grx" }) do
          pcall(vim.keymap.del, "n", lhs)
        end
        pcall(vim.keymap.del, "v", "gra")
        pcall(vim.keymap.del, "x", "gra")

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end

        -- Навигация
        map("n", "gd", vim.lsp.buf.definition, "Перейти к определению")
        map("n", "gD", vim.lsp.buf.declaration, "Перейти к объявлению")
        map("n", "gy", vim.lsp.buf.type_definition, "Перейти к типу")
        map("n", "gi", vim.lsp.buf.implementation, "Перейти к реализации")
        map("n", "gr", vim.lsp.buf.references, "Найти использования")

        -- Документация
        map("n", "K", function()
          vim.lsp.buf.hover({ border = "rounded" })
        end, "Документация")
        map("n", "gh", function()
          vim.lsp.buf.signature_help({ border = "rounded" })
        end, "Сигнатура функции")
        map("i", "<C-k>", function()
          vim.lsp.buf.signature_help({ border = "rounded" })
        end, "Сигнатура функции")

        -- Правки
        map("n", "<leader>rn", vim.lsp.buf.rename, "Переименовать")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Действия с кодом")

        -- Символы
        map("n", "<leader>ss", function()
          require("telescope.builtin").lsp_document_symbols()
        end, "Символы документа")
        map("n", "<leader>sS", function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols()
        end, "Символы воркспейса")

        -- Inlay hints
        if client:supports_method("textDocument/inlayHint", bufnr) then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          map("n", "<leader>ci", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
          end, "Тумблер inlay hints")
        end

        -- Подсветка всех вхождений символа под курсором
        if client:supports_method("textDocument/documentHighlight", bufnr) then
          vim.api.nvim_clear_autocmds({ group = hl_group, buffer = bufnr })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = hl_group,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = hl_group,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
      group = vim.api.nvim_create_augroup("LspDetachCleanup", { clear = true }),
      callback = function(args)
        vim.api.nvim_clear_autocmds({ group = hl_group, buffer = args.buf })
        vim.lsp.buf.clear_references()
      end,
    })
  end,
}
