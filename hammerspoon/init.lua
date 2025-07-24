-- Hammerspoon config for app launching and window management
-- Simple and reliable alternative to Karabiner + Rectangle

-- App launcher shortcuts using Cmd+Shift
local appShortcuts = {
    b = "Brave Browser",
    ["."] = "WezTerm", 
    t = "TablePlus",
    f = "Finder",
    m = "Postman",  -- Changed from 'p' to avoid WezTerm conflict
    w = "Ferdium"   -- Changed from 'd' to avoid WezTerm conflict
}

-- Create hotkeys for each app
for key, appName in pairs(appShortcuts) do
    hs.hotkey.bind({"cmd", "shift"}, key, function()
        hs.application.launchOrFocus(appName)
    end)
end

-- Helper function to safely get focused window
local function getFocusedWindow()
    local win = hs.window.focusedWindow()
    if not win then 
        hs.alert.show("No focused window")
        return nil 
    end
    return win
end

-- Window management shortcuts using Cmd+Alt
-- Left half
hs.hotkey.bind({"cmd", "alt"}, "h", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x,
        y = frame.y,
        w = frame.w / 2,
        h = frame.h
    })
end)

-- Right half  
hs.hotkey.bind({"cmd", "alt"}, "l", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x + frame.w / 2,
        y = frame.y,
        w = frame.w / 2,
        h = frame.h
    })
end)

-- Center (smaller window)
hs.hotkey.bind({"cmd", "alt"}, "c", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    local margin = frame.w * 0.1 -- 10% margin
    win:setFrame({
        x = frame.x + margin,
        y = frame.y + margin,
        w = frame.w - (margin * 2),
        h = frame.h - (margin * 2)
    })
end)

-- Center horizontal (full height)
hs.hotkey.bind({"cmd", "alt"}, "m", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    local width = frame.w * 0.6 -- 60% width
    win:setFrame({
        x = frame.x + (frame.w - width) / 2,
        y = frame.y,
        w = width,
        h = frame.h
    })
end)

-- Fullscreen/Maximize
hs.hotkey.bind({"cmd", "alt"}, "f", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x,
        y = frame.y,
        w = frame.w,
        h = frame.h
    })
end)

-- === 3-Section Layouts ===
-- Left third
hs.hotkey.bind({"cmd", "alt"}, "1", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x,
        y = frame.y,
        w = frame.w / 3,
        h = frame.h
    })
end)

-- Center third
hs.hotkey.bind({"cmd", "alt"}, "2", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x + frame.w / 3,
        y = frame.y,
        w = frame.w / 3,
        h = frame.h
    })
end)

-- Right third
hs.hotkey.bind({"cmd", "alt"}, "3", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x + (frame.w * 2 / 3),
        y = frame.y,
        w = frame.w / 3,
        h = frame.h
    })
end)

-- Left two-thirds
hs.hotkey.bind({"cmd", "alt"}, "4", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x,
        y = frame.y,
        w = frame.w * 2 / 3,
        h = frame.h
    })
end)

-- Right two-thirds
hs.hotkey.bind({"cmd", "alt"}, "5", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x + frame.w / 3,
        y = frame.y,
        w = frame.w * 2 / 3,
        h = frame.h
    })
end)

-- === 4-Section Layouts ===
-- Top-left quarter
hs.hotkey.bind({"cmd", "alt"}, "u", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x,
        y = frame.y,
        w = frame.w / 2,
        h = frame.h / 2
    })
end)

-- Top-right quarter
hs.hotkey.bind({"cmd", "alt"}, "i", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x + frame.w / 2,
        y = frame.y,
        w = frame.w / 2,
        h = frame.h / 2
    })
end)

-- Bottom-left quarter
hs.hotkey.bind({"cmd", "alt"}, "j", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x,
        y = frame.y + frame.h / 2,
        w = frame.w / 2,
        h = frame.h / 2
    })
end)

-- Bottom-right quarter
hs.hotkey.bind({"cmd", "alt"}, "k", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x + frame.w / 2,
        y = frame.y + frame.h / 2,
        w = frame.w / 2,
        h = frame.h / 2
    })
end)

-- Top half
hs.hotkey.bind({"cmd", "alt"}, "up", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x,
        y = frame.y,
        w = frame.w,
        h = frame.h / 2
    })
end)

-- Bottom half
hs.hotkey.bind({"cmd", "alt"}, "down", function()
    local win = getFocusedWindow()
    if not win then return end
    local screen = win:screen()
    local frame = screen:frame()
    win:setFrame({
        x = frame.x,
        y = frame.y + frame.h / 2,
        w = frame.w,
        h = frame.h / 2
    })
end)

-- === Desktop/Space Management ===
-- Move current window to desktop/space and follow
hs.hotkey.bind({"cmd", "alt", "shift"}, "right", function()
    local win = getFocusedWindow()
    if not win then return end
    local app = win:application()
    local spaces = require("hs.spaces")
    local currentSpace = spaces.focusedSpace()
    local allSpaces = spaces.allSpaces()
    local mainScreen = hs.screen.mainScreen():getUUID()
    local screenSpaces = allSpaces[mainScreen]
    
    -- Find current space index
    local currentIndex = nil
    for i, spaceId in ipairs(screenSpaces) do
        if spaceId == currentSpace then
            currentIndex = i
            break
        end
    end
    
    if currentIndex and currentIndex < #screenSpaces then
        local nextSpace = screenSpaces[currentIndex + 1]
        spaces.moveWindowToSpace(win:id(), nextSpace)
        spaces.gotoSpace(nextSpace)
        hs.alert.show("Moved to desktop " .. (currentIndex + 1))
    else
        hs.alert.show("Already on last desktop")
    end
end)

hs.hotkey.bind({"cmd", "alt", "shift"}, "left", function()
    local win = getFocusedWindow()
    if not win then return end
    local spaces = require("hs.spaces")
    local currentSpace = spaces.focusedSpace()
    local allSpaces = spaces.allSpaces()
    local mainScreen = hs.screen.mainScreen():getUUID()
    local screenSpaces = allSpaces[mainScreen]
    
    -- Find current space index
    local currentIndex = nil
    for i, spaceId in ipairs(screenSpaces) do
        if spaceId == currentSpace then
            currentIndex = i
            break
        end
    end
    
    if currentIndex and currentIndex > 1 then
        local prevSpace = screenSpaces[currentIndex - 1]
        spaces.moveWindowToSpace(win:id(), prevSpace)
        spaces.gotoSpace(prevSpace)
        hs.alert.show("Moved to desktop " .. (currentIndex - 1))
    else
        hs.alert.show("Already on first desktop")
    end
end)

-- Move to specific desktop (1-4)
for i = 1, 4 do
    hs.hotkey.bind({"cmd", "alt", "shift"}, tostring(i), function()
        local win = getFocusedWindow()
        if not win then return end
        local spaces = require("hs.spaces")
        local allSpaces = spaces.allSpaces()
        local mainScreen = hs.screen.mainScreen():getUUID()
        local screenSpaces = allSpaces[mainScreen]
        
        if screenSpaces[i] then
            spaces.moveWindowToSpace(win:id(), screenSpaces[i])
            spaces.gotoSpace(screenSpaces[i])
            hs.alert.show("Moved to desktop " .. i)
        else
            hs.alert.show("Desktop " .. i .. " not found")
        end
    end)
end

-- Show notification when config loads
hs.notify.new({title="Hammerspoon", informativeText="Complete setup! Apps: Cmd+Shift | Windows: Cmd+Alt | Desktops: Cmd+Alt+Shift"}):send()