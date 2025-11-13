local player = {
    location = "start",
    inventory = {}
}

local locations = {
    start = {
        description = "You are standing at the entrance of a dark forest. A path leads north.",
        exits = { north = "forest" },
        items = {}
    },
    forest = {
        description = "You are in a dense forest. Sunlight barely penetrates the canopy.",
        exits = { south = "start", east = "clearing" },
        items = {"sword"}
    },
    clearing = {
        description = "You are in a clearing. A small cottage stands before you.",
        exits = { west = "forest" },
        items = {}
    }
}

local items = {
    sword = {
        description = "A rusty sword.",
        usable = false
    }
}

-- Helper Functions

local function display_location()
    local loc = locations[player.location]
    print("\n" .. loc.description)
    -- Display available exits
    local exits_str = "Exits: "
    local exit_count = 0
    for direction, _ in pairs(loc.exits) do
        exits_str = exits_str .. direction .. " "
        exit_count = exit_count + 1
    end
    if exit_count > 0 then
        print(exits_str)
    end
    -- Display items in the location
    if #loc.items > 0 then
        local items_str = "You see: "
        for i, item_name in ipairs(loc.items) do
            items_str = items_str .. items[item_name].description .. " "
        end
        print(items_str)
    end
end

local function get_input()
    io.write("> ")
    local input = string.lower(io.read())
    return input
end

local function go(direction)
    local loc = locations[player.location]
    if loc.exits[direction] then
        player.location = loc.exits[direction]
        display_location()
    else
        print("You can't go that way.")
    end
end

local function take(item_name)
    local loc = locations[player.location]
    for i, item_in_loc in ipairs(loc.items) do
        if item_in_loc == item_name then
            table.remove(loc.items, i)
            table.insert(player.inventory, item_name)
            print("You take the " .. items[item_name].description .. ".")
            return
        end
    end
    print("There is no such item here.")
end

local function inventory()
    if #player.inventory == 0 then
        print("You are not carrying anything.")
    else
        print("You are carrying:")
        for i, item_name in ipairs(player.inventory) do
            print("- " .. items[item_name].description)
        end
    end
end

-- Game Loop

display_location()

while true do
    local command = get_input()

    if command == "quit" then
        print("Goodbye!")
        break
    elseif command == "north" or command == "south" or command == "east" or command == "west" then
        go(command)
    elseif string.sub(command, 1, 4) == "take" then
        local item_name = string.sub(command, 6) -- Extract item name after "take "
        take(item_name)
    elseif command == "inventory" then
        inventory()
    else
        print("I don't understand.")
    end
end
