-- Enhanced Biters, a mod for more dangerous biters
-- Factorio module by Mylon, 2018
-- MIT License

if MODULE_LIST then
	module_list_add("Enhanced Biters")
end

global.zombies = {}
global.capsules = {}

--Unique behaviors
function splitters(event)
	if not global.zombies then
		global.zombies = {}
	end
	if event.entity.force ~= "enemy" then
		return
	end
	
	if event.entity.name == "big-biter" and math.random(1,10) == 10 then
		event.entity.surface.create_entity{name="big-worm-turret", position=event.entity.position}
	end
	if event.entity.name == "big-worm-turret" and math.random(1,2) == 2 then
		for i=0, 5, 1 do
			local pos = game.surfaces[1].find_non_colliding_position("medium-biter", event.entity.position, 10, 3)
			event.entity.surface.create_entity{name="medium-worm-turret", position=pos}
		end
	end
	if event.entity.name == "medium-worm-turret" and math.random(1,2) == 2 then
		for i=0, 5, 1 do
			local pos = game.surfaces[1].find_non_colliding_position("medium-biter", event.entity.position, 10, 2)
			event.entity.surface.create_entity{name="small-worm-turret", position=pos}
		end
	end
	if event.entity.name == "acid-projectile-purple" then
		local pos = getRandom(global.spawnPoints)
		event.entity.surface.create_entity{name="small-biter", position=event.entity.position}
	end
	if event.entity.name == "medium-biter" and math.random(1,2) == 2 then
		table.insert(global.zombies, {tick=game.tick, position=event.entity.position, surface=event.entity.surface})
	end
	if event.entity.name == "behemoth-spitter" and math.random (1,10) == 10 then
		if event.cause and event.cause.valid then
			local capsule = event.entity.surface.create_entity{name="acid-projectile-purple", position=event.entity.position, speed=0.5, target=event.cause}
			table.insert(global.capsules, {entity = capsule, target=event.cause, type="medium-biter", count=2})
		end
	end
end

function delayed_spawn()
	if not global.zombies then
		global.zombies = {}
	end
	for i = #global.zombies, 1, -1 do
		local zombie = global.zombies[i]
		if game.tick > zombie.tick + (60*60*2) then
			local spawnPoint = zombie.surface.find_non_colliding_position("medium-biter", zombie.position, 10, 3)
			if spawnPoint then
				zombie.surface.create_entity{name="medium-biter", position=zombie.position}
			end
			table.remove(global.zombies, i)
		end
	end
	for i = #global.capsules, 1, -1 do
		local capsule = global.capsules[i]
		if not (capsule.entity and capsule.entity.valid) then --Projectile found its mark.
			for n = 1, capsule.count do
				local spawnPoint = capsule.target.surface.find_non_colliding_position("small-biter", capsule.target.position, 10, 2)
				if spawnPoint then
					capsule.target.surface.create_entity{name=capsule.type, position=pos}
				end
			end
			table.remove(global.capsules, i)
		end
	end
end

Event.register(defines.events.on_entity_died, splitters)
Event.register(defines.events.on_tick, delayed_spawn)