ADAMANTINE_ARMOR = 1
FLAME_EMPRESS_ARMOR = 2
GIANTS_ARMOR = 3

local Armor = {
	Adamantine_Armor = {E_ITEM_DIAMOND_HELMET, E_ITEM_DIAMOND_CHESTPLATE, E_ITEM_DIAMOND_LEGGINGS, E_ITEM_DIAMOND_BOOTS},
	Flame_Empress_Armor = {E_ITEM_LEATHER_CAP, E_ITEM_GOLD_CHESTPLATE, E_ITEM_LEATHER_PANTS, E_ITEM_LEATHER_BOOTS},
	Giants_Armor = {E_ITEM_GOLD_HELMET, E_ITEM_GOLD_CHESTPLATE, E_ITEM_GOLD_LEGGINGS, E_ITEM_GOLD_BOOTS},
}

function cRequip(a_Player)
	local self = {}
	local EquippedArmor = -1
	local DidChangeArmorBefore = false
	local FirstArmor = cItems()
	
	local function EquipPlayer(a_Player, a_ArmorTable)
		local Inventory = a_Player:GetInventory():GetArmorGrid()
		if (not DidChangeArmorBefore) then
			Inventory:CopyToItems(FirstArmor)
			DidChangeArmorBefore = true
		end
		
		for I=0, 3 do
			Inventory:SetSlot(I, cItem(a_ArmorTable[I + 1]))
		end
	end
	
	function self:OnChat(a_Player, a_Message)
		local Message = a_Message:upper()
		if (Message == "REQUIP ADAMANTINE ARMOR") then
			EquipPlayer(a_Player, Armor.Adamantine_Armor)
			EquippedArmor = ADAMANTINE_ARMOR
		elseif (Message == "REQUIP FLAME EMPRESS ARMOR") then
			EquipPlayer(a_Player, Armor.Flame_Empress_Armor)
			EquippedArmor = FLAME_EMPRESS_ARMOR
		elseif (Message == "REQUIP GIANTS ARMOR") then
			EquipPlayer(a_Player, Armor.Giants_Armor)
			EquippedArmor = GIANTS_ARMOR
		end
	end
	
	function self:OnTakeDamage(a_Receiver, a_TDI)
		if (EquippedArmor == FLAME_EMPRESS_ARMOR) then
			a_TDI.FinalDamage = a_TDI.FinalDamage / 2
		end
	end
	
	function self:OnDeselect()
		local Inventory = a_Player:GetInventory():GetArmorGrid()
		for I=0, 3 do
			Inventory:SetSlot(I, FirstArmor:Get(I))
		end
	end
	
	function self:OnDisable()
		if (not DidChangeArmorBefore) then
			return
		end
		
		local Inventory = a_Player:GetInventory():GetArmorGrid()
		for I=0, 3 do
			Inventory:SetSlot(I, FirstArmor:Get(I))
		end
	end
	
	function self:OnHitEntity(a_Player, a_Receiver, a_TDI)
		if (EquippedArmor == GIANTS_ARMOR) then
			a_TDI.FinalDamage = a_TDI.FinalDamage * 2
			if (a_Receiver:IsPlayer()) then
				a_Receiver:ForceSetSpeed(a_Player:GetLookVector() * 10)
			else
				a_Receiver:SetSpeed(a_Player:GetLookVector() * 10)
			end
		end
	end
	
	
	return self
end


return cRequip(...)
-- Once again I watched too much Fairy Tail
