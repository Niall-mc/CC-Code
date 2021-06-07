local tArgs = {...}
forward = tonumber(tArgs[1])
across = tonumber(tArgs[2])

actualDown = tonumber(tArgs[3])
remainder = actualDown % 3
down = math.ceil(actualDown / 3)

direction = tArgs[4]

function dig()
  while turtle.detect() do
      turtle.dig()
  end
end

function digDown()
  if turtle.detectDown() then
    turtle.digDown()
  end
end

function digUp()
  while turtle.detectUp() do 
    turtle.digUp()
  end
end

function move()
  while not turtle.forward() do
    turtle.attack()
    turtle.dig()
  end
end

function moveDown(amount)
  for i = 1, amount do
    digDown()
    turtle.down()
  end
end

function changeDirection()
  if(direction == "right") then
    direction = "left"
  else
    direction = "right"
  end
end

function unload()
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

function checkFull()
  while turtle.getItemCount(15) > 0 do
    if not unload() then
        print("Ender chest full!")
        sleep(10)
    end
  end
end

function mineForward(length)
  for x = 1, length do
    checkFull()
    if x ~= length then
      dig()
    end
    digUp()
    digDown()
    if x < length then      
      move()
    end
  end
end

function turn()
  if(direction == "right") then
    turtle.turnRight()
  else
    turtle.turnLeft()
  end
end

function nextRow()
  turn()
  dig()
  move()
  turn()
  changeDirection()
end

function nextLevel(last)
  turn()
  turn()
  if not last then
    moveDown(3)
  else
      if(remainder == 2) then
        moveDown(2)
      else
        moveDown(1)
      end
  end
end

function main()
  for x = 1, down do
    for y = 1, across do
      mineForward(forward)
      if y < across then
        nextRow()  
      end
    end
    
    
    last = (x == down-remainder)
    if(x ~= down) then
        nextLevel(last)
    else
        turtle.down()
    end    
  end
end

main()