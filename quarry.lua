-- TODO: 
-- Chest to empty inventory at each layer or just when full?
-- Handle TODOs and not yet implemented stuff

-- Globals
S_FUEL  = 1
S_TORCH = 2
S_CHEST = 3

-- User setup
write("Length of Quarray: ")
INP_Y  = tonumber(read())  -- Destination Y coord

write("Width of Quarry: ")
INP_X = tonumber(read())   -- Destination X coord

write("Height of Quarry: ")
INP_Z = tonumber(read())   -- Destination Z coord



-- Turtle global coordinates
DST   = {INP_X, INP_Y, INP_Z}
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
			if turtle.detect() then
				turtle.dig()
			end

			turtle.forward()
			tPos[1] = tPos[1] + dir -- Update turt pos +- 1
		end
	end
	
	-- Then handle y-direction
	if diff[2] ~= 0 then
		local dir = diff[2]/abs(diff[2])
		turn({0,dir,0})
		for i=1,abs(diff[2]) do
			if turtle.detect() then
				turtle.dig()
			end

			turtle.forward()
			tPos[2] = tPos[2] + dir -- Update turt pos +- 1
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
		end
	end
end


function mineLayer()
	-- Mine one layer in given interval
	for x=0,DST[1]-1,2 do
		mineTo({x,   0,      tPos[3]})
		mineTo({x,   DST[2], tPos[3]})
		mineTo({x+1, DST[2], tPos[3]})
		mineTo({x+1, 0,      tPos[3]})
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

-- Setup
turtle.refuel()
initialize()

mineCube()
