-- VimTeX configuration for editing LaTeX files (compilation disabled)

-- Disable compilation entirely
vim.g.vimtex_compiler_enabled = 0

-- Disable folding completely
vim.g.vimtex_fold_enabled = 0

-- Enable syntax concealment for better readability (optional)
-- This makes \alpha appear as α, etc.
vim.g.vimtex_syntax_conceal = {
  accents = 1,
  ligatures = 1,
  cites = 1,
  fancy = 1,
  spacing = 1,
  greek = 1,
  math_bounds = 0,
  math_delimiters = 1,
  math_fracs = 1,
  math_super_sub = 1,
  math_symbols = 1,
  sections = 0,
  styles = 1,
}

-- Set conceallevel for LaTeX files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = ''  -- Don't conceal on cursor line
  end,
})

-- Keymaps (using localleader which is typically backslash by default)
-- Default VimTeX keymaps include:
-- <localleader>ll - Start/stop compilation
-- <localleader>lv - View PDF
-- <localleader>lc - Clean auxiliary files
-- <localleader>le - View compilation errors
-- <localleader>lt - Open table of contents
-- <localleader>lk - Stop compilation
-- <localleader>lK - Stop all compilation jobs

-- Optional: Set localleader to comma for easier access
-- vim.g.maplocalleader = ','

-- Disable VimTeX's default insert mode mappings if you prefer
-- vim.g.vimtex_imaps_enabled = 0

-- Disable VimTeX's default folding if you don't want it
-- vim.g.vimtex_fold_enabled = 0

-- Enable auto-formatting with VimTeX's formatting engine (optional)
-- This will wrap text at textwidth
vim.g.vimtex_format_enabled = 1
