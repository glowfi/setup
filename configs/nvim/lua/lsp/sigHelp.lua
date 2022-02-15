-- Settings
cfg = {
	bind = true,
	doc_lines = 2,
	floating_window_above_cur_line = true,
	floating_window = true,
	fix_pos = false,
	hint_enable = true,
	hint_prefix = "",
	hint_scheme = "String",
	hi_parameter = "Search",
	max_height = 10,
	max_width = 30,
	transpancy = 10,
	handler_opts = { border = "single" },
	extra_trigger_chars = { "(", "," },
	zindex = 50,
	debug = false,
	log_path = "debug_log_file_path",
	padding = "",
	timer_interval = 200,
}

local status_ok, lsp_sig = pcall(require, "lsp_signature")
if not status_ok then
	return
end

lsp_sig.setup(cfg)
