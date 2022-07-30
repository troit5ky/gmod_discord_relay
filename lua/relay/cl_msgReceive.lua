net.Receive("!!discord-receive", function()
	local msg = net.ReadTable()

	chat.AddText( Discord.prefixClr, "["..Discord.prefix.."] ", Color(255, 255, 255), msg.author..": ", msg.content)
end)