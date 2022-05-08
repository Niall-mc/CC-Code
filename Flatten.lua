local tArgs = {...}
local forward = tonumber(tArgs[1])
local across = tonumber(tArgs[2])
local direction = tArgs[4]

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

local function moveDown(amount)
    for i = 1, amount do
      digDown()
      turtle.down()
    end
  end

local function digUp()
  local counter = 0
  while turtle.detectUp() do 
    turtle.digUp()
    turtle.up()
    counter = counter + 1
  end
  moveDown(counter)
end

local function move()
  while not turtle.forward() do
    turtle.attack()
    turtle.dig()
  end
end

local function changeDirection()
  if(direction == "right") then
    direction = "left"
  else
    direction = "right"
  end
end

local function unload()
  digUp()
  turtle.select(16)
  turtle.placeUp()
  for i = 1, 15 do
    turtle.select(i)
    turtle.dropUp()
  end
  turtle.select(16)
  turtle.digUp()
  turtle.select(1)
  return turtle.getItemCount(15) == 0
end

local function checkFull()
  while turtle.getItemCount(15) > 0 do
    if not unload() then
        print("Ender chest full!")
        sleep(10)
    end
  end
end

local function mineForward(length)
  for x = 1, length do
    checkFull()
    if x ~= length then
      dig()
    end
    if x < length then
      move()
    end
    digUp()
  end
end

local function turn()
  if(direction == "right") then
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
end

local function nextRow()
  turn()
  mineForward(1)
  turn()
  changeDirection()
end

local function main()
  for y = 1, across do
    mineForward(forward)
    if y < across then
      nextRow()
    end
  end
end

main()
