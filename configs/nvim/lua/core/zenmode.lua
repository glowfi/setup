require("zen-mode").setup({
	window = {
		width = 0.75,
	},
	plugins = {
		kitty = {
			enabled = true,
			font = "+3",
		},
	},
	on_open = function(win)
		vim.cmd("set nonumber")
		vim.cmd("set linebreak")
		vim.cmd("set wrap")
	end,
	on_close = function()
		vim.cmd("set number")
		vim.cmd("set nolinebreak")
		vim.cmd("set nowrap")
		io.popen("/bin/bash -c 'kill -SIGUSR1 $(pgrep kitty)'")
	end,
})
