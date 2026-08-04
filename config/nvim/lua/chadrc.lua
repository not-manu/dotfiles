---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "flexoki-alt",

	hl_override = {
		St_Lsp = { fg = "light_grey" },
		Tabline = { bg = "black" },
		TbFill = { bg = "black" },
		TbBufOn = { bg = "#282726" },
		TbBufOnModified = { bg = "#282726" },
		TbBufOff = { bg = "black" },
		TbBufOffModified = { bg = "black" },
		TbBufOffClose = { bg = "black" },
		TbTabOff = { bg = "black" },
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
	tabufline = {
		order = { "treeOffset", "buffers", "tabs" },
		modules = {
			buffers = function()
				local api = vim.api
				local opts = require("nvconfig").ui.tabufline
				local utils = require "nvchad.tabufline.utils"
				local txt = utils.txt
				local btn = utils.btn
				local cur_buf = api.nvim_get_current_buf()

				local function filename(str)
					return str:match "([^/\\]+)[/\\]*$"
				end

				local function new_hl(group1, group2)
					local fg = api.nvim_get_hl(0, { name = group1 }).fg
					local bg = api.nvim_get_hl(0, { name = "Tb" .. group2 }).bg
					api.nvim_set_hl(0, group1 .. group2, { fg = fg, bg = bg })
					return "%#" .. group1 .. group2 .. "#"
				end

				local function unique_name(name, index)
					for i2, nr2 in ipairs(vim.t.bufs) do
						local other = filename(api.nvim_buf_get_name(nr2))
						if index ~= i2 and other == name then
							return vim.fn.fnamemodify(api.nvim_buf_get_name(vim.t.bufs[index]), ":h:t") .. "/" .. name
						end
					end
				end

				local function style_buf(nr, i, w)
					local icon = "󰈚 "
					local is_curbuf = cur_buf == nr
					local hl_name = "BufO" .. (is_curbuf and "n" or "ff")
					local icon_hl = new_hl("DevIconDefault", hl_name)

					local name = filename(api.nvim_buf_get_name(nr))
					name = name and (unique_name(name, i) or name) or " No Name "

					if name ~= " No Name " then
						local devicon, devicon_hl = require("nvim-web-devicons").get_icon(name)
						if devicon then
							icon = " " .. devicon .. " "
							icon_hl = new_hl(devicon_hl, hl_name)
						end
					end

					local pad = math.floor((w - #name - 3) / 2)
					pad = pad <= 0 and 1 or pad

					local maxname_len = w - 5
					name = string.sub(name, 1, maxname_len - 2) .. (#name > maxname_len and ".." or "")
					name = txt(name, hl_name)
					name = string.rep(" ", pad) .. icon_hl .. icon .. name .. string.rep(" ", pad)

					local mod = api.nvim_get_option_value("mod", { buf = nr })
					local suffix = mod and txt("  ", hl_name .. "Modified") or ""

					return txt(btn(name, nil, "GoToBuf", nr) .. suffix, hl_name)
				end

				local function tree_width()
					for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
						if vim.bo[api.nvim_win_get_buf(win)].ft == opts.treeOffsetFt then
							return api.nvim_win_get_width(win)
						end
					end
					return 0
				end

				vim.t.bufs = vim.tbl_filter(api.nvim_buf_is_valid, vim.t.bufs or {})

				local ntabs = vim.fn.tabpagenr "$"
				local avail = vim.o.columns - tree_width() - (ntabs > 1 and (12 + 3 * ntabs) or 0)

				local buffers = {}
				local has_current = false

				for i, nr in ipairs(vim.t.bufs) do
					if ((#buffers + 1) * opts.bufwidth) > avail then
						if has_current then
							break
						end
						table.remove(buffers, 1)
					end
					has_current = cur_buf == nr or has_current
					table.insert(buffers, style_buf(nr, i, opts.bufwidth))
				end

				return table.concat(buffers) .. txt("%=", "Fill")
			end,
		},
	},

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
