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
			b.formatting.rustfmt.with({ filetypes = { "rust" } }),
			b.formatting.gofmt.with({ filetypes = { "go" } }),
			b.formatting.stylua.with({ filetypes = { "lua" } }),
			b.formatting.shfmt.with({ filetypes = { "sh" } }),
			b.diagnostics.flake8.with({ filetypes = { "python" } }),
			-- b.diagnostics.eslint_d.with({
			-- 	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
			-- }),
		},
		on_attach = function(client)
			vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]])
		end,
	})
end

return M
