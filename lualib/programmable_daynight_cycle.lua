--global.programmable_daynight_cycle = global.programmable_daynight_cycle or {}
--global.programmable_daynight_cycle.enabled = global.programmable_daynight_cycle.enabled or true
global.programmable_daynight_cycle_function_selection = 4
global.programmable_daynight_cycle_daylength_ticks = 36000
global.programmable_daynight_cycle_stepsize_ticks = 59

function programmable_daynight_cycle_tick(event)
	local stepsize_ticks = global.programmable_daynight_cycle_stepsize_ticks -- stepsize_ticks < 25000!!!
	if not (game.tick % stepsize_ticks == 0) then -- Replace with 'on_nth_tick' once I figure out how to do that
		return
	end
	if(game.surfaces[1].freeze_daytime)then
		game.surfaces[1].freeze_daytime = false
		game.print("Can't use freeze_daytime while programmable day-night cycle is active; it has been unfrozen")
	end
	local daylength_ticks = global.programmable_daynight_cycle_daylength_ticks
	local time_ratio = (daylength_ticks/25000) -- normal day-night cycle length
	local current_time = (game.tick / daylength_ticks)
	local time_step = (stepsize_ticks/daylength_ticks)
	current_curve_start = {x = current_time, y = programmable_daynight_cycle_alt_dnc(current_time)}
	current_curve_end = {x = current_time + (time_step * time_ratio), y = programmable_daynight_cycle_alt_dnc(current_time + time_step)}
	local y_top_start, y_top_end = {x = -999999999, y = 1}, {x = 999999999, y = 1}
	local y_bot_start, y_bot_end = {x = -999999999, y = 0.15}, {x = 999999999, y = 0.15}
    local top_point = programmable_daynight_cycle_intersection(current_curve_start, current_curve_end, y_top_start, y_top_end)
	local bot_point = programmable_daynight_cycle_intersection(current_curve_start, current_curve_end, y_bot_start, y_bot_end)
	-- clean-up and avoiding daytime loop-back
	game.surfaces[1].daytime = 0
	game.surfaces[1].dusk = -999999999
	game.surfaces[1].dawn = 999999999
	game.surfaces[1].evening = -999999998
	game.surfaces[1].morning = 999999998	
	if(top_point < bot_point) then -- dusk -> evening
		game.surfaces[1].evening = bot_point - current_time
		game.surfaces[1].dusk = top_point - current_time
	else -- morning -> dawn
		game.surfaces[1].morning = bot_point - current_time
		game.surfaces[1].dawn = top_point - current_time
	end
end

function programmable_daynight_cycle_alt_dnc(x) -- now more fancy and with 179.9 days 'orbit'
	local TAU = 6.28318530718 -- 2pi
	local PI =  3.14159265359
	local returnvalue = 0
	local unexpected_value = 0
	x = x * TAU
	
	if (global.programmable_daynight_cycle_function_selection == 1) then
		returnvalue = (1+((math.sin(x) + (0.111 * math.sin(3 * x))) * 1.1225)) * 0.5 -- simpler formula, no 'orbit'
		return programmable_daynight_cycle_range_limiter(returnvalue)
		
	elseif (global.programmable_daynight_cycle_function_selection == 2) then
		returnvalue = ((1+((math.sin(x)+(0.111*math.sin(3*x))-(0.02*math.sin(5*x))-(0.01020408*math.sin(7*x)))*1.1365))*0.5)*(1-(1+math.cos(0.0055555*x + PI))*0.48)
		return programmable_daynight_cycle_range_limiter(returnvalue)
		
	elseif (global.programmable_daynight_cycle_function_selection == 3) then
		local s = ((15*TAU) - x) * (1/((15*TAU))) -- how many days until it reaches lowest 'day peak'
		if (s < 0.25) then
			s = 0.25
		end
		returnvalue = (1+((math.sin(x) + (0.111 * math.sin(3 * x))) * 1.1225)) * 0.5 -- simpler formula, no 'orbit'
		return programmable_daynight_cycle_range_limiter(returnvalue * s)
	
	elseif (global.programmable_daynight_cycle_function_selection == 4) then
		returnvalue = ((1+(math.sin(x) + (0.111 * math.sin(3 * x)))) * 1.1225) * 0.5 -- simpler formula, no 'orbit'
		return programmable_daynight_cycle_range_limiter(returnvalue * 0.2) 
	else 
		returnvalue = (1 + math.sin(x)) * 0.5 -- as simple as it gets, good for backup!
		if(unexpected_value == 0) then
			game.print("programmable_daynight_cycle_function_selection recieved an unexpected value: " .. programmable_daynight_cycle_function_selection .. " default sin used instead.")
			unexpected_value = unexpected_value + 1
		end
		return programmable_daynight_cycle_range_limiter(returnvalue)
	end
end

function programmable_daynight_cycle_range_limiter(n)
	if (n < 0) then
		n = 0
	end
	if (n > 1.0) then
		n = 1
	end
	return 0.15 + (n * 0.85)
end

-- take all this and put it into a seperate module once everything else works
-- code stolen from https://rosettacode.org/wiki/Find_the_intersection_of_two_lines#Lua
function programmable_daynight_cycle_intersection (s1, e1, s2, e2)
  local d = (s1.x - e1.x) * (s2.y - e2.y) - (s1.y - e1.y) * (s2.x - e2.x)
  local a = s1.x * e1.y - s1.y * e1.x
  local b = s2.x * e2.y - s2.y * e2.x
  local x = (a * (s2.x - e2.x) - (s1.x - e1.x) * b) / d
  local y = (a * (s2.y - e2.y) - (s1.y - e1.y) * b) / d
  return x--, y
end

--function programmable_daynight_cycle_enable()
--	global.programmable_daynight_cycle.enabled = true
--	Event.register(defines.events.on_tick, programmable_daynight_cycle_tick)
--end

--function programmable_daynight_cycle_disable()
--	global.programmable_daynight_cycle.enabled = false
--	Event.remove(defines.events.on_tick, programmable_daynight_cycle_tick)
--	game.surfaces[1].daytime = 0
--	game.surfaces[1].dusk = -999999999
--	game.surfaces[1].dawn = 999999999
--	game.surfaces[1].evening = -999999998
--	game.surfaces[1].morning = 999999998
--	-- first setting to safe values before setting them back to defaults. 
--	game.surfaces[1].evening = 0.45
--	game.surfaces[1].morning = 0.55
--	game.surfaces[1].dusk = 0.25
--	game.surfaces[1].dawn = 0.75
--	game.print("Resetting day-night cycle to default values")
--end

function programmable_daynight_cycle_stepsize_ticks(n)
	if (n ~= nil) then
		if ((n < 24998) and (n >= 1)) then -- 2 tick margin 
			global.programmable_daynight_cycle_stepsize_ticks = n
		else 
			game.print("programmable_daynight_cycle_stepsize_ticks was set to " .. n .. " but needs to be [1, 24998)")
			n = 59 -- reasonably good value for most uses. 
		end
	else 
		game.print("programmable_daynight_cycle_stepsize_ticks was set to nil!")
		global.programmable_daynight_cycle_stepsize_ticks = 59
	end
end

function programmable_daynight_cycle_daylength_ticks(n)
	if (n ~= nil) then
		if ((n < 1) or (n < global.programmable_daynight_cycle_stepsize_ticks)) then
			game.print("tried to set global.programmable_daynight_cycle_daylength_ticks to an unreasonable value: " .. n)
			global.programmable_daynight_cycle_daylength_ticks = 36000 -- 10min default
		else 
			global.programmable_daynight_cycle_daylength_ticks = n
		end
	else 
		game.print("programmable_daynight_cycle_daylength_ticks was set to nil!")
		global.programmable_daynight_cycle_daylength_ticks = 36000 -- 10min default
	end
end

function programmable_daynight_cycle_function_selection(n)
	if (n ~= nil) then
		global.programmable_daynight_cycle_function_selection = n
	else 
		game.print("programmable_daynight_cycle_function_selection was set to nil!")
		global.programmable_daynight_cycle_function_selection = 0
	end
end

--function programmable_daynight_cycle_init()
--	if global.programmable_daynight_cycle.enabled then
--		game.print("PDNC is enabled!")
--		programmable_daynight_cycle_enable()
--	else
--		programmable_daynight_cycle_disable()
--		game.print("PDNC is disabled!")
--	end
--end

Event.register(defines.events.on_tick,programmable_daynight_cycle_tick)
--Event.register(-1, programmable_daynight_cycle_init)