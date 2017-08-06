--Nougat Mining, logistic mining designed for scenario use
--Written by Mylon, 2017
--MIT License

if MODULE_LIST then
	module_list_add("Nougat Mining")
end

nougat = {}
nougat.LOGISTIC_RADIUS = true --Use the logistic radius, else use construction radius.
nougat.DEFAULT_RATIO = 0.5 --The ratio of choclate to chew.  Err, I mean how many bots we assign to mining.  Starts here, changes later based on bot availability.
global.nougat = {roboports = {}, index=1, easy_ores={}, networks={}} --Networks is of format {network=network, ratio=ratio}

function nougat.bake()
    for k,v in pairs(game.entity_prototypes) do
        if v.type == "resource" and v.resource_category == "basic-solid" then
            if v.mineable_properties.required_fluid == nil and not v.infinite_resource then
                table.insert(global.nougat.easy_ores, v.name)
            end
        end
    end
    if game.entity_prototypes["electric-mining-drill"] then
        local proto  = game.entity_prototypes["electric-mining-drill"]
        --How much pollution to create per stack of products.
        --This assumes a mining hardness of 0.9
        global.nougat.pollution = (proto.electric_energy_source_prototype.emissions * proto.energy_usage * 60) / proto.mining_power / proto.mining_speed * 0.9
    else
        --Fallback if "electric-mining-drill" doesn't exist.
        global.nougat.pollution = 9 * 0.9
    end
end

function nougat.register(event)
    --game.print("Built something!")
    if (event.created_entity and event.created_entity.valid and event.created_entity.type == "roboport") then
        --game.print("Built a roboport.")
        if event.created_entity.logistic_cell and event.created_entity.logistic_cell.valid then
            local roboport = event.created_entity
            local radius = nougat.how_many_licks(roboport)
            if not radius then --Some mods use weird roboports.
                return
            end
            --game.print("Roboport is on.")
            --We'll check for solid-resource entities later.
            --game.print("Roboport Radius: "  .. roboport.logistic_cell.construction_radius)
            local count = event.created_entity.surface.count_entities_filtered{type="resource", area={{roboport.position.x - radius, roboport.position.y - radius}, {roboport.position.x + radius-1, roboport.position.y + radius-1}}}
            --game.print("Found number of ores: " .. count)

            if count > 0 then
                local network_registered = false
                for k,v in pairs(global.nougat.networks) do
                    if v.network == event.created_entity.logistic_cell.logistic_network then
                        network_registered = true
                    end
                end
                if not network_registered then
                    table.insert(global.nougat.networks, {network=event.created_entity.logistic_cell.logistic_network, ratio=nougat.DEFAULT_RATIO})
                end
                table.insert(global.nougat.roboports, event.created_entity)
                --game.print("Adding mining roboport")
            end
        end
    end
end

function nougat.chewy(event)
    if not (game.tick % 300 == 191) then
        return
    end
    if (#global.nougat.roboports == 0) then
        return
    end
    local index = global.nougat.index
    if index > #global.nougat.roboports then
        global.nougat.index = 1
        index = global.nougat.index
    end
    local roboport = global.nougat.roboports[index]
    if not (roboport and roboport.valid) then
        --game.print("Removing roboport.  Roboport.valid: " .. string(roboport.valid) )
        table.remove(global.nougat.roboports, index)
        return
    end
    if not roboport.logistic_cell and roboport.logistic_cell.valid then --Not powered.
        global.nougat.index = global.nougat.index + 1
        return
    end
    local radius = nougat.how_many_licks(roboport)
    --In case an update changes a roboport...
    if not radius or radius == 0 then
        table.remove(global.nougat.roboports, index)
        return
    end
    local area = {{roboport.position.x - radius, roboport.position.y - radius}, {roboport.position.x + radius-1, roboport.position.y + radius-1}}
    local ores = roboport.surface.find_entities_filtered{type="resource", area=area}
    --Filter out oil...
    if #ores > 0 then
        for i = #ores, 1, -1 do
            if ores[i].prototype.resource_category == "basic-fluid" or ores[i].prototype.mineable_properties.required_fluid or ores[i].prototype.infinite_resource or ores[i].prototype.mineable_properties.hardness > 100 then
                table.remove(ores, i)
            end
        end
    end
    --Now check again.
    if #ores == 0 then
        --Try harder.
        for k,v in pairs(global.nougat.easy_ores) do
            ores = roboport.surface.find_entities_filtered{name=v, limit=1, area=area}
            if #ores > 0 then
                break
            end
        end
        if #ores == 0 then
            --If we're still here, there must be nothing left to mine.
            table.remove(global.nougat.roboports, index)
            return
        end
        --game.print("Removing roboport.  No ore found.")
    end
    local count = nougat.oompa_loompa(roboport.logistic_cell.logistic_network)
    if count < 30 then
        --We shouldn't bother. Need to advance index in case this is an isolated roboport.
        global.nougat.index = global.nougat.index + 1
        return
    end
    --Finally, let's do some mining.
    --game.print("Time to mine.")
    local ore = ores[math.random(1,#ores)]
    local position = ore.position --Just in case we kill the ore.
    local productivity = roboport.force.mining_drill_productivity_bonus
    local products = {}
    count = math.min(ore.amount, count)
            
    --game.print("Mining " .. ore.name .. " with " ..count .. " bots.")
    for k,v in pairs(ore.prototype.mineable_properties.products) do
        local product
        local productivity_multiplier = 1
        if v.probability then
            if math.random < v.probability then
                product = {name=v.name, count=math.random(v.amount_min, v.amount_max)}
            end
        elseif v.amount then
            product = {name=v.name, count=v.amount}
        else
            product = {name=v.name, count=1}
        end
        --Now add productivity.
        while productivity > 0 do
            if math.random() < productivity then
                productivity_multiplier = productivity_multiplier + 1
            end
            productivity = productivity - 1
        end
        product.count = product.count * productivity_multiplier

        table.insert(products, {name=product.name, count=product.count})
    end 
    for i = 1, count do
        for k, v in pairs(products) do
            local oreitem = roboport.surface.create_entity{name="item-on-ground", stack=v, position=position}
            oreitem.order_deconstruction(roboport.force)
            --game.print(oreitem.stack.name .. " #"..i.." created for pickup. ")
        end
    end
    --Also add pollution.  This is based on count, not yield.
    roboport.surface.pollute(position, global.nougat.pollution * count)
    --game.print("Created " .. #products .. " for pickup.")

    --Deplete the ore.
    if ore.amount > count then
        ore.amount = ore.amount - count
    else
        script.raise_event(defines.events.on_resource_depleted, {entity=ore, name=defines.events.on_resource_depleted, tick=game.tick})
        if ore and ore.valid then
            ore.destroy()
        end
    end

    --Finally let's advance the index.
    global.nougat.index = global.nougat.index + 1
end

--Determine roboport radius.
function nougat.how_many_licks(entity)
    local radius
    if entity and entity.valid and entity.logistic_cell then
        if nougat.LOGISTIC_RADIUS then
            radius = entity.logistic_cell.logistic_radius
        else
            radius = entity.logistic_cell.construction_radius
        end
    end
    if radius and radius > 0 then
        return radius
    else --Invalid entity/roboport
        return nil
    end
end

--Figure out how many bots we're assigning and update the ratio along the way.
function nougat.oompa_loompa(network)
    --Fetch the table associated with this network.
    local data
    for i = #global.nougat.networks, 1, -1 do
        if not global.nougat.networks[i].network.valid then
            table.remove(global.nougat.networks, i)
        end
        if global.nougat.networks[i].network == network then
            data = global.nougat.networks[i]
        end
    end
    if not data then --Register network.
        data = {network=network, ratio=global.nougat.DEFAULT_RATIO}
        table.insert(global.nougat.networks, data)
    end
    local desired_ratio = 0.10
    if network.available_construction_robots / network.all_construction_robots > desired_ratio then
        data.ratio = data.ratio + 0.01
    else
        data.ratio = math.max(data.ratio - 0.01, 0.01)
    end
    return math.floor(network.available_construction_robots * data.ratio)
end

Event.register(-1, nougat.bake)
Event.register(defines.events.on_tick, nougat.chewy)
Event.register(defines.events.on_robot_built_entity, nougat.register)
Event.register(defines.events.on_built_entity, nougat.register)