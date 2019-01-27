//TODO: Get string code for relevant Materials
//TODO: read() for every ore
local mine = ("gold", "diamonds", "iron")

write("Tunnel length: )
local tunnelLength = read()
write("Spacing between Tunnels: ")
local spacing = read()

turtle.refuel()

print("Turtle ready")

// Starting position: Bottom
turtle.up()

function move(length)
        for i = 1, length do
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
                        turtle.refuel()
                end
        end
end

// TODO: Set slots for torch / Fuel
// TODO: Place torch
while true do
        move(tunnelLength)

        turtle.turnRight()
        move(spacing + 1)
        turtle.turnRight()

        move(tunnelLength)

        turtle.turnLeft()
        turtle.move(spacing + 1)
        turtle.turnLeft()
end