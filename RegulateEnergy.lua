local cell = peripheral.wrap("back")
local maxEnergy = cell.getEnergyCapacity()
local on = maxEnergy / 5
local off = maxEnergy * 0.8
 
local function switch(onOff)
    --rs.setAnalogOutput("left", onOff)
    rs.setAnalogOutput("right", onOff)
    rs.setAnalogOutput("bottom", onOff)
end
 
while true do
    local energy = cell.getEnergy()
    if energy < on then
        switch(15)
    elseif energy > off then
        switch(0)
    end
    sleep(10)
end
