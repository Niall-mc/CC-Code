local ButtonAPI = require "ButtonAPI"
local modem = peripheral.wrap("top")
local channel = 20
modem.open(channel)
local playerDetector = peripheral.find("playerDetector")
local integrators = table.pack(peripheral.find("redstoneIntegrator"))
local monitor = peripheral.wrap("back")
term.redirect(monitor)
local windowWidth, windowHeight = term.getSize()

monitor.setPaletteColour(colours.red, 0xCD7F32)
monitor.setPaletteColour(colours.green, 0xF2B233)
monitor.setPaletteColour(colours.orange, 0x7FCC19)

for i = 1, #integrators do integrators[i].setOutput("back", true) end

local users = {
    FusionGB = integrators[3],
    Dacilo = integrators[2],
    notaspy0_0 = integrators[1],
    JTGTheGreat4798 = integrators[4],
    beccaboop10 = integrators[5],
    DGibsy = integrators[6],
    NiallDoherty = integrators[7],
}

for k, v in pairs(users) do
    term.native().write(k .. " : " .. peripheral.getName(v) .. "\n")
    local x, y = term.native().getCursorPos()
    term.native().setCursorPos(1, y + 1)
end

local locations = {
    Niall = 10,
    --Fus = 20,
    Dac = 30,
    Stepho = 40,
    ["Jake & Becca"] = 50,
    Gibs = 60,
    Stronghold = 70
}

local locationButtons = {}
local currentLocationButton = nil

local theUser = nil
local theLocation = nil

local buttonEvents = {}

local function setCurrentButton(locButton)
    if locButton then
        if currentLocationButton then ButtonAPI.updateButton(currentLocationButton, colours.red, nil) end
        ButtonAPI.updateButton(locButton, colours.green, nil)
        currentLocationButton = locButton
    end
end

local function setLocation(location)
    return function(self)
        theLocation = math.floor(location)
        setCurrentButton(self)
    end
end

local function teleport()
    local players = playerDetector.getPlayersInRange(5)
    local player
    if players then
        player = players[1]
    else
        return
    end
    
    if theLocation then
        modem.transmit(theLocation, channel, player)
    end
end

local function receiveTeleport()
    while true do
        local _, _, c, _, user = os.pullEvent("modem_message")
        if c ~= channel then return end
        local integrator = users[user]
        if integrator then
            -- top = dropper for pearl
            -- back = trapdoor to smack pearl
            integrator.setOutput("back", false)
            integrator.setOutput("top", true)
            sleep(1)
            integrator.setOutput("top", false)
            sleep(2)
            integrator.setOutput("back", true)
        end
    end
end

local function createButtonsFromTable(xLoc, inputTable, buttonMethod)
    local yLoc = 2
    if not xLoc then xLoc = 2 end

    local buttons = {}
    for key, value in pairs(inputTable) do
        local item = key
        local button = ButtonAPI.createButton(xLoc, yLoc, nil, nil, key, colours.red, buttonMethod(value))
        table.insert(buttons, button)
        table.insert(buttonEvents, ButtonAPI.wait_for_click(button))
        yLoc = yLoc + 3
        if yLoc > 13 then
            yLoc = 2
            xLoc = xLoc + 13
        end
    end

    return buttons
end

local function createButtons()
    -- Create the buttons
    locationButtons = createButtonsFromTable(nil, locations, setLocation)
    local tpButton = ButtonAPI.createButton(windowWidth / 2 - 4, windowHeight - 3, nil, nil, "Teleport", colours.orange, teleport)
    table.insert(buttonEvents, ButtonAPI.wait_for_click(tpButton))

    -- Add incomming teleport event
    table.insert(buttonEvents, receiveTeleport)

    -- Draw the buttons
    ButtonAPI.drawButtons(locationButtons)
    ButtonAPI.drawButton(tpButton)
end

term.clear()
createButtons()

while true do
    parallel.waitForAny(table.unpack(buttonEvents))
end
