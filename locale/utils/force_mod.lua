-- force_mod (character_modification) Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module organizes the way in which the character bonuses are applied.

--
--	VARIABLES
--

global.force_mod = global.force_mod or {}
global.force_mod.enabled = global.force_mod.enabled or true
global.force_mod.apply_enabled = global.force_mod.apply_enabled or true
global.force_mod.bonus_list = {"manual_mining_speed_modifier", 
							"manual_crafting_speed_modifier",
							"laboratory_speed_modifier",
							"worker_robots_speed_modifier",
							"worker_robots_battery_modifier",
							"worker_robots_storage_bonus",
							"inserter_stack_size_bonus",
							"stack_inserter_capacity_bonus",
							"character_logistic_slot_count",
							"character_trash_slot_count",
							"quickbar_count",
							"maximum_following_robot_count",
							"character_running_speed_modifier",
							"character_build_distance_bonus",
							"character_item_drop_distance_bonus",
							"character_reach_distance_bonus",
							"character_resource_reach_distance_bonus",
							"character_item_pickup_distance_bonus",
							"character_loot_pickup_distance_bonus",
							"character_inventory_slots_bonus",
							"character_health_bonus",
							"mining_drill_productivity_bonus",
							"train_braking_force_bonus"}

global.force_mod.manual_mining_speed_modifier = global.force_mod.manual_mining_speed_modifier or {}
global.force_mod.manual_mining_speed_modifier.val = global.force_mod.manual_mining_speed_modifier.val or {}
global.force_mod.manual_mining_speed_modifier.fin = global.force_mod.manual_mining_speed_modifier.fin or {}
global.force_mod.manual_mining_speed_modifier.info = {data = "double", minimum = -1, maximum = 100}

global.force_mod.manual_crafting_speed_modifier = global.force_mod.manual_crafting_speed_modifier or {}
global.force_mod.manual_crafting_speed_modifier.val = global.force_mod.manual_crafting_speed_modifier.val or {}
global.force_mod.manual_crafting_speed_modifier.fin = global.force_mod.manual_crafting_speed_modifier.fin or {}
global.force_mod.manual_crafting_speed_modifier.info = {data = "double", minimum = -1, maximum = 100}

global.force_mod.laboratory_speed_modifier = global.force_mod.laboratory_speed_modifier or {}
global.force_mod.laboratory_speed_modifier.val = global.force_mod.laboratory_speed_modifier.val or {}
global.force_mod.laboratory_speed_modifier.fin = global.force_mod.laboratory_speed_modifier.fin or {}
global.force_mod.laboratory_speed_modifier.info = {data = "double", minimum = -1, maximum = 100}

global.force_mod.worker_robots_speed_modifier = global.force_mod.worker_robots_speed_modifier or {}
global.force_mod.worker_robots_speed_modifier.val = global.force_mod.worker_robots_speed_modifier.val or {}
global.force_mod.worker_robots_speed_modifier.fin = global.force_mod.worker_robots_speed_modifier.fin or {}
global.force_mod.worker_robots_speed_modifier.info = {data = "double", minimum = -1, maximum = 100}

global.force_mod.worker_robots_battery_modifier = global.force_mod.worker_robots_battery_modifier or {}
global.force_mod.worker_robots_battery_modifier.val = global.force_mod.worker_robots_battery_modifier.val or {}
global.force_mod.worker_robots_battery_modifier.fin = global.force_mod.worker_robots_battery_modifier.fin or {}
global.force_mod.worker_robots_battery_modifier.info = {data = "double", minimum = -1, maximum = 100}

global.force_mod.worker_robots_storage_bonus = global.force_mod.worker_robots_storage_bonus or {}
global.force_mod.worker_robots_storage_bonus.val = global.force_mod.worker_robots_storage_bonus.val or {}
global.force_mod.worker_robots_storage_bonus.fin = global.force_mod.worker_robots_storage_bonus.fin or {}
global.force_mod.worker_robots_storage_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.force_mod.inserter_stack_size_bonus = global.force_mod.inserter_stack_size_bonus or {}
global.force_mod.inserter_stack_size_bonus.val = global.force_mod.inserter_stack_size_bonus.val or {}
global.force_mod.inserter_stack_size_bonus.fin = global.force_mod.inserter_stack_size_bonus.fin or {}
global.force_mod.inserter_stack_size_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.force_mod.stack_inserter_capacity_bonus = global.force_mod.stack_inserter_capacity_bonus or {}
global.force_mod.stack_inserter_capacity_bonus.val = global.force_mod.stack_inserter_capacity_bonus.val or {}
global.force_mod.stack_inserter_capacity_bonus.fin = global.force_mod.stack_inserter_capacity_bonus.fin or {}
global.force_mod.stack_inserter_capacity_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.force_mod.character_logistic_slot_count = global.force_mod.character_logistic_slot_count or {}
global.force_mod.character_logistic_slot_count.val = global.force_mod.character_logistic_slot_count.val or {}
global.force_mod.character_logistic_slot_count.fin = global.force_mod.character_logistic_slot_count.fin or {}
global.force_mod.character_logistic_slot_count.info =  {data = "int", minimum = 0, maximum = 50}

global.force_mod.character_trash_slot_count = global.force_mod.character_trash_slot_count or {}
global.force_mod.character_trash_slot_count.val = global.force_mod.character_trash_slot_count.val or {}
global.force_mod.character_trash_slot_count.fin = global.force_mod.character_trash_slot_count.fin or {}
global.force_mod.character_trash_slot_count.info = {data = "int", minimum = 0, maximum = 50}

global.force_mod.quickbar_count = global.force_mod.quickbar_count or {}
global.force_mod.quickbar_count.val = global.force_mod.quickbar_count.val or {}
global.force_mod.quickbar_count.fin = global.force_mod.quickbar_count.fin or {}
global.force_mod.quickbar_count.info = {data = "int", minimum = 0, maximum = 10}

global.force_mod.maximum_following_robot_count = global.force_mod.maximum_following_robot_count or {}
global.force_mod.maximum_following_robot_count.val = global.force_mod.maximum_following_robot_count.val or {}
global.force_mod.maximum_following_robot_count.fin = global.force_mod.maximum_following_robot_count.fin or {}
global.force_mod.maximum_following_robot_count.info = {data = "int", minimum = 0, maximum = 500}

global.force_mod.character_running_speed_modifier = global.force_mod.character_running_speed_modifier or {}
global.force_mod.character_running_speed_modifier.val = global.force_mod.character_running_speed_modifier.val or {}
global.force_mod.character_running_speed_modifier.fin = global.force_mod.character_running_speed_modifier.fin or {}
global.force_mod.character_running_speed_modifier.info = {data = "double", minimum = -1, maximum = 100}

global.force_mod.character_build_distance_bonus = global.force_mod.character_build_distance_bonus or {}
global.force_mod.character_build_distance_bonus.val = global.force_mod.character_build_distance_bonus.val or {}
global.force_mod.character_build_distance_bonus.fin = global.force_mod.character_build_distance_bonus.fin or {}
global.force_mod.character_build_distance_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.force_mod.character_item_drop_distance_bonus = global.force_mod.character_item_drop_distance_bonus or {}
global.force_mod.character_item_drop_distance_bonus.val = global.force_mod.character_item_drop_distance_bonus.val or {}
global.force_mod.character_item_drop_distance_bonus.fin = global.force_mod.character_item_drop_distance_bonus.fin or {}
global.force_mod.character_item_drop_distance_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.force_mod.character_reach_distance_bonus = global.force_mod.character_reach_distance_bonus or {}
global.force_mod.character_reach_distance_bonus.val = global.force_mod.character_reach_distance_bonus.val or {}
global.force_mod.character_reach_distance_bonus.fin = global.force_mod.character_reach_distance_bonus.fin or {}
global.force_mod.character_reach_distance_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.force_mod.character_resource_reach_distance_bonus = global.force_mod.character_resource_reach_distance_bonus or {}
global.force_mod.character_resource_reach_distance_bonus.val = global.force_mod.character_resource_reach_distance_bonus.val or {}
global.force_mod.character_resource_reach_distance_bonus.fin = global.force_mod.character_resource_reach_distance_bonus.fin or {}
global.force_mod.character_resource_reach_distance_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.force_mod.character_item_pickup_distance_bonus = global.force_mod.character_item_pickup_distance_bonus or {}
global.force_mod.character_item_pickup_distance_bonus.val = global.force_mod.character_item_pickup_distance_bonus.val or {}
global.force_mod.character_item_pickup_distance_bonus.fin = global.force_mod.character_item_pickup_distance_bonus.fin or {}
global.force_mod.character_item_pickup_distance_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.force_mod.character_loot_pickup_distance_bonus = global.force_mod.character_loot_pickup_distance_bonus or {}
global.force_mod.character_loot_pickup_distance_bonus.val = global.force_mod.character_loot_pickup_distance_bonus.val or {}
global.force_mod.character_loot_pickup_distance_bonus.fin = global.force_mod.character_loot_pickup_distance_bonus.fin or {}
global.force_mod.character_loot_pickup_distance_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.force_mod.character_inventory_slots_bonus = global.force_mod.character_inventory_slots_bonus or {}
global.force_mod.character_inventory_slots_bonus.val = global.force_mod.character_inventory_slots_bonus.val or {}
global.force_mod.character_inventory_slots_bonus.fin = global.force_mod.character_inventory_slots_bonus.fin or {}
global.force_mod.character_inventory_slots_bonus.info = {data = "int", minimum = 0, maximum = 100}

global.force_mod.character_health_bonus = global.force_mod.character_health_bonus or {}
global.force_mod.character_health_bonus.val = global.force_mod.character_health_bonus.val or {}
global.force_mod.character_health_bonus.fin = global.force_mod.character_health_bonus.fin or {}
global.force_mod.character_health_bonus.info = {data = "int", minimum = 0, maximum = 50000}

global.force_mod.mining_drill_productivity_bonus = global.force_mod.mining_drill_productivity_bonus or {}
global.force_mod.mining_drill_productivity_bonus.val = global.force_mod.mining_drill_productivity_bonus.val or {}
global.force_mod.mining_drill_productivity_bonus.fin = global.force_mod.mining_drill_productivity_bonus.fin or {}
global.force_mod.mining_drill_productivity_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.force_mod.train_braking_force_bonus = global.force_mod.train_braking_force_bonus or {}
global.force_mod.train_braking_force_bonus.val = global.force_mod.train_braking_force_bonus.val or {}
global.force_mod.train_braking_force_bonus.fin = global.force_mod.train_braking_force_bonus.fin or {}
global.force_mod.train_braking_force_bonus.info = {data = "double", minimum = 0, maximum = 2}
--
--	FuNCTIONS
--
function force_mod_table_search(tbl, val)
	if tbl ~= nil then
		for i, str in pairs(tbl) do
			if str == val then
				return true
			end
		end
	end
	return false
end

function force_mod_enable()
	return false --Not Implemented
end

function force_mod_disable()
	return false --Not Implemented
end

function force_mod_apply_bonus(f, b)
	if force_mod_table_search(global.force_mod.bonus_list, b) then
		if global.force_mod[b].val[f.name] ~= nil then
			force_mod_calculate_bonus(f, b, true)
			if f ~= nil then
				f[b] = f[b] + global.force_mod[b].fin[f.name]
			end
		end
	else
		return false -- bonus not found
	end
end

function force_mod_calculate_bonus(f, b, bypass)
	if bypass or force_mod_table_search(global.force_mod.bonus_list, b) then
		if bypass or (global.force_mod[b].val[f.name] ~= nil) then
			local add = {}
			local mul = {}
			local div = {}
			for name, tbl in pairs(global.force_mod[b].val[f.name]) do
				if tbl.op == "add" then
					table.insert(add, tbl.val)
				elseif tbl.op == "sub" then
					table.insert(add, tbl.val)
				elseif tbl.op == "mul" then
					table.insert(mul, tbl.val)
				elseif tbl.op == "div" then
					table.insert(div, tbl.val)
				end
			end
			local total = 0
			for _, s in pairs(add) do
				total = total + s
			end
			for _, m in pairs(mul) do
				total = total * m
			end
			for _, d in pairs(div) do
				total = total / d
			end
			if total < global.force_mod[b].info.minimum then
				total = global.force_mod[b].info.minimum
			end
			if total > global.force_mod[b].info.maximum then
				total = global.force_mod[b].info.maximum
			end
			if global.force_mod[b].info.data == "int" then
				total = math.floor(total)
			end
			global.force_mod[b].fin[f.name] = total
		end
	else
		return false -- bonus not found
	end
end

function force_mod_apply_all_bonus(f)
	f.reset_technology_effects()
	for i, b in pairs (global.force_mod.bonus_list) do
		force_mod_apply_bonus(f, b)
	end
end

function force_mod_calculate_finals(f)
	for i, b in pairs (global.force_mod.bonus_list) do
		force_mod_calculate_bonus(f, b, false)
	end
end

function force_mod_add_bonus(f, b, d)
	if force_mod_table_search(global.force_mod.bonus_list, b) then
		global.force_mod[b].val[f.name] = global.force_mod[b].val[f.name] or {}
		local r = {}
		if d.name ~= nil then
			r.name = d.name -- table index is nil
		else
			r.name = "unknown"
		end
		if d.op ~= nil then
			r.op = d.op
		else
			r.op = "add"
		end
		if d.val ~= nil then
			r.val = d.val
		else
			if r.op == "add" or r.op == "sub" then
				r.val = 0
			elseif r.op == "mul" or r.op == "div" then
				r.val = 1
			else
				return false
			end
		end
		global.force_mod[b].val[f.name][r.name] = {op = r.op, val = r.val}
		force_mod_apply_all_bonus(f)
	else
		return false -- bonus not found
	end
end

-- Kinda not needed since add also replaces if exists
-- function force_mod_change_bonus(f, b, d)
	-- return false
-- end

function force_mod_remove_bonus(f, b, e)
	if force_mod_table_search(global.force_mod.bonus_list, b) then
		if global.force_mod[b].val[f.name] ~= nil then
			if global.force_mod[b].val[f.name][e] ~= nil then
				global.force_mod[b].val[f.name][e] = nil
				force_mod_apply_all_bonus(f)
				return true
			end
		end
	end
	return false
end

function force_mod_get_bonus(f, b)
	return global.force_mod[b].val[f.name]
end

function force_mod_get_final_bonus(f, b)
	return global.force_mod[b].fin[f.name]
end

--
-- Events
--

Event.register(defines.events.on_research_finished, function(event)
	f = game.forces[event.research.force]
	force_mod_apply_all_bonus(f)
end)