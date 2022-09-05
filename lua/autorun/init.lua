if SERVER then 
	include("sv_config.lua")
	include("relay/sv_msgSend.lua")
	include("relay/sv_msgGet.lua")

	-- commands
	local files, _ = file.Find( 'relay/commands/' .. "*", "LUA" )

	for num, fl in ipairs(files) do
		include("relay/commands/" .. fl)
		print('[Discord] module ' .. fl .. ' added!')
	end
	--

	AddCSLuaFile('cl_config.lua')
	AddCSLuaFile('relay/cl_msgReceive.lua')

	print( "----------------------\n" )
	print( "DISCORD RELAY LOADED!\n" )
	print( "----------------------" )
end

if CLIENT then 
	include('cl_config.lua')
	include('relay/cl_msgReceive.lua')
end