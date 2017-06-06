function rpg_permissions_init()
	local default = game.permissions.groups[1]
	default.set_allows_action(defines.input_action.deconstruct, false)
	default.set_allows_action(defines.input_action.change_programmable_speaker_parameters, false)
	default.set_allows_action(defines.input_action.edit_custom_tag, false)
	default.set_allows_action(defines.input_action.delete_custom_tag, false)
	--No changing train stations
	--This one ought to cover most of the bases...
	default.set_allows_action(defines.input_action.open_train_gui, false)
	default.set_allows_action(defines.input_action.set_train_stopped, false)
	default.set_allows_action(defines.input_action.change_train_stop_station, false)
	game.permissions.create_group("trusted") --For level 5+ players.
end

Event.register(-1, rpg_permissions_init)