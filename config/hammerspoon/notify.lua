require("hs.ipc")

local sent = {}

function notify(msg, pane)
  local n = hs.notify.new(function()
    hs.application.launchOrFocus("Ghostty")
    if pane ~= nil and pane ~= "" then
      hs.task.new("/opt/homebrew/bin/tmux", nil, {
        "select-pane", "-t", pane, ";",
        "select-window", "-t", pane, ";",
        "switch-client", "-t", pane,
      }):start()
    end
  end, {
    title = msg,
    withdrawAfter = 0,
  })
  sent[#sent + 1] = n
  n:send()
end
