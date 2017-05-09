--ISLAND_SPAWN Module
--this module generates a map of small islands, and wht landfill that generates ore dependent on quadrant of map

require "locale/island_spawn/config"
require "locale/island_spawn/util"
require "locale/island_spawn/spawn_generator"
require "locale/island_spawn/water_generator"
require "locale/island_spawn/entity_generator"
require "locale/island_spawn/island_generator"
    
	
Event.register(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]
    player.insert{name="small-electric-pole", count = 4}

    if DEBUG then
        player.insert{name="landfill", count=2000}
    else
		player.insert{name="landfill", count = 50}
    end

    if START_WITH_LANDFILL_RESEARCHED then
        player.force.technologies['landfill'].researched = true
    end
end)
		
		-- Chunk Generated event
Event.register(defines.events.on_chunk_generated, function(event)
        local x1 = event.area.left_top.x
        local y1 = event.area.left_top.y
        local x2 = event.area.right_bottom.x
        local y2 = event.area.right_bottom.y
        --local width = math.abs(x2) - math.abs(x1)
        --local height = math.abs(y2) - math.abs(y1)
        local surface = event.surface

        -- destroy decoratives
        surface.destroy_decoratives({{x1, y1}, {x2, y2}})

        -- destroy all entities
        entList = surface.find_entities({{x1, y1}, {x2, y2}})

        for i, ent in ipairs(entList) do
            if ent.name ~= "player" then
                ent.destroy()
            end
        end

        -- set water or grass
        -- create entity
        tiles = {}
        in_spawn = does_square_intersect(x1, y1, x2, y2, -SPAWN_SIZE, -SPAWN_SIZE, SPAWN_SIZE, SPAWN_SIZE)
        
        typeoftiles = "none"
        
        if (in_spawn) then
            tiles = get_spawn_tiles(surface, x1, y1, x2, y2)
            typeoftiles = "spawn"
        elseif (getRandomIntInclusive(1,100) <= ISLAND_SPAWN_CHANCE) then
            tiles = get_island_tiles(surface, x1, y1, x2, y2)
            typeoftiles = "island"
        else
            tiles = get_water_tiles(x1, y1, x2, y2)
            typeoftiles = "water"
        end
        
        -- set tiles
        if (typeoftiles == "island") then
            --log(serpent.block(tiles))
        end
        surface.set_tiles(tiles)
end)

-- Player Built Tile event
Event.register(defines.events.on_player_built_tile, function(event)
        local player = game.players[event.player_index]
        local surface = player.surface
        local positions = event.positions

        for i, pos in ipairs(positions) do
            spawn_built_ore(surface, pos.x, pos.y)
        end
end)