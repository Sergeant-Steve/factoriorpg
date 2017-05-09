function get_spawn_tiles(surface, x1, y1, x2, y2)
    tiles = {}
    for x = x1, x2 do
        for y = y1, y2 do
            if (does_square_intersect(x, y, x, y,  -SPAWN_SIZE, -SPAWN_SIZE, SPAWN_SIZE, SPAWN_SIZE)) then
                output = "grass"
                spawn_quadrant_ore(surface, x, y)
            else
                output = "water"
            end
            
            spawn_tree(surface, x, y)
            
            table.insert(tiles, { name = output, position = {x, y}})
        end
    end
    return tiles
end
