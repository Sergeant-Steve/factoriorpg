-- A 3Ra Gaming compilation
Event.register(-1, function()
    global.scenario = global.senario or {}
    global.scenario.config = {}
    global.scenario.config.announcements_enabled = true -- if true announcements will be shown
    global.scenario.config.announcement_delay = 600 -- number of seconds between each announcement
end)
