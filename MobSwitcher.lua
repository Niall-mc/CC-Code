local ButtonAPI = require "ButtonAPI"

local drawerController = peripheral.find("storagedrawers:controller")
local chests = {peripheral.find("minecraft:chest")}
local inputChest = peripheral.getName(chests[2])
local outputChest = peripheral.getName(chests[1])
local windowSize = {term.getSize()}
local windowWidth = windowSize[1]
local windowHeight = windowSize[2]
local currentScreen = 1
-- Assume a mob is in the machine
local mobInMachine = true
local spawnerOn = false

local function formatName(string)
    local actualName = string:sub(string:find(":") + 1, #string - 1)
    return actualName:sub(1, 1):upper()..actualName:sub(2)
end

local function getMobNames()
    local mobNames = {}
    for a = 2, drawerController.size() do
        local item = drawerController.getItemDetail(a)
        if item then
            mobNames[a] = formatName(item.displayName)
        end
    end
    return mobNames
end

local function switch(self)
    if spawnerOn then
        spawnerOn = false
        self:update(colours.red, "Off")
        rs.setAnalogOutput("back", 0)
        return
    end
    spawnerOn = true
    self:update(colours.green, "On")
    rs.setAnalogOutput("back", 15)
end

local currentButton = {}
local function setCurrentButton(theButton)
    currentButton:update(colours.red, nil)
    theButton:update(colours.green, nil)
    currentButton = theButton
end

local function retrieveMob(self)
    if spawnerOn then return end
    if mobInMachine then
        if self then setCurrentButton(self) end
        rs.setAnalogOutput("bottom", 0)
        local counter = 0
        while not (drawerController.pullItems(outputChest, 1) > 0) do
            sleep(0.1)
            counter = counter + 1
            if counter == 15 then break end
        end
        rs.setAnalogOutput("bottom", 15)
    end
    mobInMachine = false
end

local function swapMob(self, currentSlot)
    if spawnerOn then return end
    setCurrentButton(self)
    retrieveMob(self)
    while not (drawerController.pushItems(inputChest, currentSlot) > 0) do sleep(0.1) end
    mobInMachine = true
end

local function createScreens(mobNames)
    local screens = {}
    local screen = 1
    screens[screen] = {}
    local xValue = 2
    local yValue = 2

    for slot, name in pairs(mobNames) do
        if xValue + #name + 3 > windowWidth then
            xValue = 2
            yValue = yValue + 3
            if yValue > windowHeight - 5 then
                yValue = 2
                screen = screen + 1
                screens[screen] = {}
            end
        end
        screens[screen][slot] =  ButtonAPI.createButton(xValue, yValue, nil, nil, mobNames[slot], colours.red, swapMob)
        xValue = xValue + #name + 3
    end

    local i = 0
    while screens[currentScreen][i] == nil do i = i + 1 end
    currentButton = screens[currentScreen][i]
    return screens
end

local function drawNewScreen(self, screens, bottom)
    if self then setCurrentButton(self) end
    term.clear()
    ButtonAPI.drawButtons(screens[currentScreen])
    ButtonAPI.drawButtons(bottom)
end

local function previousScreen(self, screens, bottom)
    if currentScreen > 1 then
        currentScreen = currentScreen - 1
        drawNewScreen(self, screens, bottom)
        return
    end
    self:update(colours.red, nil)
end

local function nextScreen(self, screens, bottom)
    if currentScreen < #screens then
        currentScreen = currentScreen + 1
        drawNewScreen(self, screens, bottom)
        return
    end
    self:update(colours.red, nil)
end

-- Make sure spawner is off at startup
rs.setAnalogOutput("back", 0)

-- Make sure spawner is empty at startup
retrieveMob()

-- Generate list of mobs in drawers
local mobNames = getMobNames()

-- Create buttons for each mob and divide them into screens
local screens = createScreens(mobNames)

-- Create bottom row buttons
local prevButton = ButtonAPI.createButton(2, windowHeight - 1, nil, nil, "Previous", colours.red, previousScreen)
local retrieveButton = ButtonAPI.createButton((windowWidth / 2) - 5, windowHeight - 1, nil, nil, "Retrieve", colours.red, retrieveMob)
local onOffButton = ButtonAPI.createButton((windowWidth / 2) + 7, windowHeight - 1, nil, nil, "Off", colours.red, switch)
local nextButton = ButtonAPI.createButton(windowWidth - 6, windowHeight-1, nil, nil, "Next", colours.red, nextScreen)
local bottomRow = {prevButton, retrieveButton, onOffButton, nextButton}

-- Draw the first screen
drawNewScreen(nil, screens, bottomRow)

-- Begin event loop
while true do
    local eventData = {os.pullEvent()}
    if eventData[1] == "mouse_click" then
        -- Check if the click occured on one of the bottom row buttons
        for a = 1, #bottomRow do
            local theButton = bottomRow[a]
            if theButton:clicked(eventData[3], eventData[4]) then
                -- Parameters will be ignore for retrieve and switch functions
                theButton:onClickMethod(screens, bottomRow)
                break
            end
        end

        -- Check if the click occured on one of the mob buttons
        for slot, button in pairs(screens[currentScreen]) do
            local theButton = button
            if theButton:clicked(eventData[3], eventData[4]) then
                theButton:onClickMethod(slot)
                break
            end
        end
    end
end
