# nvim-config

Neovim configuration with LSP, completion, file tree, Git integration, and Russian-localized UI.

## Requirements

- Neovim >= 0.12
- `tar` and `curl` in PATH (for treesitter parser installation)
- C compiler (for treesitter parser compilation)
- [Nerd Font](https://www.nerdfonts.com/) (for icons in lualine, blink.cmp, neo-tree, bufferline)

## Plugins

| Plugin | Purpose |
|--------|---------|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [blink.cmp](https://github.com/Saghen/blink.cmp) | Autocompletion (LSP, path, snippets, buffer) |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Parser management and queries |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP client configurations |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | LSP server installer |
| [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | Bridge between Mason and lspconfig |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | File tree explorer |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Tabline with buffer management |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git decorations in the gutter |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keybinding help popup |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-close brackets and quotes |
| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Snippet collection |

## Keybindings

Leader key is `Space`.

### File operations

| Key | Action |
|-----|--------|
| `<leader>w` | Save file |
| `<leader>q` | Close window |

### LSP

| Key | Action |
|-----|--------|
| `<leader>ld` | Go to definition |
| `<leader>lr` | Find references |
| `<leader>d` | Show documentation (hover) |
| `<leader>ln` | Rename symbol |
| `<leader>la` | Code actions |

### Search (Telescope)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Open buffers |
| `<leader>fh` | Help tags |

### Git (Gitsigns)

| Key | Action |
|-----|--------|
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hR` | Reset buffer |
| `<leader>hp` | Preview hunk diff |
| `<leader>h<Down>` | Next hunk |
| `<leader>h<Up>` | Previous hunk |

### File tree (Neo-tree)

| Key | Action |
|-----|--------|
| `<leader>e` | Open file tree |
| `<leader>ec` | Close file tree |

### Tabs (Bufferline)

| Key | Action |
|-----|--------|
| `<leader><Left>` | Previous tab |
| `<leader><Right>` | Next tab |
| `<leader>x` | Close tab |
| `<leader>xo` | Close all tabs except current |

### Completion (blink.cmp)

| Key | Action |
|-----|--------|
| `Tab` | Accept completion |
| `Enter` | Accept completion |
| `Down` | Next item |
| `Up` | Previous item |
| `Esc` | Cancel completion |

## Installation

```bash
git clone https://github.com/andreishal/nvim-config.git ~/.config/nvim
nvim --headless "+Lazy! sync" +qa
```

On first start, lazy.nvim will bootstrap itself and install all plugins. Neo-tree opens automatically. Press `?` in Neo-tree for help, or press `<Space>e` to focus it.

## LSP servers

Add servers to `ensure_installed` in `lua/plugins/mason-lspconfig.lua`. They will be installed automatically by Mason and enabled via `vim.lsp.enable()`.

## Language support

Treesitter parsers are pre-installed for `lua`, `vim`, and `vimdoc`. Install more with `:TSInstall <language>`.

## UI Language

Interface labels and tooltips are in Russian.
