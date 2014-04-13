function GetFirstSolidBlockFromTrace(a_Player)
	local EyePos = a_Player:GetEyePosition()
	local LookVector = a_Player:GetLookVector()
	
	LookVector:Normalize()
	
	local Start = EyePos + LookVector
	local End = EyePos + LookVector * 50
	local World = a_Player:GetWorld()
	
	local DidFindBlock = false
	local Pos = Vector3i()
	
	local Callback = {
		OnNextBlock = function(a_BlockX, a_BlockY, a_BlockZ, a_BlockType, a_BlockMeta)
			Pos:Set(a_BlockX, a_BlockY, a_BlockZ)
			if (cBlockInfo:IsSolid(a_BlockType)) then
				DidFindBlock = true
				return true
			end
		end
	};
	
	cLineBlockTracer.Trace(World, Callback, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	return DidFindBlock, Pos
end

local Spells = {}
Spells["ICE-MAKE GEYSER"] =
function (a_Player, a_Message)
	local World = a_Player:GetWorld()
	local LookVector = a_Player:GetLookVector()
	LookVector:Normalize()
	LookVector.y = 0
	local Pos = a_Player:GetPosition() + (LookVector * 1.5)
	for I=Pos.y, Pos.y + 12, 0.5 do
		Pos = Pos + LookVector
		local ChunkX, ChunkZ = math.floor(Pos.x / 16), math.floor(Pos.z / 16)
		World:ForEachEntityInChunk(ChunkX, ChunkZ, 
			function(a_Entity)
				local Distance = (Pos - a_Entity:GetPosition()):Length()
				if (Distance < 1) then
					if ((a_Entity:IsPlayer()) and (a_Entity:GetUniqueID() ~= a_Player:GetUniqueID())) then
						local Speed = a_Enity:GetSpeed()
						Speed.y = Speed.y + 30
						a_Entity:ForceSetSpeed(Speed)
					else
						a_Entity:SetSpeedY(30)
					end
				end
			end
		)
		
		local function FindLowestBlock()
			for Y = Pos.y, 0, -1 do
				if (World:GetBlock(Pos.x, Y, Pos.z) ~= E_BLOCK_AIR) then
					return Y + 1
				end
			end
			return 0
		end
		
		for Y = I, FindLowestBlock(), -1 do
			local VectorPos = Vector3i(Pos)
			World:QueueSetBlock(VectorPos.x, Y, VectorPos.z, E_BLOCK_PACKED_ICE, 0, (I - Pos.y) / 2)
			World:ScheduleTask(36, 
				function()
					World:SetBlock(VectorPos.x, Y, VectorPos.z, E_BLOCK_AIR, 0)
					local EntityID = World:SpawnFallingBlock(VectorPos.x, Y, VectorPos.z, E_BLOCK_PACKED_ICE, 0)
					World:DoWithEntityByID(EntityID,
						function(a_Entity)
							a_Entity:SetSpeed(math.random(-3, 3), math.random(0, 3), math.random(-3, 3))
						end
					)
				end
			)
		end
	end
end

Spells["ICE-MAKE HOUSE"] =
function (a_Player, a_Message)
	local World = a_Player:GetWorld()
	
	local Position = a_Player:GetPosition()
	Position.x = math.floor(Position.x)
	Position.z = math.floor(Position.z)
	
	local MinX, MaxX = Position.x - 5, Position.x + 5
	local MinY, MaxY = Position.y - 1, Position.y + 5
	local MinZ, MaxZ = Position.z - 5, Position.x + 5
	for X = MinX, MaxX do
		for Z = MinZ, MaxZ do
			local Pos = Vector3d(X, Position.y, Z)
			local Distance = (Position - Pos):Length()
			if (math.floor(Distance) == 4) then
				local Ticks = math.random(6)
				for Y = MinY, MaxY do
					World:QueueSetBlock(X, Y, Z, E_BLOCK_PACKED_ICE, 0, Ticks)
					Ticks = Ticks + 2 + math.random(6)
				end
				
			elseif (Distance < 4) then
				World:QueueSetBlock(X, MinY, Z, E_BLOCK_PACKED_ICE, 0, math.random(2, 24))
				World:QueueSetBlock(X, MaxY, Z, E_BLOCK_PACKED_ICE, 0, math.random(18, 36))
			end
		end
	end
				
	World:QueueSetBlock(Position.x, Position.y, Position.z, E_BLOCK_TORCH, 0, 25)
end

Spells["ICE-MAKE LANCE"] =
function (a_Player, a_Message)
	local World = a_Player:GetWorld()
	local LookVector = a_Player:GetLookVector()
	
	for I=1, 30, 2 do
		World:ScheduleTask(I,
			function()
				local EyePos = a_Player:GetEyePosition()
				local EntityID = World:SpawnFallingBlock(EyePos.x, EyePos.y, EyePos.z, E_BLOCK_PACKED_ICE, 0)
				World:DoWithEntityByID(EntityID,
					function(a_Entity)
						a_Entity:SetSpeed(a_Player:GetLookVector() * 50)
					end
				)
				local function CheckOtherEntities(a_EntityID)
					World:ScheduleTask(1,
						function()
							if (World:DoWithEntityByID(a_EntityID,
								function(a_FallingBlock)
									local Pos = a_FallingBlock:GetPosition()
									local Speed = a_FallingBlock:GetSpeed()
									World:ForEachEntityInChunk(a_FallingBlock:GetChunkX(), a_FallingBlock:GetChunkZ(),
										function(a_OtherEntity)
											if (a_OtherEntity:GetEntityType() ~= cEntity.etFallingBlock) then
												if ((a_OtherEntity:GetPosition() - Pos):Length() < 2) then
													a_OtherEntity:AddSpeed(Speed * 2)
													a_OtherEntity:AddSpeedY(3)
												end
											end
										end
									)
								end
							)) then
								CheckOtherEntities(a_EntityID)
							end
						end
					)
				end
				CheckOtherEntities(EntityID)
			end
		)
	end
end


function cIceMake(a_Player)
	local self = {}
	
	function self:OnChat(a_Player, a_Message)
		local Spell = a_Message:upper()
		if (Spells[Spell] ~= nil) then
			return Spells[Spell](a_Player, a_Message)
		end
	end
	
	return self
end


return cIceMake(...)