--Dark Harvest.  Only biters drop uranium.
--Written by Mylon
--MIT licensed

HARVEST_MULTIPLIER = 2
PRODUCTIVITY_RESEARCH_AFFECTS_DROPS = true

--Destroy any uranium, in case someone didn't change map gen settings
function harvest_despawn(event)
	local ores = event.surface.find_entities_filtered{name="uranium-ore", area=event.area}
	for each, ore in pairs(ores) do
		ore.destroy()
	end
end

function harvest_drop(event)
	if event.entity.force.name == "enemy" then
		local amount = 0
		if string.find(event.entity.name, "small") then
			amount = harvest_sow(1)
			event.entity.surface.spill_item_stack(event.entity.position, {name="uranium-ore", count=amount}, true)
		elseif string.find(event.entity.name, "medium") then
			amount = harvest_sow(2)
			event.entity.surface.spill_item_stack(event.entity.position, {name="uranium-ore", count=amount}, true)
		elseif string.find(event.entity.name, "big") then
			amount = harvest_sow(4)
			event.entity.surface.spill_item_stack(event.entity.position, {name="uranium-ore", count=amount}, true)
		elseif string.find(event.entity.name, "behemoth") then
			amount = harvest_sow(8)
			event.entity.surface.spill_item_stack(event.entity.position, {name="uranium-ore", count=amount}, true)
		elseif string.find(event.entity.name, "spawner") then
			if not global.harvest_spawn then
				global.harvest_spawn = {}
			end
			if not global.harvest_spawn[event.entity.surface.name] then
				global.harvest_spawn[event.entity.surface.name] = {}
			end
			amount = harvest_sow(20)
			table.insert(global.harvest_spawn[event.entity.surface.name], {position=event.entity.position, amount=amount})
		end
	end
end

--Fractional amounts are allowed.  Any decimal remander represents the chance for 1 additional to drop.
function harvest_sow(amount)
	amount = amount * HARVEST_MULTIPLIER
	if PRODUCTIVITY_RESEARCH_AFFECTS_DROPS then
		--This assumes the force.  Necessary for worm kills.
		amount = amount * (1 + game.forces.player.mining_drill_productivity_bonus)
	end
	if math.random() < amount % 1 then
			amount = amount + 1
		end
	amount = math.max(1, math.floor(amount))
	return amount
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