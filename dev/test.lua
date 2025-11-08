local gui = require("lib.gui")

local monitor = peripheral.find("monitor")

local main = gui.createFrame("main")

-- Create tab control with options
main:setTerm(monitor)
local tabs = main:addTabControl()
    
    :setBackgroundColour(colors.black)
    :setTextColour(colors.lightGray)

-- Create three tabs
local overview = tabs:newTab("Overview")
local editor = tabs:newTab("Editor")
local settings = tabs:newTab("Settings")

-- Overview tab: add a label and a button
overview:addLabel()
    :setPosition(2, 2)
    :setText("Welcome to the demo")

overview:addButton()
    :setPosition(2, 4)
    :setText("Click me")
    :setBackgroundColour(colors.black)
    :setTextColour(colors.lightGray)
    :onClick(function()
        overview:addLabel()
                :setText("Button Clicked!")
                :setPosition(2, 6)
                :setTextColour(colors.red)
                :draw()
    end)

-- Editor tab: textbox with some sample text
editor:addKeyInput()
    :setPosition(2, 2)
    :setSize(12, 1)
    :setBackgroundColour(colors.black)
    :setTextColour(colors.white)
    :setText("Type here...")

-- Settings tab: show some inputs
settings:addLabel()
    :setPosition(2, 2)
    :setText("Settings")

settings:addLabel()
    :setPosition(2, 4)
    :setText("Username:")

settings:addLabel()
    :setPosition(2, 6)
    :setText("Password:")

settings:addKeyInput()
    :setPosition(12, 4)
    :setSize(20, 1)
    :setBackgroundColour(colors.black)
    :setTextColour(colors.white)

settings:addKeyInput()
    :setPosition(12, 6)
    :setSize(20, 1)
    :setBackgroundColour(colors.black)
    :setTextColour(colors.white)

gui.run("main")