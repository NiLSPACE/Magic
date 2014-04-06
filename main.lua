g_PluginFolder = ""


function Initialize(a_Plugin)
	a_Plugin:SetName("Magic")
	a_Plugin:SetVersion(1)
	
	g_PluginFolder = a_Plugin:GetLocalFolder()
	
	RegisterHooks()
	
	cPluginManager:BindCommand("/magic", "magic.choose", HandleMagicCommand, "Allows you to set the magic you want to use.")
	
	LOG("Magic is initialized")
	return true
end






function HandleMagicCommand(a_Split, a_Player)
	if (a_Split[2] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /magic [MagicName]")
		return true
	end
	
	local PlayerState = GetPlayerState(a_Player)
	local Succes, error = PlayerState:SelectMagic(a_Split[2])
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. error)
		return true
	end
	
	a_Player:SendMessage(cChatColor.LightGreen .. "You selected " .. a_Split[2] .. " as your magic.")
	return true
end