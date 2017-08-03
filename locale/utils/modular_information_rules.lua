-- modular_information_rules sub-module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This sub-module is a addon to the modular_information module, it shows players the rules


--
--	VARIABLES
--

global.modular_information_rules = global.modular_information_rules or {} 
global.modular_information_rules.list = global.modular_information_rules.list or {
					"No griefing",
					"Don't unnecessarily change stuff",
					"No driving trains manually on live tracks",
					"Listen to the admins",
					"No verbal abuse",
					"Don't build offensive structures"
					}
--
--	FUNCTIONS
--
function modular_information_rules_create_gui(p)
	miip = modular_information_get_information_pane(p)
	miip.clear()
	mirt = miip.add{type="table", name="modular_information_rules_table", colspan=1}
	for i, r in pairs(global.modular_information_rules.list) do
		mirt.add{type="label", caption= i .. ". " .. r}
	end
end
	
function modular_information_rules_gui_clicked(event)
	if not (event and event.element and event.element.valid) then return end
	local i = event.player_index
	local p = game.players[i]
	local e = event.element
	if e ~= nil then
		if p.admin then
			if e.name == "modular_information_rules" then
				if modular_information_get_active_button(p) == "modular_information_rules" then
					modular_information_set_active_button(p, "none")
				else
					modular_information_set_active_button(p, "modular_information_rules")
					modular_information_rules_create_gui(p)
				end
			end
		end
	end
end
	
--
--	EVENTS
--

Event.register(defines.events.on_player_joined_game, function(event)
	p = game.players[event.player_index]
	modular_information_add_button(p.name, {name="modular_information_rules", order = 1, caption = "Rules"})
	modular_information_set_active_button(p, "modular_information_rules")
	modular_information_gui_show(p)
	modular_information_rules_create_gui(p)
end)

Event.register(-1, function(event)
	modular_information_enable_submodule("modular_information_rules")
end)


Event.register(defines.events.on_gui_click, modular_information_rules_gui_clicked)