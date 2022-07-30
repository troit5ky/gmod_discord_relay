require("gwsockets")
util.AddNetworkString("!!discord-receive")

Discord.isSocketReloaded = false

if Discord.socket != nil then Discord.isSocketReloaded = true; Discord.socket:closeNow(); end

Discord.socket = Discord.socket or GWSockets.createWebSocket("wss://gateway.discord.gg/?encoding=json", true)
local socket = Discord.socket

local function broadcastMsg(msg)
    print('[Discord] ' .. msg.author..': '.. msg.content)

    net.Start("!!discord-receive")
        net.WriteTable(msg)
    net.Broadcast()
end

local function heartbeat()
    socket:write([[
    {
        "op": 1,
        "d": null
    }
    ]])
end

local function createHeartbeat()
    timer.Create('!!discord_hearbeat', 10, 0, function()
        socket:write([[
        {
            "op": 1,
            "d": null
        }
        ]])
    end)
end

function socket:onMessage(txt)
    local resp = util.JSONToTable(txt)
    if Discord.debug then 
        print("[Discord] Received: ")
        PrintTable(resp)
    end

    if resp.op == 10 and resp.t == nil then createHeartbeat() end
    if resp.op == 1 then heartbeat() end
    if resp.d then
        if resp.t == "MESSAGE_CREATE" && resp.d.channel_id == Discord.readChannelID && resp.d.content != '' then 
            if resp.d.author.bot == true then return end
            broadcastMsg({
                ['author'] = resp.d.author.username,
                ['content'] = resp.d.content
            }) 
        end
    end
end

function socket:onError(txt)
    print("[Discord] Error: ", txt)
end

function socket:onConnected()
	print("[Discord] connected to Discord server")
    local req = [[
    {
      "op": 2,
      "d": {
        "token": "]]..Discord.botToken..[[",
        "intents": 512,
        "status": "dnd",
        "properties": {
          "os": "linux",
          "browser": "disco",
          "device": "disco"
        }
      }
    }
    ]]

    timer.Simple(2, function() socket:write(req) end)
end

function socket:onDisconnected()
    print("[Discord] WebSocket disconnected")
    timer.Remove('!!discord_hearbeat')

    if Discord.isSocketReloaded != true then 
        print('[Discord] WebSocket reload in 5 sec...')
        timer.Simple(5, function() socket:open() end)
    end
end

print('[Discord] Socket init...')
timer.Simple(3, function() 
    socket:open()
    Discord.isSocketReloaded = false 
end)