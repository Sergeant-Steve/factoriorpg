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
global.modular_admin_boost.visable = global.modular_admin_boost.visable or {}
global.modular_admin_boost.bonus_state = global.modular_admin_boost.bonus_state or {}

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
				mabp = bf.add {type = "frame", name = "modular_admin_boost_pane", caption = "Specate Menu", direction = "vertical"}
			end
			mabp.style.visible = global.modular_admin_boost.visible[p.name]
			srb = mabp.add {type = "button", name = "modular_admin_boost_return_button", caption = "Return"}
			stb = mabp.add {type = "button", name = "modular_admin_boost_teleport_button", caption = "Teleport"}
			srb.style.minimal_width = 150
			stb.style.minimal_width = 150
			if global.modular_admin_boost.follow_target[p.index] ~= nil then
				srb.enabled = false
				stb.enabled = false
			else
				srb.style.font_color = {r = 1, b = 0, g = 0}
				stb.style.font_color = {r = 1, b = 0, g = 0}
			end
		else
			if bf.modular_admin_boost_pane ~= nil then
				bf.modular_admin_boost_pane.destroy()
			end
		end
	end
end

--
--	EVENTS
--

Event.register(defines.events.on_player_joined_game, function(event)
	p = game.players[event.player_index]
	if p.admin then
		global.modular_admin_boost.bonus_state[p.name] = global.modular_admin_boost.bonus_state[p.name] or {}
		if global.modular_admin_boost.enabled then
			if global.modular_admin_boost.visable[p.name] then
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

	
--Event.register(defines.events.on_gui_click, modular_admin_boost_gui_clicked)