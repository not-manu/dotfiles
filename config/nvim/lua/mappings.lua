require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<C-d>", "<C-d>zz", { desc = "Center cursor after moving down half-page" })
map("n", "<C-u>", "<C-u>zz", { desc = "Center cursor after moving up half-page" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- TypeScript-specific keybindings (only active in TS/JS files)
local function ts_keymap(mode, lhs, rhs, desc)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    callback = function(event)
      vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = "TS " .. desc })
    end,
  })
end

-- TypeScript Tools commands
ts_keymap("n", "<leader>to", "<cmd>TSToolsOrganizeImports<CR>", "Organize imports")
ts_keymap("n", "<leader>tF", "<cmd>TSToolsFixAll<CR>", "Fix all errors")
ts_keymap("n", "<leader>ts", "<cmd>TSToolsGoToSourceDefinition<CR>", "Go to source definition")
ts_keymap("n", "<leader>tr", "<cmd>TSToolsRenameFile<CR>", "Rename file")
ts_keymap("n", "<leader>ti", "<cmd>TSToolsAddMissingImports<CR>", "Add missing imports")
ts_keymap("n", "<leader>tR", "<cmd>TSToolsRemoveUnused<CR>", "Remove unused statements")
ts_keymap("n", "<leader>tS", "<cmd>TSToolsSortImports<CR>", "Sort imports")
ts_keymap("n", "<leader>tu", "<cmd>TSToolsRemoveUnusedImports<CR>", "Remove unused imports")
ts_keymap("n", "<leader>tf", "<cmd>TSToolsFileReferences<CR>", "File references")

-- LSP
map("n", "<leader>fr", "<cmd>Telescope lsp_references<CR>", { desc = "Find references" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })

-- Diagnostics
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic float" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })

-- Toggle markdown checkbox
local function toggle_checkbox(line)
  if line:match "%- %[ %]" then
    return (line:gsub("%- %[ %]", "- [x]", 1))
  elseif line:match "%- %[x%]" then
    return (line:gsub("%- %[x%]", "- [ ]", 1))
  else
    local new = line:gsub("^(%s*)%- ", "%1- [ ] ", 1)
    if new == line then
      new = line:gsub("^(%s*)", "%1- [ ] ", 1)
    end
    return new
  end
end

map("n", "<leader>tt", function()
  vim.api.nvim_set_current_line(toggle_checkbox(vim.api.nvim_get_current_line()))
end, { desc = "Toggle markdown checkbox" })

map("v", "<leader>tt", function()
  local start = vim.fn.line "v"
  local finish = vim.fn.line "."
  if start > finish then start, finish = finish, start end
  for lnum = start, finish do
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
    vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { toggle_checkbox(line) })
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "Toggle markdown checkboxes" })

-- Toggle diagnostics visibility (for screenshots)
local diagnostics_visible = true
map("n", "<leader>td", function()
  diagnostics_visible = not diagnostics_visible
  vim.diagnostic.config({
    virtual_text = diagnostics_visible,
    signs = diagnostics_visible,
    underline = diagnostics_visible,
  })
end, { desc = "Toggle diagnostics visibility" })

-- Lazygit
map("n", "<leader>lg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

-- Spell checking (cspell)
-- Note: Code actions for adding words are available via <leader>ca on spelling errors

-- Open URL under cursor in Zen browser
map("n", "gz", function()
  local url = vim.fn.expand "<cfile>"
  vim.fn.system { "open", "-a", "Zen", url }
end, { desc = "Open link in Zen browser" })

-- vim-visual-multi keybindings (g prefix, Vim-style)
vim.g.VM_maps = {
  ["Find Under"] = "gm", -- Start multi-cursor on word under cursor
  ["Find Subword Under"] = "gm", -- Same but for subwords
  ["Select All"] = "gM", -- Select all occurrences (like VSCode Cmd+Shift+L)
  ["Add Cursor Down"] = "gmj", -- Add cursor below
  ["Add Cursor Up"] = "gmk", -- Add cursor above
  ["Skip Region"] = "gq", -- Skip current and find next
  ["Remove Region"] = "gQ", -- Remove current cursor/selection
}
