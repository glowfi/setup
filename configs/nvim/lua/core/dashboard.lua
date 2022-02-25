-- Settings
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
}

-- CUSTOM FOOTER
local handle = io.popen("while fortune -sn80 |awk 'END { if (NR == 1) { print; exit 1 } }'; do true; done")
local var = handle:read("*a")
handle:close()
local s = var:sub(1, -2)
local custom_footer = { s }

-- SETTING CUSTOM HEADER AND FOOTER
vim.g.dashboard_custom_header = custom_header
vim.g.dashboard_custom_footer = custom_footer

-- CHANGE START SCREEN
vim.g.dashboard_default_executive = "telescope"
vim.g.dashboard_custom_section = { a = { description = { "" }, command = "" } }
