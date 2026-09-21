local M = { pids = {} }

function M.start(cmd)
  local job = vim.fn.jobstart(cmd, { detach = true })
  if job > 0 then
    M.pids[vim.fn.jobpid(job)] = true
  end
end

return M
