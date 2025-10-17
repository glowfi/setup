-- Settings
-- Lsp Diagnostic signs
local default_diagnostic_config = {
	signs = {
		active = true,
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = "",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
	virtual_text = true,
	update_in_insert = false,
	severity_sort = true,
	underline = false,
}
vim.diagnostic.config(default_diagnostic_config)

-- Keymappings
local nmap = function(keys, func, desc)
	if desc then
		desc = "LSP: " .. desc
	end

	vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
end

nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
nmap("<Leader>f", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
nmap("<leader>i", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
vim.cmd("nnoremap <silent> K     :lua vim.lsp.buf.hover()<CR>")
vim.cmd(
	"nnoremap <silent> <S-p> :lua vim.diagnostic.goto_prev({popup_opts = {border = 'rounded',max_width = 65,min_width = 35,max_height = math.floor(vim.o.lines * 0.3),min_height = 1}})<CR>"
)
vim.cmd(
	"nnoremap <silent> <S-n> :lua vim.diagnostic.goto_next({popup_opts = {border = 'rounded',max_width = 65,min_width = 35,max_height = math.floor(vim.o.lines * 0.3),min_height = 1}})<CR>"
)
vim.cmd('command! -nargs=0 LspVirtualTextToggle lua require("lsp/virtual_text").toggle()')

-- Set Default Prefix.
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = { prefix = "", spacing = 3 },
	signs = true,
	underline = true,
	update_in_insert = true,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
	max_width = 55,
	min_width = 55,
	max_height = math.floor(vim.o.lines * 0.3),
	min_height = 1,
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = "rounded",
	max_width = 55,
	min_width = 35,
	max_height = math.floor(vim.o.lines * 0.3),
	min_height = 1,
})

-- Override borders globally
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or "rounded"
	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Symbols for autocomplete
vim.lsp.protocol.CompletionItemKind = {
	"   (Text) ",
	" 󰆧  (Method)",
	" 󰊕  (Function)",
	"   (Constructor)",
	"   (Field)",
	"[] (Variable)",
	" 󰌗  (Class)",
	" I (Interface)",
	" 󰅩  (Module)",
	" 󰆅  (Property)",
	"   (Unit)",
	" 󰎠  (Value)",
	" E (Enum)",
	" 󰌋  (Keyword)",
	"   (Snippet)",
	" 󰏘  (Color)",
	" 󰈔  (File)",
	" 󰈝  (Reference)",
	" 󰉋  (Folder)",
	"   (EnumMember)",
	" 󰇽  (Constant)",
	"   (Struct)",
	"   (Event)",
	" 󰃬  (Operator)",
	" 󰊄  (TypeParameter)",
}

local function documentHighlight(client, bufnr)
	if client.server_capabilities.document_highlight then
		vim.api.nvim_exec(
			[[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=#464646
      hi LspReferenceText cterm=bold ctermbg=red guibg=#464646
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=#464646
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
			false
		)
	end
end

local lsp_config = {}

-- Document Highlighting
function lsp_config.common_on_attach(client, bufnr)
	documentHighlight(client, bufnr)
end

-- CMP SUPPORT
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = { "documentation", "detail", "additionalTextEdits" },
}

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
	return
end
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

local status_ok_, lspconfig = pcall(require, "lspconfig")
if not status_ok_ then
	return
end

-- Python LSP
vim.lsp.enable("pyright")
vim.lsp.config("pyright", { capabilities = capabilities })
-- lspconfig.pyright.setup({ capabilities = capabilities })

-- Rust LSP
vim.lsp.enable("rust_analyzer")
vim.lsp.config("rust_analyzer", {
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]])
	end,
})
-- lspconfig.rust_analyzer.setup({
-- 	capabilities = capabilities,
-- 	on_attach = function(client, bufnr)
-- 		vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]])
-- 	end,
-- })

-- Golang LSP
vim.lsp.enable("gopls")
vim.lsp.config("gopls", {
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		client.server_capabilities.document_formatting = false
	end,
})
-- require("lspconfig").gopls.setup({
-- 	capabilities = capabilities,
-- 	on_attach = function(client, bufnr)
-- 		client.server_capabilities.document_formatting = false
-- 	end,
-- })

-- Zig LSP
vim.lsp.enable("zls")
vim.lsp.config("zls", {
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		client.server_capabilities.document_formatting = false
	end,
})
-- require("lspconfig").zls.setup({
-- 	capabilities = capabilities,
-- 	on_attach = function(client, bufnr)
-- 		client.server_capabilities.document_formatting = false
-- 	end,
-- })

-- Clangd LSP
vim.lsp.enable("clangd")
vim.lsp.config("clangd", {})
-- require("lspconfig").clangd.setup({})

-- Lua LSP
vim.lsp.enable("lua_ls")
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
})
-- lspconfig.lua_ls.setup({
-- 	settings = {
-- 		Lua = {
-- 			workspace = { checkThirdParty = false },
-- 			telemetry = { enable = false },
-- 		},
-- 	},
-- })

-- HTML CSS
vim.lsp.enable("html")
vim.lsp.config("html", { capabilities = capabilities })
-- lspconfig.html.setup({ capabilities = capabilities })

vim.lsp.enable("cssls")
vim.lsp.config("cssls", { capabilities = capabilities })
-- lspconfig.cssls.setup({ capabilities = capabilities })

vim.lsp.enable("tailwindcss")
vim.lsp.config("tailwindcss", { capabilities = capabilities })
-- lspconfig.tailwindcss.setup({
-- 	capabilities = capabilities,
-- })

-- Emmet
local status_ok__, configs = pcall(require, "lspconfig.configs")
if not status_ok__ then
	return
end

configs.ls_emmet = {
	default_config = {
		cmd = { "ls_emmet", "--stdio" },
		filetypes = {
			"html",
			"css",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"htmldjango",
		},
		root_dir = function(fname)
			return vim.loop.cwd()
		end,
		settings = {},
	},
}

lspconfig.ls_emmet.setup({ capabilities = capabilities })

-- JSON
vim.lsp.enable("jsonls")
vim.lsp.config("jsonls", {
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		client.server_capabilities.document_formatting = false
	end,
})
-- lspconfig.jsonls.setup({
-- 	capabilities = capabilities,
-- 	on_attach = function(client, bufnr)
-- 		client.server_capabilities.document_formatting = false
-- 	end,
-- })

-- GraphQL
vim.lsp.enable("graphql")
vim.lsp.config("graphql", {
	capabilities = capabilities,
})
-- lspconfig.graphql.setup({ capabilities = capabilities })

-- TS TSX JS JSX
require("typescript-tools").setup({
	settings = {
		separate_diagnostic_server = true,
		publish_diagnostic_on = "insert_leave",
		expose_as_code_action = {},
		tsserver_path = nil,
		tsserver_plugins = {},
		tsserver_max_memory = "auto",
		tsserver_format_options = {},
		tsserver_file_preferences = {},
		complete_function_calls = false,
		include_completions_with_insert_text = true,
		code_lens = "off",
		disable_member_code_lens = true,
	},
})
vim.cmd("nnoremap <silent>gi :TSToolsAddMissingImports<CR>")
vim.cmd("nnoremap <silent>gs :TSToolsOrganizeImports<CR>")
vim.cmd("nnoremap <silent>qq :TSToolsFixAll<CR>")
vim.cmd("nnoremap <silent>gr :TSToolsRenameFile<CR>")

-- Bash
vim.lsp.enable("bashls")
vim.lsp.config("bashls", {
	capabilities = capabilities,
})
-- lspconfig.bashls.setup({ capabilities = capabilities })

-- Null-ls Integration
local status_ok___, null_ls = pcall(require, "lsp.null-ls")
if not status_ok___ then
	return
end

null_ls.setup()
