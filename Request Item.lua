local tArgs = {...}
local chest = peripheral.wrap("ironchest:diamond_chest_5")
local controllers = table.pack({
    peripheral.find("storagedrawers:controller")
})[1]

local item = string.lower(tostring(tArgs[1]))
local amount = tonumber(tArgs[2])

for key, drawer in pairs(controllers) do
  local list = drawer.list()
  for i = 2, #list do
    local drawerItem = list[i]
    if(drawerItem) then
        local drawerItemName = drawerItem.name:gsub("_", ""):lower()
        if(drawerItemName:find(item)) then
          chest.pullItems(peripheral.getName(drawer), i, amount)
        end
    end
  end   
end