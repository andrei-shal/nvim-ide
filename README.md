# nvim-ide

Neovim-конфигурация с LSP, автодополнением, файловым деревом, Git-интеграцией и русским интерфейсом.

## Требования

- Neovim >= 0.12
- `tar` и `curl` в PATH (для установки парсеров treesitter)
- C-компилятор (для сборки парсеров treesitter)
- [Nerd Font](https://www.nerdfonts.com/) (для иконок в blink.cmp, neo-tree, heirline)

## Плагины

| Плагин | Назначение |
|--------|------------|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Менеджер плагинов |
| [blink.cmp](https://github.com/Saghen/blink.cmp) | Автодополнение (LSP, path, snippets, buffer) |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Управление парсерами и запросами |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Конфигурации LSP-клиентов (новый API `vim.lsp.enable`) |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | Установщик LSP-серверов |
| [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | Связка Mason и nvim-lspconfig |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | Файловое дерево |
| [heirline.nvim](https://github.com/rebelot/heirline.nvim) | Статуслайн + панель вкладок (замена lualine + bufferline) |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Нечёткий поиск |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git-декорации в gutter |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Подсказки по хоткеям |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Авто-закрытие скобок и кавычек |
| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Коллекция сниппетов |

## Хоткеи

Лидер-клавиша -- `Space`.

### Файлы

| Клавиша | Действие |
|---------|----------|
| `<leader>w` | Сохранить файл |
| `<leader>q` | Закрыть окно |

### LSP

| Клавиша | Действие |
|---------|----------|
| `<leader>ld` | Перейти к определению |
| `<leader>lr` | Найти использования |
| `<leader>d` | Показать документацию |
| `<leader>ln` | Переименовать |
| `<leader>la` | Действия с кодом |

### Поиск (Telescope)

| Клавиша | Действие |
|---------|----------|
| `<leader>ff` | Найти файл |
| `<leader>fg` | Поиск по тексту |
| `<leader>fb` | Открытые буферы |
| `<leader>fh` | Справка |

### Git (Gitsigns)

| Клавиша | Действие |
|---------|----------|
| `<leader>hs` | Добавить изменение |
| `<leader>hr` | Откатить изменение |
| `<leader>hS` | Добавить весь файл |
| `<leader>hR` | Откатить весь файл |
| `<leader>hp` | Показать изменения |
| `<leader>h<Down>` | Следующее изменение |
| `<leader>h<Up>` | Предыдущее изменение |

### Файловое дерево (Neo-tree)

| Клавиша | Действие |
|---------|----------|
| `<leader>e` | Открыть проводник |
| `<leader>ec` | Закрыть проводник |

### Буферы

| Клавиша | Действие |
|---------|----------|
| `<leader><Left>` | Предыдущий буфер |
| `<leader><Right>` | Следующий буфер |
| `<leader>x` | Закрыть буфер |
| `<leader>xo` | Закрыть все кроме текущего |

### Автодополнение (blink.cmp)

| Клавиша | Действие |
|---------|----------|
| `Tab` | Принять вариант |
| `Enter` | Принять вариант |
| `Down` | Следующий вариант |
| `Up` | Предыдущий вариант |
| `Esc` | Закрыть меню |

## Установка

```bash
git clone https://github.com/andrei-shal/nvim-ide.git ~/.config/nvim
nvim --headless "+Lazy! sync" +qa
```

При первом запуске lazy.nvim сам установится и загрузит все плагины. Neo-tree откроется автоматически. Нажми `?` внутри Neo-tree для справки или `<Space>e` для перехода в него.

## LSP-серверы

Серверы устанавливаются через Mason: добавь название в `ensure_installed` в `lua/plugins/mason-lspconfig.lua`.

Включаются через `vim.lsp.enable()` в `lua/plugins/lspconfig.lua`. Там же настраиваются специфичные параметры — например, `JDTLS_JVM_ARGS` для Lombok.

### Текущие серверы

| Язык | Сервер | Особенности |
|------|--------|-------------|
| Java | `jdtls` | Lombok-поддержка через `-javaagent` (Mason-пакет включает lombok.jar) |
| Python | `pyright` | — |
| C/C++ | `clangd` | — |

### Lombok

JDTLS работает с Lombok через `-javaagent`. Mason при установке jdtls автоматически скачивает `lombok.jar` в каталог пакета. В конфиге lspconfig выставляется `JDTLS_JVM_ARGS`, который встроенный конфиг jdtls конвертирует в `--jvm-arg=-javaagent:...`.

Если используешь Lombok в проекте, не забудь добавить зависимость в `pom.xml` или `build.gradle` — это нужно для компиляции, а LSP-поддержка работает отдельно.

## Поддержка языков

Парсеры treesitter предустановлены для:
- `lua`, `vim`, `vimdoc`
- `python`
- `c`, `cpp`
- `java`

Установить другие — `:TSInstall <язык>`.

## Интерфейс

Все подписи и подсказки на русском языке.
