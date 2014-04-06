function RegisterHooks()
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICKING_ENTITY, OnPlayerRightClickingEntity)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK,           OnPlayerRightClick)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK,            OnPlayerLeftClick)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_MOVING,                OnPlayerMoving)
	cPluginManager:AddHook(cPluginManager.HOOK_CHAT,                         OnChat)
	cPluginManager:AddHook(cPluginManager.HOOK_KILLING,                      OnKilling)
	cPluginManager:AddHook(cPluginManager.HOOK_TAKE_DAMAGE,                  OnTakeDamage)
	cPluginManager:AddHook(cPluginManager.HOOK_TAKE_DAMAGE,                  OnHitEntity)
end





function OnPlayerRightClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_CursorX, a_CursorY, a_CursorZ)
	local PlayerState = GetPlayerState(a_Player)
	return PlayerState:OnPlayerRightClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_CursorX, a_CursorY, a_CursorZ)
end





function OnPlayerRightClickingEntity(a_Player, a_Entity)
	local PlayerState = GetPlayerState(a_Player)
	return PlayerState:OnPlayerRightClickingEntity(a_Player, a_Entity)
end





function OnPlayerLeftClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Action)
	local PlayerState = GetPlayerState(a_Player)
	return PlayerState:OnPlayerLeftClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Action)
end





function OnPlayerMoving(a_Player)
	local PlayerState = GetPlayerState(a_Player)
	PlayerState:OnPlayerMoving(a_Player)
end





function OnChat(a_Player, a_Message)
	local PlayerState = GetPlayerState(a_Player)
	return PlayerState:OnChat(a_Player, a_Message)
end





function OnKilling(a_Victim, a_Killer)
	if (not a_Victim:IsPlayer()) then
		return false
	end
	
	local Player = tolua.cast(a_Victim, "cPlayer")
	local PlayerState = GetPlayerState(Player)
	return PlayerState:OnKilling(a_Victim, a_Killer)
end





function OnTakeDamage(a_Receiver, a_TDI)
	if (not a_Receiver:IsPlayer()) then
		return false
	end
	
	local Player = tolua.cast(a_Receiver, "cPlayer")
	local PlayerState = GetPlayerState(Player)
	return PlayerState:OnTakeDamage(a_Receiver, a_TDI)
end





function OnHitEntity(a_Receiver, a_TDI)
	if (a_TDI.Attacker == nil) then
		return false
	end
	
	if (not a_TDI.Attacker:IsPlayer()) then
		return false
	end
	
	local Player = tolua.cast(a_TDI.Attacker, "cPlayer")
	local PlayerState = GetPlayerState(Player)
	return PlayerState:OnHitEntity(Player, a_Receiver)
end