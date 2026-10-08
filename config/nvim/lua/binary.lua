local M = {}

M.extensions = {
  "png", "jpg", "jpeg", "webp", "gif", "ico", "icns", "bmp", "psd", "xcf", "raw", "rgb", "sgi",
  "aseprite", "ase", "afpalette", "excalidraw",
  "pdf", "docx", "pptx", "xlsx",
  "ttf", "otf", "woff", "woff2", "ttc",
  "aac", "mp3", "ogg", "wav", "opus", "flac", "pcm", "mp4", "mov", "webm", "flp",
  "zst", "zip", "gz", "tgz", "jar", "pack", "idx",
  "o", "a", "so", "node", "wasm", "pyc", "swiftmodule", "swiftdoc", "swiftsourceinfo", "dia", "swiftdeps",
  "sqlite", "db", "sst", "binarypb", "pb", "onnx", "rten", "glb", "traineddata", "tiktoken", "lockb", "dmp", "der",
}

M.filenames = { ".DS_Store" }

function M.open(path)
  if path:match "%.excalidraw$" then
    require("detached").start { "code", path }
  else
    require("detached").start { "open", path }
  end
end

local function human(size)
  local units = { "B", "KB", "MB", "GB" }
  local i = 1
  while size >= 1024 and i < #units do
    size = size / 1024
    i = i + 1
  end
  return string.format(i == 1 and "%d %s" or "%.1f %s", size, units[i])
end

local function stub(args)
  local buf = args.buf
  local path = vim.fn.fnamemodify(args.file, ":p")
  local stat = vim.uv.fs_stat(path)
  local bo = vim.bo[buf]
  bo.modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    path,
    stat and human(stat.size) or "missing",
    "",
    "<CR> / o  open externally",
  })
  bo.modified = false
  bo.modifiable = false
  bo.buftype = "nowrite"
  bo.swapfile = false
  bo.undolevels = -1
  for _, key in ipairs { "<CR>", "o" } do
    vim.keymap.set("n", key, function()
      M.open(path)
    end, { buffer = buf, desc = "Open binary externally" })
  end
end

function M.setup()
  local ft = { extension = {}, filename = {} }
  local patterns = {}
  for _, ext in ipairs(M.extensions) do
    ft.extension[ext] = "binary"
    ft.extension[ext:upper()] = "binary"
    patterns[#patterns + 1] = "*." .. ext
    if not vim.o.fileignorecase then
      patterns[#patterns + 1] = "*." .. ext:upper()
    end
  end
  for _, name in ipairs(M.filenames) do
    ft.filename[name] = "binary"
    patterns[#patterns + 1] = name
  end
  vim.filetype.add(ft)
  vim.api.nvim_create_autocmd("BufReadCmd", {
    group = vim.api.nvim_create_augroup("BinaryStub", { clear = true }),
    pattern = patterns,
    callback = stub,
  })
end

function M.telescope_hook(_, bufnr, opts)
  if opts.ft ~= "binary" then
    return true
  end
  require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary file", opts.preview.msg_bg_fillchar)
  return false
end

return M
