--Dark Harvest.  Only biters drop uranium.
--Written by Mylon
--MIT licensed

HARVEST_MULTIPLIER = 2

--Destroy any uranium, in case someone didn't change map gen settings
function harvest_despawn(event)
	local ores = event.surface.find_entities_filtered{name="uranium-ore", area=event.area}
	for each, ore in pairs(ores) do
		ore.destroy()
	end
end

function harvest_drop(event)
	if event.entity.force.name == "enemy" then
		if string.find(event.entity.name, "small") then
			harvest_reap(event, 1)
		elseif string.find(event.entity.name, "medium") then
			harvest_reap(event, 2)
		elseif string.find(event.entity.name, "big") then
			harvest_reap(event, 4)
		elseif string.find(event.entity.name, "behemoth") then
			harvest_reap(event, 8)
		elseif string.find(event.entity.name, "spawner") then
			if not global.harvest_spawn then
				global.harvest_spawn = {}
			end
			if not global.harvest_spawn[event.entity.surface.name] then
				global.harvest_spawn[event.entity.surface.name] = {}
			end
			table.insert(global.harvest_spawn[event.entity.surface.name], {position=event.entity.position, amount=20})
		end
	end
end

function harvest_reap(event, amount)
	amount = math.max(1, math.ceil(amount * HARVEST_MULTIPLIER))
	loot = event.entity.surface.spill_item_stack(event.entity.position, {name="uranium-ore", count=amount}, true)
end

function harvest_prettifier()
	for k, v in pairs(game.surfaces) do
		if global.harvest_spawn and global.harvest_spawn[k] then
			for n, p in pairs(global.harvest_spawn[k]) do
				v.spill_item_stack(p.position, {name="uranium-ore", count=p.amount}, true)
			end
			global.harvest_spawn[k] = {}
		end
	end
end

Event.register(defines.events.on_chunk_generated, harvest_despawn)
Event.register(defines.events.on_entity_died, harvest_drop)
Event.register(defines.events.on_tick, harvest_prettifier)