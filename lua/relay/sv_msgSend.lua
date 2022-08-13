require("chttp")

local tmpAvatars = {}

function Discord.send(form) 
	if type(form) ~= "table" then Error("[Discord] invalid type!") return end

	local json = util.TableToJSON(form)

	CHTTP({
		["failed"] = function(msg)
			print("[Discord] "..msg)
		end,
		["method"] = "POST",
		["url"] = Discord.webhook,
		["body"] = json,
		["type"] = "application/json"
	})
end

local function getAvatar(id, co)
	http.Fetch("https://steamcommunity.com/profiles/"..id.."?xml=1", 
	function(body)
		local _, _, url = string.find(body, '<avatarFull>.*.(https://.*)]].*\n.*<vac')
		tmpAvatars[id] = url

		coroutine.resume(co)
	end, 
	function (msg)
		Error("[Discord] error getting avatar ("..msg..")")
	end)
end

local function formMsg(ply, str)
	local id = ply:SteamID()

	local co = coroutine.create(function() 
		local form = {
			["username"] = ply:Nick(),
			["content"] = str,
			["avatar_url"] = tmpAvatars[id],
			["allowed_mentions"] = {
				["parse"] = {}
			},
		}
		
		Discord.send(form)
	end)

	if tmpAvatars[id] == nil then 
		getAvatar(id, co)
		return
	end

	coroutine.resume(co)
end

local function playerConnect(ply)
	local form = {
		["username"] = Discord.hookname,
		["embeds"] = {{
			["title"] = "Игрок "..ply.name.." ("..ply.networkid..") подключается...",
			["color"] = 16763979,
		}}
	}

	Discord.send(form)
end

local function plyFrstSpawn(ply)
	local form = {
		["username"] = Discord.hookname,
		["embeds"] = {{
			["title"] = "Игрок "..ply:GetName().." ("..ply:SteamID()..") подключился",
			["color"] = 4915018,
		}}
	}

	Discord.send(form)
end

local function plyDisconnect(ply)
	if tmpAvatars[ply.networkid] then tmpAvatars[ply.networkid] = nil end

	local form = {
		["username"] = Discord.hookname,
		["embeds"] = {{
			["title"] = "Игрок "..ply.name.." ("..ply.networkid..") отключился",
			["color"] = 16730698,
		}}
	}

	Discord.send(form)
end

hook.Add("PlayerSay", "!!discord_sendmsg", formMsg)
gameevent.Listen( "player_connect" )
hook.Add("player_connect", "!!discord_plyConnect", playerConnect)
hook.Add("PlayerInitialSpawn", "!!discordPlyFrstSpawn", plyFrstSpawn)
gameevent.Listen( "player_disconnect" )
hook.Add("player_disconnect", "!!discord_onDisconnect", plyDisconnect)
hook.Add("Initialize", "!!discord_srvStarted", function() 
	local form = {
		["username"] = Discord.hookname,
		["embeds"] = {{
			["title"] = "Сервер запущен!",
			["description"] = "Карта сейчас - " .. game.GetMap(),
			["color"] = 5793266
		}}
	}

	Discord.send(form)
	hook.Remove("Initialize", "!!discord_srvStarted")
end)