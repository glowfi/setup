-- Settings
-- Lsp Diagnostic signs
vim.fn.sign_define("DiagnosticSignError", { texthl = "DiagnosticSignError", text = "", numhl = "" })
vim.fn.sign_define("DiagnosticSignWarn", { texthl = "DiagnosticSignWarn", text = "", numhl = "" })
vim.fn.sign_define("DiagnosticSignHint", { texthl = "DiagnosticSignHint", text = "", numhl = "" })
vim.fn.sign_define("DiagnosticSignInfo", { texthl = "DiagnosticSignInfo", text = "", numhl = "" })

-- Keymappings
vim.cmd("nnoremap <silent> <F2>  <cmd>lua vim.lsp.buf.rename()<CR>")
vim.cmd("nnoremap <silent> <F1>  <cmd>lua vim.lsp.buf.code_action()<CR>")
vim.cmd("nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>")
vim.cmd("nnoremap <silent> ga    <cmd>lua vim.lsp.buf.declaration()<CR>")
vim.cmd("nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>")
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
	"   (Method)",
	"   (Function)",
	"   (Constructor)",
	"   (Field)",
	"[] (Variable)",
	"   (Class)",
	" 蘒 (Interface)",
	"   (Module)",
	"   (Property)",
	"   (Unit)",
	"   (Value)",
	" 練 (Enum)",
	"   (Keyword)",
	"   (Snippet)",
	"   (Color)",
	"   (File)",
	"   (Reference)",
	"   (Folder)",
	"   (EnumMember)",
	"   (Constant)",
	"   (Struct)",
	"   (Event)",
	"   (Operator)",
	"   (TypeParameter)",
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
lspconfig.pyright.setup({ capabilities = capabilities })

-- Rust LSP
lspconfig.rust_analyzer.setup({
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		client.server_capabilities.document_formatting = false
	end,
})

-- Golang LSP
require("lspconfig").gopls.setup({
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		client.server_capabilities.document_formatting = false
	end,
})

-- Clangd LSP
require("lspconfig").clangd.setup({})

-- Lua LSP
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

lspconfig.lua_ls.setup({
	settings = {
		Lua = {
			runtime = { version = "LuaJIT", path = runtime_path },
			diagnostics = { globals = { "vim" } },
			workspace = { library = vim.api.nvim_get_runtime_file("", true) },
			telemetry = { enable = false },
		},
	},
})

-- HTML CSS
lspconfig.html.setup({ capabilities = capabilities })

lspconfig.cssls.setup({ capabilities = capabilities })

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
lspconfig.jsonls.setup({
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		client.server_capabilities.document_formatting = false
	end,
})

-- TS TSX JS JSX
lspconfig.tsserver.setup({
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		client.server_capabilities.document_formatting = false
		require("typescript").setup({
			server = {
				capabilities = capabilities,
			},
		})

		-- Keymappings
		vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", ":TypescriptOrganizeImports<CR>", { silent = true })
		vim.api.nvim_buf_set_keymap(bufnr, "n", "qq", ":TypescriptFixAll<CR>", { silent = true })
		vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", ":TypescriptRenameFile<CR>", { silent = true })
		vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", ":TypescriptAddMissingImports<CR>", { silent = true })
	end,
	flags = { debounce_text_changes = 150 },
})

-- Null-ls Integration
local status_ok___, null_ls = pcall(require, "lsp.null-ls")
if not status_ok___ then
	return
end

null_ls.setup()
