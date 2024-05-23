-- TODO: 
-- -> Place chest once inventory full
-- -> Handle TODOs and not yet implemented stuff

-- User setup
write("Length of Quarray: ")
INP_Y  = tonumber(read())  -- Destination Y coord

write("Width of Quarry: ")
INP_X = tonumber(read())   -- Destination X coord

write("Height of Quarry: ")
INP_Z = tonumber(read())   -- Destination Z coord



-- Turtle global coordinates
DST   = {INP_X, INP_Y, INP_Z}  -- Destination is within boundary "-1"
tPos  = {0, 0, 0}
tFace = {0, 1, 0}  -- Direction where it's facing


-- Turn the player by pi/2 around the z-axis in mathematically positive orientation
-- and update the destination coordinates
function initTurn()
	local temp = DST[1]
	DST[1] = DST[2]
	DST[2] = - temp
	turtle.turnLeft()

	write("dest: " .. DST[1])
	write("  " .. DST[2])
	write("  " .. DST[3])
	write("")
end


-- Turn the turtle in the relative direction of the destination
-- such that DST.x and DST.y are positive
function initialize()
	write("Initializing \n")

	if DST[1] < 0 and DST[2] > 0 then
		initTurn()
	end
	if DST[1] < 0 and DST[2] < 0 then
		initTurn()
		initturn()
	end
	if DST[1] > 0 and DST[2] < 0 then
		initTurn()
		initTurn()
		initturn()
	end
	-- else: orientation already ok
	
	-- Dont include border
	DST[1] = DST[1]-1
	DST[2] = DST[2]-1
end


function abs(a)
	if a > 0 then
		return a
	end
	return -a
end

function cross(a, b)
	return {a[2]*b[3] - a[3]*b[2], a[3]*b[1] - a[1]*b[3], a[1]*b[2]-a[2]*b[1]}
end

function scalar(a, b)
	return a[1]*b[1] + a[2]*b[2] + a[3]*b[3]
end

function sub(a, b)
	return {a[1]-b[1], a[2]-b[2], a[3]-b[3]}
end


-- Turn a turtle in a direction according to the current tFace
-- direction... (x,y,z)
function turn(dir)
	if dir[3] ~= 0 then
		write("MOVE TO Z DIRECTION NOT SUPPORTED YET\n")
	end
	if scalar(dir, dir) ~= 1 then
		write("Non-normalized data received for turn command\n")
	end
	if dir[1] ~= 0 and dir[2] ~= 0 then
		write("Can only turn to discrete x-y-z direction\n")
	end

	-- Actual turning
	-- Scalar product to check for direction inversion
	local rot = scalar(dir, tFace)
	if rot == -1 then
		turtle.turnLeft()
		turtle.turnLeft()
	elseif rot == 0 then
		-- Cross product to check rotation direction
		if cross(dir, tFace)[3] == -1 then
			turtle.turnLeft()
		else
			turtle.turnRight()
		end
	end
	tFace = dir
end

function isOre(element)
	local ores = {
		"minecraft:coal",
		"minecraft:iron_ore",
		"minecraft:gold_ore", 
		"minecraft:diamond_ore",
		"minecraft:raw_copper",
		"minecraft:raw_gold",
		"minecraft:raw_iron",
		"minecraft:diamond",
		"indrev:raw_tungsten",
		"techreborn:raw_silver",
		"techreborn:raw_tin",
		"mythicmetals:raw_platinum",
		"create:raw_zinc",
		"techreborn:red_garnet_gem",
		"techreborn:ruby_gem",
		"techreborn:sapphire_gem",
		"mythicmetals:raw_osmium",
		"mythicmetals:raw_banglum"
	}

	for _, value in pairs(ores) do
        if value == element then
            return true
        end
    end
    return false
end

function isFuel(element)
	local fuelTypes = {
		"minecraft:coal",
		"minecraft:charcoal"
	}

	for _, value in pairs(ores) do
        if value == element then
            return true
        end
    end
    return false

end

-- Fix for when gravel falls down blocking the turtle
function digForward()
	while turtle.detect() do
		turtle.dig()
	end
end

-- Fuel always at pos 1
-- Returns: false if it needs fuel and could not refuel
function refuel()
	if turtle.getFuelLevel() > 1 then
		return True
	end

	for i=1,16 do
    	local data = turtle.getItemDetail(i)
    	if data and isFuel(data.name) then
    	    turtle.select(i)
			turtle.refuel(1)
			return True
    	end
    end
	return False
end

-- destination in global coordinates
function mineTo(dest)
	local diff = {dest[1] - tPos[1], dest[2] - tPos[2], dest[3] - tPos[3]}
	if diff[3] ~= 0 then
		print("MOVE TO Z DIRECTION NOT SUPPORTED YET")
	end

	-- First move in x-direction
	if diff[1] ~= 0 then
		local dir = diff[1]/abs(diff[1])
		turn({dir,0,0})
		for i=1,abs(diff[1]) do
			digForward()

			turtle.forward()
			tPos[1] = tPos[1] + dir -- Update turt pos +- 1

			refuel() -- TODO: Handle case if could not refuel
		end
	end
	
	-- Then handle y-direction
	if diff[2] ~= 0 then
		local dir = diff[2]/abs(diff[2])
		turn({0,dir,0})
		for i=1,abs(diff[2]) do
			digForward()

			turtle.forward()
			tPos[2] = tPos[2] + dir -- Update turt pos +- 1

			refuel() -- TODO: Handle case if could not refuel
		end
	end

	-- Then handle z-direction
	-- TODO: Test this
	if diff[3] ~= 0 then
		local dir = diff[3]/abs(diff[3])
		for i=1,abs(diff[3]) do
			if turtle.detectUp() then
				turtle.digUp()
			end

			turtle.up()
			tPos[3] = tPos[3] + dir

			refuel() -- TODO: Handle case if could not refuel
		end
	end
end


function clearInventory()
	for i=1,16 do -- loop over all inventory slots
        local data = turtle.getItemDetail(i) -- get the details of the item in the slot
        if data and not isOre(data.name) then -- if the item is not an ore
            turtle.select(i) -- select the slot
            turtle.drop() -- drop the item
        end
    end
	turtle.select(1)
end

function mineLayer()
	-- Mine one layer in given interval
	for x=0,DST[1]-1,2 do
		mineTo({x,   0,      tPos[3]})
		mineTo({x,   DST[2], tPos[3]})
		mineTo({x+1, DST[2], tPos[3]})
		mineTo({x+1, 0,      tPos[3]})
		clearInventory()
	end

	-- Make sure we do last line
	if tPos[1] < DST[1] then
		mineTo({DST[1], 0,      tPos[3]})
		mineTo({DST[1], DST[2], tPos[3]})
	end
end

function newLayer()
	local offZ = DST[3] - tPos[3]

end

function mineCube()
	local mineDown = DST[3] < tPos[3]

	while (mineDown and DST[3] < tPos[3]) or (not mineDown and DST[3] > tPos[3]) do
		mineLayer()
		mineTo({0,0,tPos[3]})

		if mineDown then
			turtle.digDown()
			turtle.down()
			tPos[3] = tPos[3] - 1
		else
			turtle.digUp()
			turtle.down()
			tPos[3] = tPos[3] + 1
		end
	end

	-- TODO: Test this
	mineTo({0,0,0})
end

-- Walk around parimeter of given area
-- function perimeter()
-- 	write("Walking around perimeter\n")
-- 	mineTo({0,      DST[2], 0})
-- 	mineTo({DST[1], DST[2], 0})
-- 	mineTo({DST[1], 0,      0})
-- 	mineTo({0,      0,      0})
-- 	turn({0,        1,      0})
-- end

-- function debugMovement
-- 	write("Start debug movement \n")
-- 	mineTo({0, 5, 0})
-- 	mineTo({-3, 5, 0})
-- 	mineTo({0, 5, 0})
-- 	mineTo({0, 0, 0})
-- 	turn({0,1,0})
-- end

-- clearInventory()


-- Setup
refuel()
-- turtle.refuel(1)
refuel()
initialize()

mineCube()
