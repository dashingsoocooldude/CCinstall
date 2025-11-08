local Element = {}
Element.__index = Element

function Element:new(o)
    local self = setmetatable({
        x = 1,
        y = 1,
        width = 1,
        height = 1,
        backgroundColor = colors.black,
        TextColour = colors.white,
        SelectedBackgroundColor = colors.gray,
        SelectedTextColour = colors.white,
        term = nil
    }, Element)

    -- get term size for elements that need it
    if term then 
        self.termWidth, self.termHeight = term.getSize()
    else
        self.termWidth, self.termHeight = 51, 19 -- default
    end

    -- set default sizes based on element type
    if self.elementType == "TabControl" then
        self.width = self.termWidth
        self.height = self.termHeight
    end

    return self
end

function Element:setElementType(type)
    self.elementType = type
    return self
end


-- safe helper to apply bg/fg to a terminal (handles both spellings)
function Element.applyColors(t, bg, fg)
    if not t then return end
    if bg ~= nil then
        if type(t.setBackgroundColor) == "function" then t.setBackgroundColor(bg) end
        if type(t.setBackgroundColour) == "function" then t.setBackgroundColour(bg) end
    end
    if fg ~= nil then
        if type(t.setTextColor) == "function" then t.setTextColor(fg) end
        if type(t.setTextColour) == "function" then t.setTextColour(fg) end
    end
end

function Element:setPosition(x, y)
    self.x = x
    self.y = y
    return self
end

function Element:setSize(width, height)
    self.width = width
    self.height = height
    return self
end

function Element:setBackgroundColour(color)
    self.backgroundColor = color
    return self
end

function Element:setTextColour(color)
    self.TextColour = color
    return self
end

function Element:setSelBackgroundColor(color)
    self.SelectedBackgroundColor = color
    return self
end

function Element:setSelTextColor(color)
    self.SelectedTextColour = color
    return self
end

function Element:setTerm(termObj)
    self.term = termObj
    if self.term and type(self.term.getSize) == "function" then
        local w, h = self.term.getSize()
        self.termWidth, self.termHeight = w, h
        -- of element has no explicit size yet, make TabControl fill term
        if self.elementType == "TabControl" then
            if not self.width or self.width <= 1 then self.width = w end
            if not self.height or self.height <= 1 then self.height = h end
        end
        -- other elements go here
    end
    return self
end

-- base draw method to handle colours
function Element:draw(term)
    local t = term or self.term
    if not t then return end

    Element.applyColors(t, self.backgroundColor, self.TextColour)
end

return Element