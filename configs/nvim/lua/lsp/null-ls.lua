-- Settings

local M = {}
M.setup = function()
	local status_ok, null_ls = pcall(require, "null-ls")
	if not status_ok then
		return
	end

	local b = null_ls.builtins
	vim.env.PRETTIERD_DEFAULT_CONFIG = vim.fn.stdpath("config") .. "/.prettierrc"

	null_ls.setup({
		debounce = 150,
		sources = {
			require("none-ls.diagnostics.ruff"),
			b.formatting.prettierd.with({
				filetypes = {
					"typescriptreact",
					"typescript",
					"javascriptreact",
					"javascript",
					"css",
					"html",
					"json",
					"markdown",
				},
			}),
			b.formatting.fish_indent.with({ filetypes = { "fish" } }),
			b.formatting.black.with({ filetypes = { "python" } }),
			b.formatting.goimports.with({ filetypes = { "go" } }),
			b.formatting.gofumpt.with({ filetypes = { "go" } }),
			b.formatting.stylua.with({ filetypes = { "lua" } }),
			b.formatting.shfmt.with({ filetypes = { "sh" } }),
		},
		on_attach = function(client)
			vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]])
		end,
	})
end

return M
