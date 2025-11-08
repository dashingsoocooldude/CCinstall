print("init.lua loaded")
local Frame = require("lib.gui.frame")



local gui = {
    frames = {},
    activeFrame = nil
}

-- Create a frame by name
function gui.createFrame(name, terminal)
    local frame = Frame:new(name, terminal)
    gui.frames[name] = frame
    return frame
end

-- Show a specific frame
function gui.showFrame(name)
    if gui.frames[name] then
        gui.activeFrame = gui.frames[name]
        gui.activeFrame:draw()
    else
        error("Frame not found: " .. name)
    end
end

-- Run the GUI loop starting with a given frame
function gui.run(startFrame)
    gui.showFrame(startFrame)

    --main event loop
    while true do
        --draw all frames
        for _, frame in pairs(gui.frames) do
            if frame.visible then
                frame:draw()
            end
        end

        -- handle events
        local event = {os.pullEvent()}
        for _, frame in pairs(gui.frames) do
            frame:handleEvent(event)
        end
    end
end

return gui
