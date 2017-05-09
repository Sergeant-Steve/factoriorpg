-- spawns the correct type of ore depending on it's quadrant
function spawn_quadrant_ore(surface, x, y)
	local entityName = nil
	
	if (x >= TRACK_WIDTH and y <= -TRACK_WIDTH) then --top right
		entityName = "iron-ore"
	end
	if (x >= TRACK_WIDTH and y >= TRACK_WIDTH) then --bottom right
		entityName = "stone"
	end
	if (x <= -TRACK_WIDTH and y >= TRACK_WIDTH) then --bottom left
		entityName = "copper-ore"
	end
	if (x <= -TRACK_WIDTH and y <= -TRACK_WIDTH) then --top left
		entityName = "coal"
	end
	
	if entityName ~= nil then
		spawn_entity(surface, entityName, costCalc(x,y), x, y)
	end
end

function spawn_built_ore(surface, x, y)
    local tile = surface.get_tile(x, y)
    
    if (tile.name ~= "grass") then
        return
    end
    
    spawn_quadrant_ore(surface, x, y)
end

function spawn_entity(surface, entityName, amount, x, y)
    surface.create_entity({name=entityName, position={x,y}, amount=amount})
end

function spawn_tree(surface, x, y)
    if (x % 2 == 0 and y % 3 == 0 and getRandomIntInclusive(1, 100) <= 50) then
        spawn_entity(surface, "tree-01", 1, x, y)
    end
end

function spawn_oil(surface, x, y)
    if (x % 2 == 0 and y % 2 == 0 and getRandomIntInclusive(1, 100) <= 10) then
        spawn_entity(surface, "crude-oil", getRandomIntInclusive(400000,1000000), x, y)
    end
end

function spawn_enemy(surface, x, y)
    spawnertype = "biter-spawner"
    chance = getRandomIntInclusive(1, 100)
    if (chance <= 33) then
        spawnertype = "spitter-spawner"
    elseif (chance <= 40) then
        spawnertype = "medium-worm-turret"
    end
    
    if (x % 4 == 0 and y % 4 == 0 and getRandomIntInclusive(1, 100) <= 40) then
        spawn_entity(surface, spawnertype, 1, x, y)
    end
end