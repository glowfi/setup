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
	-- vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#D70000" })
	-- vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#fabd2f" })
	-- vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#7788AA" })
	-- vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#ffAA88" })
	-- vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#789978" })
	-- vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#D7007D" })
	-- vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#708090" })
	vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#ffffff" })
	vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#ffffff" })
	vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#ffffff" })
	vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#ffffff" })
	vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#ffffff" })
	vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#ffffff" })
	vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#ffffff" })
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
