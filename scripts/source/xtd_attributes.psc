Scriptname XTD_Attributes extends Quest 
 
Bool Property WDReady Auto
Actor Property playerRef Auto

GlobalVariable[] Property AttributeInherentGlobal Auto
GlobalVariable[] Property AttributeBonusGlobal Auto

string[] Property AgiAV Auto
string[] Property DexAV Auto
string[] Property EndAV Auto
string[] Property IntAV Auto
string[] Property PerAV Auto
string[] Property StrAV Auto
string[] Property WisAV Auto

float[] Property AgiBonus Auto
float[] Property DexBonus Auto
float[] Property EndBonus Auto
float[] Property IntBonus Auto
float[] Property PerBonus Auto
float[] Property StrBonus Auto
float[] Property WisBonus Auto

Event OnInit()
	RegisterForSingleUpdate(1.0)
Endevent

Event OnUpdate()
	If (WDReady)
		InitArrays()
		Reload()
		SetAllAttributes()
	Else
		RegisterForSingleUpdate(1.0)
	Endif
Endevent

Event OnPlayerStatusUpdate(string eventName, string strArg, float numArg = 0.0, Form sender)
	If (strArg =="")
		SetAllAttributes()
	Elseif (strArg =="Agi")
		SetAgility()
	Elseif (strArg =="Dex")
		SetDexterity()
	Elseif (strArg =="End")
		SetEndurance()
	Elseif (strArg =="Int")
		SetIntellect()
	Elseif (strArg =="Per")
		SetPersonality()
	Elseif (strArg =="Str")
		SetStrength()
	Elseif (strArg =="Wis")
		SetWisdom()
	Endif
EndEvent

Function SetAllAttributes()
	SetAgility()
	SetDexterity()
	SetEndurance()
	SetIntellect()
	SetPersonality()
	SetStrength()
	SetWisdom()
Endfunction

Function SetAgility()
	SetAttribute(AgiAV, AgiBonus, 0.6, 0.5, 1.2, 1.3, 2) ;Crit,Mov Speed,Backstab,ARPen
Endfunction

Function SetDexterity()
	SetAttribute(DexAV, DexBonus, 2.0, 0.8, 1.0, 0.8, 3) ;Execution,PA Cost,PA Dmg,Phys Mitigation
Endfunction

Function SetEndurance()
	SetAttribute(EndAV, EndBonus, 2.4, 1.2, 0.9, 0.015, 1) ;Stamina regen,Carry,DT,%Armor
Endfunction

Function SetIntellect()
	SetAttribute(IntAV, IntBonus, 2.0, 0.3, 1.2, 1.7, 4) ;Spell DMG,Mps,Absorb,Magic XP
Endfunction

Function SetPersonality()
	SetAttribute(PerAV, PerBonus, 2.1, 1.2, 1.2, 0.7, 6) ;Gold,Temper Find,Magic Find,Extra Loot
Endfunction

Function SetStrength()
	SetAttribute(StrAV, StrBonus, 2.0, 0.015, 0.2, 1.2, 0) ;Overpower,DMG,Hps,Crit DMG
Endfunction

Function SetWisdom()
	SetAttribute(WisAV, WisBonus, 2.4, 1.3, 0.8, 1.0, 5) ;Mana regen,Mana cost,Magic mitigation,%All XP
Endfunction

Function SetAttribute(String[] AttributeAV, Float[] args, Float arg1, Float arg2, Float arg3, Float arg4, Int Index)
	float sum = GetModifier(GetTotalValue(Index) as Float)
	RefreshBonus(AttributeAV, args, True)
	args[0] = arg1 * sum
	args[1] = arg2 * sum
	args[2] = arg3 * sum
	args[3] = arg4 * sum
	RefreshBonus(AttributeAV, args)
Endfunction

Function RefreshBonus(string[] PlayerAV, float[] PlayerBonus, Bool bSubstract=False)
	int i
	While i < PlayerAV.length
		If (bSubstract)
			playerRef.ModAV(PlayerAV[i], -PlayerBonus[i])
		Else
			playerRef.ModAV(PlayerAV[i], PlayerBonus[i])
		Endif
		i += 1
	Endwhile
Endfunction

Float Function GetModifier(Float value)
	Return ((value * 18.0)/(playerRef.GetLevel() * 1.6 + 16.0))
Endfunction

int Function GetTotalValue(int index)
	Return ((AttributeInherentGlobal[index].GetValue() + AttributeBonusGlobal[index].GetValue()) as int) 
endfunction

Function Reload()
	RegisterForModEvent("PlayerStatusUpdate", "OnPlayerStatusUpdate")
endfunction

Function ResetOnEffectFinish(String AttributeName = "")
	SendModEvent("PlayerStatusUpdate",  AttributeName)
Endfunction

Function InitArrays()

	AgiBonus = new float[4]
	DexBonus = new float[4]
	EndBonus = new float[4]
	IntBonus = new float[4]
	PerBonus = new float[4]
	StrBonus = new float[4]
	WisBonus = new float[4]
	
	AgiAV = new string[4]
	DexAV = new string[4]
	EndAV = new string[4]
	IntAV = new string[4]
	PerAV = new string[4]
	StrAV = new string[4]
	WisAV = new string[4]

	AgiAV[0] = "CritChance"
	AgiAV[1] = "SpeedMult"
	AgiAV[2] = "Backstab"
	AgiAV[3] = "ArmorPenetration"
	
	DexAV[0] = "Execution"
	DexAV[1] = "PowerAttackDmgMod"
	DexAV[2] = "PowerAttackStaminaMod"
	DexAV[3] = "DmgMitigation"
	
	EndAV[0] = "StaminaRateMult"
	EndAV[1] = "CarryWeight"
	EndAV[2] = "DamageThreshold"
	EndAV[3] = "ArmorPerks"
	
	IntAV[0] = "DestructionPowerMod"
	IntAV[1] = "MpS"
	IntAV[2] = "AbsorbChance"
	IntAV[3] = "MagicXpMod"
	
	PerAV[0] = "GoldFindMod"
	PerAV[1] = "TemperedItemFindMod"
	PerAV[2] = "MagicItemFindMod"
	PerAV[3] = "ExtraLootMod"
	
	StrAV[0] = "Overpower"
	StrAV[1] = "attackDamageMult"
	StrAV[2] = "HpS"
	StrAV[3] = "CritDmgMod"
	
	WisAV[0] = "MagickaRateMult"
	WisAV[1] = "SpellCostDecrease"
	WisAV[2] = "MagicDmgReduce"
	WisAV[3] = "RestorationSkillAdvance"
	
Endfunction

