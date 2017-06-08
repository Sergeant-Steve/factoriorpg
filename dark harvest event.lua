global.server = "set global.server" --Trees or Aliens

function second_to_tick(seconds)
    return seconds * 60 * game.speed
end

function minute_to_tick(minutes)
    return second_to_tick(minutes*60)
end

function tick_to_second(ticks)
    return math.floor(ticks / 60 / game.speed)
end

function formattime(ticks)
    local seconds = tick_to_second(ticks)
    local days = math.floor(seconds / 86400)
    local remainder = seconds % 86400
    local hours = math.floor(remainder / 3600)
    local remainder = remainder % 3600
    local minutes = math.floor(remainder / 60)
    local seconds = remainder % 60

    if days and days > 0 then
        return string.format("%dd %02d:%02d", days, hours, minutes)
    end
    if hours and hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, seconds)
    end
    return string.format("%d:%02d", minutes, seconds)
end

function number_to_readable(num)
    num = tonumber(num)
    if (num > 10000) then
        return math.floor(num / 1000) .. "k"
    end
    if (num > 1000) then
        return math.floor(num / 1000) .. "." .. math.floor((num % 1000) / 100) .. "k"
    end
    return num
end


function get_player_online_count()
    local counter = 0
    for i, x in pairs(game.players) do
        if x.connected then
            counter = counter + 1
        end
    end
    return counter
end

function event_create_gui(player)
    if (player.gui.top.factoriommo_frame ~= nil) then
        player.gui.top.factoriommo_frame.destroy()
	end
	
	local frame = player.gui.top.add{type="frame", name="factoriommo_frame", caption = "/r/factorio MMO", direction="vertical"}
	local table = frame.add{type="table", name="table", colspan=2}

    table.add{type="label", caption="Local server:", style="caption_label_style"}
    table.add{type="label", caption= "", name="server_name"}

    table.add{type="label", caption="Players online:", style="bold_label_style"}
    table.add{type="label", caption= "?", name="local_players"}
	
	table.add{type="label", caption="Bombs sent:", style="bold_label_style"}
	table.add{type="label", caption= "?", name="bombs_sent"}
	
	table.add{type="label", caption="Space science:", style="bold_label_style"}
	table.add{type="label", caption= "?", name="space_science"}
	
	table.add{type="label", caption="Fuel cells used:", style="bold_label_style"}
	table.add{type="label", caption= "?", name="nukular"}
	
	
	table.add{type="label", caption="Time played:", style="caption_label_style"}
    table.add{type="label", caption= "?", name="time_played"}
	
	
end

function event_update_gui(player)
	local target = player.gui.top.factoriommo_frame.table
	
	target.server_name.caption = global.server
	target.local_players.caption = #game.connected_players
	target.bombs_sent.caption = player.force.get_item_launched("atomic-bomb")
	target.space_science.caption = player.force.item_production_statistics.get_input_count("space-science-pack")
	target.nukular.caption = player.force.item_production_statistics.get_output_count("uranium-fuel-cell")

	target.time_played.caption = formattime(game.tick)

	--player.force.get_item_launched("atomic-bomb")
	--player.force.item_production_statistics.get_input_count("space-science-pack")
	
end

function event_victory()
	for n, p in pairs(game.players) do
		if p.connected then
			if p.gui.center.dark_harvest == nil then
				p.gui.center.add{type="frame", name="dark_harvest", caption="Scenario complete!", direction="vertical"}
				p.gui.center.dark_harvest.add{type="label", caption="Scenario complete in " .. formattime(game.tick)}
			end
		end
	end
end

function event_update_player_guis(event)
	for n, p in pairs(game.players) do
		if p.connected then
			if (p.index + game.tick) % 60 == 0 then		
				if not p.gui.top.factoriommo_frame then
					event_create_gui(p)
				end
				event_update_gui(p)
			end
		end
	end
end

function event_check_win(event)
	if game.tick % 120 == 0 then
		--Check victory conditions.
		if game.forces.player.get_item_launched("atomic-bomb") >= 100 and game.forces.player.item_production_statistics.get_input_count("space-science-pack") >= 20000 and game.forces.player.item_production_statistics.get_output_count("uranium-fuel-cell") >= 500 then
			--You win!
			event_victory()
		end
	end
end
	
	
Event.register(defines.events.on_tick, event_update_player_guis)
Event.register(defines.events.on_tick, event_check_win)