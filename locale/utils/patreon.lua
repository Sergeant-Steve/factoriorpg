--A patreon-rewarding module build by I_IBlackI_I for FactorioMMO
--This module gives patreons the ability to have a unique tag and a general patreon tag
--  they can also use basic spectating, but not teleporting or following.


global.patreon = global.patreon or {}
global.patreon.patreon_list = {
		"I_IBlackI_I",
		"psihius",
		"Hornwitser",
		"jordank321", 
		"viceroypenguin",
		"sikian",
		"Lyfe",
		"sniperczar",
		"i-l-i",
		"Uriopass",
		"audigex",
		"Sergeant_Steve",
		"Zr4g0n",
		"LordKiwi",
		"stik",
		"Zirr",
		"Nr42",
		"zerot"
	}
global.patreon.patreon_tag = {
		"Lua Hero",
		"SysAdmin",
		"MoneyBags",
		"Im not sure LMAO",
		"MoneyBags",
		"Sikjizz!",
		"Is Alive",
		"Behemoth Bait",
		"Space Dolphin",
		"Ratio Maniac",
		"Spaghetti Monster",
		"Biter Killer",
		"Totally not a dragon!",
		nil,
		nil,
		nil,
		nil,
		nil
	}
global.patreon.player_spectator_state = global.patreon.player_spectator_state or {}
global.patreon.player_spectator_character = global.patreon.player_spectator_character or {}
global.patreon.player_spectator_force = global.patreon.player_spectator_force or {}
global.patreon.player_spectator_logistics_slots = global.patreon.player_spectator_logistics_slots or {}


function shoutOut(event)
	local player = game.players[event.player_index]
	if checkPatreon(player) and player.admin == false then
		game.print("Special shout out to our Patreon " .. player.name)
	end
end

function patreon_joined(event)
	local player = game.players[event.player_index]
	if(checkPatreon(player)) then
		create_patreon_top_gui(player.name)
	end
end

function checkPatreon(player)
	for _, patreon in pairs(global.patreon.patreon_list) do
		if(player.name == patreon) then
			return true
		end
	end
	return false
end
function create_patreon_top_gui(player_name)
	local player = game.players[player_name]
	if player.gui.top.patreon_menu == nil then
		player.gui.top.add { name = "patreon_menu", type = "button", caption = "Open Patreon" }
	end
end
function create_patreon_pane(player_name)
	local player = game.players[player_name]
	local index = player.index
	local patreon_pane = nil
	if not player.gui.left.patreon_pane then
		patreon_pane = player.gui.left.add { name = "patreon_pane", type = "frame", direction = "vertical", caption = "Patreon GUI " }
	else
		patreon_pane = player.gui.left.patreon_pane
	end
	if not player.gui.left.patreon_pane.unique_tag then
		patreon_pane.add { name = "unique_tag", type = "button", caption = "Unique Tag" }
	end
	if not player.gui.left.patreon_pane.patreon_tag then
		patreon_pane.add { name = "patreon_tag", type = "button", caption = "Patreon Tag" }
	end
	if player.admin == false then
		if not player.gui.left.patreon_pane.spectate then
			patreon_pane.add { name = "spectate", type = "button", caption = "Spectate" }
		end
	end
end

function gui_click_patreon(event)
	local i = event.player_index
	local p = game.players[i]
	local e = event.element
	if e ~= nil then
		if e.name == "spectate" and e.parent.name == "patreon_pane" then
			if(p.admin == false) then
				patreon_spectate_on(i)
			else
				p.print("Use the spectate in the admin tools")
			end
		elseif e.name == "return_character" and e.parent.name == "patreon_pane" then
			if(p.admin == false) then
				patreon_spectate_off(i)
			else
				p.print("Use the spectate in the admin tools")
			end
		elseif e.name == "unique_tag" and e.parent.name == "patreon_pane" then
			apply_unique_tag(p)
		elseif e.name == "patreon_tag" and e.parent.name == "patreon_pane" then
			p.print("The general patreon tag has been applied!")
			p.tag = " [Patreon]"
		elseif e.name == "patreon_menu" and e.caption == "Open Patreon" then
			create_patreon_pane(p.name)
			p.gui.top.patreon_menu.caption = "Close Patreon"
		elseif e.name == "patreon_menu" and e.caption == "Close Patreon" then
			if p.gui.left.patreon_pane ~= nil then
				p.gui.left.patreon_pane.destroy()
			end
			p.gui.top.patreon_menu.caption = "Open Patreon"
		end
	end
end

function apply_unique_tag(player)
	for i, patreon in pairs(global.patreon.patreon_list) do
		if(player.name == patreon) then
			if(global.patreon.patreon_tag[i] ~= nil) then
				player.tag = " [" .. global.patreon.patreon_tag[i] .. "]"
				player.print("Your unique tag has been applied!")
			else 
				player.print("O.o It seems you don't have a unique tag.. Please contact the admins to get one.")
			end
		end
	end
end


function patreon_spectate_off(index)
	local player = game.players[index]
	global.patreon.player_spectator_state[index] = false
	player.gui.left.patreon_pane.return_character.destroy()
	player.gui.left.patreon_pane.add { name = "spectate", type = "button", caption = "Spectate" }
	if player.character == nil then
		local pos = player.position
		if global.patreon.player_spectator_character[index] and global.patreon.player_spectator_character[index].valid then
			player.print("Returning you to your character.")
			player.set_controller { type = defines.controllers.character, character = global.patreon.player_spectator_character[index] }
		else
			player.print("Character missing, will create new character at spawn.")
			player.set_controller { type = defines.controllers.character, character = player.surface.create_entity { name = "player", position = { 0, 0 }, force = global.patreon.player_spectator_force[index] } }
			player.insert { name = "pistol", count = 1 }
			player.insert { name = "firearm-magazine", count = 10 }
		end
		--restore character logistics slots due to bug in base game that clears them after returning from spectator mode
		for slot=1, player.character.request_slot_count do
			if global.patreon.player_spectator_logistics_slots[index][slot] then
				player.character.set_request_slot(global.player_spectator_logistics_slots[index][slot], slot)
			end
		end
	end
	player.force = game.forces[global.patreon.player_spectator_force[index].name]
end

function patreon_spectate_on(index)
	local player = game.players[index]
	global.patreon.player_spectator_state[index] = true
	player.gui.left.patreon_pane.spectate.destroy()
	player.gui.left.patreon_pane.add { name = "return_character", type = "button", caption = "Stop Spectating" }
	if player.character then
		player.character.destructible = false
		player.walking_state = { walking = false, direction = defines.direction.north }
		global.patreon.player_spectator_character[index] = player.character
		global.patreon.player_spectator_force[index] = player.force
		--store character logistics slots due to an apparent bug in the base game that discards them when returning from spectate
		global.patreon.player_spectator_logistics_slots[index] = {}
		for slot=1, player.character.request_slot_count do
			global.patreon.player_spectator_logistics_slots[index][slot] = player.character.get_request_slot(slot)
		end
		player.set_controller { type = defines.controllers.god }
	end
	player.force = game.forces["Patreon"]
	player.print("You are now a spectator")
end

function patreon_reveal(event)
	if (game.tick % 1800 == 0) then
		game.forces.Patreons.chart_all()
	end
end

Event.register(-1, function()
	game.create_force("Patreons")
end)

Event.register(defines.events.on_force_created, function(event)
	event.force.set_cease_fire(game.forces.Patreons, true)
	game.forces.Patreons.set_cease_fire(event.force, true)
end)

Event.register(defines.events.on_player_joined_game, shoutOut)
Event.register(defines.events.on_player_joined_game, patreon_joined)
Event.register(defines.events.on_tick, patreon_reveal)
Event.register(defines.events.on_gui_click, gui_click_patreon)