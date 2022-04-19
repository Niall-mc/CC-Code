local ButtonAPI = require "ButtonAPI"
local modem = peripheral.find("modem")
modem.open(10)
local windowSize = {term.getSize()}
local windowWidth = windowSize[1]
local windowHeight = windowSize[2]

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
local tpButton = {}
local currentUserButton = nil
local currentLocationButton = nil

local theUser = nil
local theLocation = nil

local function setCurrentButton(userButton, locButton)
    if userButton then
        if currentUserButton then currentUserButton:update(colours.red, nil) end
        userButton:update(colours.green, nil)
        currentUserButton = userButton
    end
    if locButton then
        if currentLocationButton then currentLocationButton:update(colours.red, nil) end
        locButton:update(colours.green, nil)
        currentLocationButton = locButton
    end
end

local function setUser(self, user)
    theUser = math.floor(user)
    setCurrentButton(self, nil)
end

local function setLocation(self, location)
    theLocation = math.floor(location)
    setCurrentButton(nil, self)
end

local function teleport()
    if theUser and theLocation then
        modem.transmit(theLocation, 10, theUser)
    end
end

local function receiveTeleport(user)
    rs.setBundledOutput("left", user)
    sleep(1)
    rs.setBundledOutput("left", colours.black)
end

local function createButtons()
    local y = 2
    for i = 1, #users do
        local button = ButtonAPI.createButton(2, y, nil, nil, users[i][1], colours.red, setUser)
        table.insert(userButtons, button)
        y = y + 3
    end
    y = 2
    for i = 1, #locations do
        local text = locations[i][1]
        local button = ButtonAPI.createButton(windowWidth - (#text + 2), y, nil, nil, text, colours.red, setLocation)
        table.insert(locationButtons, button)
        y = y + 3
    end
    tpButton = ButtonAPI.createButton(windowWidth / 2 - 4, windowHeight - 3, nil, nil, "Teleport", colours.red, teleport)
    tpButton:draw()
    ButtonAPI.drawButtons(userButtons)
    ButtonAPI.drawButtons(locationButtons)
end

term.clear()
createButtons()

while true do
    local eventData = {os.pullEvent()}
    local eventName = eventData[1]
    if eventName == "mouse_click" then
        for a = 1, #userButtons do
            local theButton = userButtons[a]
            if theButton:clicked(eventData[3], eventData[4]) then
                theButton:onClickMethod(users[a][2])
                break
            end
        end

        for a = 1, #locationButtons do
            local theButton = locationButtons[a]
            if theButton:clicked(eventData[3], eventData[4]) then
                theButton:onClickMethod(locations[a][2])
                break
            end
        end

        if tpButton:clicked(eventData[3], eventData[4]) then
            tpButton:onClickMethod()
        end
    elseif eventName == "modem_message" then
        receiveTeleport(eventData[5])
    end
end
