-- modular_information_about sub-module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This sub-module is a addon to the modular_information module, it shows players information about FMMO
--
--	VARIABLES
--

global.modular_information_about = global.modular_information_about or {} 

--
--	FUNCTIONS
--
function modular_information_about_create_gui(p)
	local miip = modular_information_get_information_pane(p)
	miip.clear()
	
end
	
function modular_information_about_gui_clicked(event)
	if not (event and event.element and event.element.valid) then return end
	local i = event.player_index
	local p = game.players[i]
	local e = event.element
	if e ~= nil then		
		if e.name == "modular_information_about" then
			if modular_information_get_active_button(p) == "modular_information_about" then
				modular_information_set_active_button(p, "none")
			else
				modular_information_set_active_button(p, "modular_information_about")
				modular_information_about_create_gui(p)
			end
		end
	end
end
	
--
--	EVENTS
--

Event.register(defines.events.on_player_joined_game, function(event)
	local p = game.players[event.player_index]
	modular_information_add_button(p.name, {name="modular_information_about", order = 1, caption = "Rules"})
	modular_information_set_active_button(p, "modular_information_about")
	modular_information_gui_show(p)
	modular_information_about_create_gui(p)
end)

Event.register(-1, function(event)
	modular_information_enable_submodule("modular_information_about")
end)


Event.register(defines.events.on_gui_click, modular_information_about_gui_clicked)