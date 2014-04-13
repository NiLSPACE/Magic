local function GetFireDragonsRoarCallbacks(a_World)
	return {
		OnNextBlock = function(BlockX, BlockY, BlockZ, BlockType, BlockMeta)
			if (BlockType ~= E_BLOCK_AIR) then
				-- abort the trace
				return true;
			end
			for X=-1, 1 do
				for Z=-1, 1 do
					a_World:BroadcastSoundParticleEffect(2004, (BlockX + X)*8, (BlockY)*8, (BlockZ + Z)*8, BlockType)
				end
			end
			a_World:DoExplosionAt(3, BlockX, BlockY, BlockZ, true, esPlugin, nil);
		end
	};
end

local Spells = {}
Spells["FIRE DRAGONS ROAR!"] = function(a_Player, a_Message)
	if (a_Player:GetFoodLevel() < 7) then
		a_Player:SendMessage(cChatColor.Rose .. "Aaaah man I'm hungry")
		return true
	end
	
	local EyePos = a_Player:GetEyePosition()
	local LookVector = a_Player:GetLookVector()
	
	LookVector:Normalize()
	
	local Start = EyePos + LookVector
	local End = EyePos + LookVector * 50
	local World = a_Player:GetWorld()
	
	local Callback = GetFireDragonsRoarCallbacks(World)
	
	cLineBlockTracer.Trace(World, Callback, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	a_Player:SetFoodLevel(a_Player:GetFoodLevel() - 7)
end

function cFireDragon(a_User)
	local self = {}
	local PlayerName = a_User:GetName()
	
	function self:OnChat(a_Player, a_Message)
		local Message = a_Message:upper()
		if (Spells[Message]) then
			return Spells[Message](a_Player, a_Message)
		end
	end
	
	-- Explode when hitting something
	function self:OnPlayerLeftClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Action)
		if (a_BlockFace == BLOCK_FACE_NONE) then
			return false
		end
		
		local World = a_Player:GetWorld()
		if (a_Player:GetFoodLevel() > 0.5) then
			World:DoExplosionAt(1, a_BlockX, a_BlockY, a_BlockZ, true, esPlugin, nil)
		end
		a_Player:SetFoodLevel(a_Player:GetFoodLevel() - 0.5)
	end
	
	-- fire or explosions are nothing if you can eat them
	function self:OnTakeDamage(a_Receiver, a_TDI)
		if ((a_TDI.DamageType == dtFireContact) or (a_TDI.DamageType == dtExplosion) or (a_TDI.DamageType == dtBurning)) then
			return true
		end
	end
	
	-- Fire dragons can eat fire.
	function self:OnPlayerMoving(a_Player)
		if (a_Player:IsOnFire()) then
			a_Player:StopBurning()
			a_Player:Feed(2, 5)
		end
			
		local World = a_Player:GetWorld()
		local Pos = a_Player:GetPosition()
		if (World:GetBlock(Vector3i(Pos)) == E_BLOCK_FIRE) then
			World:SetBlock(Pos.x, Pos.y, Pos.z, E_BLOCK_AIR, 0)
			a_Player:Feed(2, 5)
		end
	end
	
	function self:OnHitEntity(a_Player, a_Receiver, a_TDI)
		a_Receiver:StartBurning(50)
	end
	
	return self
end


return cFireDragon(...) -- return the handler
-- I watched too much Fairy Tail, but this is awesome :)