print("frame.lua loaded")

local fs = fs or {} -- for cc tweaked
local Element = require("lib.gui.elements.element")
local Frame = {}
Frame.__index = Frame

--create new frame
function Frame:new(name, terminal)
    local self = setmetatable({}, Frame)
    self.name = name
    self.term = terminal or term -- defaults to main terminal
    local ok, pname = pcall(peripheral.getName, self.term)
    if ok and pname then self.termName = pname end
    self.elements = {}
    self.visible = true
    return self
end

function Frame:setTerm(terminal)
    self.term = terminal
    local ok, pname = pcall(peripheral.getName, self.term)
    if ok and pname then self.termName = pname else self.termName = nil end
    for _, el in ipairs(self.elements) do
        if el.setTerm then el:setTerm(self.term) else el.term = self.term end
    end
    return self
end

-- dynamically create add methods for all elements
local function createElementMethods(frame)
    local elementFiles = fs.list("lib/gui/elements")
    for _, file in ipairs(elementFiles) do
        -- skip element.lua
        if file ~= "element.lua" then
            -- convert filename to element name
            local elementName = file:gsub("%.lua$", "")
            local className = elementName:gsub("^%l", string.upper)

            -- create the add method
            local methodName = "add" .. className
            frame[methodName] = function(self)
                local Element = require("lib.gui.elements." .. elementName)
                local el = Element:new()
                -- use setTerm sp Element can recalc defaults from the assigned terminal
                if el.setTerm then
                    el:setTerm(self.term)
                else
                    el.term = self.term
                end
                table.insert(self.elements, el)
                return el
            end
        end
    end
end

-- call this after defining frame
createElementMethods(Frame)

-- draw the frame
function Frame:draw()
    local t = self.term
    if not t then return end

    -- apply background/text defaults and clear safely
    Element.applyColors(t, colors.black, colors.white)
    if type(t.clear) == "function" then t.clear() end

    for _, element in ipairs(self.elements) do
        if element.draw then element:draw(t) end
    end
end

-- Handle mouse clicks
function Frame:handleEvent(event)
    local ev = event[1]
    if ev == "mouse_click" then
        local _, _, x, y = table.unpack(event)
        for _, el in ipairs(self.elements) do
            if el.checkClick then el:checkClick(x, y) end
        end
    elseif ev == "monitor_touch" then
        local _, side, x, y = table.unpack(event)
        -- only handle touches for this frame's monitor (if we have a name)
        if self.termName and side ~= self.termName then return end
        for _, el in ipairs(self.elements) do
            if el.checkClick then el:checkClick(x, y) end
        end
    elseif ev == "key" or ev == "char" then
        for _, el in ipairs(self.elements) do
            if el.handleKey and el:handleKey(event) then
                el:draw(self.term)
                break
            end
        end
    elseif ev == "timer" then
        local timerId = event[2]
        for _, el in ipairs(self.elements) do
            if el.handleTimer and el:handleTimer(timerId) then
                break
            end
        end
    end
end

return Frame
