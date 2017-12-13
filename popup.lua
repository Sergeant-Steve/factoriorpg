-- Popup Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module displays an popup on all players their screens.

function popup_create_popup_creator(player_name)
	local player = game.players[player_name]
	local index = player.index
	if not mod_gui.get_frame_flow(player).popup_creator_pane then
		popup_pane = mod_gui.get_frame_flow(player).add { name = "popup_creator_pane", type = "frame", direction = "vertical", caption = "Popup GUI " }
	else
		popup_pane = mod_gui.get_frame_flow(player).popup_creator_pane
	end
	if not mod_gui.get_frame_flow(player).popup_creator_pane.popup_creator_title_label then
		popup_pane.add { name = "popup_creator_title_label", type = "label", caption="Title of the popup" }
	end
	if not mod_gui.get_frame_flow(player).popup_creator_pane.popup_creator_title then
		popup_pane.add { name = "popup_creator_title", type = "textfield" }
	end
	if not mod_gui.get_frame_flow(player).popup_creator_pane.popup_creator_message_label then
		popup_pane.add { name = "popup_creator_message_label", type = "label", caption="Message of the popup" }
	end
	if not mod_gui.get_frame_flow(player).popup_creator_pane.popup_creator_message then
		popup_pane.add { name = "popup_creator_message", type = "textfield" }
	end
	if not mod_gui.get_frame_flow(player).popup_creator_pane.popup_create then
		popup_pane.add { name = "popup_create", type = "button", caption="Create popup" }
	end
end

function popup_player_joined(event)
	local player = game.players[event.player_index]
	if(player.admin) then
		popup_create_top_gui(player.name)
	end
end

function popup_create_top_gui(player_name)
	local player = game.players[player_name]
	if mod_gui.get_button_flow(player).popup_menu == nil then
		mod_gui.get_button_flow(player).add { name = "popup_menu", type = "button", caption = "Open Popup" }
	end
end

function popup_create_popup(title, message)
	for i, x in pairs(game.connected_players) do
		local tick = game.tick
		local popup = x.gui.center.add{type="frame", name="popup" .. tick, caption=title, direction="vertical"}
		popup.style.maximal_width = 400
		pl = popup.add{type="label", caption=message}
		pl.style.single_line = false
		local button = popup.add{type="button", name="popup_close", caption="Close this message"}
		button.style.minimal_width = 380
	end
end

function popup_on_gui_click(event)
	if not (event and event.element and event.element.valid) then return end
	local i = event.player_index
	local p = game.players[i]
	local e = event.element
	if e ~= nil then
		if e.name == "popup_close" then
			e.parent.destroy()
		elseif e.name == "popup_menu" and e.caption == "Open Popup" then
			popup_create_popup_creator(p.name)
			mod_gui.get_button_flow(p).popup_menu.caption = "Close Popup"
		elseif e.name == "popup_menu" and e.caption == "Close Popup" then
			if mod_gui.get_frame_flow(p).popup_creator_pane ~= nil then
				mod_gui.get_frame_flow(p).popup_creator_pane.destroy()
			end
			mod_gui.get_button_flow(p).popup_menu.caption = "Open Popup"
		elseif e.name == "popup_create" then
			popup_create_popup(mod_gui.get_frame_flow(p).popup_creator_pane.popup_creator_title.text, mod_gui.get_frame_flow(p).popup_creator_pane.popup_creator_message.text)
		end
	end
end

Event.register(defines.events.on_player_joined_game, popup_player_joined)
Event.register(defines.events.on_gui_click, popup_on_gui_click)