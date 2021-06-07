local function draw(self)
    term.setCursorPos(self.x, self.y)
    paintutils.drawFilledBox(self.x, self.y, (self.x + self.width) - 1, (self.y + self.height) - 1, self.colour)
    term.setCursorPos(self.x+1, self.y+1)
    term.setTextColor(colours.black)
    term.write(self.text)
    term.setBackgroundColor(colours.black)
end

local function drawButtons(buttons)
    for _, button in pairs(buttons) do
        button:draw()
    end
end

local function update(self, colour, text) 
    self.colour = colour or self.colour
    self.text = text or self.text
    self:draw()
end

local function clicked(self, x, y)
    return x >= self.x and x < (self.x + self.width) and y >= self.y and y < (self.y + self.height)
end

local function createButton(x, y, width, height, text, colour, onClickMethod)
    return {
        x = x,
        y = y,
        width = width or #text + 2,
        height = height or 2,
        colour = colour,
        text = text,
        onClickMethod = onClickMethod,
        draw = draw,
        update = update,
        clicked = clicked
    }
end

return {
    createButton = createButton,
    drawButtons = drawButtons
}