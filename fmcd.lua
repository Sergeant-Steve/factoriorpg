-- Factorio Log File Module
-- Made by: Viceroypenguin (@viceroypenguin#8303 on discord) for FactorioMMO
-- This module provides a common print function for all log messages to go to the agent.

local filename = "fmcd.out"

function fmcd_print(_module, route, data)
    local str = "FMC::" .. module .. " " .. route .. " " .. data
    game.write_file(file_name, str, true)
end
