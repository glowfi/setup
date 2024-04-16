-- Keymappings
vim.keymap.set("v", "<leader>]", ":Gen<CR>")
vim.keymap.set("n", "<leader>]", ":Gen<CR>")

-- Setup
require("gen").setup({
	opts = {
		model = "zephyr:7b-beta",
	},
})
