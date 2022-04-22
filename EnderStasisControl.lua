local ButtonAPI = require "ButtonAPI"
local modem = peripheral.find("modem")
local channel = 10
local cableSide = "right"
modem.open(channel)
local windowWidth, windowHeight = term.getSize()

local users = {
    {"Niall", colours.green},
    {"Fusion", colours.red},
    {"Dacilo", colours.blue},
    {"KJ", colours.orange}
}

local locations = {
    {"FusCorp", 10},
    {"DacCorp", 20},
    {"KJCorp", 30},
    {"Stronghold", 40}
}

local userButtons = {}
local locationButtons = {}

local currentUserButton = nil
local currentLocationButton = nil

local theUser = nil
local theLocation = nil

local buttonEvents = {}

local function setCurrentButton(userButton, locButton)
    if userButton then
        if currentUserButton then currentLocationButton(currentUserButton, colours.red, nil) end
        ButtonAPI.updateButton(userButton, colours.green, nil)
        currentUserButton = userButton
    end
    if locButton then
        if currentLocationButton then ButtonAPI.updateButton(currentLocationButton, colours.red, nil) end
        ButtonAPI.updateButton(locButton, colours.green, nil)
        currentLocationButton = locButton
    end
end

local function setUser(user)
    return function(self)
        theUser = math.floor(user)
        setCurrentButton(self, nil)
    end
end

local function setLocation(location)
    return function(self)
        theLocation = math.floor(location)
        setCurrentButton(nil, self)
    end
end

local function teleport()
    if theUser and theLocation then
        modem.transmit(theLocation, channel, theUser)
    end
end

local function receiveTeleport()
    while true do
        local _, _, _, _, user = os.pullEvent("modem_message")
        rs.setBundledOutput(cableSide, user)
        sleep(1)
        rs.setBundledOutput(cableSide, colours.black)
    end
end

local function createButtonsFromTable(xLoc, inputTable, outputTable, buttonMethod)
    local y = 2
    for i = 1, #inputTable do
        local item = inputTable[i]
        local button = ButtonAPI.createButton(xLoc, y, nil, nil, item[1], colours.red, buttonMethod(item[2]))
        table.insert(outputTable, button)
        table.insert(buttonEvents, ButtonAPI.wait_for_click(button))
        y = y + 3
    end
end

local function createButtons()
    -- Create the buttons
    createButtonsFromTable(2, users, userButtons, setUser)
    createButtonsFromTable(windowWidth - 12, locations, locationButtons, setLocation)
    local tpButton = ButtonAPI.createButton(windowWidth / 2 - 4, windowHeight - 3, nil, nil, "Teleport", colours.red, teleport)
    table.insert(buttonEvents, ButtonAPI.wait_for_click(tpButton))

    -- Add incomming teleport event
    table.insert(buttonEvents, receiveTeleport)

    -- Draw the buttons
    ButtonAPI.drawButtons(userButtons)
    ButtonAPI.drawButtons(locationButtons)
    ButtonAPI.drawButton(tpButton)
end

term.clear()
createButtons()

while true do
    parallel.waitForAny(table.unpack(buttonEvents))
end


