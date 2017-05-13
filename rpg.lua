--Factorio RPG, written by Mylon


require "rpgdata" --Savedata
--rpg_scale = 4.6

--On player join, fetch exp.
function rpg_loadsave(event)
	local player = game.players[event.player_index]
	global.rpg_exp[player.name] = {level=1, exp=0, online=0}
	if rpg_save[player.name] then
		rpg_addexp(rpg_save[player.name])
	end
end

--Save the persistent data.
function rpg_savedata()
	local filename = "rpgdata.txt"
	local target
	--Are we on a dedicated server?
	if game.players[0] then
		target = 0
	else
		target = 1
	end
	game.write_file(filename, "{\n", true, target)
	for k, v in pairs(global.rpg_exp) do
		--Sanitize inputs.  If your name contains these characters, too bad.
		if rpg_is_sanitary(k) then
			--Goal: "name"=exp, diff=delta_exp\n
			--Store delta exp (diff) in case we need to merge 2 save files.
			local diff = 0
			if rpg_save[k] then
				diff = v.exp - rpg_save[k]
			end
			local data = '"' ..
				k ..
				'"=' ..
				v.exp ..
				', diff=' ..
				diff ..
				",\n"
			game.write_file(filename, data, true, target)
		end
	end
	game.write_file(filename, "}", true, target)
end

--Add levelup gui
function rpg_add_gui(event)
	local player = game.players[event.player_index]
	player.gui.top.add{type="frame", name="rpg", caption="Level 1"}
	player.gui.top.rpg.add{type="progressbar", name="exp", size=200}
end

-- Produces format { "player-name"=total exp }
function rpg_export()
	for name, data in pairs(global.rpg_exp) do
		game.write_file("rpgsave.txt", "{ '" .. name .."'=" .. data.exp .. ",\n", true, 1)
	end
end

--TODO: During merge script, check if old exp is greater than new exp to prevent possible data loss.

function rpg_nest_killed(event)
	--game.print("Entity died.")
	if event.entity.type == "unit-spawner" then
		--game.print("Spawner died.")
		if event.cause and event.cause.player then
			--game.print("Spawner died by player.  Awarding exp.")
			rpg_addexp(event.cause.player, 10)
		else
			if event.cause and event.cause.last_user then
				rpg_addexp(event.cause.last_user, 10)
			end
		end
	end
end

function rpg_satellite_launched(event)
	local bonus = 0
	--Todo: Check for hard recipes mode.
	if event.rocket.get_item_count("satellite") > 0 then
		global.satellites_launched = global.satellites_launched + 1
		bonus = math.max(10, 1500 / (global.satellites_launched^1.2))
		for n, player in pairs(game.players) do
			local fraction_online = global.rpg_exp[player.name].online / (game.tick * 60 * 60)
			rpg_addexp(player, bonus * fraction_online)
		end
	end
end

--Display exp, check for level up, update gui
function rpg_addexp(player, amount)
	--if not global.rpg_exp then 
	global.rpg_exp[player.name].exp = global.rpg_exp[player.name].exp + amount
	local level = global.rpg_exp[player.name].level
	--Now check for levelup.
	local levelled = false
	while global.rpg_exp[player.name].exp >= rpg_exp_tnl(global.rpg_exp[player.name].level) do
		rpg_levelup(player)
		levelled = true
	end
	if levelled == false and player.connected then
		player.surface.create_entity{name="flying-text", text="+" .. amount .. " exp", position={player.position.x, player.position.y - 3}}
	end
	--Parent value updated so update our local value.
	level = global.rpg_exp[player.name].level
	--Update progress bar.
	player.gui.top.rpg.exp.value = (global.rpg_exp[player.name].exp - rpg_exp_tnl(level-1)) / ( rpg_exp_tnl(level) - rpg_exp_tnl(level-1) )
	--game.print("Updating exp bar value to " .. player.gui.top.rpg.exp.value)
end

--Every minute, increment the time tracker.
function rpg_time_tracker(event)
	if event.tick % ( 60 * 60 ) then
		for n, player in pairs(game.players) do
			if player.connected then
				global.rpg_exp[player.name].online = global.rpg_exp[player.name].online + 1
			end
		end
	end
end
	
--Free exp.  For testing.
function rpg_exp_tick(event)
	if event.tick % (60 * 10) == 0 then
		for n, player in pairs(game.players) do
			game.print("Adding auto-exp")
			rpg_addexp(player, 60)
		end
	end
end

--The EXP curve function
function rpg_exp_tnl(level)
	if level == 0 then
		return 0
	end
	return (math.ceil( (3.6 + level)^3 / 10) * 10)
end

--Possible benefits from leveling up:
--Personal:
--Increased health
--Nearby ore deposits are enriched.
--Increased reach/build distance
--Bonus logistics slots
--Bonus trash slots
--Bonus combat robot slots
--Bonus run speed.
--Forcewide: (This is when I add classes)
--Increased health (function of cumulative bonuses of online players)
--Force gets a damage boost (function of cumulative offense bonus of online players)
--Increased ore.

function rpg_levelup(player)
	if player.connected then
		player.surface.create_entity{name="flying-text", text="Level up!", position={player.position.x, player.position.y-3}}
	end
	global.rpg_exp[player.name].level = global.rpg_exp[player.name].level + 1
	local bonuslevel = global.rpg_exp[player.name].level
	--Need to reset on respawn or reconnect.
	if player.character then --Just in case player is in spectate mode or some other weird stuff is happening
		player.character_health_bonus = 10 * bonuslevel
		player.character_running_speed_modifier = 0.03 * bonuslevel
		player.character_mining_speed_modifier = 0.07 * bonuslevel
		player.character_crafting_speed_modifier = 0.07 * bonuslevel
		--if global.rpg_exp[player.name].level % 4 == 0 then
			player.character_reach_distance_bonus = math.floor(bonuslevel/4)
			player.character_build_distance_bonus = math.floor(bonuslevel/4)
		--end
	end
	--Update GUI
	player.gui.top.rpg.caption = "Level " .. global.rpg_exp[player.name].level
end

function rpg_init()
	global.rpg_exp = {}
	--Players can give bonuses to the team, so let's nerf the base values so players can re-buff them.
	game.forces.player.manual_crafting_speed_modifier = -0.3

	--Doh, can't have a negative bonus.  This does not work.
	--game.forces.player.character_health_bonus = -50

	--Scenario stuff.
	global.satellites_launched = 0
	--game.forces.Admins.chart(player.surface, {{-400, -400}, {400, 400}}) --This doesn't work.  Admins is not created at the time?
	
end

--Utility function.
function rpg_is_sanitary(name)
	local sanitary = true
	if string.find(name, "\\") or
		string.find(name, "{") or
		string.find(name, "}") or
		string.find(name, "'") or
		string.find(name, ",") or
		string.find(name, "\"")
	then
		sanitary = false
	end
	if sanitary == false then
		log("rpg save: Name was not sanitary!")
		return false
	end
	--Still here?  Good!
	return true
end


commands.add_command("export", "Export exp table for processing", function()
	rpg_savedata()
end)

Event.register(defines.events.on_player_joined_game, rpg_loadsave)
Event.register(defines.events.on_player_joined_game, rpg_add_gui)
Event.register(defines.events.on_rocket_launched, rpg_satellite_launched)
Event.register(defines.events.on_entity_died, rpg_nest_killed)
--Event.register(defines.events.on_tick, rpg_exp_tick)
Event.register(defines.events.on_tick, rpg_time_tracker)
Event.register(-1, rpg_init)