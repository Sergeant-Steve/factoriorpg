
if MODULE_LIST then
	module_list_add("Hexi's Maze")
end

hexi = {}

function hexi.init()
    game.forces.player.technologies["logistic-system"].enabled = false --This doesn't actually work... Class changing re-enables it.
end

function hexi.nologistics()
    if not (event.research and event.research.valid) then
        return
    end
    if event.research.name == "logistic-system" then
        event.research.force.current_research=nil
        event.research.enabled = false
    end
end

--Radars cannot scan.  They only reveal the nearby area.
function hexi.unscan(event)
    if not (event and event.entity and event.entity.valid) then
        return
    end
    event.entity.force.unchart_chunk(event.chunk_position, event.entity.surface)
end

--Depreciated.
-- function hexi.radars(event)
--     if event.created_entity and event.created_entity.valid and event.created_entity.name == "radar" then
--         event.created_entity.surface.create_entity{name="item-on-ground", stack={name="radar"}, position=event.created_entity.position}
--         event.created_entity.destroy()
--         local last_user = event.created_entity.last_user
--         if last_user then
--             last_user.print("Radars are disabled for this scenario.")
--         end
--     end
-- end

--Event.register(-1, hexi.init)
Event.register(on_research_started, hexi.nologistics)
Event.register(defines.events.on_sector_scanned, hexi.unscan)
Event.remove(defines.events.on_sector_scanned, rpg_bonus_scan)