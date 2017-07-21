--Loco Trains
-- By Mylon, 2017
-- MIT License

--Notes:
--Positions are always odd.  
--A corner is 2 curved-rail joined by a straight-rail.
--For a bottom-left corner, the top rail "faces" west, curve inbetween faces SW, and the bottom one faces northwest,
--For bottomleft corner, NW rail is position 0,0, first curve is 1, 5, straight rail is 4, 8, second curve is 7, 11, SE rail is 12, 12
--SE corner (from bottom-left): facing: E, NE, S

if MODULE_LIST then
	module_list_add("Loco Trains")
end

--If train is stopped or dies, bad stuff happens.
function test_loco(event)
    if not (event.entity and event.entity.valid) then
        return
    end
    if not event.entity.name == "locomotive" and event.entity.force.name = "loco" then
        return
    end
    --We're still here?  Boom!
    go_loco(event.entity)
end

function go_loco(entity)
    entity.surface.create_entity{name="atomic-rocket", target=entity, speed=20}
end

-- Draw rails
function draw_locos(event)
    --Each corner function is anchored by the position of the last straight-rail on the NW or SW corner.  Each corner function is named by where it would be on a square.
    --Based on NW corner
    local function draw_SW_corner(position)
        event={surface=game.player.surface}
        position=game.player.selected.position
        event.surface.create_entity{name="curved-rail", position={position.x+1, position.y+5}, force=game.forces.enemy, direction=defines.direction.south}
        event.surface.create_entity{name="straight-rail", position={position.x+4, position.y+8}, force=game.forces.enemy, direction=defines.direction.southwest}
        event.surface.create_entity{name="curved-rail", position={position.x+7, position.y+11}, force=game.forces.enemy, direction=defines.direction.northwest}
    end
    --Based on SW corner position
    local function draw_SE_corner(position)
        --For testing
        event={surface=game.player.surface}
        position=game.player.selected.position
        event.surface.create_entity{name="curved-rail", position={position.x+5, position.y-1}, force=game.forces.enemy, direction=defines.direction.east}
        event.surface.create_entity{name="straight-rail", position={position.x+8, position.y-4}, force=game.forces.enemy, direction=defines.direction.southeast}
        event.surface.create_entity{name="curved-rail", position={position.x+11, position.y-7}, force=game.forces.enemy, direction=defines.direction.southwest}
    end
    --Based on SW corner position
    local function draw_NW_corner(position)
        event={surface=game.player.surface}
        position=game.player.selected.position
        event.surface.create_entity{name="curved-rail", position={position.x+1, position.y-5}, force=game.forces.enemy, direction=defines.direction.northeast}
        event.surface.create_entity{name="straight-rail", position={position.x+4, position.y-8}, force=game.forces.enemy, direction=defines.direction.northwest}
        event.surface.create_entity{name="curved-rail", position={position.x+7, position.y-11}, force=game.forces.enemy, direction=defines.direction.west}
    end
    local function draw_NE_corner(position)
        event={surface=game.player.surface}
        position=game.player.selected.position
        event.surface.create_entity{name="curved-rail", position={position.x+5, position.y+1}, force=game.forces.enemy, direction=defines.direction.southeast}
        event.surface.create_entity{name="straight-rail", position={position.x+8, position.y+4}, force=game.forces.enemy, direction=defines.direction.northeast}
        event.surface.create_entity{name="curved-rail", position={position.x+11, position.y+7}, force=game.forces.enemy, direction=defines.direction.north}
end

function loose_wheel()

end

Event.register(defines.events.on_entity_died, test_loco)
Event.register(defines.events.on_chunk_generated, draw_locos)