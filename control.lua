require "util"
require "locale/utils/event"
require "config"
require "locale/utils/admin"
require "locale/utils/undecorator"
require "locale/utils/utils"
require "locale/utils/gravestone"
require "announcements"
require "bps"
require "tag"
require "locale/utils/patreon"
require "rocket"
require "grid"



-- Give player starting items.
-- Gives admins a tool
-- @param event on_player_joined event
function player_joined(event)
	local player = game.players[event.player_index]
	player.insert { name = "iron-plate", count = 8 }
	player.insert { name = "pistol", count = 1 }
	player.insert { name = "firearm-magazine", count = 20 }
	player.insert { name = "burner-mining-drill", count = 2 }
	player.insert { name = "stone-furnace", count = 2 }
end

-- Give player weapons after they respawn.
-- @param event on_player_respawned event
function player_respawned(event)
	local player = game.players[event.player_index]
	player.insert { name = "pistol", count = 1 }
	player.insert { name = "firearm-magazine", count = 10 }
end


Event.register(defines.events.on_player_created, player_joined)
Event.register(defines.events.on_player_respawned, player_respawned)