--Regional production, goods can only be produced within certain regions
--Written by Mylon, 2018-10
--MIT License

if MODULE_LIST then
	module_list_add("Regional Production")
end

regional = {
    RANGE = 64,
    CHANCE = 8
}

global.regional = {registry = {}, index=1}

function regional.region(event)
    --First check if we're spawning one.
    if not (math.random(regional.CHANCE) == regional.CHANCE) then
        return
    end
    local choice = math.random(#game.forces.player.recipes)
    local count = 1
    local recipe
    for k,v in pairs(game.forces.player.recipes) do
        if count == choice then
            if v.hidden then --Don't show smelting recipes!
                break
            end
            recipe = game.forces.player.recipes[k]
            break
        end
        count = count + 1
    end
    if recipe then
        local signal = {type=recipe.products[1].type, name=recipe.products[1].name}
        local combinator = event.surface.create_entity{name="constant-combinator", force=game.forces.player, position={math.random(event.area.left_top.x, event.area.right_bottom.x), math.random(event.area.left_top.y, event.area.right_bottom.y)} }
        combinator.get_or_create_control_behavior().set_signal(1, {signal=signal, count=regional.RANGE})
        combinator.destructible = false
        combinator.operable = false
        combinator.minable = false
    end
    --Multiple may spawn!
    regional.region(event)

end

function regional.register(event)
    if not(event.created_entity.type == "assembling-machine") then
        return
    end
    table.insert(global.regional.registry, event.created_entity)
end

function regional.checker(event)
    -- Iterate over 30 entities
    for i = 0, 29 do
        --if #global.regional.registry == 0 or i >= #global.regional.registry then
        if i >= #global.regional.registry then
            return
        end
        if global.regional.index + i > #global.regional.registry then
            global.regional.index = 1
        end
        local entity = global.regional.registry[global.regional.index + i]
        if entity.valid then
            regional.enforcement(entity)
        else
            table.remove(global.regional.registry, global.regional.index + i)
        end
        global.regional.index = global.regional.index + 1
    end
end

function regional.enforcement(entity)
    local area = {{entity.position.x - regional.RANGE, entity.position.y - regional.RANGE}, {entity.position.x + regional.RANGE, entity.position.y + regional.RANGE}}
    local regions = entity.surface.find_entities_filtered{type="constant-combinator", area=area}
    local allowed = {}
    for k,v in pairs(regions) do
        if v.operable == false then
            table.insert(allowed, {position = v.position, recipe=v.get_control_behavior().get_signal(1).signal.name})
        end
    end
    for k,v in pairs(allowed) do
        local recipe = entity.get_recipe()
        if recipe and recipe.products[1].name == v.recipe and regional.get_range_squared(entity.position, v.position) < regional.RANGE^2 then
            return
        end
    end
    --Still here?  Shut it down!
    entity.set_recipe(nil)
end

function regional.discovered(event)
    local force = event.force
    local area = {{event.position.x * 32, event.position.y * 32}, {(event.position.x + 1) * 32, (event.position.y + 1) * 32}}
    local regions = game.surfaces[event.surface_index].find_entities_filtered{type="constant-combinator", area=area}
    for k,v in pairs(regions) do
        if v.operable == false then
            log("Adding chart tag")
            local signal = v.get_control_behavior().get_signal(1).signal
            force.add_chart_tag(game.surfaces[event.surface_index], {position = v.position, icon=signal} )
            --force.add_chart_tag(game.surfaces[event.surface_index], {position = v.position, text=signal.name} )
        end
    end
end

function regional.get_range_squared(pos1, pos2)
    return (pos1.x - pos2.x)^2 + (pos1.y - pos2.y)
end

Event.register(defines.events.on_chunk_generated, regional.region)
Event.register(defines.events.on_built_entity, regional.register)
Event.register(defines.events.on_robot_built_entity, regional.register)
Event.register(defines.events.on_chunk_charted, regional.discovered)
script.on_nth_tick(60, regional.checker)