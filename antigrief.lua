--Grief detection
--Written by Mylon
--MIT License

--Print text to online admins and write to the log.
function antigrief_alert(text)
    for n, p in pairs(game.players) do
        if p.admin then
            p.print(text)
        end
    end
    log("Antigrief: " .. text)
end

--Common tactic is to remove pump.  So if someone landfills a pump and removes it... That's a huge red flag.
function antigrief_pump(event)
    if not event.entity and not event.entity.valid then
        return
    end
    --Only check for entities in a specific list.
    if antigrief_is_well_pump(event.entity) then
        local player = game.players[event.player_index]
        antigrief_alert(player.name .. " has mined a well-water pump.")
    end
end

--When someone decons > 50 entities, fire an alert
function antigrief_decon(event)
    if event.alt then --This is a cancel order.
        return
    end
    local player = game.players[event.player_index]
    local count = player.surface.count_entities_filtered{area=event.area, force=player.force}
    if count >= 50 then
        antigrief_alert(player.name .. "has deconstructed 50+ entities.")
        return
    end
    --Check to see if a off-shore pump was targetted.
    local ents = player.surface.find_entities_filtered{area=event.area, force=player.force, name="offshore-pump"}
    for k, v in pairs(ents) do

        if antigrief_is_well_pump(v) then
            antigrief_alert(player.name .. " has deconned a well-water pump.")
            return
        end
    end
end

function antigrief_is_well_pump(entity)
    if entity.name ~= "offshore-pump" then
        return false
    end
    if entity.surface.get_tile(entity.position.x+1, entity.position.y).collides_with("ground-tile") and
        entity.surface.get_tile(entity.position.x, entity.position.y+1).collides_with("ground-tile") and
        entity.surface.get_tile(entity.position.x-1, entity.position.y).collides_with("ground-tile") and
        entity.surface.get_tile(entity.position.x, entity.position.y-1).collides_with("ground-tile") then

        return true
    end

end


Event.register(defines.events.on_player_mined_entity, antigrief_pump)
Event.register(defines.events.on_player_deconstructed_area, antigrief_decon)