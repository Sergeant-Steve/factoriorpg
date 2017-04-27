-- fmmo_moderatrion Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module adds commands to warn/ban players and write to log.
function fmmo_moderatrion_warn(command)
	if game.players[command.player_index].admin then
		local player = game.players[command.parameter]
		if player ~= nil then
			print("##FMC::MOD WARN ".. player.name)
			game.print(player.name .. " has been warned!")
		end
	end
end

function fmmo_moderatrion_ban(command)
	if game.players[command.player_index].admin then
		local player = game.players[command.parameter]
		if player ~= nil then
			print("##FMC::MOD BAN ".. player.name)
			game.print(player.name .. " has been banned!")
		end
	end
end

Event.register(-1, function()
	commands.add_command("fmmowarn", "Enter the username of the player you want to add to the warned list", fmmo_moderatrion_warn)
	commands.add_command("fmmoban", "Enter the username of the player you want to add to the ban list", fmmo_moderatrion_ban)
end)