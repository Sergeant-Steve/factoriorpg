-- modular_admin_boost sub-module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This sub-module is a addon to the modular_admin module, it allows admins to boost their character

--
--	PLAN
--	
--	This module is going to replace the character menu in the old admin tools
--	Admins will be able to increase their reach, speed, crafting, mining and be invincible
--	The gui will present a list of buttons to toggle each of the above
--

--
--	VARIABLES
--

global.modular_admin_boost = global.modular_admin_boost or {}
global.modular_admin_boost.enabled = true
global.modular_admin_boost.visible = global.modular_admin_boost.visible or {}
global.modular_admin_boost.bonus_state = global.modular_admin_boost.bonus_state or {}
global.modular_admin_boost.active_color = {r = 1, b = 0, g = 1}
global.modular_admin_boost.inactive_color = {r = 0, b = 0.5, g = 0}

--
--	FUNCTIONS
--

function modular_admin_boost_enable(mod)
	global.modular_admin_boost.enabled = true
	modular_admin_add_submodule("modular_admin_boost")
	for i, p in pairs(game.connected_players) do
		modular_admin_boost_update_menu_button(p)
	end
end

function modular_admin_boost_disable(mod)
	global.modular_admin_boost.enabled = false
	for i, p in pairs(game.connected_players) do
		modular_admin_boost_update_menu_button(p)
	end
	modular_admin_remove_submodule("modular_admin_boost")
end


function modular_admin_boost_update_menu_button(p)
	if p.admin then
		if global.modular_admin_boost.enabled then
			if global.modular_admin_boost.visible[p.name] then
				modular_admin_add_button(p.name, {name="modular_admin_boost_button", caption="Close character", order = 50, color = {r = 1, b = 0, g = 0}})
			else
				modular_admin_add_button(p.name, {name="modular_admin_boost_button", caption="Open character", order = 50, color = {r = 0, b = 0, g = 1}})
			end
		else 
			modular_admin_remove_button(p.name, "modular_admin_boost_button")
		end
		modular_admin_boost_gui_changed(p)
	end
end

function modular_admin_boost_gui_changed(p)
	if p.admin then
		bf = modular_admin_get_flow(p)
		if global.modular_admin_boost.enabled then
			if bf.modular_admin_boost_pane ~= nil then
				mabp = bf.modular_admin_boost_pane
				mabp.clear()
			else
				mabp = bf.add {type = "frame", name = "modular_admin_boost_pane", caption = "Character Menu", direction = "vertical"}
			end
			mabp.style.visible = global.modular_admin_boost.visible[p.name]
			bpb = mabp.add {type = "button", name = "modular_admin_boost_pickup_button", caption = "Pickup"}
			bmb = mabp.add {type = "button", name = "modular_admin_boost_movement_button", caption = "Movement"}
			bcb = mabp.add {type = "button", name = "modular_admin_boost_crafting_button", caption = "Crafting"}
			brb = mabp.add {type = "button", name = "modular_admin_boost_reach_button", caption = "Reach"}
			bib = mabp.add {type = "button", name = "modular_admin_boost_invincible_button", caption = "Invincible"}
			bpb.style.minimal_width = 150
			bmb.style.minimal_width = 150
			bcb.style.minimal_width = 150
			brb.style.minimal_width = 150
			bib.style.minimal_width = 150
			pbs = global.modular_admin_boost.bonus_state[p.name]
			if pbs.pickup then
				bpb.style.font_color = global.modular_admin_boost.active_color
			else
				bpb.style.font_color = global.modular_admin_boost.inactive_color 
			end
			if pbs.movement then
				bmb.style.font_color = global.modular_admin_boost.active_color
			else
				bmb.style.font_color = global.modular_admin_boost.inactive_color 
			end
			if pbs.crafting then
				bcb.style.font_color = global.modular_admin_boost.active_color
			else
				bcb.style.font_color = global.modular_admin_boost.inactive_color 
			end
			if pbs.reach then
				brb.style.font_color = global.modular_admin_boost.active_color
			else
				brb.style.font_color = global.modular_admin_boost.inactive_color 
			end
			if pbs.invincible then
				bib.style.font_color = global.modular_admin_boost.active_color
			else
				bib.style.font_color = global.modular_admin_boost.inactive_color 
			end
		else
			if bf.modular_admin_boost_pane ~= nil then
				bf.modular_admin_boost_pane.destroy()
			end
		end
	end
end

function modular_admin_boost_gui_clicked(event)
	if not (event and event.element and event.element.valid) then return end
	local i = event.player_index
	local p = game.players[i]
	local e = event.element
	if e ~= nil then
		if e.name == "modular_admin_boost_button" then
			global.modular_admin_boost.visible[p.name] = (not global.modular_admin_boost.visible[p.name])
			modular_admin_boost_update_menu_button(p)
		elseif e.parent.name == "modular_admin_boost_pane" then
			if e.name == "modular_admin_boost_pickup_button" then
				global.modular_admin_boost.bonus_state[p.name].pickup = not global.modular_admin_boost.bonus_state[p.name].pickup
			elseif e.name == "modular_admin_boost_movement_button" then
				global.modular_admin_boost.bonus_state[p.name].movement = not global.modular_admin_boost.bonus_state[p.name].movement
			elseif e.name == "modular_admin_boost_crafting_button" then
				global.modular_admin_boost.bonus_state[p.name].crafting = not global.modular_admin_boost.bonus_state[p.name].crafting
			elseif e.name == "modular_admin_boost_reach_button" then
				global.modular_admin_boost.bonus_state[p.name].reach = not global.modular_admin_boost.bonus_state[p.name].reach
			elseif e.name == "modular_admin_boost_invincible_button" then
				global.modular_admin_boost.bonus_state[p.name].invincible = not global.modular_admin_boost.bonus_state[p.name].invincible
			end
			modular_admin_boost_gui_changed(p)
		end
	end
end

--
--	EVENTS
--

Event.register(defines.events.on_player_joined_game, function(event)
	p = game.players[event.player_index]
	if p.admin then
		global.modular_admin_boost.bonus_state[p.name] = global.modular_admin_boost.bonus_state[p.name] or {pickup = false, movement = false, crafting = false, reach = false, invincible = false}
		if global.modular_admin_boost.enabled then
			if global.modular_admin_boost.visible[p.name] then
				modular_admin_add_button(p.name, {name="modular_admin_boost_button", caption="Close character", order = 50, color = {r = 1, b = 0, g = 0}})
			else
				modular_admin_add_button(p.name, {name="modular_admin_boost_button", caption="Open character", order = 50, color = {r = 0, b = 0, g = 1}})
			end
		else 
			modular_admin_remove_button(p.name, "modular_admin_boost_button")
		end
	end
end)

Event.register(-1, function(event)
	if(global.modular_admin_boost.enabled) then
		modular_admin_add_submodule("modular_admin_boost")
	else
		modular_admin_remove_submodule("modular_admin_boost")
	end
end)

Event.register(defines.events.on_gui_click, modular_admin_boost_gui_clicked)