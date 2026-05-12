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

-- Use markdown treesitter parser for MDX files
vim.treesitter.language.register("markdown", "mdx")

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
