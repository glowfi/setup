-- Highlight color
local highlight = {
	"RainbowRed",
	"RainbowYellow",
	"RainbowBlue",
	"RainbowOrange",
	"RainbowGreen",
	"RainbowViolet",
	"RainbowCyan",
}

local hooks = require("ibl.hooks")
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
	vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#fb4934" })
	vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#fabd2f" })
	vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#83a598" })
	vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#fe8019" })
	vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#b8bb26" })
	vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#d3869b" })
	vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#8ec07c" })
end)

-- Settings
require("ibl").setup({
	indent = { highlight = highlight, char = "┊" },
	whitespace = {
		highlight = highlight,
		remove_blankline_trail = false,
	},
	scope = { enabled = false },
})
