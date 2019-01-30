-- TODO: Get string code for relevant Materials
-- TODO: read() for every ore
local mine = ("Gold Ore", "Diamond Ore", "Iron Ore")

local slotFuel = 1
local slotTorch = 2
local slotChestFuel = 3
local slotChestShit = 4

local torchDistance = 7

write("Tunnel length: )
local tunnelLength = read()

write("Spacing between Tunnels: ")
local spacing = read()

write("Side ajacent tunnels: ")
write("1 - Left")
write("2 - Right")
local side = read()

write("Fuel slot: " .. slotFuel)
write("Torch slot: " .. slotTorch)
write("Enderchest Fuel slot: " .. slotChestFuel)
write("Enderchest Shit slot: " .. slotChestShit)
write("-----------------------------")
write("Press Enter to continue")

-- Turtle starting
turtle.select(slotFuel)
turtle.refuel()

print("Turtle ready")

-- Starting position: Bottom
turtle.up()

function place(slot)
        turtle.turnRight()
        turtle.turnRight()

        turtle.select(slot)
        turtle.place()
                                
        turtle.turnLeft()
        turtle.turnLeft()
end

function store(slot)
        turtle.select(slotChestShit)
        turtle.placeDown()

        turtle.select(slot)
        turtle.dropDown()

        turtle.digDown()
end

function getFuel()
        turtle.select(slotChestFuel)
        turtle.placeDown()

        turtle.select(slotFuel)
        turtle.suckDown(63)
        turtle.digDown()
end

function move(length)
        for i = 1, length do
                -- Basic Movement
                if turtle.detect() == true then
                        turtle.dig()
                end
                
                turtle.forward()
                
                if turtle.detectUp() == true then
                        turtle.digUp()
                end

                if turtle.detectDown() == true then
                        turtle.digDown()
                end

                if turtle.getFuelLevel() == 1 then
                        turtle.select(slotFuel)
                        turtle.refuel()
                end

                -- Check if moved torchDistance Blocks
                -- TODO: move efficient: i is a multiple of torchDistance
                for a = 0, torchDistance * torchDistance do
                        if i = a * torchDistance then
                                place(slotTorch)
                        end
                end

                -- If a slot is full -> store in ender chest
                for a = 5, 12 do
                        if turtle.getItemSpace(a) == 0 then
                                store(a);
                        end
                end

                -- If fuel slot is empty -> refuel
                if turtle.getItemCount(slotFuel) == 1 then
                        getFuel()
                end

                -- TODO: Detect and mine specific ores
        end
end

function moveLeft()
        turtle.turnLeft()
        turtle.move(spacing + 1)
        turtle.turnLeft()
end

function moveRight()
        turtle.turnRight()
        move(spacing + 1)
        turtle.turnRight()
end

-- TODO: Set slots for torch / Fuel
-- TODO: Place torch
while true do
        -- Turtle continue left
        if side == 1 then
                move(tunnelLength)
                moveLeft()

                move(tunnelLength)
                moveRight()
        end

        -- Turtle continue right
        if side == 2 then
                move(tunnelLength)
                moveRight()

                move(tunnelLength)
                moveLeft()
        end
end