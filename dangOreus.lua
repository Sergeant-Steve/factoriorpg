STARTING_RADIUS = 100
EASY_ORE_RADIUS = 250

if MODULE_LIST then
	module_list_add("dangOreus")
end

--Sprinkle ore everywhere
function gOre(event)
    local oldores = event.surface.find_entities_filtered{type="resource", area=event.area}
    for k, v in pairs(oldores) do
        if v.prototype.resource_category == "basic-solid" then
            v.destroy()
        end
    end

    --Generate our random once for the whole chunk.
    local rand = math.random()

    --What kind of chunk are we generating?  Biased, ore, or random?
    --Check our global table of nearby chunks.
    --If any nearby chunks use the biased table, we must use the matching that ore to determine ore type.
    -- chunk_type starts off as a table in case it borders multiple biased patches, then we collapse it after checking neighbors
    local chunk_type = {}
    local biased = false
    local chunkx = event.area.left_top.x
    local chunky = event.area.left_top.y

    local function check_chunk_bias(x,y)
        if global.ore_chunks[x] then
            if global.ore_chunks[x][y] then
                if global.ore_chunks[x][y].biased then
                    table.insert(chunk_type, global.ore_chunks[x][y].type)
                end
            end
        end
    end

    local function check_chunk_type(x,y)
        if global.ore_chunks[x] then
            if global.ore_chunks[x][y] then
                table.insert(chunk_type, global.ore_chunks[x][y].type)
                return
            end
        end
        -- Still here? Insert random.
        table.insert(chunk_type, "random")
    end

    --starting from top, clockwise
    check_chunk_bias(chunkx, chunky-32)
    check_chunk_bias(chunkx+32, chunky)
    check_chunk_bias(chunkx, chunky+32)
    check_chunk_bias(chunkx-32, chunky)

    --Collapse table
    if #chunk_type > 0 then
        chunk_type = chunk_type[math.random(#chunk_type)]
        -- chance this chunk is also biased.
        if math.random() < 0.25 then
            biased = true
        end
    else
        --Repeat process for non-biased chunks
        check_chunk_type(chunkx, chunky-32)
        check_chunk_type(chunkx+32, chunky)
        check_chunk_type(chunkx, chunky+32)
        check_chunk_type(chunkx-32, chunky)

        chunk_type = chunk_type[math.random(#chunk_type)]
        --If type is not random, chance chunk is biased.
        --If type is random, chance chunk type is different.
        if chunk_type == "random" then
            if math.random() < 0.25 then
                chunk_type = global.diverse_ore_list[math.random(#global.diverse_ore_list)]
            end
        else
            if math.random() < 0.25 then
                biased = true
            end
        end
    end

    --Set global table with this type/bias
    if not global.ore_chunks[chunkx] then
        global.ore_chunks[chunkx] = {}
    end
    global.ore_chunks[chunkx][chunky] = {type=chunk_type, biased=biased}

    for x = event.area.left_top.x, event.area.left_top.x + 31 do
        for y = event.area.left_top.y, event.area.left_top.y + 31 do
            if event.surface.get_tile(x,y).collides_with("ground-tile") then
                local amount = (x^2 + y^2)^0.75 / 8
                if x^2 + y^2 >= STARTING_RADIUS^2 then
                    --Build the ore list.  Uranium can only appear in uranium chunks.
                    local ore_list = {}
                    for k, v in pairs(global.easy_ore_list) do
                        table.insert(ore_list, v)
                    end
                    if not (chunk_type == "random") then
                        --Build the ore list.  non-baised chunks get 3 instances, biased chunks get 6.  Except uranium, which has no default instance in the table.
                        table.insert(ore_list, chunk_type)
                        --table.insert(ore_list, chunk_type)
                        if biased then
                            table.insert(ore_list, chunk_type)
                            table.insert(ore_list, chunk_type)
                            --table.insert(ore_list, chunk_type)
                        end
                        --game.print(serpent.line(ore_list))
                    end

                    local type = ore_list[math.random(#ore_list)]
                    --With noise
                    event.surface.create_entity{name=type, amount=amount, position={x+0.45+0.1*math.random(), y+0.45+0.1*math.random()}}
                    --Without noise
                    -- event.surface.create_entity{name=type, amount=amount, position={x+0.5, y+0.5}}
                end
            end
        end
    end
end

--Auto-destroy non-mining drills.
function dangOre(event)
    if event.created_entity.type == "mining-drill" or event.created_entity.type == "car" or not event.created_entity.destructible then
        return
    end
    local last_user = event.created_entity.last_user
    local ores = event.created_entity.surface.count_entities_filtered{type="resource", area=event.created_entity.bounding_box}
    if ores > 0 then
        --Need to turn off ghosts left by dead buildings so construction bots won't keep placing buildings and having them blow up.
        local ttl = event.created_entity.force.ghost_time_to_live
        local force = event.created_entity.force
        event.created_entity.force.ghost_time_to_live = 0
        event.created_entity.die()
        force.ghost_time_to_live = ttl
        if last_user then
            last_user.print("Cannot build non-miners on resources!")
        end
    end
end

--Destroying chests causes any contained ore to spill onto the ground.
function ore_rly(event)
    local items = {"stone", "coal", "iron-ore", "copper-ore", "uranium-ore"}
    if event.entity.type == "container" or event.entity.type == "cargo-wagon" then
        --Let's spill all items instead.
        for k,v in pairs(event.entity.get_inventory(defines.inventory.chest).get_contents()) do
            event.entity.surface.spill_item_stack(event.entity.position, {name=k, count=v})
        end
        -- for k, v in pairs(items) do
        --     if event.entity.get_item_count(v) > 0 then
        --         event.entity.surface.spill_item_stack(event.entity.position, {name=v, count=event.entity.get_item_count(v)})
        --     end
        -- end
    end
end

--Build the list of ores
function divOresity_init()
    --Each chunk picks a table to generate from.  Each table has either 3 copies of one ore, or 6 copies.
    global.easy_ore_list = {}
	global.diverse_ore_list = {}

    global.easy_ores = {}
    global.diverse_ores = {}
    global.ore_chunks = {}

	for k,v in pairs(game.entity_prototypes) do
		if v.type == "resource" and v.resource_category == "basic-solid" then
            table.insert(global.diverse_ore_list, v.name)
            if v.mineable_properties.required_fluid == nil then
			    table.insert(global.easy_ore_list, v.name)
            end
		end
	end
    
    --These tables should look like:


    --Easy ores
    for k, v in pairs(global.easy_ore_list) do
        local ore = {}
        local biased = {}
        local random = {}
        
        for i = 1, 2 do
            table.insert(ore, v)
            table.insert(biased, v)
        end
        for i = 1, 3 do
            table.insert(biased, v)
        end
        for n, p in pairs(global.easy_ore_list) do
            table.insert(ore, p)
            table.insert(biased, p)
            table.insert(random, p)
        end
        table.insert(global.easy_ores, ore)
        table.insert(global.easy_ores, biased)
        table.insert(global.easy_ores, random)
    end

    --Diverse ores
    for k, v in pairs(global.diverse_ore_list) do
        local ore = {}
        local biased = {}
        local random = {}
        
        for i = 1, 2 do
            table.insert(ore, v)
            table.insert(biased, v)
        end
        for i = 1, 3 do
            table.insert(biased, v)
        end
        for n, p in pairs(global.diverse_ore_list) do
            table.insert(ore, p)
            table.insert(biased, p)
            table.insert(random, p)
        end
        table.insert(global.diverse_ores, ore)
        table.insert(global.diverse_ores, biased)
        table.insert(global.diverse_ores, random)
    end

end

Event.register(defines.events.on_built_entity, dangOre)
Event.register(defines.events.on_robot_built_entity, dangOre)
Event.register(defines.events.on_chunk_generated, gOre)
Event.register(defines.events.on_entity_died, ore_rly)
Event.register(-1, divOresity_init)