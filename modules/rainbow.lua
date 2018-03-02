--Rainbow names!
--Written by Mylon, Feb 2018
--MIT License

global.rainbow = {}

commands.add_command("rainbow", "Rainbow chat colors!", function()
    if game.player and game.player.admin then
        if not global.rainbow[game.player.name] then
            global.rainbow[game.player.name] = 1800 * math.random() --This is an offset so everyone doesn't have the same color.
        else
            global.rainbow[game.player.name] = nil
            game.player.color = {}
            game.player.chat_color = {}
        end
    end
end)

function rainbow()
    for k,v in pairs(global.rainbow) do
        if game.players[k] and game.players[k].connected then
            local player = game.players[k]
            local color = {
                r = math.sin((game.tick + 133 + global.rainbow[game.player.name]) / 1700) * 127 + 127,
                b = math.sin((game.tick + 266 + global.rainbow[game.player.name]) / 1800) * 127 + 127,
                g = math.sin((game.tick + 500 + global.rainbow[game.player.name]) / 1900) * 127 + 127
            }
            player.color = color
            color.alpha = 0.5
            player.chat_color = color
        end
    end
end

script.on_nth_tick(3, rainbow)