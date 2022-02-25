-- Settings
vim.cmd("let g:mkdp_auto_start = 0")

vim.cmd("let g:mkdp_auto_close = 1")

vim.cmd("let g:mkdp_refresh_slow = 1")

vim.cmd("let g:mkdp_command_for_global = 0")

vim.cmd("let g:mkdp_open_to_the_world = 0")

vim.cmd("let g:mkdp_open_ip = ''")

vim.cmd("let g:mkdp_browser = '/usr/bin/brave'")

vim.cmd("let g:mkdp_echo_preview_url = 0")

vim.cmd("let g:mkdp_browserfunc = ''")

vim.cmd(
	"let g:mkdp_preview_options = {'mkit': {},'katex': {}, 'uml': {},'maid': {},'disable_sync_scroll': 0,'sync_scroll_type': 'middle','hide_yaml_meta': 1,'sequence_diagrams': {},'flowchart_diagrams': {},'content_editable': v:false,'disable_filename': 0}"
)

vim.cmd("let g:mkdp_markdown_css = '~/.config/nvim/custom.css'")

vim.cmd("let g:mkdp_highlight_css = ''")

vim.cmd("let g:mkdp_port = '3000'")

vim.cmd("let g:mkdp_page_title = '${name}'")

vim.cmd("let g:mkdp_filetypes = ['markdown']")

vim.cmd(
	"let g:markdown_fenced_languages = ['bash=sh','python','javascript', 'js=javascript', 'json=javascript', 'typescript', 'ts=typescript','html', 'css']"
)
