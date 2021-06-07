local ender = peripheral.find("enderstorage:ender_chest")

local controllers = table.pack(peripheral.find("storagedrawers:controller"))
local chests = table.pack(peripheral.find("ironchest:obsidian_chest"))

local magicLocation = peripheral.getName(chests[1])
local magicFilter = "nouveau, astral, eidolon"

local immersiveLocation = peripheral.getName(chests[2])
local immersiveFilter = {"immersive", "tetra"}

local someMachinesLocation = peripheral.getName(chests[3])
local machineFilter = {"foregoing", "computercraft", "enderstorage", "fluxnetworks", "mekanism"}

local organicsLocation = peripheral.getName(chests[4])
local organicItemsFilter = {"petal", "dye", "flower", "mushroom", "head", "tear", "shell", "kelp", "bat_wing",
                            "weed", "clover", "brush", "allium", "bush", "seed", "orchid",
                            "skull", "alex", "web", "raw"}
                
local woodItemsLocation = peripheral.getName(chests[5])
local woodItemsFilter = {
    "scaffold", "minecraft:chest", "sign", "fence", "crafting_table",
    "storagedrawers", "bowl", "frame"}

local potionsLocation = peripheral.getName(chests[6])
local potionsFilter = "potions"

local forbiddenArtifactsLocation = peripheral.getName(chests[7])
local forbiddenArtifactsFilter = {"forbidden", "artifacts"}

local locationsMap = {
    [magicLocation] = magicFilter,
    [immersiveLocation] = immersiveFilter,
    [someMachinesLocation] = machineFilter,
    [potionsLocation] = potionsFilter,
    [forbiddenArtifactsLocation] = forbiddenArtifactsFilter,
    [woodItemsLocation] = woodItemsFilter,
    [organicsLocation] = organicItemsFilter
}

local function moveItem(item, slot)
    local itemName = item.name
    for i = 1, #controllers do
        local amount = ender.pushItems(peripheral.getName(controllers[i]), slot)
        if amount > 0 then
            if amount == item.count then
                return item.count
            end
            print("Sending " .. itemName .. " to overflow.")
            i = #controllers
        end
    end
    for k, v in pairs(locationsMap) do
        if type(v) == "string" then
            if itemName:find(v) then
                return ender.pushItems(k, slot)
            end
        end
        if type(v) == "table" then
            for i = 1, #v do
                if itemName:find(v[i]) then
                    return ender.pushItems(k, slot)
                end
            end
        end   
    end
    return ender.pushItems(peripheral.getName(chests[8]), slot)
end

local function moveItems()
    for i = 1, ender.size() do
        local item = ender.getItemDetail(i)
        if item then
            if moveItem(item, i) < item.count then
                print("No space for: " .. item.name)
            end
        end
    end
end

while true do
    moveItems()
    sleep(1)
end