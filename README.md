# nvim-ide

Neovim-конфигурация: терминальная IDE для мультиязыковой разработки с уклоном в **агентное ревью** — код пишут ИИ-агенты (Claude Code, opencode), человек читает дифф и применяет или откатывает изменения.

Языки: Rust, C/C++, Python, TypeScript/JavaScript (React, Next.js), Java, HTML, CSS, JSON, Markdown, Lua.

Интерфейс на русском языке.

---

## Ревью правок агента

Главный сценарий, под который заточен конфиг. Агент отработал — дальше:

| Шаг | Клавиша | Что происходит |
|-----|---------|----------------|
| 1. Посмотреть весь changeset | `<leader>gD` | Панель со списком всех изменённых файлов слева, side-by-side дифф справа. `<Tab>` — следующий файл |
| 2. Дифф конкретного файла | `<leader>gd` | Вертикальный сплит: слева версия из HEAD, справа текущая. Изменения подсвечены построчно и посимвольно |
| 3. Пройти по правкам | `]h` / `[h` | Прыжок к следующему / предыдущему изменению |
| 4. Разглядеть одно изменение | `<leader>gp` | Ханк разворачивается прямо в буфере, без отдельного окна |
| 5. Принять или откатить | `<leader>gs` / `<leader>gr` | Ханк уходит в stage либо откатывается. В visual-режиме работает по выделенным строкам |
| 6. Если нужна подсветка всего | `<leader>gv` | Режим ревью: изменённые строки подсвечиваются целиком, разница внутри строки — посимвольно, удалённые строки показываются поверх буфера |

Плюс, когда нужно:

- `<leader>gm` — дифф всей ветки относительно `main`/`master`. Ревью работы агента целиком, а не последнего прогона.
- `<leader>gQ` — все изменения репозитория одним списком в панели проблем.
- `<leader>gg` — lazygit во float-окне: интерактивный rebase, откат коммитов агента.

### Базы сравнения

По умолчанию gitsigns сравнивает файл с **индексом**. Если агент выполнил `git add`, эти изменения перестают считаться «незастейдженными» — но не пропадают: они показываются отдельными знаками (`┋` вместо `┃`).

Когда нужно видеть всё разом относительно последнего коммита — `<leader>gB` переключает базу по кругу: **индекс → HEAD → HEAD~1**. При базе, отличной от индекса, gitsigns не даёт применять и откатывать ханки — это ограничение самого git, поэтому база по умолчанию именно индекс.

### Файлы, изменённые снаружи

Агент правит файлы на диске, пока они открыты в буферах. Конфиг перечитывает их автоматически (`autoread` + `checktime` на смену фокуса и `CursorHold`) и показывает уведомление. Без этого буфер держал бы устаревший текст, а дифф считался бы по старому содержимому.

---

## Требования

- Neovim >= 0.11 (проверено на 0.12)
- `git`, `curl`, `tar`
- C-компилятор — для сборки парсеров treesitter
- [Nerd Font](https://www.nerdfonts.com/) — иконки в blink.cmp, neo-tree, heirline, диагностике
- [ripgrep](https://github.com/BurntSushi/ripgrep) >= 14 — поиск по проекту и глобальная замена
- [lazygit](https://github.com/jesseduffield/lazygit) — опционально, для `<leader>gg`
- Node.js — для ts_ls, eslint, prettier, marksman
- JDK 17+ — для jdtls
- Rust toolchain — для rust-analyzer и rustfmt

```bash
# Arch
sudo pacman -S neovim git ripgrep lazygit nodejs npm jdk-openjdk

# macOS
brew install neovim git ripgrep lazygit node openjdk

# rustfmt ставится не через Mason, а компонентом rustup
rustup component add rustfmt rust-src
```

`rust-src` нужен, чтобы rust-analyzer видел стандартную библиотеку — без него он ругается `can't load standard library`.

---

## Установка

```bash
git clone https://github.com/andrei-shal/nvim-ide.git ~/.config/nvim
nvim --headless "+Lazy! sync" +qa
```

Затем один раз внутри Neovim:

```vim
:MasonInstallAll
```

Команда доустанавливает все LSP-серверы и форматтеры. Прогресс — в `:Mason`, там же список установленного.

Парсеры treesitter ставятся автоматически при первом запуске, это занимает пару минут.

Проверка после установки:

```vim
:Lazy            " все плагины без ошибок
:Mason           " серверы и форматтеры установлены
:checkhealth     " общая диагностика
```

---

## Хоткеи

Лидер-клавиша — `Space`.

### Git и диффы — `<leader>g`

| Клавиша | Действие |
|---------|----------|
| `<leader>gd` | Дифф текущего файла относительно HEAD, в сплите |
| `<leader>gi` | Дифф относительно индекса (что ещё не в stage) |
| `<leader>gD` | Панель диффа: все изменённые файлы |
| `<leader>gm` | Дифф всей ветки относительно main/master |
| `<leader>gf` | История текущего файла |
| `<leader>gF` | История репозитория |
| `]h` / `[h` | Следующее / предыдущее изменение (`]c` / `[c` — то же) |
| `<leader>gp` | Превью изменения инлайн |
| `<leader>gs` | Применить изменение (stage). В visual — выделенные строки |
| `<leader>gr` | Откатить изменение. В visual — выделенные строки |
| `<leader>gu` | Отменить stage |
| `<leader>gS` | Применить весь файл |
| `<leader>gR` | Откатить весь файл |
| `<leader>gv` | Режим ревью: подсветка изменённых строк |
| `<leader>gB` | Сменить базу диффа: индекс → HEAD → HEAD~1 |
| `<leader>gl` | Blame текущей строки |
| `<leader>gL` | Blame всего файла |
| `<leader>gQ` | Все изменения репозитория списком |
| `<leader>gg` | lazygit |

### LSP

Хоткеи буфер-локальные, вешаются автоматически на любой прикреплённый сервер.

| Клавиша | Действие |
|---------|----------|
| `gd` | Перейти к определению |
| `gD` | Перейти к объявлению |
| `gy` | Перейти к типу |
| `gi` | Перейти к реализации |
| `gr` | Найти использования |
| `K` | Показать документацию |
| `gh` | Сигнатура функции (`<C-k>` в режиме вставки) |
| `<leader>rn` | Переименовать |
| `<leader>ca` | Действия с кодом (работает и в visual) |
| `<leader>ss` | Символы документа |
| `<leader>sS` | Символы воркспейса |
| `<leader>ci` | Тумблер inlay hints |

### Код и диагностика — `<leader>c`

| Клавиша | Действие |
|---------|----------|
| `<leader>cf` | Форматировать файл |
| `<leader>cd` | Диагностика текущей строки |
| `]d` / `[d` | Следующая / предыдущая проблема |
| `]e` / `[e` | Следующая / предыдущая ошибка |

### Панель проблем — `<leader>x`

| Клавиша | Действие |
|---------|----------|
| `<leader>xx` | Проблемы всего проекта |
| `<leader>xX` | Проблемы текущего файла |
| `<leader>xs` | Структура файла (outline) |
| `<leader>xl` | Ссылки и определения |
| `<leader>xq` | Quickfix |
| `<leader>xL` | Loclist |

### Файлы — `<leader>f`

| Клавиша | Действие |
|---------|----------|
| `<leader>ff` | Найти файл |
| `<leader>fg` | Поиск по тексту |
| `<leader>fb` | Открытые буферы |
| `<leader>fr` | Недавние файлы |
| `<leader>fd` | Диагностика списком |
| `<leader>fh` | Справка |

### Поиск и замена — `<leader>s`

| Клавиша | Действие |
|---------|----------|
| `<leader>sr` | Найти и заменить в проекте (в visual — по выделению) |
| `<leader>sw` | Заменить слово под курсором |
| `<leader>sf` | Найти и заменить в текущем файле |

Внутри окна замены: `\r` — выполнить замену, `\q` — выгрузить результаты в quickfix, `q` — закрыть (локальная лидер-клавиша — `\`).

### Буферы — `<leader>b`

| Клавиша | Действие |
|---------|----------|
| `<leader>bd` | Закрыть буфер |
| `<leader>bo` | Закрыть все кроме текущего |
| `<leader>bb` | Список буферов |
| `<leader><Left>` / `<leader><Right>` | Предыдущий / следующий буфер |
| `Shift-h` / `Shift-l` | То же самое |

### Терминал — `<leader>t`

| Клавиша | Действие |
|---------|----------|
| `Ctrl-\` | Терминал во float-окне |
| `<leader>tt` | Терминал во float-окне |
| `<leader>th` | Терминал снизу |
| `<leader>tv` | Терминал справа |
| `Esc Esc` | Выйти из режима терминала |
| `Ctrl-h/j/k/l` | Перейти в соседнее окно прямо из терминала |

### Тумблеры — `<leader>u`

| Клавиша | Действие |
|---------|----------|
| `<leader>uf` | Автоформат по сохранению |
| `<leader>ud` | Диагностика |
| `<leader>ui` | Inlay hints |
| `<leader>uw` | Перенос длинных строк |
| `<leader>ub` | Blame текущей строки |

### Прочее

| Клавиша | Действие |
|---------|----------|
| `<leader>w` / `Ctrl-s` | Сохранить файл |
| `<leader>W` | Сохранить все |
| `<leader>q` | Закрыть окно |
| `<leader>e` | Проводник |
| `<leader>E` | Показать текущий файл в проводнике |
| `<leader>m` | Переключить превью Markdown |
| `Ctrl-h/j/k/l` | Перемещение между окнами |
| `Esc` | Снять подсветку поиска |

### Автодополнение

| Клавиша | Действие |
|---------|----------|
| `Tab` | Принять вариант / прыжок по сниппету |
| `Shift-Tab` | Назад по сниппету |
| `Enter` | Принять вариант |
| `Up` / `Down` | Предыдущий / следующий вариант |
| `Esc` | Закрыть меню |
| `Ctrl-Space` | Показать меню / документацию |
| `Ctrl-b` / `Ctrl-f` | Прокрутка документации |

---

## Миграция хоткеев

Раскладка переразмечена по образцу VS Code. Что изменилось:

| Было | Стало |
|------|-------|
| `<leader>ld` | `gd` |
| `<leader>lr` | `gr` |
| `<leader>d` | `K` |
| `<leader>ln` | `<leader>rn` |
| `<leader>la` | `<leader>ca` |
| `<leader>hs` | `<leader>gs` |
| `<leader>hr` | `<leader>gr` |
| `<leader>hS` | `<leader>gS` |
| `<leader>hR` | `<leader>gR` |
| `<leader>hp` | `<leader>gp` |
| `<leader>h<Down>` | `]h` |
| `<leader>h<Up>` | `[h` |
| `<leader>x` | `<leader>bd` |
| `<leader>xo` | `<leader>bo` |
| `<leader>ec` | `<leader>e` (стал тумблером) |

Префикс `<leader>x` теперь занят панелью проблем, `<leader>h` освободился.

---

## LSP-серверы

Серверы включаются в `lua/plugins/lspconfig.lua` через `vim.lsp.enable()`, список для установки — в `lua/plugins/mason-lspconfig.lua`.

| Язык | Сервер | Пакет Mason |
|------|--------|-------------|
| Rust | `rust_analyzer` | `rust-analyzer` |
| C / C++ | `clangd` | `clangd` |
| Python | `pyright` | `pyright` |
| TypeScript / JavaScript / JSX / TSX | `ts_ls` | `typescript-language-server` |
| JS/TS-линтинг | `eslint` | `eslint-lsp` |
| Tailwind CSS | `tailwindcss` | `tailwindcss-language-server` |
| Java | `jdtls` | `jdtls` |
| HTML | `html` | `html-lsp` |
| CSS | `cssls` | `css-lsp` |
| JSON | `jsonls` | `json-lsp` |
| Markdown | `marksman` | `marksman` |
| Lua | `lua_ls` | `lua-language-server` |

Проверить, что прикрепилось к текущему файлу — `:checkhealth vim.lsp`.

### Особенности

**Настройки задаются только через `vim.lsp.config(name, {...})`.** Файлы `~/.config/nvim/lsp/<name>.lua` для этого не годятся: Neovim мержит все такие файлы по runtimepath, где побеждает последний, а каталог конфига идёт в rtp раньше плагинов — версия из nvim-lspconfig просто перезатёрла бы вашу.

**Java.** `jdtls` запускается с отдельным workspace на каждый проект в `~/.cache/nvim/jdtls/<имя-проекта>`. Lombok подключается через `-javaagent`, но только если `lombok.jar` реально скачан Mason'ом — иначе JVM с несуществующим агентом не стартует вообще.

**Tailwind.** Встроенный в nvim-lspconfig поиск корня считает признаком Tailwind в том числе `.git`, из-за чего сервер поднимался бы в каждом репозитории. Здесь требуется настоящий признак: `tailwind.config.*`, `postcss.config.*` или зависимость `tailwindcss` в `package.json`.

**ESLint.** Работает поверх `ts_ls`, правила проекта видны как диагностика. Автофикс на сохранение не вешается — конфликтовал бы с prettier. Правится вручную через `:EslintFixAll`.

---

## Форматирование

[conform.nvim](https://github.com/stevearc/conform.nvim) форматирует файл при сохранении, с откатом на форматирование средствами LSP.

| Язык | Форматтер |
|------|-----------|
| Lua | stylua |
| Python | ruff |
| Rust | rustfmt |
| C / C++ | clang-format |
| JS / TS / JSX / TSX / JSON / CSS / HTML / YAML / Markdown | prettierd, с откатом на prettier |
| Java | не форматируется |

Java исключена намеренно: форматирование через jdtls медленное и требует отдельного профиля.

`<leader>uf` выключает автоформат на лету. Это стоит делать перед чтением агентского диффа — иначе правки форматтера подмешиваются в то, что вы ревьюите. `<leader>cf` форматирует вручную.

---

## Плагины

| Плагин | Назначение |
|--------|------------|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Менеджер плагинов |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Знаки изменений, инлайн-дифф, работа с ханками, blame |
| [diffview.nvim](https://github.com/sindrets/diffview.nvim) | Панель диффа по всему changeset'у, история файлов |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Конфигурации LSP-клиентов |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | Установщик серверов и инструментов |
| [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | Связка Mason и nvim-lspconfig |
| [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Установка форматтеров, команда `:MasonInstallAll` |
| [SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim) | JSON-схемы для package.json, tsconfig и ~1000 других |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Форматирование по сохранению |
| [trouble.nvim](https://github.com/folke/trouble.nvim) | Панель проблем, структура файла |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Встроенный терминал, lazygit во float |
| [grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim) | Глобальный поиск и замена с превью |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Нечёткий поиск |
| [blink.cmp](https://github.com/Saghen/blink.cmp) | Автодополнение с документацией и сигнатурами |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Парсеры подсветки |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | Файловое дерево |
| [heirline.nvim](https://github.com/rebelot/heirline.nvim) | Статуслайн и панель вкладок |
| [tiny-inline-diagnostic.nvim](https://github.com/rachartier/tiny-inline-diagnostic.nvim) | Инлайн-диагностика в стиле powerline |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Подсказки по хоткеям |
| [markview.nvim](https://github.com/OXY2DEV/markview.nvim) | Превью Markdown / YAML / LaTeX в буфере |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Авто-закрытие скобок |
| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Коллекция сниппетов |
| [cyberdream.nvim](https://github.com/scottmckendry/cyberdream.nvim) | Цветовая схема |

---

## Диагностика

Виртуальный текст отключён — вместо него [tiny-inline-diagnostic.nvim](https://github.com/rachartier/tiny-inline-diagnostic.nvim) показывает сообщения инлайн в стиле powerline: все уровни серьёзности, отображение в режимах вставки и выделения, несколько сообщений на строке, мультилайн.

Диагностика обновляется прямо во время набора текста (`update_in_insert`).

---

## Интерфейс

Статуслайн: режим (НАВИГАЦИЯ, РЕДАКТИР, ВЫДЕЛЕНИЕ и др.), иконка и имя файла, git-ветка, **счётчик правок `+N ~N -N` относительно git**, активные LSP-серверы, количество ошибок и предупреждений, позиция курсора.

Панель вкладок кликабельна: левый клик переключает буфер, средний закрывает. Скрывается, когда открыт один буфер.

Все плавающие окна с единой скруглённой рамкой (`winborder`).

---

## Структура

```
init.lua                    загрузка lazy.nvim и модулей
lua/options.lua             настройки редактора, качество диффов
lua/keymaps.lua             глобальные хоткеи
lua/autocmds.lua            автокоманды, перечитывание файлов
lua/plugins/*.lua           по файлу на плагин
```

---

## Проверка после установки

**Диффы**

1. В любом git-репозитории измените файл и откройте его.
2. `<leader>gd` — открылся сплит с версией из HEAD, изменения подсвечены.
3. `]h` / `[h` — курсор прыгает по изменениям.
4. `<leader>gp` — изменение разворачивается инлайн.
5. `<leader>gs` — знак меняется на staged (`┋`); `<leader>gu` возвращает обратно.
6. `<leader>gv` — включилась подсветка изменённых строк, повторное нажатие выключает.
7. `<leader>gD` — панель со всеми изменёнными файлами.
8. Измените открытый файл извне (`echo x >> файл`) — буфер перечитается с уведомлением.

**LSP**

Откройте по файлу каждого типа и в каждом выполните `:checkhealth vim.lsp` — сервер из таблицы выше должен быть прикреплён. Затем: `gd` прыгает к определению, `K` показывает документацию, `gr` находит использования, `]d` ходит по проблемам, `<leader>xx` открывает панель проблем.

Java проверяется в проекте с `pom.xml` или `build.gradle` — workspace появится в `~/.cache/nvim/jdtls/`.

**Форматирование**

Сохраните `.ts` с кривыми отступами — prettier выправит. Сохраните `.java` — файл останется как есть. `<leader>uf` — сохранение перестаёт форматировать.
