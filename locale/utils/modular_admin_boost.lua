-- modular_admin_boost sub-module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This sub-module is a addon to the modular_admin module, it allows admins to boost their character

--
--	PLAN
--	
--	This module is going to replace the character menu in the old admin tools
--	Admins will be able to increase their reach, speed, crafting, mining and be invincible
--	The gui will present a list of buttons to toggle each of the above
--

--
--	VARIABLES
--

global.modular_admin_boost = global.modular_admin_boost or {}
global.modular_admin_boost.enabled = true

--
--	FUNCTIONS
--
function modular_admin_boost_enable(mod)
	global.modular_admin_boost.enabled = true
	modular_admin_add_submodule("modular_admin_boost")
	for i, p in pairs(game.connected_players) do
		modular_admin_boost_update_menu_button(p)
	end
end

function modular_admin_boost_disable(mod)
	global.modular_admin_boost.enabled = false
	for i, p in pairs(game.connected_players) do
		modular_admin_boost_update_menu_button(p)
	end
	modular_admin_remove_submodule("modular_admin_boost")
end

--
--	EVENTS
--

Event.register(-1, function(event)
	if(global.modular_admin_boost.enabled) then
		modular_admin_add_submodule("modular_admin_boost")
	else
		modular_admin_remove_submodule("modular_admin_boost")
	end
end)