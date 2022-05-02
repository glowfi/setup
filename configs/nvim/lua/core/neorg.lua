-- Config
require("neorg").setup({
	load = {
		["core.defaults"] = {},
		["core.norg.concealer"] = {},
	},
})

-- CodeBlock Highlighting
vim.cmd("autocmd VimEnter * highlight! NeorgCodeBlock guibg=#3c3836")
