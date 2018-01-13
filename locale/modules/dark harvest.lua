--Dark Harvest.  Only biters drop uranium.
--Written by Mylon
--MIT licensed

if MODULE_LIST then
	module_list_add("Dark Harvest")
end

HARVEST_MULTIPLIER = 0.3

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
	local count = math.floor(amount * HARVEST_MULTIPLIER)
	if math.random() < ((amount * HARVEST_MULTIPLIER) % 1) then
		count = count + 1
	end
	if amount > 0 then
		event.entity.surface.spill_item_stack(event.entity.position, {name="uranium-ore", count=count}, true)
		--We'll assume force = player
		local force = game.forces.player
		force.item_production_statistics.on_flow("uranium-ore", amount)
	end
end

function harvest_prettifier()
	for k, v in pairs(game.surfaces) do
		if global.harvest_spawn and global.harvest_spawn[k] then
			for n, p in pairs(global.harvest_spawn[k]) do
				harvest_reap({event = {entity = {surface=v} }}, p.amount)
				--v.spill_item_stack(p.position, {name="uranium-ore", count=p.amount}, true)
			end
			global.harvest_spawn[k] = {}
		end
	end
end

Event.register(defines.events.on_chunk_generated, harvest_despawn)
Event.register(defines.events.on_entity_died, harvest_drop)
Event.register(defines.events.on_tick, harvest_prettifier)