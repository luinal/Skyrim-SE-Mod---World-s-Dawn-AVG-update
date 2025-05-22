Scriptname XTD_ConfigEx extends ReferenceAlias

import XTDUtil

Event OnActorAliasFill(string eventName, string strArg, float numArg, Form sender)
	If GetActorRef()
		UnRegisterForModEvent("ActorAliasFill")
		;MiscUtil.PrintConsole(GetName()+" assigned to "+GetActorRef())
		AddLoot(GetActorRef())
	Endif
Endevent

Function AddLoot(Actor akToCheck)
	form item
	bool BetterLoot
	float luckMult = (1 + (Attributes.GetTotalValue(6) * 0.01))
	If akToCheck.HaskeywordString("ActorTypeNPC") || (akToCheck.HaskeywordString("ActorTypeCreature") && !akToCheck.HaskeywordString("ActorTypeAnimal"))
		float odds = CalculateMyOdds(PlayerRef, "MagicItemFindMod", (XTDGV_MIF.GetValue()))
		float TemperChance = CalculateMyOdds(PlayerRef, "TemperedItemFindMod", (XTDGV_TIF.GetValue()))
		XTD.CalculateOdds(PlayerRef)
		if (akToCheck.GetLevel() - PlayerRef.GetLevel() >= 5) || (RNDF() <= (Attributes.GetTotalValue(6)/7))
			BetterLoot = true
		endif
		if !(akToCheck.IsDead())
			akToCheck.AddSpell(XTD_AbHealPlayerHidden, false)
		endif
		int index
		int slotsChecked
		slotsChecked += 0x00100000
		slotsChecked += 0x00200000
		slotsChecked += 0x80000000
		int thisSlot = 0x01
		while (thisSlot < 0x80000000)
			if (Math.LogicalAnd(slotsChecked, thisSlot) != thisSlot)
				Armor thisArmor = akToCheck.GetWornForm(thisSlot) as Armor
				if (thisArmor && thisArmor.IsPlayable())
					if (!thisArmor.GetEnchantment() && RNDF() <= odds && !thisArmor.HasKeywordString("MagicDisallowEnchanting"))
						XTD.ApplyPlayerMadeEnchantment(akToCheck, 0, thisSlot, BetterLoot)
					endif
					if (TemperChance > 0.0 && RNDF() <= TemperChance && thisArmor.GetWeightClass() != 2 && WornObject.GetItemHealthPercent(akToCheck, 0, thisSlot) == 1.0)
						XTD.TemperItem(akToCheck, 0, thisSlot)
					endif
					index += 1
					slotsChecked += thisArmor.GetSlotMask()
				else
					slotsChecked += thisSlot
				endif
			endif
			thisSlot *= 2
		endWhile
		Weapon thisWeapon = akToCheck.GetEquippedWeapon()
		if thisWeapon
			if (!thisWeapon.HasKeywordString("MagicDisallowEnchanting") && RNDF() <= odds && !thisWeapon.GetEnchantment())
				XTD.ApplyPlayerMadeEnchantment(akToCheck, 1, 0, BetterLoot)
			endif
			if (WornObject.GetItemHealthPercent(akToCheck, 1, 0) == 1.0 && TemperChance > 0.0 && RNDF() <= TemperChance)
				XTD.TemperItem(akToCheck, 1, 0)
			endif
		endif
		thisWeapon = akToCheck.GetEquippedWeapon(true)
		if thisWeapon
			if (!thisWeapon.HasKeywordString("MagicDisallowEnchanting") && RNDF() <= odds && !thisWeapon.GetEnchantment())
				XTD.ApplyPlayerMadeEnchantment(akToCheck, 0, 0, BetterLoot)
			endif
			if (WornObject.GetItemHealthPercent(akToCheck, 0, 0) == 1.0 && TemperChance > 0.0 && RNDF() <= TemperChance)
				XTD.TemperItem(akToCheck, 0, 0)
			endif
		endif
	Endif
    If (akToCheck.GetItemCount(Gold001) > 0 && PlayerRef.GetActorValue("GoldFindMod") > 0.0)
        int BonusGold = (akToCheck.GetItemCount(Gold001) * (PlayerRef.GetActorValue("GoldFindMod")/ 100.0)) as int
        akToCheck.AddItem(Gold001, BonusGold)
    endif
    float dropmult = (0.5 * luckMult)
	if (BetterLoot)
		dropmult *= 1.25
	elseif (PlayerRef.GetLevel() - akToCheck.GetLevel() >= 5)
		dropmult *= 0.8
	endif
	if (dropmult > 3.0)
		dropmult = 3.0
	endif
    if (Utility.RandomFloat(0, 100) <= dropmult)
        float grandchance = (5.0 * luckMult)
        if (RNDF() <= (grandchance * 0.01))
            item = XTDCrystals.GetAt(2)
        else
            item = XTDCrystals.GetAt(Utility.RandomInt(0, 1))
        endif
        akToCheck.AddItem(item, 1)
    endif
	if ((XTD_NoPotions.GetValue() as int) == 0)
		dropmult = (0.33 * luckMult)
		if (BetterLoot)
			dropmult *= 1.25
		elseif (PlayerRef.GetLevel() - akToCheck.GetLevel() >= 5)
			dropmult *= 0.8
		endif
		if (dropmult > 3.0)
			dropmult = 3.0
		endif
		if (Utility.RandomFloat(0, 100) <= dropmult)
			item = XTDPotions.GetAt(Utility.RandomInt(0, (XTDPotions.GetSize() - 1)))
			akToCheck.AddItem(item, 1)
		endif
		dropmult = (3.33 * luckMult)
		if (BetterLoot)
			dropmult *= 1.25
		elseif (PlayerRef.GetLevel() - akToCheck.GetLevel() >= 5)
			dropmult *= 0.8
		endif
		if (dropmult > 6.66)
			dropmult = 6.66
		endif
		if (Utility.RandomFloat(0, 100) <= dropmult)
			item = XTDPotionsMisc.GetAt(Utility.RandomInt(0, (XTDPotionsMisc.GetSize() - 1)))
			akToCheck.AddItem(item, 1)
		endif
	endif
	ExtraLoot(akToCheck)
	Clear()
Endfunction

Function ExtraLoot(Actor akActor)
	Float xChance = PlayerRef.GetActorValue("ExtraLootMod")
	If RNDF() <= xChance
		int i
		int j = Utility.RandomInt(1, 3)
		While i < j
			If RNDF() <= 33.0
				akActor.AddItem(WDExtraLoot, 1)
			Endif
			i +=1
		Endwhile
	Endif
Endfunction

Actor Property PlayerRef Auto
MiscObject Property xtdToken  Auto
MiscObject Property Gold001  Auto
XTD_BaseScript Property XTD Auto
XTD_Attributes Property Attributes Auto
FormList Property XTDCrystals  Auto 
FormList Property XTDPotions  Auto
FormList Property XTDPotionsMisc  Auto
SPELL Property XTD_AbHealPlayerHidden Auto
GlobalVariable Property XTDGV_MIF Auto
GlobalVariable Property XTDGV_TIF Auto
GlobalVariable Property XTDGV_Person Auto
GlobalVariable Property XTD_NoPotions  Auto
LeveledItem Property WDExtraLoot  Auto 