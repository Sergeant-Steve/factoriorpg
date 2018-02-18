-- Give patreons the option to set their patreon tag
-- A 3Ra Gaming Idea
-- Made by I_IBlackI_I

global.modular_tag_patreon = global.modular_tag_patreon or {}
global.modular_tag_patreon.patreons = {
		{name = "I_IBlackI_I", tag = "Lua Hero"},
		{name = "psihius", tag = "SysAdmin"},
		{name = "Hornwitser", tag = "MoneyBags"},
		{name = "jordank321", tag = "Im not sure LMAO"},
		{name = "viceroypenguin", tag = "MoneyBags"},
		{name = "sikian", tag = "Sikjizz!"},
		{name = "Lyfe", tag = "Is Alive"},
		{name = "sniperczar", tag = "Behemoth Bait"},
		{name = "i-l-i", tag = "Space Dolphin"},
		{name = "Uriopass", tag = "Ratio Maniac"},
		{name = "audigex", tag = "Spaghetti Monster"},
		{name = "Sergeant_Steve", tag = "Biter Killer"},
		{name = "Zr4g0n", tag = "Totally not a dragon!"},
		{name = "LordKiwi", tag = nil},
		{name = "stik", tag = nil},
		{name = "Zirr", tag = nil},
		{name = "Nr42", tag = nil},
		{name = "zerot", tag = nil}
}

function modular_tag_patreon_on_gui_click(event)
	if not (event and event.element and event.element.valid) then return end
	local player = game.players[event.element.player_index]
	local p = player
	local name = event.element.name
	if (name == "modular_tag_patreon_button") then
		player.tag = "[Patreon]"
	end
	if (name == "modular_tag_patreon_unique_button") then
		for i, patreon in pairs(global.modular_tag_patreon.patreons) do
			if(player.name == patreon.name) then
				if(patreon.tag ~= nil) then
					player.tag = "[" .. patreon.tag .. "]"
					player.print("Your unique tag has been applied!")
				else 
					player.print("O.o It seems you don't have a unique tag.. Please contact the admins to get one.")
				end
			end
		end
	end
end

function modular_tag_patreon_create_gui(event)
	local player = game.players[event.player_index]
	local p = player
	mtgf = modular_tag_get_frame(p)
	if mtgf.modular_tag_patreon_flow ~= nil and mtgf.modular_tag_patreon_flow.valid then
		mtf = mtgf.mtgf.modular_tag_patreon_flow
	else
		mtf = mtgf.add {type = "flow", direction = "vertical", name = "modular_tag_patreon_flow", style = "slot_table_spacing_vertical_flow"}
	end
	if mtf.modular_tag_patreon_unique_button ~= nil and mtf.modular_tag_unique_button.valid then
	
	else
		b2 = mtf.add {type = "button", name = "modular_tag_patreon_unique_button", caption = "Unique"}
		b2.style.font_color = {r=0.1, g=0.9, b=0.1}
		b2.style.minimal_width = 155
	end
	if mtf.modular_tag_patreon_button ~= nil and mtf.modular_tag_patreon_button.valid then
	
	else
		b1 = mtf.add { type = "button", caption = "Patreon", name = "modular_tag_patreon_button" }
		b1.style.font_color = {r=0.2, g=0.7, b=1}
		b1.style.minimal_width = 155
	end
	
	
end


Event.register(defines.events.on_gui_click, modular_tag_patreon_on_gui_click)
Event.register(defines.events.on_player_joined_game, modular_tag_patreon_create_gui)