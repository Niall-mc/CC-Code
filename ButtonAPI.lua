local function createButton(x, y, width, height, text, colour, onClickMethod)
    return {
        x = x,
        y = y,
        width = width or #text + 2,
        height = height or 2,
        colour = colour,
        text = text,
        onClickMethod = onClickMethod
    }
end

local function drawButton(button)
    term.setCursorPos(button.x, button.y)
    paintutils.drawFilledBox(button.x, button.y, (button.x + button.width) - 1, (button.y + button.height) - 1, button.colour)
    term.setCursorPos(button.x+1, button.y+1)
    term.setTextColor(colours.black)
    term.write(button.text)
    term.setBackgroundColor(colours.black)
end

local function drawButtons(buttons)
    for _, button in pairs(buttons) do
        drawButton(button)
    end
end

local function updateButton(button, colour, text)
    button.colour = colour or button.colour
    button.text = text or button.text
    drawButton(button)
end

local function wait_for_click(button)
    return function()
        while true do
            local _, _, xLoc, yLoc = os.pullEvent({"mouse_click", "monitor_touch"})
            if xLoc >= button.x and xLoc < (button.x + button.width) and yLoc >= button.y and yLoc < (button.y + button.height) then
                button:onClickMethod()
            end
        end
    end
end

return {
    createButton = createButton,
    drawButton = drawButton,
    drawButtons = drawButtons,
    updateButton = updateButton,
    wait_for_click = wait_for_click
}
