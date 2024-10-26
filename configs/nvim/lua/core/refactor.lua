-- Setup
local reafactoring_status_ok, ref = pcall(require, "refactoring")
if not reafactoring_status_ok then
	return
end

ref.setup()

-- Keymappings
require("telescope").load_extension("refactoring")

vim.keymap.set({ "n", "x" }, "<leader>rr", function()
	require("telescope").extensions.refactoring.refactors()
end)
