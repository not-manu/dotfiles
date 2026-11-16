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

hs.execute([[/usr/bin/hidutil property --set '{"HIDKeyRepeat":25000000,"HIDInitialKeyRepeat":150000000}']])

HeliumProfileTap = hs.eventtap
  .new({ hs.eventtap.event.types.keyDown }, function(event)
    if event:getKeyCode() ~= hs.keycodes.map.n or not event:getFlags():containExactly({ "cmd", "shift" }) then
      return false
    end
    local app = hs.application.frontmostApplication()
    if not app or app:bundleID() ~= "net.imput.helium" then
      return false
    end
    local win = app:focusedWindow()
    if not win or not win:title():match(" %- Manu$") then
      return false
    end
    app:selectMenuItem({ "Profiles", "Personal" })
    return true
  end)
  :start()

hs.hotkey.bind({ "alt", "shift" }, "G", function()
  hs.application.launchOrFocus("Ghostty")
end)
