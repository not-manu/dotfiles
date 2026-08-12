require("notify")

local apps = { ["Preview"] = true, ["QuickTime Player"] = true, ["IINA"] = true }

local wf = hs.window.filter.new(function(w)
  local app = w:application()
  return app ~= nil and apps[app:name()] == true
end)

wf:subscribe(hs.window.filter.windowDestroyed, function(_, appName)
  hs.timer.doAfter(0.1, function()
    local app = hs.application.get(appName)
    if app and #app:allWindows() == 0 then
      app:kill()
    end
  end)
end)
