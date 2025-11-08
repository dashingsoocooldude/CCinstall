local Element = require("lib.gui.elements.element")
local KeyInput = setmetatable({}, { __index = Element })
KeyInput.__index = KeyInput

function KeyInput:new()
    local self = Element:new()
    self:setElementType("KeyInput")
    setmetatable(self, KeyInput)
    self.text = ""
    self.active = false
    self.maxLength = 20
    self.callback = nil
    return self
end

function KeyInput:setText(text)
    self.text = text
    return self
end

function KeyInput:setMaxLength(max)
    self.maxLength = max
    return self
end

function KeyInput:onSubmit(cb)
    self.callback = cb
    return self
end

function KeyInput:draw(term)
    Element.draw(self, term)
    local t = term or self.term
    if not t then return end

    t.setCursorPos(self.x, self.y)
    --draw background for entire length
    t.setBackgroundColor(self.backgroundColor)
    t.setTextColor(self.TextColour)
    t.write(string.rep(" ", self.maxLength))

    t.setCursorPos(self.x, self.y)
    --show cursor if active
    if self.active then
        t.setBackgroundColor(self.SelectedBackgroundColor)
        t.setTextColor(self.SelectedTextColour)
    end

    -- write text
    local displayText = self.text
    if self.active then
        displayText = displayText .. "_"
    end
    t.write(displayText:sub(1, self.width))
end

function KeyInput:checkClick(mx, my)
    if my == self.y and mx >= self.x and mx < self.x + self.width then
        self.active = true
        return true
    else
        self.active = false
    end
    return false
end

function KeyInput:handleKey(event)
    if not self.active then return end

    local eventtype = event[1]
    if eventtype == "key" then
        local key = event[2]
        if key == keys.backspace then
            self.text = self.text:sub(1, -2)
            return true
        elseif key == keys.enter then
            self.active = false
            if self.callback then
                self.callback(self.text)
            end
            return true
        end
    elseif eventtype == "char" then
        local char = event[2]
        if #self.text < self.maxLength then
            self.text = self.text .. char
            return true
        end
    end
    return false
end

return KeyInput