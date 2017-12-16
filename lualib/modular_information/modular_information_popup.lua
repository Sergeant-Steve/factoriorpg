-- modular_information_popup sub-module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This sub-module is a addon to the modular_information module, it shows players information about the scenario
--
--	VARIABLES
--

global.modular_information_popup = global.modular_information_popup or {} 
global.modular_information_popup.popups = global.modular_information_popup.popups or {{button = "Welcome", text = "Welcome to this new game, enjoy!"}} 


--
--	FUNCTIONS
--
function modular_information_popup_create_gui(p)
	miip = modular_information_get_information_pane(p)
	miip.clear()
	
	--Display selected (or last) popup
	miip.add {type="label", caption = "This is here to test only!"}
	
	
	mimc = modular_information_get_menu_canvas(p)
	mimc.style.visible = true
	mimc.caption = "Popup"
	--Create a button for each popup
	mimcb = mimc.add {type="button", name = "modular_information_popup_button", caption = "1234567890123"}
	mimcb.style.minimal_width = 140
	mimcb.style.maximal_width = 140
end
	
function modular_information_popup_gui_clicked(event)
	if not (event and event.element and event.element.valid) then return end
	local i = event.player_index
	local p = game.players[i]
	local e = event.element
	if e ~= nil then		
		if e.name == "modular_information_popup" then
			if modular_information_get_active_button(p) == "modular_information_popup" then
				modular_information_set_active_button(p, "none")
			else
				modular_information_set_active_button(p, "modular_information_popup")
				modular_information_popup_create_gui(p)
			end
		end
	end
end
	
--
--	EVENTS
--

Event.register(defines.events.on_player_joined_game, function(event)
	p = game.players[event.player_index]
	modular_information_add_button(p.name, {name="modular_information_popup", order = 5, caption = "Popup"})
end)

Event.register(-1, function(event)
	modular_information_enable_submodule("modular_information_popup")
end)


Event.register(defines.events.on_gui_click, modular_information_popup_gui_clicked)