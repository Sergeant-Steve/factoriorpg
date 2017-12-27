--Seasons, a mod to vary day length
--Written by Mylon, 2017
--MIT License

--Default values:
--ticks_per_day:    25000
--dusk:             0.25
--dawn:             0.75
--evening:          0.45
--morning:          0.55
--Full daylight 50% of the time, partial daylight an additional 40%.  Let's call this summer.
--Winter is the opposite: Full night 50% of the time, full daylight 10%.
--Dusk can be < 0 and morning > 1, leading to less full daylight.

if MODULE_LIST then
	module_list_add("Seasons")
end

seasons = {}
seasons.YEAR_LENGTH = 30 --Length in days
--seasons.SUMMER_STATS = { dusk=0.25, evening=0.45, morning=0.55, dawn=0.75 }
seasons.SPRING_STATS = { dusk=0.15, evening=0.35, morning=0.65, dawn=0.85 }
--seasons.WINTER_STATS = { dusk=0.05, evening=0.25, morning=0.75, dawn=0.95 }
seasons.AXIAL_TILT = 0.10 -- Determines how much day length varies.  Goes from 0.01 to 0.15


global.seasons = {day_length = 25000}

function seasons.daylight_savings(event)
    if not (event.tick % global.seasons.day_length == 0) then return end
    global.seasons.day_length = game.surfaces[1].ticks_per_day
    local time_of_year = seasons.time_of_year()
    for _, surface in pairs(game.surfaces) do
        if not surface.freeze_daytime then
            for k, v in pairs(seasons.SPRING_STATS) do
                --surface[k] = seasons.SPRING_STATS[k] + 0.10 * math.sin(2 * math.pi * (time_of_year-0.25))
                if seasons.SPRING_STATS[k] < 0.5 then
                    surface[k] = seasons.SPRING_STATS[k] + 0.10 * math.sin(2 * math.pi * (time_of_year-0.25))
                else
                    surface[k] = seasons.SPRING_STATS[k] - 0.10 * math.sin(2 * math.pi * (time_of_year-0.25))
                end
            end
        end
    end
    --These will break if year_length changes.
    if time_of_year < 0.02 then
        game.print("Winter is here.")
    elseif time_of_year > 0.23 and time_of_year < 0.24 then --Day 7
        game.print("Spring is here.")
    elseif time_of_year == 0.5 then --day 15
        game.print("Summer is here.")
    elseif time_of_year > 0.72 and time_of_year < 0.74 then --Day 22
        game.print("Autumn is here.")
    end
end

function seasons.lerp(start, finish, scalar)
    return start + (finish-start) * scalar
end

function seasons.time_of_year()
    return (game.tick % (global.seasons.day_length * seasons.YEAR_LENGTH)) / global.seasons.day_length / seasons.YEAR_LENGTH
end

commands.add_command("date", "What year and season is it currently?", function()
    if not game.player then return end
    local year = math.floor(game.tick / global.seasons.day_length / seasons.YEAR_LENGTH)
    local time_of_year = seasons.time_of_year()
    local str = ""
    if time_of_year < 0.233333 then
        str = str .. "Winter, "
    elseif time_of_year < 0.5 then
        str = str .. "Spring, "
    elseif time_of_year < 0.74 then
        str = str .. "Summer, "
    else
        str = str .. "Autumn, "
    end
    str = str .. "Year " .. year .. "."
    game.player.print(str)
end)

Event.register(defines.events.on_tick, seasons.daylight_savings)