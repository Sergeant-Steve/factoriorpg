--divOresity
--Written by Mylon
--MIT licensed
--Inspired by Ore Chaos

DIVERSITY_QUOTA = 0.125
EXEMPT_AREA = 200 --This is the radius of the starting area that can't be affected.

--Build a table of potential ores to pick from.  Uranium is exempt from popping up randomly.
function divOresity_init()
	global.diverse_ores = {}
	for k,v in pairs(game.entity_prototypes) do
		if v.type == "resource" and v.resource_category == "basic-solid" and v.mineable_properties.required_fluid == nil then
			table.insert(global.diverse_ores, v.name)
		end
	end
end

function diversify(event)
	local ores = event.surface.find_entities_filtered{type="resource", area=event.area}
	for k,v in pairs(ores) do
		if math.abs(v.position.x) > EXEMPT_AREA or math.abs(v.position.y) > EXEMPT_AREA then
			if v.prototype.resource_category == "basic-solid" then
				if math.random() < DIVERSITY_QUOTA then --Replace!
					local refugee = global.diverse_ores[math.random(#global.diverse_ores)]
					event.surface.create_entity{name=refugee, position=v.position, amount=v.amount}
					v.destroy()
				end
			end
		end
	end
end

Event.register(defines.events.on_chunk_generated, diversify)
Event.register(-1, divOresity_init)