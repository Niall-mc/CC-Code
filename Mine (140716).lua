local tArgs = {...}
local forward = tonumber(tArgs[1])
local across = tonumber(tArgs[2])

local actualDown = tonumber(tArgs[3])
local remainder = actualDown % 3
local down = math.ceil(actualDown / 3)

local direction = tArgs[4]

local function readValue(fileName)
  if fs.exists(fileName) then
    local file = fs.open(fileName, "r")
    local value = file.readLine()
    file.close()
    return value
  end

  return 1
end

local function writeValue(fileName, value)
  local file = fs.open(fileName, "w")
  file.writeLine(tostring(value))
  file.close()
end

local cForward, cAcross, cDown = tonumber(readValue("mine.forward")), tonumber(readValue("mine.across")), tonumber(readValue("mine.down"))

if fs.exists("mine.direction") then
  direction = readValue("mine.direction")
end


local function dig()
  while turtle.detect() do
    turtle.dig()
  end
end

local function digDown()
  if turtle.detectDown() then
    turtle.digDown()
  end
end

local function digUp()
  while turtle.detectUp() do 
    turtle.digUp()
  end
end

local function move()
  while not turtle.forward() do
    turtle.attack()
    turtle.dig()
  end
end

local function moveDown(amount)
  for i = 1, amount do
    digDown()
    turtle.down()
  end
end

local function changeDirection()
  if direction == "right" then
    direction = "left"
  else
    direction = "right"
  end
  writeValue("mine.direction", direction)
end

local function unload()
  digUp()
  turtle.select(16)
  turtle.placeUp()
  for i = 1, 15 do
    turtle.select(i)
    local count = 0
    while turtle.getItemCount(i) > 0 do
      turtle.dropUp()
	if count > 0 then
    print("Ender chest full!")
    sleep(5)
	end
	count = 1
    end
  end
  turtle.select(16)
  turtle.digUp()
  turtle.select(1)
end

local function checkFull()
  if turtle.getItemCount(15) > 0 then
    unload()
  end
end

local function mineForward(length)
  for x = cForward, length do
    checkFull()
    if x ~= length then
      dig()
    end
    digUp()
    digDown()
    if x < length then
      move()
    end
    writeValue("mine.forward", x)
  end
end

local function turn()
  if direction == "right" then
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
end

local function nextRow()
  turn()
  dig()
  move()
  turn()
  changeDirection()
end

local function nextLevel(last)
  turn()
  turn()
  if not last then
    moveDown(3)
  else
      if remainder == 2 then
        moveDown(2)
      else
        moveDown(1)
      end
  end
end

local function main()
  for x = cDown, down do
    for y = cAcross, across do
      mineForward(forward)
      if y < across then
        nextRow()
      end
      writeValue("mine.across", y)
    end


    local last = (x == down - remainder)
    if x ~= down then
        nextLevel(last)
    else
        turtle.down()
    end
    writeValue("mine.down", x)
  end
end

main()
