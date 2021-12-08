-- Settings
local null_ls = require("null-ls")
local b = null_ls.builtins

vim.env.PRETTIERD_DEFAULT_CONFIG = vim.fn.stdpath "config" .. "/.prettierrc"

local sources = {
        b.formatting.prettierd.with {
        filetypes = {
          "typescriptreact",
          "typescript",
          "javascriptreact",
          "javascript",
          "css",
          "html",
          "json",
          "markdown"
        },
      },
        b.formatting.fish_indent.with {
        filetypes = {"fish"},
    },
        b.formatting.black.with {
        filetypes = {"python"},
    },
        b.formatting.rustfmt.with {
        filetypes = {"python"},
    },
        b.diagnostics.flake8.with {
        filetypes = {"python"},
    }
       
}

local M = {}
M.setup = function(on_attach)
    null_ls.config({
        debounce = 150,
        sources = sources,
    })
    require("lspconfig")["null-ls"].setup({ on_attach = on_attach })
end

return M
