-- Grid Ore Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module is an extention to the grid module and is able to place ores / oil in certain "Grid chunks"
global.grid_ore = global.grid_ore or {}
global.grid_ore.resource_chance = 40
global.grid_ore.ore_start_amount = 225
global.grid_ore.ore_random_addition_amount = 600
global.grid_ore.oil_start_amount = 10000
global.grid_ore.oil_random_addition_amount = 20000
global.grid_ore.oil_spout_chance = 1


function grid_ore_place_ore_in_grid_chunck(location, ore)
	xoffset = (math.floor(location.x/global.grid.size))*global.grid.size
	yoffset = (math.floor(location.y/global.grid.size))*global.grid.size
	for y=global.grid.y_border_width,global.grid.size-1 do
		for x=global.grid.x_border_width,global.grid.size-1 do
			game.surfaces["nauvis"].create_entity({name=ore, amount=math.random(global.grid_ore.ore_random_addition_amount)+global.grid_ore.ore_start_amount, position={x+xoffset, y+yoffset}})
		end
	end
end

function grid_ore_place_oil_in_grid_chunck(location)
	xoffset = (math.floor(location.x/global.grid.size))*global.grid.size
	yoffset = (math.floor(location.y/global.grid.size))*global.grid.size
	for y=global.grid.y_border_width,global.grid.size-1 do
		for x=global.grid.x_border_width,global.grid.size-1 do
			if math.random(100) < global.grid_ore.oil_spout_chance then
				game.surfaces["nauvis"].create_entity({name="crude-oil", amount=global.grid_ore.oil_start_amount+math.random(global.grid_ore.oil_random_addition_amount), position={x+xoffset, y+yoffset}})
			end
		end
	end
end

function grid_ore_generate_resources(location)
	if(math.random(global.grid_ore.resource_chance ) == 1) then
		rndm = math.random(8)-1
		if(rndm < 1) then
			grid_ore_place_ore_in_grid_chunck(location, "stone")
		elseif (0 < rndm and rndm < 3) then
			grid_ore_place_ore_in_grid_chunck(location, "iron-ore")
		elseif (2 < rndm and rndm < 5) then
			grid_ore_place_ore_in_grid_chunck(location, "copper-ore")
		elseif (4 < rndm and rndm < 6) then
			grid_ore_place_ore_in_grid_chunck(location, "coal")
		elseif (5 < rndm and rndm < 7) then
			grid_ore_place_oil_in_grid_chunck(location)
		end
	end
end
