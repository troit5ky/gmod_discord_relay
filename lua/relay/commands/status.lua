Discord.commands['status'] = function()
    local plys = player.GetCount() .. '/' .. game.MaxPlayers()
    local plyList = ''
    local plysTable = player.GetAll()

    if #plysTable > 0 then
        for num, ply in ipairs(plysTable) do
            plyList = plyList .. ply:Nick() .. '\n'
        end
    else plyList = 'никого ¯\\_(ツ)_/¯' end

    local form = {
        ['embeds'] = {{
            ['color'] = 5793266,
            ['title'] = GetHostName(),
            ['description'] = [[
**Подключиться** - steam://connect/]] .. game.GetIPAddress() .. [[

**Карта сейчас** - ]] .. game.GetMap() .. [[

**Игроков** - ]] .. plys .. [[
            ]],
            ['fields'] = {{
                ['name'] = 'Список игроков',
                ['value'] = plyList
            }}
        }}
    }

    Discord.send(form)
end

Discord.commands['ping'] = function()
    local form = {
        ['content'] = ':ping_pong: pong'
    }

    Discord.send(form)
end