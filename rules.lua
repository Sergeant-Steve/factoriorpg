-- Rules Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module displays the rules on all players their screens when they join.

global.rules = global.rules or {}
global.rules.rules = {
					"No griefing",
					"Don't unnecessarily change stuff",
					"No driving trains manually on live tracks",
					"Listen to the admins",
					"No verbal abuse",
					"Don't build offensive structures"
					}
global.rules.color = global.rules.color or {}
global.rules.color.hint = { r = 0, g = 0.5, b = 0.5 }
global.rules.color.rule = { r = 1, g = 0.2, b = 0.2 }

function rules_player_joined(event)
	local player = game.players[event.player_index]
	rules_create_top_gui(player.name)
	rules_show(player.name)
end

function rules_create_top_gui(player_name)
	local player = game.players[player_name]
	if not mod_gui.get_button_flow(player).rules_menu then
		mod_gui.get_button_flow(player).add { name = "rules_menu", type = "button", caption = "Close Rules" }
	else
		mod_gui.get_button_flow(player).rules_menu.caption = "Close Rules"
	end
end

function rules_show(player_name)
	local p = game.players[player_name]
	p.character_running_speed_modifier = -0.9
	if not p.gui.center.rules then
		local rules = p.gui.center.add{type="frame", name="rules", caption="FactorioMMO Rules", direction="vertical"}
		rules.add{type="button", name="rules_close", caption="X"}
		local rules_table = p.gui.center.rules.add{type="table", name="rules_table", colspan=1}
		for i, r in pairs(global.rules.rules) do
			local e = rules_table.add{type="label", caption= i .. ". " .. r}
			e.style.font_color = global.rules.color.rule
		end
		local e = rules.add{type="label", caption= "Click the button in the top-left to close this message"}
		e.style.font_color = global.rules.color.hint
		--rules.add{type="button", name="rules_close", caption="Close this message"}
	end
end

function rules_on_gui_click(event)
	if not (event and event.element and event.element.valid) then return end
	local i = event.player_index
	local p = game.players[i]
	local e = event.element
	if e ~= nil then
		if e.name == "rules_close" then
			if p.gui.center.rules ~= nil then
				p.gui.center.rules.destroy()
				if mod_gui.get_button_flow(p).rules_menu ~= nil then
					mod_gui.get_button_flow(p).rules_menu.caption = "Open Rules"
				end
				p.character_running_speed_modifier = 0
			end
		elseif e.name == "rules_menu" and e.caption == "Open Rules" then
			rules_show(p.name)
			mod_gui.get_button_flow(p).rules_menu.caption = "Close Rules"
		elseif e.name == "rules_menu" and e.caption == "Close Rules" then
			p.character_running_speed_modifier = 0
			if p.gui.center.rules ~= nil then
				p.gui.center.rules.destroy()
			end
			mod_gui.get_button_flow(p).rules_menu.caption = "Open Rules"
		end
	end
end

Event.register(defines.events.on_player_joined_game, rules_player_joined)
Event.register(defines.events.on_gui_click, rules_on_gui_click)