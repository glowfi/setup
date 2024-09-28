-- Settings
local status_ok, dap = pcall(require, "dap")
if not status_ok then
	return
end

local ui = require("dapui")
ui.setup()
require("dap-go").setup()

dap.listeners.before.attach.dapui_config = function()
	ui.open()
end
dap.listeners.before.launch.dapui_config = function()
	ui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	ui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	ui.close()
end

-- Keymappings
vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
vim.keymap.set("n", "<space>dc", dap.continue)
vim.keymap.set("n", "<space>di", dap.step_into)
vim.keymap.set("n", "<space>dv", dap.step_over)
vim.keymap.set("n", "<space>do", dap.step_out)
vim.keymap.set("n", "<space>k", dap.step_back)
vim.keymap.set("n", "<space>dr", dap.restart)
