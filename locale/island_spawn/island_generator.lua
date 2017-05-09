function count_alive_neighbors(tiles, depth, _x, _y)
    count = 0
    for y = -depth, depth do
        for x = -depth, depth do
            if not ((y == 0 and x == 0) or (x + _x < 0 or x + _x >= 31 or y + _y < 0 or y + _y >= 31)) then -- don't select ourself or out-of-bounds
                if(tiles[y + _y][x + _x]) then count = count + 1 end
            end
        end
    end
    return count
end
 
local function generate_initial()
    tiles = {}
    for y = 0, 31 do
        tiles[y] = {}
        for x = 0, 31 do
            tiles[y][x] = getRandomIntInclusive(1, 100) <= 55
            if (x == 0 or x == 31 or y == 0 or y == 31) then -- kill edges
                tiles[y][x] = false
            end
        end
end
return tiles
end
 
local function iterate_tiles(tiles)
    new_tiles = tiles
    for y = 0, 31 do
        for x = 0, 31 do
            count = count_alive_neighbors(tiles, 1, x, y)
            if (count >= 5 and not tiles[y][x]) then new_tiles[y][x] = true
            elseif (count <= 3 and tiles[y][x]) then new_tiles[y][x] = false
            end
        end
    end
 
    return new_tiles
end
 
 
local function generate_island_tiles(iterations)
    tiles = generate_initial()
    
    for i = 1, iterations do
        tiles = iterate_tiles(tiles)
    end
    
    return tiles
end

local function get_ore_type()
    ratio = getRandomIntInclusive(1, 100)
    if (ratio <= 15) then
        return "iron-ore" -- 15% iron
    elseif (ratio <= 30) then
        return "copper-ore" -- 15% copper
    elseif (ratio <= 45) then
        return "coal" -- 15% coal
    elseif (ratio <= 78) then
        return "stone" -- 33% stone
    elseif (ratio <= 83) then
        return "uranium-ore" -- 5% uranium
    else
        return nil -- 17% empty
    end
end

local function get_entity_type()
    return "tree-01"
end

local function get_total_amount(one, two, three, four, x, y)
    amount = 0
    if (one >= 8) then amount = amount + costCalc(x,y)*2 end
    if (two >= 24) then amount = amount + costCalc(x,y)*4 end
    if (three >= 48) then amount = amount + costCalc(x,y)*6 end
    if (four >= 80) then amount = amount + costCalc(x,y)*8 end
    return amount
end

function get_island_tiles(surface, x1, y1, x2, y2)
    ore_type = get_ore_type()
    entity_type = get_entity_type()
    
    tiles = generate_island_tiles(getRandomIntInclusive(1,3))
    
    transformed_tiles = {}
    
    ore = get_ore_type()
    do_oil = getRandomIntInclusive(1, 10) <= 2
    do_enemies = getRandomIntInclusive(1, 100) <= 25
    if (ore == "uranium-ore") then do_enemies = true end
    
    for y = 0, 31 do
        for x = 0, 31 do
            -- spawn ore
            
            count_one = count_alive_neighbors(tiles, 0, x, y) -- >=  8
            count_two = count_alive_neighbors(tiles, 2, x, y) -- >= 24
            count_three = count_alive_neighbors(tiles, 3, x, y) -- >= 48
            count_four = count_alive_neighbors(tiles, 4, x, y) -- >= 80
            
            if (ore) then        
                if (count_one == nil) then count_one = 0 end
                if (count_two == nil) then count_two = 0 end
                if (count_three == nil) then count_three = 0 end
                if (count_four == nil) then count_four = 0 end

                amount = get_total_amount(count_one, count_two, count_three, count_four, x + x1, y + y1)
                if (amount > 0) then
                    spawn_entity(surface, ore, amount, x + x1, y + y1)
                end
                
                spawn_tree(surface, x + x1, y + y1)
                
                if (do_oil) then
                    spawn_oil(surface, x + x1, y + y1)
                end
                
                if (do_enemies) then
                    spawn_enemy(surface, x + x1, y + y1)
                end
            end

            -- spawn entities

            -- transform tile
            tile_type = "grass"
            
            if (not tiles[y][x]) then
                if (count_two <= 5) then
                    tile_type = "deepwater"
                else
                    tile_type = "water"
                end
            end
            
            table.insert(transformed_tiles, {name=tile_type, position={x+x1, y+y1}})
        end
    end
    
    return transformed_tiles
end