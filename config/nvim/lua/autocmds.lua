require "nvchad.autocmds"

-- Per-project shada (search history, marks, etc.)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local cwd = vim.fn.getcwd()
    local root = vim.fs.root(cwd, ".git") or cwd
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

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    if vim.b[args.buf].bigfile_detected == 1 then
      pcall(vim.treesitter.stop, args.buf)
    end
  end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    local keep = require("detached").pids
    for _, pid in ipairs(vim.api.nvim_get_proc_children(vim.fn.getpid())) do
      if not keep[pid] then
        vim.uv.kill(pid, "sigkill")
      end
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("File changed on disk — buffer reloaded", vim.log.levels.INFO)
  end,
})
