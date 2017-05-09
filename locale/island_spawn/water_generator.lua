function get_water_tiles(x1, y1, x2, y2)
    tiles = {}
    for x = x1, x2 do
            for y = y1, y2 do
                table.insert(tiles, { name = "deepwater", position = {x, y}})
            end
        end
    return tiles
end