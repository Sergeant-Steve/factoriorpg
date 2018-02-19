-- topgui Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module allows some more complex actions on the button in the top left, for example order them.

-- 
-- EXAMPLE USAGES CAN BE FOUND AT THE BOTTOM OF THIS FILE
--

--
--	VARIABLES
--

global.topgui = global.topgui or {}
global.topgui.raw = global.topgui.raw or {}
global.topgui.sorted = global.topgui.sorted or {}
global.topgui.style = mod_gui.button_style

--
--	FUNCTIONS
--

function topgui_add_button(player_name, button)
	if button.name ~= nil then
		nb = {}
		if button.caption ~= nil then
			nb.caption = button.caption
		else
			nb.caption = "NO CAPTION"
		end
		if button.order ~= nil then
			nb.order = button.order
		else
			nb.order = 10
		end
		if button.color ~= nil then
			nb.color = button.color
		else
			nb.color = {r = 1, g = 1, b = 1}
		end
		global.topgui.raw[player_name][button.name] = nb
		topgui_gui_changed(game.players[player_name])
	end
end

function topgui_add_sprite_button(player_name, button)
	if button.name ~= nil then
		nb = {}
		if button.sprite ~= nil then
			nb.sprite = button.sprite
		end
		if button.order ~= nil then
			nb.order = button.order
		else
			nb.order = 10
		end
		if button.color ~= nil then
			nb.color = button.color
		else
			nb.color = {r = 1, g = 1, b = 1}
		end
		global.topgui.raw[player_name][button.name] = nb
		topgui_gui_changed(game.players[player_name])
	end
end

function topgui_remove_button(player_name, button_name)
	global.topgui.raw[player_name][button_name] = nil
	topgui_get_flow(game.players[player_name])[button_name].destroy()
end

function topgui_change_button_caption(player_name, button_name, caption)
	global.topgui.raw[player_name][button_name].caption = caption
	topgui_get_flow(game.players[player_name])[button_name].caption = caption
end

function topgui_change_button_color(player_name, button_name, color)
	global.topgui.raw[player_name][button_name].color = color
	topgui_get_flow(game.players[player_name])[button_name].style.font_color = color
end

function topgui_change_button_order(player_name, button_name, order)
	global.topgui.raw[player_name][button_name].order = order
	topgui_gui_changed(game.players[player_name])
end

function topgui_gui_changed(p)
	topgui_sort_table(p)
	tg = topgui_get_flow(p)
	tg.clear()
	for i, button in pairs(global.topgui.sorted[p.name]) do
		b = tg.add {name=button.name, type="button", caption=button.caption}
		if button.color ~= nil then
			b.style.font_color = button.color
		end
	end
end

function topgui_sort_table(p)
	global.topgui.sorted[p.name] = {}
	for i, b in pairs(global.topgui.raw[p.name]) do
		newtable = {name = i, caption = b.caption, order = b.order, color = b.color}
		table.insert(global.topgui.sorted[p.name], newtable)
	end
	table.sort(global.topgui.sorted[p.name], function(t1, t2)
			return t1.order < t2.order
		end)
	
end

function topgui_get_flow(p)
	bf = mod_gui.get_button_flow(p)
	if bf.topgui ~= nil then
		tg = bf.topgui
	else
		tg = bf.add {name = "topgui", type = "flow", direction = "horizontal", style = "slot_table_spacing_horizontal_flow"}
	end
	return tg
end
	
--
--	EVENTS
--

Event.register(defines.events.on_player_joined_game, function(event)
	p = game.players[event.player_index]
	global.topgui.raw[p.name] = global.topgui.raw[p.name] or {}
	topgui_gui_changed(p)
end)

--
--	EXAMPLES
--

-- 			add a button, only name is required.

-- new_button = {name = newbutton}
-- topgui_add_button(p.name, new_button)

-- 			add a button, all possible values

-- new_button1 = {name = newbutton1, caption = "I has caption!", order=1337, color={r = 1, g = 0, b = 1}}
-- topgui_add_button(game.player.name, {name = "newbutton1", caption = "I has caption!", order=1337, color={r = 1, g = 0, b = 1}})

-- 			remove a button

-- topgui_remove_button(p.name, new_button1)

--			change button values

-- topgui_change_button_caption(p.name, "new_button1", "Hello world!")
-- topgui_change_button_order(p.name, "new_button1", 1)
-- topgui_change_button_color(p.name, "new_button1", {r=0, g=1, b=0})


