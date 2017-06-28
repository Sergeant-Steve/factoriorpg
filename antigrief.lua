--Grief detection
--Written by Mylon
--MIT License

--Print text to online admins and write to the log.
function antigrief_alert(text)
    for n, p in game.players do
        if p.admin then
            game.player.print(text)
        end
    end
    log("Antigrief: " .. text)
end

--Common tactic is to remove pump.  So if someone landfills a pump and removes it... That's a huge red flag.
function antigrief_pump(event)
    if not event.entity and not event.entity.valid and not event.entity.name == "offshore-pump" then
        return
    end
    if event.entity.surface.get_tile(event.entity.position.x, event.entity.position.y).collides_with("ground-tile") then--This is a well water pump.
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
    local count = player.surface.count_entities_filtered{area=event.area, force=game.player.force}
    if count >= 50 then
        antigrief_alert(player.name .. "has deconstructed a large number of entities.")
        return
    end
    --Check to see if a off-shore pump was targetted.
    local ents = player.surface.find_entities_filtered{area=event.area, force=game.player.force, name="offshore-pump"}
    for k, v in pairs(ents) do
        if v.surface.get_tile(v.position.x, v.y).collides_with("ground-tile") then--This is a well water pump.
        antigrief_alert(player.name .. " has deconned a well-water pump.")
        return
    end


Event.register(defines.events.on_player_mined_entity, antigrief_pump)
Event.register(defines.events.on_player_deconstructed_area, antigrief_decon)