local Element = require("lib.gui.elements.element")
local TabControl = setmetatable({}, { __index = Element })
TabControl.__index = TabControl

function TabControl:new(opts)
    local self = Element:new()
    self:setElementType("TabControl")
    setmetatable(self, TabControl)

    opts = opts or {}
    self.x = opts.x or 1
    self.y = opts.y or 1
    -- if caller specified size use it, otherwise leave default (1)
    -- so setTerm can fill actual terminal size later
    self.width = opts.width or self.width
    self.height = opts.height or self.height

    -- header config
    self.headerHeight = opts.headerHeight or 1
    self.headerBackground = opts.headerBackground or colors.gray
    self.headerText = opts.foreground or colors.white
    self.tabPadding = opts.tabPadding or 1 -- spaces around label text

    -- body config
    self.background = opts.background or colors.black
    self.bodyText = opts.bodyText or colors.white

    self.tabs = {}
    self.selectedIndex = 1
    self.term = opts.term or self.term

    return self
end

-- configuratuion setters
function TabControl:setSize(w, h)
    self.width = w or self.width
    self.height = h or self.height
    return self
end

function TabControl:setHeaderHeight(h)
    self.headerHeight = h or self.headerHeight
    return self
end

function TabControl:setHeaderBackground(col)
    self.headerBackground = col
    return self
end

function TabControl:setHeaderTextColour(col)
    self.headerText = col
    return self
end

function TabControl:setTabPadding(pad)
    self.tabPadding = pad or self.tabPadding
    return self
end

function TabControl:setBackgroundColour(col)
    self.background = col
    return self
end

function TabControl:setBodyTextColour(col)
    self.bodyText = col
    return self
end

-- Return top-left coordinate of content area (useful for placing elements)
function TabControl:getContentOrigin()
    return self.x, self.y + self.headerHeight
end

function TabControl:newTab(name)
    local tab = {
        name = name or "Tab",
        elements = {}
    }

    --helper to add any element by module name
    function tab:addElementModule(modName)
        local ok, ElementClass = pcall(require, "lib.gui.elements." .. modName)
        if not ok or not ElementClass then return nil end
        local el = ElementClass:new()
        el.term = tab._parent and tab._parent.term or el.term
        
        -- offset default positions so elements appear below header
        local cx, cy = tab._parent:getContentOrigin()
        -- only adjust if element left at default (1,1)
        if el.x == 1 then el.x = cx end
        if el.y == 1 then el.y = cy end

        -- wrap setPosition so future calls are relative to content origin
        if el.setPosition then
            local origSet = el.setPosition
            function el:setPosition(rx, ry)
                -- if user passes nil or 0 keep defaults
                rx = rx or 1
                ry = ry or 1
                return origSet(self, (cx - 1) + rx, (cy - 1) + ry)
            end
        end

        table.insert(self.elements, el)
        return el
    end

    -- convinience methods for common elements
    function tab:addLabel() return self:addElementModule("label") end
    function tab:addButton() return self:addElementModule("button") end
    function tab:addKeyInput() return self:addElementModule("keyinput") end
    function tab:addDropdown() return self:addElementModule("dropdown") end
    function tab:addTextBox() return self:addElementModule("textbox") end

    -- allow external code to add raw element instance
    function tab:addElementInstance(el)
        el.term = tab._parent and tab._parent.term or el.term
        local cx, cy = tab._parent:getContentOrigin()
        if el.x == 1 then el.x = cx end
        if el.y == 1 then el.y = cy end
        
        if el.setPosition then
            local origSet = el.setPosition
            function el:setPosition(rx, ry)
                rx = rx or 1
                ry = ry or 1
                return origSet(self, (cx - 1) + rx, (cy - 1) + ry)
            end
        end

        table.insert(self.elements, el)
        return el
    end

    -- attach back ref so elements get proper term from parent control
    tab._parent = self
    table.insert(self.tabs, tab)
    -- if this is the first tab, select it
    if #self.tabs == 1 then self.selectedIndex = 1 end
    return tab
end

function TabControl:draw(term)
    local t = term or self.term
    if not t then return end

    -- draw header background rows
    if type(t.setBackgroundColor) == "function" then
        t.setBackgroundColor(self.headerBackground)
        t.setTextColor(self.headerText)
    end
    for row = 0, self.headerHeight - 1 do
        t.setCursorPos(self.x, self.y + row)
        t.write(string.rep(" ", self.width))
    end

    -- draw tabs in header
    local offset = 0
    for i, tab in ipairs(self.tabs) do
        local label = string.rep(" ", self.tabPadding) .. tab.name .. string.rep(" ", self.tabPadding)
        local lx = self.x + offset
        if lx > self.x + self.width - 1 then break end

        -- selected styling
        if i == self.selectedIndex then
            -- selected uses body background to appear "active"
            if type(t.setBackgroundColor) == "function" then
                t.setBackgroundColor(self.background)
                t.setTextColor(self.bodyText)
            end
        else
            if type(t.setBackgroundColor) == "function" then
                t.setBackgroundColor(self.headerBackground)
                t.setTextColor(self.headerText)
            end
        end

        t.setCursorPos(lx, self.y)
        local spaceRemaining = (self.x + self.width) - lx
        t.write(label:sub(1, math.max(0, spaceRemaining)))
        offset = offset + #label
    end

    -- draw body background
    if type(t.setBackgroundColor) == "function" then
        t.setBackgroundColor(self.background)
        t.setTextColor(self.bodyText)
    end
    for row = 1, (self.height - self.headerHeight) do
        t.setCursorPos(self.x, self.y + self.headerHeight - 1 + row)
        t.write(string.rep(" ", self.width))
    end

    -- draw elements of the selected tab
    local active = self.tabs[self.selectedIndex]
    if active then
        for _, el in ipairs(active.elements) do
            if el.draw then el:draw(t) end
        end
    end
end

-- route clicks: header click switches tab, otherwise forward to active tab elements
function TabControl:checkClick(mx, my)
    -- header click?
    if my >= self.y and my < self.y + self.headerHeight and mx >= self.x and mx < self.x + self.width then
        local offset = 0
        for i, tab in ipairs(self.tabs) do
            local label = string.rep(" ", self.tabPadding) .. tab.name .. string.rep(" ", self.tabPadding)
            local lx = self.x + offset
            local rx = lx + #label - 1
            if mx >= lx and mx <= rx then
                self.selectedIndex = i
                return true
            end
            offset = offset + #label
        end
        return false
    end

    -- propagate to active tab elements
    local active = self.tabs[self.selectedIndex]
    if not active then return false end
    for _, el in ipairs(active.elements) do
        if el.checkClick and el:checkClick(mx, my) then
            return true
        end
    end
    return false
end

-- basic keyboard event passthrough to active elements if they impliment handleKey
function TabControl:handleKey(event)
    local active = self.tabs[self.selectedIndex]
    if not active then return false end
    for _, el in ipairs(active.elements) do
        if el.handleKey and el:handleKey(event) then
            return true
        end
    end
    return false
end

return TabControl