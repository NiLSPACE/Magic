g_PlayerStates = {}

function cPlayerState(a_Player)
	local self = {} -- Object that will contain all the public functions and variables.
	local CurrentMagic = {} -- Normaly it's a handler but at first we can use a table.
	local CurrentMagicName = ""
	
	local Magic = {}
	
	local function SearchMagic()
		local AvailableMagic = cFile:GetFolderContents(g_PluginFolder .. "/Magic")
		
		for Idx, MagicName in ipairs(AvailableMagic) do
			if ((MagicName ~= ".") and (MagicName ~= "..")) then
				local Loader, error = loadfile(g_PluginFolder .. "/Magic/" .. MagicName)
				if (not Loader) then
					LOGWARNING("Could not load " .. MagicName .. ": " .. error)
				else
					Magic[MagicName:sub(1, MagicName:len() - 4):upper()] = Loader(a_Player)
				end
			end
		end
	end
	
	SearchMagic()
	
	do -- All the hooks.
		function self:OnPlayerRightClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_CursorX, a_CursorY, a_CursorZ)
			if (CurrentMagic["OnPlayerRightClick"] ~= nil) then
				return CurrentMagic["OnPlayerRightClick"](nil, a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_CursorX, a_CursorY, a_CursorZ)
			end
		end
		
		function self:OnPlayerRightClickingEntity(a_Player, a_Entity)
			if (CurrentMagic["OnPlayerRightClickingEntity"] ~= nil) then
				return CurrentMagic["OnPlayerRightClickingEntity"](nil, a_Player, a_Entity)
			end
		end
		
		function self:OnPlayerLeftClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Action)
			if (CurrentMagic["OnPlayerLeftClick"] ~= nil) then
				return CurrentMagic["OnPlayerLeftClick"](nil, a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Action)
			end
		end
		
		function self:OnPlayerMoving(a_Player)
			if (CurrentMagic["OnPlayerMoving"] ~= nil) then
				return CurrentMagic["OnPlayerMoving"](nil, a_Player)
			end
		end
		
		function self:OnChat(a_Player, a_Message)
			if (CurrentMagic["OnChat"] ~= nil) then
				return CurrentMagic["OnChat"](nil, a_Player, a_Message)
			end
		end
		
		function self:OnKilling(a_Victim, a_Killer)
			if (CurrentMagic["OnKilling"] ~= nil) then
				return CurrentMagic["OnKilling"](nil, a_Victim, a_Killer)
			end
		end
		
		function self:OnTakeDamage(a_Receiver, a_TDI)
			if (CurrentMagic["OnTakeDamage"] ~= nil) then
				return CurrentMagic["OnTakeDamage"](nil, a_Receiver, a_TDI)
			end
		end
		
		function self:OnHitEntity(a_Player, a_Receiver, a_TDI)
			if (CurrentMagic["OnHitEntity"] ~= nil) then
				return CurrentMagic["OnHitEntity"](nil, a_Player, a_Receiver, a_TDI)
			end
		end
		
		function self:OnDeselect()
			if (CurrentMagic["OnDeselect"] ~= nil) then
				CurrentMagic["OnDeselect"]()
			end
		end
		
		function self:OnSelect()
			if (CurrentMagic["OnSelect"] ~= nil) then
				CurrentMagic["OnSelect"]()
			end
		end
		
		function self:OnDisable()
			for Key, Data in pairs(Magic) do
				if (Data["OnDisable"] ~= nil) then
					Data["OnDisable"]()
				end
			end
		end
	end -- do
	
	function self:SelectMagic(a_MagicName)
		assert(type(a_MagicName) == 'string')
		
		local UpperCaseMagicName = a_MagicName:upper()
		if (Magic[UpperCaseMagicName] == nil) then
			return false, "the magic doesn't exist."
		end
		
		if (CurrentMagicName == UpperCaseMagicName) then
			return false, "that magic is already selected."
		end
		
		self:OnDeselect()
		CurrentMagic = Magic[UpperCaseMagicName]
		CurrentMagicName = UpperCaseMagicName
		self:OnSelect()
		return true
	end
	
	return self
end






function GetPlayerState(a_Player)
	local PlayerName = a_Player:GetName()
	if (g_PlayerStates[PlayerName] ~= nil) then
		return g_PlayerStates[PlayerName]
	end
	
	local PlayerState = cPlayerState(a_Player)
	g_PlayerStates[PlayerName] = PlayerState
	return PlayerState
end
