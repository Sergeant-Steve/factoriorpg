-- Popup Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module displays an popup on all players their screens.

function popup_create_popup_creator(player_name)
	local player = game.players[player_name]
	local index = player.index
	if not player.gui.left.popup_creator_pane then
		popup_pane = player.gui.left.add { name = "popup_creator_pane", type = "frame", direction = "vertical", caption = "Popup GUI " }
	else
		popup_pane = player.gui.left.popup_creator_pane
	end
	if not player.gui.left.popup_creator_pane.popup_creator_title_label then
		popup_pane.add { name = "popup_creator_title_label", type = "label", caption="Title of the popup" }
	end
	if not player.gui.left.popup_creator_pane.popup_creator_title then
		popup_pane.add { name = "popup_creator_title", type = "textfield" }
	end
	if not player.gui.left.popup_creator_pane.popup_creator_message_label then
		popup_pane.add { name = "popup_creator_message_label", type = "label", caption="Message of the popup" }
	end
	if not player.gui.left.popup_creator_pane.popup_creator_message then
		popup_pane.add { name = "popup_creator_message", type = "textfield" }
	end
	if not player.gui.left.popup_creator_pane.popup_create then
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
	if player.gui.top.popup_menu == nil then
		player.gui.top.add { name = "popup_menu", type = "button", caption = "Open Popup" }
	end
end

function popup_create_popup(title, message)
	for i, x in pairs(game.connected_players) do
		if x.gui.center.popup == nil then
			local popup = x.gui.center.add{type="frame", name="popup", caption=title, direction="vertical"}
			popup.add{type="label", caption=message}
			popup.add{type="button", name="popup_close", caption="Close this message"}
		else
			x.gui.center.popup.destroy()
		end
	end
end

function popup_on_gui_click(event)
	if not (event and event.element and event.element.valid) then return end
	local i = event.player_index
	local p = game.players[i]
	local e = event.element
	if e ~= nil then
		if e.name == "popup_close" then
			if p.gui.center.popup ~= nil then
				p.gui.center.popup.destroy()
			end
		elseif e.name == "popup_menu" and e.caption == "Open Popup" then
			popup_create_popup_creator(p.name)
			p.gui.top.popup_menu.caption = "Close Popup"
		elseif e.name == "popup_menu" and e.caption == "Close Popup" then
			if p.gui.left.popup_creator_pane ~= nil then
				p.gui.left.popup_creator_pane.destroy()
			end
			p.gui.top.popup_menu.caption = "Open Popup"
		elseif e.name == "popup_create" then
			popup_create_popup(p.gui.left.popup_creator_pane.popup_creator_title.text, p.gui.left.popup_creator_pane.popup_creator_message.text)
		end
	end
end

Event.register(defines.events.on_player_joined_game, popup_player_joined)
Event.register(defines.events.on_gui_click, popup_on_gui_click)