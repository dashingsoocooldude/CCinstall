local Element = require("lib.gui.elements.element")
local Label = setmetatable({}, { __index = Element })
Label.__index = Label

function Label:new()
    local self = Element:new()
    self:setElementType("Label")
    setmetatable(self, Label)
    self.text = "Label"
    return self
end

function Label:setText(txt)
    self.text = txt
    return self
end

function Label:draw(term)
    Element.draw(self, term)
    local t = term or self.term
    if not t then return end

    t.setCursorPos(self.x, self.y)
    t.write(self.text)
end

return Label
