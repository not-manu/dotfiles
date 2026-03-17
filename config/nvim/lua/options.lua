require "nvchad.options"

-- add yours here!

-- Disable global shada so we can load a per-project one in VimEnter
vim.o.shadafile = "NONE"

vim.opt.backupcopy = "yes" -- Enable hot reloading for file watchers

-- Treesitter-based code folding
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""
vim.opt.foldcolumn = "0"
vim.opt.fillchars:append({ fold = " " })

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- Diagnostic display configuration (for nice squiggly underlines)
vim.diagnostic.config({
  underline = true,
  virtual_text = {
    spacing = 4,
    prefix = "",
  },
  signs = true,
  update_in_insert = false,
  severity_sort = true,
})
