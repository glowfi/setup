local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    })
    print("Installing packer close and reopen Neovim...")
    vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init({
    display = {
        open_fn = function()
            return require("packer.util").float({ border = "rounded" })
        end,
    },
})

-- Plugins
return require("packer").startup(function(use)
    -- Packer Plugin Manager
    use("wbthomason/packer.nvim")

    -- Utilities

    -- NNN File Manager
    use({ "mcchrish/nnn.vim", config = [[require('core.filemanager')]] })

    -- Fuzzy search
    use({
        "nvim-telescope/telescope.nvim",
        requires = {
            { "nvim-lua/popup.nvim" },
            { "nvim-lua/plenary.nvim" },
            { "nvim-telescope/telescope-fzy-native.nvim" },
        },
        config = [[require('core.telescope')]],
    })

    -- Git Integration
    use({
        "lewis6991/gitsigns.nvim",
        requires = { "nvim-lua/plenary.nvim" },
        config = [[require('core.gitsigns')]],
        event = "BufRead",
    })

    -- Code Runner
    use({
        "sbdchd/vim-run",
        config = [[require('core.coderunner')]],
        ft = { "javascript", "typescript", "python" },
    })

    -- Multi Cursor
    use({
        "mg979/vim-visual-multi",
        branch = "master",
        config = [[require('core.visualMulti')]],
    })

    -- Auto Comments
    use({
        "terrortylor/nvim-comment",
        config = [[require('core.comments')]],
        event = "BufRead",
    })

    -- Tabs
    use({
        "romgrk/barbar.nvim",
        requires = { "kyazdani42/nvim-web-devicons" },
        event = "BufRead",
        config = [[require('core.bufferline')]],
    })

    -- Colorizer
    use({
        "norcalli/nvim-colorizer.lua",
        ft = { "css", "javascript", "vim", "html", "cpp", "conf" },
        config = [[require('colorizer').setup {'css', 'javascript', 'vim', 'html','cpp','conf'}]],
    })

    -- Emmet
    -- use{'mattn/emmet-vim',ft={'javascript','javascriptreact','typescript','typescriptreact','htmldjango'}}

    -- Ricing

    -- Gruvbox theme
    use({
        "ellisonleao/gruvbox.nvim",
        requires = { "rktjmp/lush.nvim" },
        config = [[require('core.colorscheme')]],
    })

    -- Status line
    use({
        "hoob3rt/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons" },
        config = [[require('core.statusline')]],
        event = "BufWinEnter",
    })

    -- Devicons
    use({ "kyazdani42/nvim-web-devicons" })

    -- Dashboard
    use({
        "glepnir/dashboard-nvim",
        event = "BufWinEnter",
        config = [[require('core.dashboard')]],
    })

    -- Indentline
    use({
        "lukas-reineke/indent-blankline.nvim",
        event = "BufRead",
        setup = function()
            vim.g.indentLine_enabled = 1
            vim.g.indent_blankline_char = "▏"

            vim.g.indent_blankline_filetype_exclude = {
                "help",
                "terminal",
                "dashboard",
                "packer",
                "norg",
            }
            vim.g.indent_blankline_buftype_exclude = { "terminal" }

            vim.g.indent_blankline_show_trailing_blankline_indent = false
            vim.g.indent_blankline_show_first_indent_level = true
        end,
    })

    -- Treesitter integrations

    -- Treesitter
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = [[require('core.treesitter')]],
    })

    -- Treesitter text-objects
    use({ "nvim-treesitter/nvim-treesitter-textobjects" })

    -- Treesitter playground
    use({ "nvim-treesitter/playground" })

    -- Treesitter(integrated) Rainbow pairs
    use({ "p00f/nvim-ts-rainbow" })

    -- Bracket Matchup
    use({ "andymass/vim-matchup" })

    -- Smart Commenting for complex filetypes
    use({ "JoosepAlviste/nvim-ts-context-commentstring" })

    -- HTML Autotag and Autorename tags
    use({
        "windwp/nvim-ts-autotag",
        ft = {
            "html",
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "javascript.jsx",
            "typescript.tsx",
        },
    })

    --   Refactor
    use({
        "ThePrimeagen/refactoring.nvim",
        requires = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-treesitter/nvim-treesitter" },
            { "nvim-lua/popup.nvim" },
        },
        config = [[require('core.refactor')]],
    })

    -- Native LSP (ENGINE)

    --   Nvim native LSP
    use({ "neovim/nvim-lspconfig" })

    --   Auto completion
    use({
        "hrsh7th/nvim-cmp",
        after = "nvim-lspconfig",
        event = "InsertEnter *",
        config = [[require('lsp.cmp')]],
    })
    use({
        "hrsh7th/cmp-nvim-lsp",
        config = function()
            require("cmp_nvim_lsp").setup({})
        end,
    })
    use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
    use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })

    --   Snippet engine
    use({
        "hrsh7th/vim-vsnip",
        after = "nvim-cmp",
        event = "InsertCharPre",
        config = [[require('lsp.vsnip')]],
    })
    use({ "hrsh7th/cmp-vsnip", after = "nvim-cmp" })

    --   Signature popup on typing
    use({ "ray-x/lsp_signature.nvim", config = [[require('lsp.sigHelp')]] })

    --   Auto pairs
    use({
        "windwp/nvim-autopairs",
        after = "nvim-cmp",
        config = [[require('lsp.autopairs')]],
    })

    --   Null-ls
    use({ "jose-elias-alvarez/null-ls.nvim" })

    -- Languages Plugins

    --   Snippets
    use({ "rafamadriz/friendly-snippets", event = "InsertCharPre" })
    use({
        "dsznajder/vscode-es7-javascript-react-snippets",
        event = "InsertCharPre",
    })
    use({ "wyattferguson/jinja2-kit-vscode", event = "InsertCharPre" })

    --   Typescript
    use({
        "jose-elias-alvarez/nvim-lsp-ts-utils",
        ft = {
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "javascript.jsx",
            "typescript.tsx",
        },
    })

    --   Graphql
    use({ "jparise/vim-graphql", ft = { "graphql" } })

    -- Org
    use({ "nvim-neorg/neorg",
        config = [[require('core.neorg')]],
    })

    --   Markdown
    use({
        "iamcco/markdown-preview.nvim",
        run = "cd app && yarn install",
        ft = { "markdown" },
        config = [[require('core.mkdp')]],
        cmd = "MarkdownPreview",
    })
end)
