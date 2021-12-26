-- Settings
local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then return end

configs.setup {

    -- Treesitter
    ensure_installed = "maintained",
    highlight = {enable = true, additional_vim_regex_highlighting = true},
    incremental_selection = {
        enable = true,
        disable = {"cpp", "lua"},
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm"
        }
    },

    -- Rainbow-pairs
    rainbow = {enable = true, extended_mode = true, max_file_lines = 1000},

    -- Textobjects
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner"
            }
        }
    },

    -- Matchup
    matchup = {enable = true},

    -- Autotag/Auto Rename HTML Tags
    autotag = {
        enable = true,
        filetypes = {
            'html', 'javascript', 'typescript', 'javascriptreact',
            'typescriptreact'
        }
    },

    -- Smart Commenting
    context_commentstring = {enable = true, enable_autocmd = false}
}

-- Matchup
vim.cmd "let g:matchup_surround_enabled = 1"
vim.g.matchup_matchparen_offscreen = {method = 'popup'}
