-- Give players the option to set their preferred role as a tag
-- A 3Ra Gaming creation
-- Modified by I_IBlackI_I

global.tag = global.tag or {}
global.tag.visible = global.tag.visible or {}


function tag_create_gui(event)
	local player = game.players[event.player_index]
	local p = player
	global.tag.visible[p.name] = global.tag.visible[p.name] or false
	if global.tag.visible[p.name] then
		topgui_add_button(p.name, {name = "tag_toggle_button", caption = "Close Tag", color = {r=1, g=0, b=0}})
	else
		topgui_add_button(p.name, {name = "tag_toggle_button", caption = "Open Tag", color = {r=0, g=1, b=0}})
	end
end

-- Tag list
global.tag = global.tag or {}
global.tag.tags = {
	{ display_name = "Mining" },
	{ display_name = "Oil" },
	{ display_name = "Bus" },
	{ display_name = "Smelting" },
	{ display_name = "Pest Control" },
	{ display_name = "Automation" },
	{ display_name = "Quality Control" },
	{ display_name = "Power" },
	{ display_name = "Trains" },
	{ display_name = "Science" },
	{ display_name = "Robotics"},
	{ display_name = "AFK" },
	{ display_name = "Clear" }
}

function tag_expand_gui(player)
	local frame = mod_gui.get_frame_flow(player)["tag-panel"]
	if (frame) then
		frame.destroy()
		global.tag.visible[player.name] = false
	else
		local frame = mod_gui.get_frame_flow(player).add { type = "frame", name = "tag-panel", caption = "Choose Tag"}
		local scroll = frame.add { type = "scroll-pane", name = "tag-panel-scroll"}
		scroll.style.maximal_height = 250
		local list = scroll.add { name="tag_table", type = "table", colspan = 1}
		for _, role in pairs(global.tag.tags) do
			list.add { type = "button", caption = role.display_name, name = "tag_" .. role.display_name }
		end
		global.tag.visible[player.name] = true
	end
	if global.tag.visible[player.name] then
		topgui_add_button(player.name, {name = "tag_toggle_button", caption = "Close Tag", color = {r=1, g=0, b=0}})
	else
		topgui_add_button(player.name, {name = "tag_toggle_button", caption = "Open Tag", color = {r=0, g=1, b=0}})
	end
end



function tag_on_gui_click(event)
	if not (event and event.element and event.element.valid) then return end
	local player = game.players[event.element.player_index]
	local p = player
	local name = event.element.name
	if (name == "tag_toggle_button") then
		tag_expand_gui(player)
	end

	if (name == "tag_Clear") then
		player.tag = ""
		tag_expand_gui(player)
		return
	end
	
	for _, role in pairs(global.tag.tags) do
		if (name == "tag_" .. role.display_name) then
			player.tag = "[" .. role.display_name .. "]"
			tag_expand_gui(player)
		end
	end
	
end


Event.register(defines.events.on_gui_click, tag_on_gui_click)
Event.register(defines.events.on_player_joined_game, tag_create_gui)
