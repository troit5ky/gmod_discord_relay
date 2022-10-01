require("chttp")

local tmpAvatars = {}

local IsValid = IsValid
local util_TableToJSON = util.TableToJSON
local http_Fetch = http.Fetch
local coroutine_resume = coroutine.resume
local coroutine_create = coroutine.create

function Discord.send(form) 
	if type(form) ~= "table" then Error("[Discord] invalid type!") return end

	local json = util_TableToJSON(form)

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
	http_Fetch("https://steamcommunity.com/profiles/"..id.."?xml=1", 
	function(body)
		local _, _, url = string.find(body, '<avatarFull>.*.(https://.*)]].*\n.*<vac')
		tmpAvatars[id] = url

		coroutine_resume(co)
	end, 
	function (msg)
		Error("[Discord] error getting avatar ("..msg..")")
	end)
end

local function formMsg(ply, str)
	local id = tostring(ply:SteamID64())

	local co = coroutine_create(function() 
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
	else 
		coroutine_resume(co)
	end
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
	if IsValid(ply) then
		local form = {
			["username"] = Discord.hookname,
			["embeds"] = {{
				["title"] = "Игрок "..ply:Nick().." ("..ply:SteamID()..") подключился",
				["color"] = 4915018,
			}}
		}

		Discord.send(form)
	end
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