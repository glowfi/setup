-- Settings

local db_status_ok, db = pcall(require, "dashboard")
if not db_status_ok then
	return
end

-- CUSTOM HEADER
local custom_header = {
	"               ,   ,                             ",
	"               $,  $,     ,                      ",
	'               "ss.$ss. .s"                      ',
	"       ,     .ss$$$$$$$$$$s,                     ",
	"       $. s$$$$$$$$$$$$$$`$$Ss                   ",
	'       "$$$$$$$$$$$$$$$$$$o$$$       ,           ',
	"      s$$$$$$$$$$$$$$$$$$$$$$$$s,  ,s            ",
	'     s$$$$$$$$$"$$$$$$""""$$$$$$"$$$$$,          ',
	'     s$$$$$$$$$$s""$$$$ssssss"$$$$$$$$"          ',
	'    s$$$$$$$$$$"         `"""ss"$"$s""           ',
	'    s$$$$$$$$$$,              `"""""$  .s$$s     ',
	'    s$$$$$$$$$$$$s,...               `s$$"  `    ',
	'`ssss$$$$$$$$$$$$$$$$$$$$####s.     .$$"$.   , s-',
	'  `""""$$$$$$$$$$$$$$$$$$$$#####$$$$$$"     $.$" ',
	'        "$$$$$$$$$$$$$$$$$$$$$####s""     .$$$|  ',
	'         "$$$$$$$$$$$$$$$$$$$$$$$$##s    .$$" $  ',
	'          $$""$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"   ` ',
	'         $$"  "$"$$$$$$$$$$$$$$$$$$$$S"""""      ',
	'        ,"     $  $$$$$$$$$$$$$$$$####s          ',
	'                .s$$$$$$$$$$$$$$$$$####"         ',
	'              $$$$$$$$$$$$$$$$$$$$####"          ',
	"                                                 ",
}

-- CUSTOM FOOTER
local handle = io.popen("while fortune -sn80 |awk 'END { if (NR == 1) { print; exit 1 } }'; do true; done")
local var = handle:read("*a")
handle:close()
local s = var:sub(1, -2)
local custom_footer = { s }

-- Configuration
db.setup({
	theme = "doom",
	config = {
		header = custom_header,
		center = {
			{
				icon = "",
				icon_hl = "",
				desc = "neo",
				desc_hl = "",
				key = "VIM",
				key_hl = "",
				action = "",
			},
		},
		footer = custom_footer,
		project = { limit = 1, icon = "Projects", label = "", action = "Telescope find_files cwd=" },
		mru = { limit = 3, icon = "Files", label = "" },
	},
	hide = {
		statusline = false,
	},
})

-- HIGHLIGHT COLORS
vim.cmd("hi! DashboardHeader guifg=#fabd2f")
vim.cmd("hi! DashboardFooter guifg=#d3869b")
