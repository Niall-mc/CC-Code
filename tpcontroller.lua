local ButtonAPI = require "ButtonAPI"
local modem = peripheral.find("modem")
local REPLY = 10
modem.open(REPLY)

local windowSize = {term.getSize()}
local windowWidth = windowSize[1]
local windowHeight = windowSize[2]

local users = {
    ["Niall"] = colours.green,
    ["Fusion"] = colours.blue,
    ["dacilo"] = colours.red,
    ["KJ"] = colours.orange
}

local destinations = {
    ["Dac Corp"] = 20,
    ["KJ Corp"] = 30
}

local userButtons = {}
local y = 2
for u = 1, #users do
    userButtons[u] = ButtonAPI.createButton(2, y, nil, nil, users[u], colours.red, setUser)
    y = y + 3
end

local destinationButtons = {}
y = 2
for u = 1, #destinations do
    ButtonAPI.createButton(5, y, nil, nil, destinations[u], colours.red, setDestination)
    y = y + 3
end

local tpButton = ButtonAPI.createButton(windowHeight / 2, windowHeight - 3, nil, nil, "Teleport!", colours.red, teleport)

local currentUser = nil
local function setUser(self, theUser)
    setCurrentButton(self, nil)
    currentUser = users[theUser]
end

local currentDestination = nil
local function setDestination(self, theDestination)
    setCurrentButton(nil, self)
    currentDestination = destinations[theDestination]
end

local function teleport(userColor, dest)
    if user and dest then
        modem.transmit(dest, REPLY, userColor)
    end
end


local currentUserButton = {}
local currentDestinationButton = {}
local function setCurrentButton(theUserButton, theDestinationButton)
    if theUserButton then
        currentUserButton:update(colours.red, nil)
        theUserButton:update(colours.green, nil)
        currentUserButton = theUserButton
    end
    if theDestinationButton then
        currentDestinationButton:update(colours.red, nil)
        theDestinationButton:update(colours.green, nil)
        currentDestinationButton = theDestinationButton
    end
end

local function drawUI(self)
    if self then setCurrentButton(self) end
    term.clear()
    ButtonAPI.drawButtons(userButtons)
    ButtonAPI.drawButtons(destinationButtons)
    tpButton:draw()
end

drawUI()
-- Begin event loop
while true do
    local eventData = {os.pullEvent()}
    if eventData[1] == "mouse_click" then
        for a = 1, #userButtons do
            local theButton = userButtons[a]
            if theButton:clicked(eventData[3], eventData[4]) then
                theButton:onClickMethod(theButton.text)
                break
            end
        end

        for a = 1, #destinationButtons do
            local theButton = destinationButtons[a]
            if theButton:clicked(eventData[3], eventData[4]) then
                theButton:onClickMethod(slot)
                break
            end
        end

        local theButton = tpButton
        if theButton:clicked(eventData[3], eventData[4]) then
            theButton:onClickMethod(currentDestination, currentUser)
        end
    end
end