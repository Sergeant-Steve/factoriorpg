DIRT_THRESHOLD = 6

if MODULE_LIST then
	module_list_add("Dirt Path")
end

function dirtDirt()
	if not global.dirt then
		global.dirt = {}
		--game.print("Initalizing Dirt Path.")
	end
	for __, p in pairs(game.connected_players) do
		-- Trains aren't cars!  This breaks it.  Dunno why they're handled differently.
		--if p.walking_state.walking or (p.driving and p.vehicle.speed ~= 0) then
		-- Special conditional check for Factorissimo
		if ( (p.surface == game.surfaces[1] or not game.active_mods["factorrisimo"]) and (p.walking_state.walking or (p.vehicle and p.vehicle.type == "car" and p.vehicle.speed ~= 0)) ) then
			local tile = p.surface.get_tile(p.position)
			if not (tile.hidden_tile or string.find(tile.name, "dirt") or string.find(tile.name, "sand")) then				
				if not global.dirt[tile.position.x] then
					global.dirt[tile.position.x] = {}
				end
				if global.dirt[tile.position.x][tile.position.y] then
					global.dirt[tile.position.x][tile.position.y] = global.dirt[tile.position.x][tile.position.y] + 1
				else	
					global.dirt[tile.position.x][tile.position.y] = 1
				end
				--game.print("Dirt value now at: ".. global.dirt[tile.position.x][tile.position.y])
				if global.dirt[tile.position.x][tile.position.y] >= DIRT_THRESHOLD then
					--game.print("Converting patch to dirt.")
					
					-- Check for waterfix, else prevent exploit
					local waterfix = false
					if game.active_mods["water-fix"] then
						waterfix = true
					end
					-- for module, version in pairs(game.active_mods) do
						-- if module == "water-fix" then
							-- waterfix = true
						-- end
					-- end
					if not waterfix then
					-- Check for water to prevent landfill exploit
						for xx = -1, 2 do
							for yy = -1, 2 do
								local waterCheck = p.surface.get_tile(tile.position.x + xx, tile.position.y + yy)
								if not waterCheck or not waterCheck.valid or waterCheck.collides_with("water-tile") then
									return
								end
							end
						end
					end
					local dirt = {}
					for xx = 0, 1, 1 do
						for yy = 0, 1, 1 do
							if global.dirt[tile.position.x + xx] and global.dirt[tile.position.x + xx][tile.position.y + yy] then
								global.dirt[tile.position.x + xx][tile.position.y + yy] = nil
							end
							local validTile = p.surface.get_tile(tile.position.x + xx, tile.position.y + yy)
							if validTile.collides_with("ground-tile") and not validTile.hidden_tile then
								table.insert(dirt, {name="dirt-dark", position={p.position.x+xx, p.position.y+yy}})
							end
						end
					end
					p.surface.set_tiles(dirt)
				end
			end
		end
	end
end

function cleanDirt()
	for x, _ in pairs(global.dirt) do
		local count = 0
		for y, __ in pairs(global.dirt[x]) do
			global.dirt[x][y] = global.dirt[x][y] - 1
			if global.dirt[x][y] <= 0 then
				global.dirt[x][y] = nil
			end
			count = count + 1
		end
		if count == 0 then
			global.dirt[x] = nil
		end
	end
end

function dirt_handler(event)
	if event.tick % 30 == 0 then
		dirtDirt()
	end
	if (event.tick+500) % (60 * 60 * 30) == 0 then
		cleanDirt()
	end
end


Event.register(defines.events.on_tick, dirt_handler)