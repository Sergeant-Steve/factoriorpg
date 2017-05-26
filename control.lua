-- TOOLS: Recommend all be turned on
--require "mod-gui"
--require "locale/utils/event" --Yes this line is seriously commented out, and yes without this it won't even work. I guess you now HAVE TO change the settings to match what you need.
--require "permissions" --Permission manager
--require "trusted" --Module to add trusted players to a seperate permission group
--require "locale/utils/patreon" --Module to give patreons spectate and a nice unique tag
--require "locale/utils/admin"	--Admin module to give the admins spectate, commands and character modifications.
--require "announcements"	--Module to announce stuff ingame / give the players a welcome message
--require "tag" --Module to let players set a tag behind their names to improve teamwork
--require "fmcd" --Module to consolidate saving data to an output file for the agent
--require "stats" --Module to generate stats and print them to the filesystem
--require "popup" --Module to create and display an popup in the center of all players their screens.
--require "rules" --Module which displays a popup with the rules when a player joins, or presses the open rules button
--require "rocket" --Module to stop people removing the rocket silo
--require "gravemarker" --Create a map tag on player death for easier corpse finding

-- World Generators: Pick only ONE
--NOT UPDATED require "void" --Worldgenerator which randomly generates holes in the world
--require "nuclear" --worldgenerator for nuclear scenario
--NOT UPDATED require "grid" --Worldgenerator which devides the world into a grid.
--require "wave_defense" -- move all files from wave-defense folder to root in order to use

-- FOLLOWING CODE GIVES SAME MINIMUM INVENTORY TO ALL SCENARIOS:
-- turn off when using wave_defense
require "equipment"
