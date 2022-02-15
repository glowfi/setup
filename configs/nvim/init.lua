-- Global Paths
CONFIG_PATH = vim.fn.stdpath("config")
DATA_PATH = vim.fn.stdpath("data")
CACHE_PATH = vim.fn.stdpath("cache")

-- General Settings
require("settings")
require("keymaps")

-- Plugins
require("plugins")

-- LSP
require("lsp")
