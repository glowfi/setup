require("neorg").setup({
	load = {
		["core.defaults"] = {},
		["core.norg.concealer"] = {
			config = {
				icon_preset = "diamond",
				markup_preset = "dimmed",
				dim_code_blocks = false,
			},
		},
	},
})
