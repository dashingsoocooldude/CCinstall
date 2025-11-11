local Element = require("lib.gui.elements.element")
local Dropdown = setmetatable({}, { __index = Element })
Dropdown.__index = Dropdown

function Dropdown:new()
    local self = Element:new()
    self:setElementType("Dropdown")
    setmetatable(self, Dropdown)
    self.options = {}
    self.selectedIndex = 0
    self.isOpen = false
    self.width = 10
    self.callback = nil
    return self
end

function Dropdown:setOptions(opts)
    self.options = opts
    return self
end

function Dropdown:setSelected(index)
    if index >= 1 and index <= #self.options then
        self.selectedIndex = index
        if self.callback then
            self.callback(self.options[index])
        end
    end
    return self
end

function Dropdown:onSelect(cb)
    self.callback = cb
    return self
end

function Dropdown:toggle()
    self.isOpen = not self.isOpen
    return self
end

function Dropdown:draw(term)
    Element.draw(self, term)
    local t = term or self.term
    if not t then return end

    -- calculate max width of options
    local maxWidth = 0
    for _, option in ipairs(self.options) do
        maxWidth = math.max(maxWidth, #option)
    end
    self.width = maxWidth

    -- draw selected option with dropdown arrow
    t.setCursorPos(self.x, self.y)
    local text
    if self.selectedIndex > 0 then
        text = self.options[self.selectedIndex]
    else
        text = string.rep(" ", maxWidth)
    end
    t.write(text)

    --draw options if dropdown is open
    if self.isOpen then
        for i, option in ipairs(self.options) do
            t.setCursorPos(self.x, self.y + i)
            if i == self.selectedIndex then
                t.setBackgroundColour(self.SelectedBackgroundColor) -- selected colour
                t.setTextColour(self.SelectedTextColour)
            else
                t.setBackgroundColour(self.backgroundColor)
                t.setTextColour(self.TextColour)
            end
            t.write(option:sub(1, self.width))
        end
    end
end

function Dropdown:checkClick(mx, my)
    -- Check if click is within dropdown area
    if mx >= self.x and mx < self.x + self.width then
        if my == self.y then
            -- Click on main dropdown
            self:toggle()
            return true
        elseif self.isOpen and my > self.y and my <= self.y + #self.options then
            -- Click on option
            self:setSelected(my - self.y)
            self.isOpen = false
            return true
        end
    else
        -- Click outside dropdown
        self.isOpen = false
    end
    return false
end

return Dropdown
