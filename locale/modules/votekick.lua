--Votekick: Allow users to banish other users.
--Written by Mylon, 2017
--MIT License.  Free to use

if MODULE_LIST then
	module_list_add("Votekick")
end


votekick = { VOTEKICK_COUNT = 3, KICKED_MESSAGE = "You have been kicked.  To appeal, " }
global.votekick = {}

--Note, this command looks for a hardcoded group named "trusted" and uses that to qualify the ability to vote.
--Name is case insensitive.

--commands.add_command("votekick", "Usage: /votekick <player> <reason> (optional)", function(params)
commands.add_command("votekick", "Usage: /votekick <player>", function(params)
	local name = params.parameter
	if not game.player then --Server cannot run this command.
		return
	end
	if name == nil then
		game.player.print("Do /votekick <name> to start a vote to kick that player.")
		return
	end
    name = name:lower()
    --Look for hardcoded group "trusted".  If present, deny player from voting unless they belong to that group.
	if game.permissions.get_group("trusted") and game.permissions.get_group("trusted") ~= game.player.permission_group then
		game.player.print("Must be trusted to votekick.")
		return
	end
	if not (game.players[name]) then
		game.player.print("Invalid name.")
		return
	end
    if not global.votekick[name] then
        global.votekick[name] = {}
        game.print(game.player.name .. " has started a vote to kick player " .. name)
    end
    if not global.votekick[name][game.player.name] then
        global.votekick[name][game.player.name] = true
        game.player.print("You have voted to kick player " .. name)
        --Must have VOTEKICK_COUNT votes or 2 votes if 3 players online.  Do not want to allow a single user to votekick on a 2 player server.
        if #global.votekick[name] >= votekick.VOTEKICK_COUNT or (#global.votekick[name] == 2 and 3 == #game.connected_players)  then
            game.print(name .. " has been kicked by player vote.")
        end
    else
        game.player.print("You have already voted to kick " .. params.parameter .. ".")
    end
end)

function votekick.init()
    local settings = {width = 10, height = 10, seed=86}
    game.create_surface("jail", settings)
    local group = game.permissions.create_group("jailed")
    --Disable features that might be abusable.
    group.set_allows_action(defines.input_action.change_programmable_speaker_parameters, false)
    group.set_allows_action(defines.input_action.edit_custom_tag, false)
    group.set_allows_action(defines.input_action.delete_custom_tag, false)
    group.set_allows_action(defines.input_action.open_train_gui, false)
    group.set_allows_action(defines.input_action.set_train_stopped, false)
    group.set_allows_action(defines.input_action.change_train_stop_station, false)
    group.set_allows_action(defines.input_action.write_to_console, false)

end

function votekick.kick(name)
    local player = game.players[name]
    if not (player and player.valid) then return end
    player.teleport({0,0}, "jail")
    player.permission_group = game.permissions.get_group("jailed")
end

Event.register(-1, votekick.init)