Scriptname XTD_LoneWolfFollowersCheck extends ReferenceAlias

import XTDUtil

Event OnObjRefFill(string eventName, string strArg, float numArg = 0.0, Form sender)
	If GetRef()
		UnRegisterForModEvent("ObjRefFill")
		AddLoot(GetRef())
	Endif
Endevent

Function AddLoot(ObjectReference afContainer)
    form item
    bool BetterLoot
	int[] masks = Utility.CreateIntArray(30)
	float luckMult = (1 + (Attributes.GetTotalValue(6) * 0.01))
	float odds = CalculateMyOdds(PlayerRef, "FavorActive", (XTDGV_MIF.GetValue()))
	float TemperChance = CalculateMyOdds(PlayerRef, "FavorsPerDay", (XTDGV_TIF.GetValue()))
	XTD.CalculateOdds(PlayerRef)
	Actor akTarget = afContainer.PlaceActorAtMe(XTD_DummyActor)
	akTarget.Disable()
	akTarget.SetPosition(afContainer.X, afContainer.Y, afContainer.Z - 200.0)
	if (RNDF() <= (Attributes.GetTotalValue(6)/7)) || (XTDContainerBossList.HasForm(afContainer.GetBaseObject() as Form)) || (afContainer.GetLockLevel() >= 25)
		BetterLoot = true
		odds *= 1.25
		TemperChance *= 1.25
	elseif (WDContainersLow.HasForm(afContainer.GetBaseObject() as Form)) || IsMiscContainer(afContainer)
		odds *= 0.1
		TemperChance *= 0.1
		luckMult *= 0.1
	elseif (XTDMerchantList.HasForm(afContainer.GetBaseObject() as Form))
		float speechMult = 1.0 + PlayerRef.GetAV("Speechcraft") * 0.01
		BetterLoot = true
		odds *= speechMult
		TemperChance *= speechMult
	endif
	akTarget.Enable()
	bool transfer
	Weapon thisWeaponOne = akTarget.GetEquippedWeapon()
	Weapon thisWeaponTwo = akTarget.GetEquippedWeapon(True)
	if thisWeaponOne
		if (!thisWeaponOne.HasKeywordString("MagicDisallowEnchanting") && RNDF() <= odds && !(thisWeaponOne as Weapon).GetEnchantment())
			XTD.ApplyPlayerMadeEnchantment(akTarget, 1, 0, BetterLoot)
			transfer = True
		endif
		if (WornObject.GetItemHealthPercent(akTarget, 1, 0) == 1.0 && TemperChance > 0.0 && RNDF() <= TemperChance)
			XTD.TemperItem(akTarget, 1, 0)
			transfer = True
		endif
	endif
	If transfer
		transfer = False
		akTarget.RemoveItem(akTarget.GetEquippedWeapon(), 1, true, afContainer)
	Endif
	if thisWeaponTwo
		if (!thisWeaponTwo.HasKeywordString("MagicDisallowEnchanting") && RNDF() <= odds && !(thisWeaponTwo as Weapon).GetEnchantment())
			XTD.ApplyPlayerMadeEnchantment(akTarget, 0, 0, BetterLoot)
			transfer = True
		endif
		if (WornObject.GetItemHealthPercent(akTarget, 0, 0) == 1.0 && TemperChance > 0.0 && RNDF() <= TemperChance)
			XTD.TemperItem(akTarget, 0, 0)
			transfer = True
		endif
	endif
	If transfer
		transfer = False
		akTarget.RemoveItem(akTarget.GetEquippedWeapon(True), 1, true, afContainer)
	Endif
	akTarget.Disable()
	int index
	int slotsChecked
	slotsChecked += 0x00100000
	slotsChecked += 0x00200000
	slotsChecked += 0x80000000
	int thisSlot = 0x01
	while (thisSlot < 0x80000000)
		if (Math.LogicalAnd(slotsChecked, thisSlot) != thisSlot)
			Armor thisArmor = akTarget.GetWornForm(thisSlot) as Armor
			if (thisArmor && thisArmor.IsPlayable())
				if RNDF() < odds && !thisArmor.GetEnchantment() && !thisArmor.HasKeyword(MagicDisallowEnchanting)
					masks[index] = thisSlot
					XTD.ApplyPlayerMadeEnchantment(akTarget, 0, thisSlot, BetterLoot)
				endif
				if (TemperChance > 0.0 && RNDF() <= TemperChance && thisArmor.GetWeightClass() != 2 && WornObject.GetItemHealthPercent(akTarget, 0, thisSlot) == 1.0)
					masks[index] = thisSlot
					XTD.TemperItem(akTarget, 0, thisSlot)
				endif
				index += 1
				slotsChecked += thisArmor.GetSlotMask()
			else
				slotsChecked += thisSlot
			endif
		endif
		thisSlot *= 2
	endWhile
    If (afContainer.GetItemCount(Gold001) > 0 && PlayerRef.GetActorValue("FavorPointsBonus") > 0.0)
        int BonusGold = (afContainer.GetItemCount(Gold001) * (PlayerRef.GetActorValue("FavorPointsBonus")/ 100.0)) as int
        afContainer.AddItem(Gold001, BonusGold)
    endif
    float dropmult = (1.25 * luckMult)
	if (BetterLoot)
		dropmult *= 1.25
	endif
	if (dropmult > 5.0)
		dropmult = 5.0
	endif
    if (RNDF() <= dropmult)
        float grandchance = (5.0 * luckMult)
        if (RNDF() <= grandchance)
            item = XTDCrystals.GetAt(2)
        else
            item = XTDCrystals.GetAt(Utility.RandomInt(0, 1))
        endif
        afContainer.AddItem(item, 1)
    endif
	dropmult = (2.5 * luckMult)
	if (BetterLoot)
		dropmult *= 1.25
	endif
	if (dropmult > 10.0)
		dropmult = 10.0
	endif
	if (RNDF() <= dropmult)
		item = XTDPotions.GetAt(Utility.RandomInt(0, (XTDPotions.GetSize() - 1)))
		afContainer.AddItem(item, 1)
	endif
	dropmult = (5.5 * luckMult)
	if (BetterLoot)
		dropmult *= 1.25
	endif
	if (dropmult > 15.0)
		dropmult = 15.0
	endif
	if (RNDF() <= dropmult)
		item = XTDPotionsMisc.GetAt(Utility.RandomInt(0, (XTDPotionsMisc.GetSize() - 1)))
		afContainer.AddItem(item, 1)
	endif
	ExtraLoot(afContainer)
	TransferItemsAndDisable(akTarget, afContainer, masks)
Endfunction

function TransferItemsAndDisable(Actor TransferFrom, ObjectReference TransferTo, int[] slotmasks)
	int i
    form item
	While (i < slotmasks.Length)
	item = TransferFrom.GetWornForm(slotmasks[i])
	if (item) 
		if (WornObject.GetEnchantment(TransferFrom, 0, slotmasks[i]))
			TransferFrom.RemoveItem(TransferFrom.GetWornForm(slotmasks[i]), 1, true, TransferTo)
		endif
		if (WornObject.GetItemHealthPercent(TransferFrom, 0, slotmasks[i]) > 1.0)
			TransferFrom.RemoveItem(TransferFrom.GetWornForm(slotmasks[i]), 1, true, TransferTo)
		endif
	endif
	i += 1
	EndWhile
	TransferFrom.Delete()
	Clear()
endfunction


Bool Function IsMiscContainer(ObjectReference afContainer)
	If !(XTDContainerList.HasForm(afContainer.GetBaseObject() as Form)) && !(XTDContainerBossList.HasForm(afContainer.GetBaseObject() as Form)) && !(XTDMerchantList.HasForm(afContainer.GetBaseObject() as Form))
		Return True
	Else
		Return False
	Endif
Endfunction

Function ExtraLoot(ObjectReference afContainer)
	Float xChance = PlayerRef.GetActorValue("FavorsPerDayTimer")
	If RNDF() <= xChance
		int i
		int j = Utility.RandomInt(1, 3)
		While i < j
			If RNDF() <= 33.0
				afContainer.AddItem(WDExtraLoot, 1)
			Endif
			i +=1
		Endwhile
	Endif
Endfunction

Actor Property PlayerRef  Auto
ActorBase Property XTD_DummyActor  Auto 
MiscObject Property Gold001  Auto
MiscObject Property XTDToken  Auto 
XTD_BaseScript Property XTD Auto
XTD_Attributes Property Attributes Auto
FormList Property XTDCrystals  Auto
FormList Property XTDPotions  Auto  
FormList Property XTDPotionsMisc  Auto 
Formlist Property XTDContainerBossList Auto 
GlobalVariable Property XTDGV_MIF Auto
GlobalVariable Property XTDGV_TIF Auto
GlobalVariable Property XTDGV_Person Auto
Keyword Property MagicDisallowEnchanting  Auto 
LeveledItem Property WDExtraLoot  Auto  
FormList Property WDContainersBlacklist  Auto  
FormList Property WDContainersLow  Auto 
FormList Property XTDMerchantList  Auto  
FormList Property XTDContainerList  Auto 