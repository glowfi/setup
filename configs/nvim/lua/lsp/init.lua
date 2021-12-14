-- Settings

-- Lsp Diagnostic signs
vim.fn.sign_define(
  "DiagnosticSignError",
  { texthl = "DiagnosticSignError", text = "", numhl = "" }
)
vim.fn.sign_define(
  "DiagnosticSignWarn",
  { texthl = "DiagnosticSignWarn", text = "", numhl = "" }
)
vim.fn.sign_define(
  "DiagnosticSignHint",
  { texthl = "DiagnosticSignHint", text = "", numhl = "" }
)
vim.fn.sign_define(
  "DiagnosticSignInfo",
  { texthl = "DiagnosticSignInfo", text = "", numhl = "" }
)

-- Keymappings
vim.cmd "nnoremap <silent> <F2>  <cmd>lua vim.lsp.buf.rename()<CR>"
vim.cmd "nnoremap <silent> <F1>  <cmd>lua vim.lsp.buf.code_action()<CR>"
vim.cmd "nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>"
vim.cmd "nnoremap <silent> ga    <cmd>lua vim.lsp.buf.declaration()<CR>"
vim.cmd "nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>"
vim.cmd "nnoremap <silent> K     :lua vim.lsp.buf.hover()<CR>"
vim.cmd "nnoremap <silent> <S-p> :lua vim.diagnostic.goto_prev({popup_opts = {border = 'rounded',max_width = 65,min_width = 35,max_height = math.floor(vim.o.lines * 0.3),min_height = 1}})<CR>"
vim.cmd "nnoremap <silent> <S-n> :lua vim.diagnostic.goto_next({popup_opts = {border = 'rounded',max_width = 65,min_width = 35,max_height = math.floor(vim.o.lines * 0.3),min_height = 1}})<CR>"
vim.cmd 'command! -nargs=0 LspVirtualTextToggle lua require("lsp/virtual_text").toggle()'


-- Set Default Prefix.
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = {
        prefix = "",
        spacing = 3,
    },
    signs = true,
    underline = true,
    update_in_insert = true
  }
)


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
  opts.border = opts.border or 'rounded'
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
    "   (TypeParameter)"
}

local function documentHighlight(client, bufnr)
    if client.resolved_capabilities.document_highlight then
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
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  }
}
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)


-- Python LSP
require'lspconfig'.pyright.setup{
  capabilities = capabilities,
}

-- Rust LSP 
require'lspconfig'.rust_analyzer.setup{
  capabilities = capabilities,
  on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
    end
}

-- HTML CSS
require'lspconfig'.html.setup {
  capabilities = capabilities,
}

require'lspconfig'.cssls.setup {
  capabilities = capabilities,
}

-- Emmet
local lspconfig = require'lspconfig'
local configs = require'lspconfig.configs'

configs.ls_emmet = {
  default_config = {
    cmd = {'ls_emmet', '--stdio'};
    filetypes = {'html', 'css','javascript','javascriptreact','typescript','typescriptreact','htmldjango'};
    root_dir = function(fname)
      return vim.loop.cwd()
      end;
    settings = {};
  };
}

lspconfig.ls_emmet.setup{ capabilities = capabilities }

-- JSON
require'lspconfig'.jsonls.setup {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
    end
}

-- TS TSX JS JSX
local nvim_lsp = require("lspconfig")
nvim_lsp.tsserver.setup {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false

    local ts_utils = require("nvim-lsp-ts-utils")
        ts_utils.setup {
            debug = false,
            disable_commands = false,
            enable_import_on_completion = true,
            import_all_timeout = 5000, -- ms

            -- Eslint
            eslint_enable_code_actions = true,
            eslint_enable_disable_comments = true,
            eslint_bin = "eslint_d",
            eslint_config_fallback = nil,
            eslint_enable_diagnostics = false,

            -- Formatting
            enable_formatting = true,
            formatter = "prettierd",
            formatter_opts = {},

            -- Update imports on file move
            import_all_scan_buffers = 100,
            update_imports_on_move = true,
            require_confirmation_on_move = false,
            watch_dir = nil,
        }

        -- Required to fix code action ranges
        ts_utils.setup_client(client)

        -- Keymappings
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", ":TSLspOrganize<CR>", {silent = true})
        vim.api.nvim_buf_set_keymap(bufnr, "n", "qq", ":TSLspFixCurrent<CR>", {silent = true})
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", ":TSLspRenameFile<CR>", {silent = true})
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", ":TSLspImportAll<CR>", {silent = true})
    end,
     flags = {
            debounce_text_changes = 150,
    },
}


-- Null-ls Integration
local null_ls = require("lsp.null-ls").setup()
