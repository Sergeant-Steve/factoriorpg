--Grief detection
--Written by Mylon
--MIT License

antigrief = {}
global.antigrief_cooldown = {}

antigrief.TROLL_TIMER = 60 * 60 * 30 --30 minutes.  Players must be online this long to not throw some warnings.
antigrief.SPAM_TIMER = 60 * 60 * 2 --10 minutes.  Limit inventory related messages to once per 10m.

--antigrief.WARN_TYPES = {"destruction", "hoarding", "mining"} --We'll just pass a string for the type.

--Print text to online admins and write to the log.
function antigrief.alert(text)
    for n, p in pairs(game.players) do
        if p.admin then
            p.print(text)
        end
    end
    log("Antigrief: " .. text)
end

--Common tactic is to remove pump.  So if someone landfills a pump and removes it... That's a huge red flag.
function antigrief.pump(event)
    if not event.entity and not event.entity.valid then
        return
    end
    --Only check for entities in a specific list.
    if antigrief.is_well_pump(event.entity) then
        local player = game.players[event.player_index]
        antigrief.alert(player.name .. " has mined a well-water pump.")
    end
end

--Look for players mining ghosts far away.
function antigrief.ghosting(event)
    if not event.entity and not event.entity.valid then
        return
    end
    if event.entity.type == "entity-ghost" then
        --Look for units mined 200 tiles away.
        if math.abs(event.entity.position.x - event.player.position.x) + math.abs(event.entity.position.y - event.player.position.y) > 200 then
            if antigrief.check_cooldown(event.player.index, "ghosting") then
                antigrief.alert(event.player.name .. " is removing blueprint ghosts.")
            end
        end
    end
end

--When someone decons > 50 entities, fire an alert
function antigrief.decon(event)
    if event.alt then --This is a cancel order.
        return
    end
    if event.area.left_top.x == event.area.right_bottom.x or event.area.left_top.y == event.area.right_bottom.y then
        log("Antigrief: Deconstruction area is of zero size.")
        return
    end
    local player = game.players[event.player_index]
    local count = player.surface.count_entities_filtered{area=event.area, force=player.force}
    if count >= 50 then
        --Need a proper check of entities.  Most might be filtered out and not actually deconned.
        local ents = player.surface.find_entities_filtered{area=event.area, force=player.force}
        count = 0
        for k, v in pairs(ents) do
            if v.to_be_deconstructed(player.force) then
                count = count + 1
            end
        end
        if count >= 50 then
            antigrief.alert(player.name .. " has deconstructed ".. count .. " entities.")
            return
        end
    end
    --Check to see if a off-shore pump was targetted.
    local ents = player.surface.find_entities_filtered{area=event.area, force=player.force, name="offshore-pump"}
    for k, v in pairs(ents) do
        if v.to_be_deconstructed(player.force) and antigrief.is_well_pump(v) then
            antigrief.alert(player.name .. " has marked a well-water pump for deconstruction")
            return
        end
    end
end

--If new players equip an atomic bomb... Throw a warning!
function antigrief.da_bomb(event)
    local player = game.players[event.player_index]
    if player.online_time > antigrief.TROLL_TIMER then
        return
    end
    if player.get_item_count("atomic-bomb") > 0 then
        if antigrief.check_cooldown(event.player_index, "atomic") then
            antigrief.alert(player.name .. " has equipped an Atomic Bomb.")
        end
    end
end

--Look for players hoarding high value items.
function antigrief.hoarder(event)
    local player = game.players[event.player_index]
    if player.online_time > antigrief.TROLL_TIMER then
        return
    end
    if antigrief.check_cooldown(event.player_index, "hoarding") then
        if player.get_item_count("speed-module-3") > 10 or
        player.get_item_count("productivity-module-3") > 10 or
        player.get_item_count("effectivity-module-3") > 10 then
            antigrief.alert(player.name .. " is hoarding T3 modules.")
        end
        if player.get_item_count("uranium-235") > 10 then
            antigrief.alert(player.name .. " is hoarding U-235.")
        end
        if player.get_item_count("power-armor-mk2") >= 2 then
            antigrief.alert(player.name.. " is hoarding power armor mk2s.")
        end
    end
end

--Did someone craft/request Mk2 power armor and then log out?
function antigrief.armor_drop(event)
    local player = game.players[event.player_index]
    if player.online_time > antigrief.TROLL_TIMER then
        return
    end
    if player.get_item_count("power-armor-mk2") >= 1 then
        local armor = player.get_inventory(defines.inventory.player_armor).find_item_stack("power-armor-mk2") or
        player.get_inventory(defines.inventory.player_main).find_item_stack("power-armor-mk2") or
        player.get_inventory(defines.inventory.player_quickbar).find_item_stack("power-armor-mk2") or
        player.get_inventory(defines.inventory.player_trash).find_item_stack("power-armor-mk2")

        if armor then
            local item = player.surface.spill_item_stack(player.position, armor) --This could be used to duplicate equipment if we remove the wrong PA2.  But such a weird edge case...
            player.remove_item("power-armor-mk2")
            item.order_deconstruction(player.force)
        else --Something went wrong.  We should have found the armor.  God inventory?
            log("Antigrief: Power Armor mk2 detected but not found")
        end
    end           
end

--Look for players merging roboport networks
function antigrief.check_size_loginet_size(event)
    if not (event.entity and event.entity.valid and event.entity.type == "roboport") then
        return
    end
    if not (event.entity.last_user) then
        --How did we get here?
        return
    end
    local network = event.entity.logistic_network
    local cells = network.cells
    if not (cells[1] and cells[1].valid) then
        return
    end
    local minx, miny, maxx, maxy = cells[1].owner.position.x, cells[1].owner.position.y, cells[1].owner.position.x, cells[1].owner.position.y
    for k, v in pairs(cells) do
        if v.owner.position.x < minx then
            minx = v.owner.position.x
        elseif v.owner.position.x > maxx then
            maxx = v.owner.position.x
        end
        if v.owner.position.y < miny then
            miny = v.owner.position.y
        elseif v.owner.position.y > maxy then
            maxy = v.owner.position.y
        end
    end

    if math.abs(maxx-minx) > 2000 or math.abs(maxy-miny) then
        antigrief.alert(event.entity.last_user.name .. "has placed a roboport in a large network.")
    end
end

--Check if a message has been generated about this player recently.  If true, set cooldown.
function antigrief.check_cooldown(player_index, type)
    local cooldown = global.antigrief_cooldown[player_index]
    if not cooldown then
        cooldown = {}
    end
    if (not cooldown.tick) or cooldown.tick < game.tick then
        cooldown.tick = game.tick + antigrief.SPAM_TIMER
        cooldown.type = type
        global.antigrief_cooldown[player_index] = cooldown
        return true
    else
        if not cooldown.type == type then
            cooldown.tick = game.tick + antigrief.SPAM_TIMER
            cooldown.type = type
            return true
        else
            return false
        end
    end
end

--Is this a water-well pump?
function antigrief.is_well_pump(entity)
    if entity.name ~= "offshore-pump" then
        return false
    end
    if not (entity.surface.get_tile(entity.position.x+1, entity.position.y).collides_with("water-tile") or
        entity.surface.get_tile(entity.position.x, entity.position.y+1).collides_with("water-tile") or
        entity.surface.get_tile(entity.position.x-1, entity.position.y).collides_with("water-tile") or
        entity.surface.get_tile(entity.position.x, entity.position.y-1).collides_with("water-tile")) then

        return true
    end
end

function antigrief.wanton_destruction(event)
    if not (event.entity and event.entity.valid) then
        return
    end
    if not (event.cause and event.cause.type == "player") then
        return
    end
    if event.cause.force == event.entity.force then
        --Friendly fire detected!
        if antigrief.is_well_pump(event.entity) then
            antigrief.alert(event.cause.player.name .. " destroyed a well-water pump")
            return
        end
        if event.entity.type == "player" and event.entity.player then
            antigrief.alert(event.cause.player.name .. " killed " .. event.entity.player.name )
            return
        end
        if antigrief.check_cooldown(event.cause.player.index, "destruction") then
            antigrief.alert(event.cause.player.name .. " is destroying friendly entites.")
        end       
    end
end

Event.register(defines.events.on_player_ammo_inventory_changed, antigrief.da_bomb)
Event.register(defines.events.on_player_main_inventory_changed, antigrief.hoarder)
Event.register(defines.events.on_player_left_game, antigrief.armor_drop)
Event.register(defines.events.on_player_mined_entity, antigrief.pump)
Event.register(defines.events.on_player_mined_entity, antigrief.ghosting)
Event.register(defines.events.on_entity_died, antigrief.wanton_destruction)
Event.register(defines.events.on_built_entity, antigrief.check_size_loginet_size)
Event.register(defines.events.on_robot_built_entity, antigrief.check_size_loginet_size)
Event.register(defines.events.on_player_deconstructed_area, antigrief.decon)