--Factorio RPG, written by Mylon
--Utility command for griefing.
-- /silent-command do local hoarder = {amount=0} for k,v in pairs(game.players) do if v.get_item_count("uranium-235") > hoarder.amount then hoarder.name = v.name hoarder.amount = v.get_item_count("uranium-235") end end game.print(hoarder.name .. " is hoarding " .. hoarder.amount .. " uranium-235!") end

require "rpgdata" --Savedata.  This is externally generated.
--rpg_scale = 4.6

--On player join, fetch exp.
function rpg_loadsave(event)
	local player = game.players[event.player_index]
	if not global.rpg_exp[player.name] then
		global.rpg_exp[player.name] = {level=1, exp=0}
		if rpg_save[player.name] then
			rpg_addexp(player, rpg_save[player.name])
		end
	end
end

--Save the persistent data.

function rpg_savedata()
	local filename = "rpgdata - " .. game.tick .. ".txt"
	local target
	--Are we on a dedicated server?
	if game.players[0] then
		target = 0
	else
		target = 1
	end
	game.write_file(filename, serpent.block(global.rpg_exp), true, target)
end

--Old serializer.
-- function rpg_savedata()
	-- local filename = "rpgdata - " .. game.tick .. ".txt"
	-- local target
	-- --Are we on a dedicated server?
	-- if game.players[0] then
		-- target = 0
	-- else
		-- target = 1
	-- end
	-- game.write_file(filename, "{\n", true, target)
	-- for k, v in pairs(global.rpg_exp) do
		-- --Sanitize inputs.  If your name contains these characters, too bad.
		-- if rpg_is_sanitary(k) then
			-- --Goal: "name"=exp, diff=delta_exp\n
			-- --Store delta exp (diff) in case we need to merge 2 save files.
			-- local diff = 0
			-- if rpg_save[k] then
				-- diff = v.exp - rpg_save[k]
			-- end
			-- local data = '["' ..
				-- k ..
				-- '"]={' ..
				-- math.floor(v.exp) ..
				-- ', diff=' ..
				-- diff ..
				-- "},\n"
			-- game.write_file(filename, data, true, target)
		-- end
	-- end
	-- game.write_file(filename, "}", true, target)
-- end

--Add levelup gui
function rpg_add_gui(event)
	local player = game.players[event.player_index]
	if not player.gui.top.rpg then
		player.gui.top.add{type="frame", name="rpg", caption="Level 1"}
		player.gui.top.rpg.add{type="progressbar", name="exp", size=200, tooltip="Kill biter bases or launch rockets to level up."}
	end
end

--Higher level players get more starting resources for an accelerated start!
function rpg_starting_resources(event)
	local player = game.players[event.player_index]
	local bonuslevel = global.rpg_exp[player.name].level - 1
	player.insert{name="iron-plate", count=bonuslevel * 10}
	player.insert{name="copper-plate", count=math.floor(bonuslevel / 4) * 10}
	player.insert{name="stone", count=math.floor(bonuslevel / 4) * 10}
end

-- Produces format { "player-name"=total exp }
-- function rpg_export()
	-- for name, data in pairs(global.rpg_exp) do
		-- game.write_file("rpgsave.txt", "{ '" .. name .."'=" .. data.exp .. ",\n", true, 1)
	-- end
-- end

--TODO: During merge script, check if old exp is greater than new exp to prevent possible data loss.

function rpg_nest_killed(event)
	--game.print("Entity died.")
	if event.entity.type == "unit-spawner" then
		--game.print("Spawner died.")
		if event.cause and event.cause.type == "player" then
			--game.print("Spawner died by player.  Awarding exp.")
			rpg_addexp(event.cause.player, 100)
		else
			if event.cause and event.cause.last_user then
				rpg_addexp(event.cause.last_user, 100)
			end
		end
	end
	if event.entity.type == "turret" and event.entity.force == "enemy" then
		--Worm turret died.
		if event.cause and event.cause.player then
			rpg_addexp(event.cause.player, 50)
		else
			if event.cause and event.cause.last_user then
				rpg_addexp(event.cause.last_user, 50)
			end
		end
	end
end

--Award exp based on number of beakers
function rpg_tech_researched(event)
	local value = 0
	--Space science packs aren't worth anything.  You already got exp for the rocket!
	for _, ingredient in pairs(event.research.research_unit_ingredients) do
		if ingredient.name == "science-pack-1" then
			value = value + ingredient.amount * event.research.research_unit_count
		elseif ingredient.name == "science-pack-2" then
			value = value + ingredient.amount * event.research.research_unit_count
		elseif ingredient.name == "science-pack-3" then
			value = value + ingredient.amount * event.research.research_unit_count
		elseif ingredient.name == "military-science-pack" then
			value = value + ingredient.amount * event.research.research_unit_count
		elseif ingredient.name == "production-science-pack" then
			value = value + ingredient.amount * event.research.research_unit_count
		elseif ingredient.name == "high-tech-science-pack" then
			value = value + ingredient.amount * event.research.research_unit_count
		end
	end
	value = math.floor(value / 2)
	for _, player in pairs(game.players) do
		if player.connected then
			rpg_addexp(player, value)
		end
	end
	-- Expected value of Logistic System: 150 * (5) / 2 =  375 exp
end

function rpg_satellite_launched(event)
	local bonus = 0
	--Todo: Check for hard recipes mode.
	if event.rocket.get_item_count("satellite") > 0 then
		global.satellites_launched = global.satellites_launched + 1
		bonus = math.max(10, 20000 / (global.satellites_launched^1.2))
		for n, player in pairs(game.players) do
			local fraction_online = player.online_time / game.tick
			rpg_addexp(player, math.floor(bonus * fraction_online))
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
	player.gui.top.rpg.tooltip = math.floor(player.gui.top.rpg.exp.value * 10000)/100 .. "% to next level ( " .. math.floor(global.rpg_exp[player.name].exp) - rpg_exp_tnl(level-1) .. " / " .. rpg_exp_tnl(level) - rpg_exp_tnl(level-1) .. " )"
	--game.print("Updating exp bar value to " .. player.gui.top.rpg.exp.value)
end
	
--Free exp.  For testing.
function rpg_exp_tick(event)
	if event.tick % (60 * 10) == 0 then
		for n, player in pairs(game.players) do
			game.print("Adding auto-exp")
			rpg_addexp(player, 600)
		end
	end
end

--The EXP curve function
function rpg_exp_tnl(level)
	if level == 0 then
		return 0
	end
	return (math.ceil( (3.6 + level)^3 / 10) * 100)
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
	
	--Award bonuses
	rpg_give_bonuses(player)
	
	--Update GUI
	if player.connected then
		player.gui.top.rpg.caption = "Level " .. global.rpg_exp[player.name].level
	end
end

function rpg_respawn(event)
	local player = game.players[event.player_index]
	rpg_give_bonuses(player)
end

--Award bonuses
function rpg_give_bonuses(player)
	local bonuslevel = global.rpg_exp[player.name].level - 1
	if player.character then --Just in case player is in spectate mode or some other weird stuff is happening
		player.character_health_bonus = 10 * bonuslevel
		player.character_running_speed_modifier = 0.015 * bonuslevel -- This seems multiplicative
		player.character_mining_speed_modifier = 0.06 * bonuslevel
		player.character_crafting_speed_modifier = 0.06 * bonuslevel
		--if global.rpg_exp[player.name].level % 4 == 0 then
			player.character_reach_distance_bonus = math.floor(bonuslevel/4)
			player.character_build_distance_bonus = math.floor(bonuslevel/4)
			player.character_inventory_slots_bonus = math.floor(bonuslevel/4)
			player.character_maximum_following_robot_count_bonus = math.floor(bonuslevel/5)
		--end
	end
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

--Replaced with serpent.block(global.rpg_data)
-- commands.add_command("export", "Export exp table for processing", function()
	-- rpg_savedata()
-- end)

Event.register(defines.events.on_player_created, rpg_add_gui)
Event.register(defines.events.on_player_created, rpg_loadsave)
Event.register(defines.events.on_player_created, rpg_starting_resources)
Event.register(defines.events.on_player_respawned, rpg_respawn)
Event.register(defines.events.on_rocket_launched, rpg_satellite_launched)
Event.register(defines.events.on_entity_died, rpg_nest_killed)
Event.register(defines.events.on_research_finished, rpg_tech_researched)
--Event.register(defines.events.on_tick, rpg_exp_tick) --For debug
Event.register(-1, rpg_init)