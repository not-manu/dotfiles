-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "flexoki",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
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
		order = { "mode", "file", "git", "recording", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cwd", "cursor" },
		modules = {
			recording = function()
				if vim.g.recording_mode then
					return "%#St_InsertMode#  REC %#St_InsertModeSep#"
				end
				return ""
			end,
		},
	},
}

return M
