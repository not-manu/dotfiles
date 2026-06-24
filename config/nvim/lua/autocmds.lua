require "nvchad.autocmds"

-- Per-project shada (search history, marks, etc.)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
    if vim.v.shell_error ~= 0 or not root or root == "" then
      root = vim.fn.getcwd()
    end
    local shada_dir = vim.fn.stdpath "data" .. "/project-shada"
    vim.fn.mkdir(shada_dir, "p")
    local project_key = root:gsub("[/\\:%%]", "%%")
    local shada_file = shada_dir .. "/" .. project_key .. ".shada"
    vim.o.shadafile = shada_file
    vim.cmd("silent! rshada! " .. vim.fn.fnameescape(shada_file))
  end,
})

-- MDX filetype detection
vim.filetype.add {
  extension = {
    mdx = "mdx",
  },
}

-- MDX has no dedicated treesitter parser; davidmh/mdx.nvim maps the `mdx`
-- filetype onto the `markdown` parser (see lua/plugins/init.lua). NvChad's
-- nvim-treesitter keeps its own ft->lang table and won't start highlighting
-- automatically, so we explicitly start the markdown highlighter per buffer.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "mdx",
  callback = function(args)
    pcall(vim.treesitter.start, args.buf, "markdown")
  end,
})

-- Auto-reload buffers when files change on disk (e.g. agent edits)
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd "silent! checktime"
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("File changed on disk — buffer reloaded", vim.log.levels.INFO)
  end,
})
