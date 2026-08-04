---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "flexoki-alt",

	hl_override = {
		St_Lsp = { fg = "light_grey" },
	},
}

M.term = {
	float = {
		relative = "editor",
		row = 0.1,
		col = 0.075,
		width = 0.85,
		height = 0.8,
		border = "single",
	},
}

M.ui = {
	statusline = {
		order = { "mode", "file", "git", "recording", "%=", "lsp_msg", "%=", "diagnostics", "lsp" },
		modules = {
			recording = function()
				if vim.g.recording_mode then
					return "%#St_lspError#  REC "
				end
				return ""
			end,
		},
	},
}

return M
