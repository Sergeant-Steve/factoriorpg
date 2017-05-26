function camera_create_top_button(player_name)
	local player = game.players[player_name]
	if not player.gui.top.camera_create then
		player.gui.top.add { name = "camera_create", type = "button", caption = "Create Camera" }
	end
end

function camera_player_joined(event)
	local player = game.players[event.player_index]
	if(player.admin) then
		camera_create_top_button(player.name)
	end
end

function camera_create(player)
	if not player.gui.left.camera_pane then
		frame = player.gui.left.add { type = "frame", name = "camera_pane", caption = "Camera's", direction = "vertical"}
	else
		frame = player.gui.left.camera_pane
	end
	if not frame.camera_wrapper
	local scroll = frame.add { type = "scroll-pane", name = "camera_wrapper"}
	scroll.style.maximal_height = 800
	local camera = scroll.add {type="camera", name = "camera", position=player.position, zoom = 0.25}
	camera.style.maximal_width = 200
	camera.style.maximal_height = 200
	camera.style.minimal_width = 200
	camera.style.minimal_height = 200
end

function camera_on_gui_click(event)
	if not (event and event.element and event.element.valid) then return end
	local i = event.player_index
	local p = game.players[i]
	local e = event.element
	if e ~= nil then
		if e.name == "camera_create" then
			camera_create(p)
		elseif e.name == "camera" then
			e.parent.destroy()
		elseif e.name == "camera_wrapper_destroy" then
			e.parent.destroy()
		end
	end
end

Event.register(defines.events.on_player_joined_game, camera_player_joined)
Event.register(defines.events.on_gui_click, camera_on_gui_click)