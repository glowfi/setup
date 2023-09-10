-- Settings
local check_backspace = function()
	local col = vim.fn.col(".") - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

local function T(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
	return
end

cmp.setup({
	window = {
		documentation = {
			border = "single",
			winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
			max_width = 120,
			min_width = 60,
			max_height = math.floor(vim.o.lines * 0.3),
			min_height = 1,
		},
	},
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	mapping = {
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-e>"] = cmp.mapping.close(),
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = false,
		}),
		["<Tab>"] = cmp.mapping(function()
			if cmp.visible() then
				cmp.select_next_item()
			elseif vim.fn["vsnip#jumpable(1)"] then
				vim.fn.feedkeys(T("<Plug>(vsnip-jump-next)"), "")
			elseif check_backspace() then
				vim.fn.feedkeys(T("<Tab>"), "n")
			else
				vim.fn.feedkeys(T("<Tab>"), "n")
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif vim.fn["vsnip#jumpable(-1)"] then
				vim.fn.feedkeys(T("<Plug>(vsnip-jump-prev)"), "")
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "path" },
		{ name = "buffer" },
		{ name = "vsnip" },
	},
	completion = { completeopt = "menu,menuone,noinsert", keyword_length = 1 },
	experimental = { ghost_text = true, native_menu = false },
	formatting = {
		format = function(entry, vim_item)
			local comp_kind = {
				Text = "   (Text) ",
				Method = "   (Method)",
				Function = "   (Function)",
				Constructor = "   (Constructor)",
				Field = "   (Field)",
				Variable = "[] (Variable)",
				Class = "   (Class)",
				Interface = " 蘒 (Interface)",
				Module = "   (Module)",
				Property = "   (Property)",
				Unit = "   (Unit)",
				Value = "   (Value)",
				Enum = " 練 (Enum)",
				Keyword = "   (Keyword)",
				Snippet = "   (Snippet)",
				Color = "   (Color)",
				File = "   (File)",
				Reference = "   (Reference)",
				Folder = "   (Folder)",
				EnumMember = "   (EnumMember)",
				Constant = "   (Constant)",
				Struct = "   (Struct)",
				Event = "   (Event)",
				Operator = "   (Operator)",
				TypeParameter = "   (TypeParameter)",
			}

			vim_item.kind = comp_kind[vim_item.kind]
			vim_item.menu = ({
				nvim_lsp = "[LS]",
				vsnip = "[VSNIP]",
				path = "[Path]",
				buffer = "[Buffer]",
			})[entry.source.name]
			return vim_item
		end,
	},
})
