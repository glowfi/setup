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

-- SETTING CUSTOM HEADER,CENTER AND FOOTER
db.custom_header = custom_header
db.custom_center = {
	{
		icon = "",
		desc = "",
		action = "",
		shortcut = ".",
	},
}
db.custom_footer = custom_footer
