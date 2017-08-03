--Nougat Mining, logistic mining designed for scenario use
--Written by Mylon, 2017
--MIT License

if MODULE_LIST then
	module_list_add("Nougat Mining")
end

nougat = {}
global.nougat = {roboports = {}, index=1, easy_ores={}}

function nougat.bake()
    for k,v in pairs(game.entity_prototypes) do
        if v.type == "resource" and v.resource_category == "basic-solid" then
            if v.mineable_properties.required_fluid == nil and not v.infinite_resource then
                table.insert(global.nougat.easy_ores, v.name)
            end
        end
    end
end

function nougat.register(event)
    --game.print("Built something!")
    if (event.created_entity and event.created_entity.valid and event.created_entity.type == "roboport") then
        --game.print("Built a roboport.")
        if event.created_entity.logistic_cell and event.created_entity.logistic_cell.valid and event.created_entity.logistic_cell.construction_radius > 0 then
            --game.print("Roboport is on.")
            local roboport = event.created_entity
            --We'll check for solid-resource entities later.
            --game.print("Roboport Radius: "  .. roboport.logistic_cell.construction_radius)
            local count = event.created_entity.surface.count_entities_filtered{type="resource", area={{roboport.position.x - roboport.logistic_cell.construction_radius, roboport.position.y - roboport.logistic_cell.construction_radius}, {roboport.position.x + roboport.logistic_cell.construction_radius-1, roboport.position.y + roboport.logistic_cell.construction_radius-1}}}
            --game.print("Found number of ores: " .. count)

            if count > 0 then
                table.insert(global.nougat.roboports, event.created_entity)
                --game.print("Adding mining roboport")
            end
        end
    end
end

function nougat.chewy(event)
    if (#global.nougat.roboports == 0) then
        return
    end
    if not (game.tick % 300 == 191) then
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
    --Filter out oil...
    if roboport.logistic_network.available_construction_robots < 20 then
        --We shouldn't bother.
        return
    end
    local ores = roboport.surface.find_entities_filtered{type="resource", limit=30, area={{roboport.position.x - roboport.logistic_cell.construction_radius, roboport.position.y - roboport.logistic_cell.construction_radius}, {roboport.position.x + roboport.logistic_cell.construction_radius-1, roboport.position.y + roboport.logistic_cell.construction_radius-1}}}
    if #ores > 0 then
        for i = #ores, 1, -1 do
            if ores[i].prototype.resource_category == "basic-fluid" or ores[i].prototype.mineable_properties.required_fluid or ores[i].prototype.infinite_resource then
                table.remove(ores, i)
            end
        end
    end
    --Now check again.
    if #ores == 0 then
        --Try harder.
        for k,v in pairs(global.nougat.easy_ores) do
            ores = roboport.surface.find_entities_filtered{name=v.name, limit=1, area={{roboport.position.x - roboport.logistic_cell.construction_radius, roboport.position.y - roboport.logistic_cell.construction_radius}, {roboport.position.x + roboport.logistic_cell.construction_radius-1, roboport.position.y + roboport.logistic_cell.construction_radius-1}}}
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
    --Finally, let's do some mining.
    --game.print("Time to mine.")
    local ore = ores[math.random(1,#ores)]
    local count = math.min(ore.amount, math.floor(roboport.logistic_network.available_construction_robots / 4))
    local position = ore.position --Just in case we kill the ore.
    local products = {}
    ore.amount = ore.amount - count
    --game.print("Mining " .. ore.name .. " with " ..count .. " bots.")
    for k,v in pairs(ore.prototype.mineable_properties.products) do
        local product
        if v.probability then
            if math.random < v.probability then
                product = {name=v.name, count=math.random(v.amount_min, v.amount_max)}
            end
        elseif v.amount then
            product = {name=v.name, count=v.amount}
        else
            product = {name=v.name, count=1}
        end
        table.insert(products, {name=product.name, count=product.count})
    end 
    for i = 1, count do
        for k, v in pairs(products) do
            local oreitem = roboport.surface.create_entity{name="item-on-ground", stack=v, position=position}
            oreitem.order_deconstruction(roboport.force)
            --game.print(oreitem.stack.name .. " #"..i.." created for pickup. ")
        end
    end
    --game.print("Created " .. #products .. " for pickup.")
    --Finally let's advance the index.
    global.nougat.index = global.nougat.index + 1
end

Event.register(-1, nougat.bake)
Event.register(defines.events.on_tick, nougat.chewy)
Event.register(defines.events.on_robot_built_entity, nougat.register)
Event.register(defines.events.on_built_entity, nougat.register)