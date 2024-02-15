Discord.commands['status'] = function()
    local plys = player.GetCount() .. '/' .. game.MaxPlayers()
    local plyList = ''
    local plysTable = player.GetAll()

    if #plysTable > 0 then
        for num, ply in ipairs(plysTable) do
            plyList = plyList .. ply:Nick() .. '\n'
        end
    else plyList = DiscordString.nobody .. '¯\\_(ツ)_/¯' end

    local form = {
        ['embeds'] = {{
            ['color'] = 5793266,
            ['title'] = GetHostName(),
            ['description'] = [[
DiscordString.connect - steam://connect/]] .. game.GetIPAddress() .. [[

DiscordString.currentMap - ]] .. game.GetMap() .. [[

DiscordString.players - ]] .. plys .. [[
            ]],
            ['fields'] = {{
                ['name'] = DiscordString.playerList,
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