local ender = peripheral.find("enderstorage:ender_chest")

local controllers = table.pack(peripheral.find("storagedrawers:controller"))
local chests = table.pack(peripheral.find("ironchest:obsidian_chest"))

local magicLocation = peripheral.getName(chests[1])
local magicFilter = {"nouveau", "astral", "eidolon", "rune", "tome", "enchanted", "potion", "forbidden", "artifacts", "mana",
                    "dragon_breath", "ender_air", "charm", "brewing"}

local immersiveLocation = peripheral.getName(chests[2])
local immersiveFilter = {"immersive", "tetra"}

local someMachinesLocation = peripheral.getName(chests[3])
local machineFilter = {"create", "foregoing", "computercraft", "enderstorage", "fluxnetworks", "mekanism", "darkutils", "itemcollector"}

local organicsLocation = peripheral.getName(chests[4])
local organicItemsFilter = {"petal", "dye", "flower", "minecraft:flowers", "mushroom", "head", "tear", "shell",
                            "kelp", "bat_wing", "weed", "seed", "skull", "cactus", "alex", "web", "venison",
                            "apple", "lotus", "mud", "carapace", "forge:slimeballs", "chitin", "mysticalworld:proteins",
                            "silkworm", "neapolitan", "sapling", "vine", "fungus", "stem", "farmers", "minecraft:crops", "forge:seeds",
                            "leaf", "jelly", "antlers", "root", "fruit", "melon", "fish", "minecraft:fishes", "forge:grains", "forge:crops"}

local woodItemsLocation = peripheral.getName(chests[5])
local woodItemsFilter = {
    "scaffold", "sign", "minecraft:wooden_fences", "crafting_table",
    "drawer", "bowl", "carpentry", "boat", "minecraft:wooden_doors", "rail", "pattern",
    "ladder", "plank", "minecraft:logs", "beehive", "item_frame", "forge:chests/wooden", "minecraft:wooden_slabs",
    "minecraft:wooden_stairs", "minecraft:wooden_trapdoors", "forge:fence_gates/wooden", "minecraft:wooden_buttons", "pestle", "composter"}

local toolsArmourLocation = peripheral.getName(chests[6])
local toolsArmourFilter = {"ironchest", "armor", "armour", "helm", "chestplate", "leggings", "boots", "axe", "sword", "shovel",
                     "shears", "hoe", "hood", "disc", "bucket", "bow", "flint_and_steel", "xercamusic", "saddle", "hat"}

local stoneStuffLocation = peripheral.getName(chests[7])
local stoneStuffFilter = {"stone", "furnace", "observer", "dispenser", "smoker", "smithing"}

local locationsMap = {
    [magicLocation] = magicFilter,
    [immersiveLocation] = immersiveFilter,
    [someMachinesLocation] = machineFilter,
    [toolsArmourLocation] = toolsArmourFilter,
    [stoneStuffLocation] = stoneStuffFilter,
    [woodItemsLocation] = woodItemsFilter,
    [organicsLocation] = organicItemsFilter
}

local function moveItem(item, slot)
    local itemName = item.name
    local itemCount = item.count
    local tags = item.tags
    for i = 1, #controllers do
        local amount = ender.pushItems(peripheral.getName(controllers[i]), slot)
        if amount > 0 then
            if amount == itemCount then
                return itemCount
            end
            print("Sending " .. itemName .. " to overflow.")
            i = #controllers
        end
    end
    for k, v in pairs(locationsMap) do
        for i = 1, #v do
            if itemName:find(v[i]) or tags[v[i]] then
                return ender.pushItems(k, slot)
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