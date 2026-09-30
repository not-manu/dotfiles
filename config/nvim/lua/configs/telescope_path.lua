local width = vim.fn.strdisplaywidth

local function available(opts)
  local ok, status = pcall(require("telescope.state").get_status, vim.api.nvim_get_current_buf())
  if not ok or not status or not status.layout then
    return 80
  end
  return vim.api.nvim_win_get_width(status.layout.results.winid)
    - status.picker.selection_caret:len()
    - 2
    - (opts.__prefix or 0)
end

local function prompt()
  local ok, line = pcall(require("telescope.actions.state").get_current_line)
  return ok and line:lower():gsub("%s+", "") or ""
end

local function overlap(seg, needle)
  seg = seg:lower()
  local best = 0
  for i = 1, #needle do
    for j = i + best, #needle do
      if seg:find(needle:sub(i, j), 1, true) then
        best = j - i + 1
      else
        break
      end
    end
  end
  return best
end

return function(opts, path)
  local max = available(opts)
  if width(path) <= max then
    return path, {}
  end

  local dirs = vim.split(path, "/")
  local name = table.remove(dirs)
  local needle = prompt()
  local order = {}
  for i, d in ipairs(dirs) do
    if overlap(d, needle) < 3 then
      order[#order + 1] = i
    end
  end

  local shown = vim.deepcopy(dirs)
  local collapsed = {}
  local function line()
    return table.concat(vim.list_extend(vim.deepcopy(shown), { name }), "/")
  end
  for _, i in ipairs(order) do
    if width(line()) <= max then
      break
    end
    shown[i] = vim.fn.strcharpart(dirs[i], 0, 1)
    collapsed[i] = true
  end

  local out = line()
  local hl = {}
  local col = 0
  for i, seg in ipairs(shown) do
    if collapsed[i] then
      hl[#hl + 1] = { { col, col + #seg + 1 }, "TelescopeResultsComment" }
    end
    col = col + #seg + 1
  end

  if width(out) > max then
    return require("plenary.strings").truncate(out, max, nil, -1), {}
  end

  return out, hl
end
