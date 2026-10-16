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

hs.execute([[/usr/bin/hidutil property --set '{"HIDKeyRepeat":25000000}']])

hs.hotkey.bind({ "alt", "shift" }, "G", function()
  hs.application.launchOrFocus("Ghostty")
end)

local heliumProfiles = { Manu = "Default", Personal = "Profile 4" }

local function heliumProfile(win)
  return win and win:title():match(".* %- Helium %- (.+)$")
end

local heliumToggle = hs.hotkey.new({ "alt", "shift" }, "N", function()
  local app = hs.application.frontmostApplication()
  local target = heliumProfile(app:focusedWindow()) == "Personal" and "Manu" or "Personal"
  for _, win in ipairs(app:allWindows()) do
    if heliumProfile(win) == target then
      return win:focus()
    end
  end
  hs.task.new("/usr/bin/open", nil, { "-na", "Helium", "--args", "--profile-directory=" .. heliumProfiles[target] }):start()
end)

heliumWatcher = hs.application.watcher.new(function(name, event)
  if name ~= "Helium" then return end
  if event == hs.application.watcher.activated then heliumToggle:enable() end
  if event == hs.application.watcher.deactivated then heliumToggle:disable() end
end):start()
