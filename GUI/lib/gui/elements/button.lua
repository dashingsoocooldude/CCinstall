print("button.lua loaded")

local Element = require("lib.gui.elements.element")
local Button = setmetatable({}, { __index = Element })
Button.__index = Button

function Button:new()
    local self = Element:new()
    self:setElementType("Button")
    setmetatable(self, Button)
    self.text = "Button"
    self.callback = nil
    self.isPressed = false
    return self
end

-- only need button specific methods
function Button:setText(txt)
    self.text = txt
    return self
end

function Button:onClick(cb)
    self.callback = cb
    return self
end

function Button:draw(term)
    Element.draw(self, term)
    local t = term or self.term
    if not t then return end

    -- use selected colors if pressed
    if self.isPressed then
        Element.applyColors(t, self.SelectedBackgroundColor, self.SelectedTextColour)
    else
        Element.applyColors(t, self.backgroundColor, self.TextColour)
    end

    t.setCursorPos(self.x, self.y)
    t.write(self.text)
end

function Button:checkClick(mx, my)
    if my == self.y and mx >= self.x and mx < self.x + #self.text then
        self.isPressed = true
        self:draw() -- redraw with pressed state

        -- return to normal state
        
            
        self.pressTimer = os.startTimer(1)
        print("sleep ended")
        self.isPressed = false
        self:draw()

        if self.callback then
            self.callback(self, mx, my)
        end
        return true
    end
    return false
end

function Button:handleTimer(timerId)
    if self.pressTimer and timerId == self.pressTimer then
        self.isPressed = false
        self:draw()
        self.pressTimer = nil
        return true
    end
    return false
end

return Button
