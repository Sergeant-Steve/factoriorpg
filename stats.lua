-- Stats Module
-- Made by: Viceroypenguin (@viceroypenguin#8303 on discord) for FactorioMMO
-- This module generates stats and writes them to file in JSON format


local function stats_generate_prod_stats()
    local str = ""
    local ips = game.forces["player"].item_production_statistics
    for k, v in pairs(ips.input_counts) do
      str = str .. "{ \"type\": \"" .. k .. "\", \"amount\": " .. v .. " }, "
    end

    local fps = game.forces["player"].fluid_production_statistics
    for k, v in pairs(fps.input_counts) do
      str = str .. "{ \"type\": \"" .. k .. "\", \"amount\": " .. v .. " }, "
    end

    str = string.sub(str, 1, -3)
    return str
end

local function stats_generate_death_stats()
    local str = ""
    local deaths = global.deaths
    global.deaths = {}

    for _, v in pairs(deaths) do
      str = str .. "{ \"player\": \"" .. v.player .. "\", \"cause\": \"" .. v.cause .. "\", \"tick\": " .. v.tick .. " }, "
    end

    str = string.sub(str, 1, -3)
    return str
end

local function stats_generate_stats()
    local str = "{ \"tick\": " .. game.tick .. ", \"speed\": " .. game.speed .. ", \"deaths\": [" .. stats_generate_death_stats() .. "], \"statistics\": [" .. stats_generate_prod_stats() .. "] }"
    local file_name = "stats_" .. game.tick .. ".json"
    game.write_file(file_name, str, false)
end

Event.register(defines.events.on_player_died, function(event)
    local death = {}
    death.tick = event.tick
    death.cause = "<unknown>"
    death.player = game.players[event.player_index].name

    table.insert(global.deaths, death)
end)

local function second_to_tick(seconds)
    return seconds * 60 * game.speed
end

Event.register(defines.events.on_tick, function(event)
    local tick = game.tick

    if (global.remaining_until_update < 1) then
        global.remaining_until_update = second_to_tick(10) - 1
        stats_generate_stats()
    else
        global.remaining_until_update = global.remaining_until_update - 1
    end
end)

Event.register(-1, function(event)
    global.remaining_until_update = 0
    global.deaths = {}
end)

