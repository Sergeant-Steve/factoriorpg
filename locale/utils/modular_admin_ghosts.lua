-- modular_admin_ghosts sub-module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This sub-module is a addon to the modular_admin module, it creates ghosts when someone destroys an entity

--
--	PLAN
--	
--	This module is going to create a ghost when a player destroys an entity
--	It will also create the admin force in which the ghosts will be placed
--	--OPTIONALLY it will also have a list to exclude certain entities and place another defined entity instead
--

--
--	VARIABLES
--

global.modular_admin_ghosts = global.modular_admin_ghosts or {}
global.modular_admin_ghosts.enabled = true

--
--	FUNCTIONS
--
function modular_admin_ghosts_create_force()
	if not game.forces.Admins then
		game.create_force("Admins")
		game.forces.Admins.research_all_technologies()
	end
end

function modular_admin_ghosts_entity_mined(event)
	local entity = event.entity
	if entity.force.name == "neutral" 
	or entity.name == "entity-ghost" 
	or entity.type == "locomotive" 
	or entity.type == "cargo-wagon" 
	or entity.type == "fluid-wagon"
	or entity.type == "car" 
	or entity.type:find("robot") 
	or game.players[event.player_index].force == game.forces.Admins 
	or entity.name == "tile-ghost"
    or entity.name == 'item-request-proxy'
	then return end
	local ghost = "a"
	if (game and game.active_mods.base:sub(1,4) == '0.14' and (entity.type == 'underground-belt' or entity.type == 'electric-pole')) or entity.type == "pipe-to-ground" then
		ghost = entity.surface.create_entity
		{name="entity-ghost",	force=game.forces.Admins, inner_name="programmable-speaker", position=entity.position, direction = entity.direction}
	else
		ghost = entity.surface.create_entity
		{name="entity-ghost",	force=game.forces.Admins, inner_name=entity.name, position=entity.position, direction = entity.direction}
	end
	ghost.last_user = game.players[event.player_index]
end

function modular_admin_ghosts_entity_deconstructed(event)
	local entity = event.entity
	if entity.force.name == "neutral" 
	or entity.name == "entity-ghost" 
	or entity.type == "locomotive" 
	or entity.type == "cargo-wagon" 
	or entity.type == "fluid-wagon"
	or entity.type == "car" 
	or entity.type:find("robot") 
	or entity.name == "tile-ghost"
    or entity.name == 'item-request-proxy'
	then return end
	local ghost = "a"
	if (game and game.active_mods.base:sub(1,4) == '0.14' and (entity.type == 'underground-belt' or entity.type == 'electric-pole')) or entity.type == "pipe-to-ground" then
		ghost = entity.surface.create_entity
		{name="entity-ghost",	force=game.forces.Admins, inner_name="programmable-speaker", position=entity.position, direction = entity.direction}
	else
		ghost = entity.surface.create_entity
		{name="entity-ghost",	force=game.forces.Admins, inner_name=entity.name, position=entity.position, direction = entity.direction}
	end
	ghost.last_user = entity.last_user
end

function modular_admin_ghosts_enable()
	global.modular_admin_ghosts.enabled = true
	modular_admin_add_submodule("modular_admin_ghosts")
	for i, p in pairs(game.connected_players) do
		modular_admin_ghosts_update_menu_button(p)
	end
	modular_admin_ghosts_create_force()
end

function modular_admin_ghosts_disable()
	global.modular_admin_ghosts.enabled = false
	modular_admin_remove_submodule("modular_admin_ghosts")
	for i, p in pairs(game.connected_players) do
		modular_admin_ghosts_update_menu_button(p)
	end
end

--
--	EVENTS
--

Event.register(defines.events.on_preplayer_mined_item, modular_admin_ghosts_entity_mined)
Event.register(defines.events.on_robot_pre_mined, modular_admin_ghosts_entity_deconstructed)

Event.register(-1, function(event)
	if(global.modular_admin_ghosts.enabled) then
		modular_admin_add_submodule("modular_admin_ghosts")
	else
		modular_admin_remove_submodule("modular_admin_ghosts")
	end
	modular_admin_ghosts_create_force()
end)

Event.register(defines.events.on_force_created, function(event)
	if(event.force.name ~= "Admins") then
		modular_admin_ghosts_create_force()
		event.force.set_friendly(game.forces.Admins, true)
		game.forces.Admins.set_cease_fire(event.force, true)
	end
end)