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
function modular_admin_ghosts_enable(mod)
	global.modular_admin_ghosts.enabled = true
	modular_admin_add_submodule("modular_admin_ghosts")
	for i, p in pairs(game.connected_players) do
		modular_admin_ghosts_update_menu_button(p)
	end
end

function modular_admin_ghosts_disable(mod)
	global.modular_admin_ghosts.enabled = false
	for i, p in pairs(game.connected_players) do
		modular_admin_ghosts_update_menu_button(p)
	end
	modular_admin_remove_submodule("modular_admin_ghosts")
end

--
--	EVENTS
--

Event.register(-1, function(event)
	if(global.modular_admin_ghosts.enabled) then
		modular_admin_add_submodule("modular_admin_ghosts")
	else
		modular_admin_remove_submodule("modular_admin_ghosts")
	end
end)