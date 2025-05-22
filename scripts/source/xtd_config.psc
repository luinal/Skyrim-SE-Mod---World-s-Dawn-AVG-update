Scriptname XTD_Config extends SKI_ConfigBase 

;************************* Unused AVs effects list ********************************
;**********************************************************************************
;	FavorActive				Magic Items Find modifier
;	FavorsPerDay			Tempered Items Find modifier
;	FavorsPerDayTimer		Extra Loot
;	WardDeflection			-% Spell cost
;	ShieldPerks				DMG mitigation
;	LastFlattered			Power attacks stamina
;	PickPocketSkillAdvance	Power attacks damage
;	VoicePoints				Crit Damage
;	DetectLifeRange		HpS
;	EnchantingSkillAdvance	MpS
;	NightEye				Overpower
;	SmithingSkillAdvance		Backstab
;	RestorationSkillAdvance	All skills XP
;	DestructionSkillAdvance	Magic skills XP
;	HeavyArmorSkillAdvance	Armor Penetration
;	LastBribedIntimidated	Magic damage mitigation
;	FavorPointsBonus		+Gold found
;	VoiceRate				Damage Threshold
;	OneHandedSkillAdvance	Counterattack
;	AlchemySkillAdvance	Execution
;**********************************************************************************
;**********************************************************************************

import XTDUtil

int function GetVersion()
	return 1
endFunction

int function GetInternalVersion()
	return 214
endFunction

string function GetVersionString()
	float f = GetInternalVersion()/100.0
	Return StringUtil.Substring(f as string, 0, 4)
endfunction

string function GetSKSEStatus()
	string s = "<font color='#5CFF57'>Ok</font>"
	if SKSE.GetScriptVersionRelease() < 48
		s = "<font color='#FF0000'>"+"$Outdated"+"</font>"
	endif
	Return s
endfunction

string function GetPapyrusUtilStatus()
	string s = "<font color='#5CFF57'>Ok</font>"
	if PapyrusUtil.GetVersion() < 33
		s = "<font color='#FF0000'>"+"$Outdated"+"</font>"
	endif
	Return s
endfunction

function InternalUpdate()
	if (GetInternalVersion() > internalVersion)
		internalVersion = GetInternalVersion()
		XTD.RegisterNames()
	endif
endfunction

event OnConfigInit()
	InitMasks()
	InitStrings()
	iWD				=	new int[32]
	flags           =   new int[4]
	xtdStatOIDs     =   new int[16]
	effectsdur      =   new int[3]
	fxmag			=   new float[3]
	fxmagnew		=   new float[3]
	fxmagstored		=   new float[3]
	mgefs           =   new MagicEffect[3]
	XTDCONSMENU     =   new string[4]
    
	flag            =   OPTION_FLAG_DISABLED
	flags[0]        =   OPTION_FLAG_DISABLED
	flags[1]        =   OPTION_FLAG_DISABLED
	flags[2]		=	OPTION_FLAG_DISABLED
	flags[3]		=	OPTION_FLAG_DISABLED
	
	Pages           =   SetStringArrays(0)
	xtdMENUs        =   SetStringArrays(1)
	XTDMIFMENU      =   SetStringArrays(2)
	XTDTEMPMENU     =   SetStringArrays(2)
	XTDMIAMENU      =   SetStringArrays(3)
	storedeffects	=   SetStringArrays(4)
	effects         =   SetStringArrays(5)

	XTDCONSMENU[0]  =   "$None"
	XTDCONSMENU[1]  =   XTDCrystals.GetAt(0).GetName()
	XTDCONSMENU[2]  =   XTDCrystals.GetAt(1).GetName()
	XTDCONSMENU[3]  =   XTDCrystals.GetAt(2).GetName()
    
	XTD.RegisterNames()
	XTD.CalculateOdds(PlayerRef)
	today = GameDaysPassed.GetValue() as int
	PlayerRef.AddPerk(XTDPerk_Cumulative)
	PlayerRef.AddSpell(XTD_AbHealPlayerHidden, false)
	XTD_AttributePoints = PlayerRef.GetLevel() * pointsPerLevel
	AddToLList(LItemApothecaryRecipesRare50, XTDPotions)
	AddToLList(LItemApothecaryIngredientsCommon75, XTDPotionsMisc)	
	RegisterForKey(keyAbsorb)
	RegisterForKey(keyAttMenu)
	RegisterForModEvent("XTDPlayerLevelUp", "OnPlayerLevelUpEx")
	RegisterForModEvent("PlayerStatusUpdate", "OnPlayerStatusUpdate")
	RegisterForModEvent("PlayerUseElixir", "OnPlayerUseElixir")
	RegisterForModEvent("ExtraPointsAdd", "OnExtraPointsAdd")
	Attributes.WDReady = True
	
endevent

function ReregisterModEvent()
	InitMasks()
	InitStrings()
	InternalUpdate()
	Attributes.Reload()
	RegisterForModEvent("XTDPlayerLevelUp", "OnPlayerLevelUpEx")
	RegisterForModEvent("PlayerUseElixir", "OnPlayerUseElixir")
	RegisterForModEvent("ExtraPointsAdd", "OnExtraPointsAdd")
	Debug.Trace("*** WORLD'S DAWN > Compatibility check: start ***")
	bool bWintermyst = (Game.GetFormFromFile(0x514CC, "Wintermyst - Enchantments of Skyrim.esp"))
	UsesWintermyst.SetValueInt(bWintermyst as int)
	if (Game.GetFormFromFile(0x200CA, "Corpse_Preparation.esp"))
		WDContainersBlacklist.AddForm(Game.GetFormFromFile(0x200CA, "Corpse_Preparation.esp"))
	endif
	Debug.Trace("*** WORLD'S DAWN > Compatibility check: done ***")
endfunction

Event OnPlayerLevelUpEx(string eventName, string strArg, float numArg, Form sender)
	XTD_AttributePoints = (PlayerRef.GetLevel() * pointsPerLevel) - APtsSpent
	SendModEvent("PlayerStatusUpdate")
endevent

Event OnPlayerUseElixir(string eventName, string strArg, float numArg = 1.0, Form sender)
	pElixirsUsed += numArg as int
	if (strArg == "AddPoint")
		XTD_AttributePoints += numArg as int
		APtsSpent -= numArg as int
	endif
endevent

Event OnExtraPointsAdd(string eventName, string strArg, float numArg = 1.0, Form sender)
	int i = numArg as int
	pElixirsUsed += i
	XTD_AttributePoints += i
	APtsSpent -= i
	If (StatsConfirm)
		VFX0.Play(PlayerRef,3)
		If (strArg == "")
			Debug.Notification("Awarded "+i+" attribute point(s).")
		Else
			Debug.Notification(strArg+" Awarded "+i+" attribute point(s).")
		Endif
	Endif
endevent

Event OnVersionUpdate(int a_version)
endevent

event OnPageReset(string a_page)
    if (a_page == "" || a_page == "$XTDSettings")
        SetCursorFillMode(TOP_TO_BOTTOM)
        AddHeaderOption("$XTDSettings")
		iWD[0] = AddToggleOption("<font color='#5CFF57'>"+"$XLEnable"+"</font>", bModActive)
        iWD[1] = AddMenuOption("$XLDropRate", XTDMIFMENU[iMIFMENU])
        iWD[2] = AddMenuOption("$XLTemperRate", XTDTEMPMENU[iTEMPMENU])
        iWD[3] = AddMenuOption("$XLRename", xtdMENUs[XTD.RenameIndex])
		iWD[4] = AddSliderOption("$XLRarityRate", augmentCap, "$XTDLimitValue")
        iWD[5] = AddSliderOption("$XTDTuneMIF", fScanRadius, "{0}")
        iWD[6] = AddSliderOption("$XTDTuneTIF", fScanInterval, "{1}")
        iWD[7] = AddToggleOption("$XTDChests", bScanChest)
		iWD[8] = AddToggleOption("$XTDVendors", bScanNPC)
		iWD[9] = AddToggleOption("$XTDNoPots", bNoPotions)
		AddHeaderOption("$XTDHotkeys")
        iWD[10] = AddKeyMapOption("$XTDAbsorbKey", keyAbsorb)
		iWD[11] = AddKeyMapOption("$XTDAttMenuKey", keyAttMenu)
		AddHeaderOption("")
		SetCursorPosition(1)
        AddHeaderOption("$XTDMisc")
		AddTextOption("$XTDSKSEVer", GetSKSEStatus(), flag)
		AddTextOption("$XTDPUVer", GetPapyrusUtilStatus(), flag)
        AddTextOption("$XTDModVer", GetVersionString(), flag)
        AddTextOption("$XTDArmor", XTD.ArmorsEnchanted, flag)
        AddTextOption("$XTDWeapon", XTD.WeaponsEnchanted, flag)
        AddTextOption("$WDTemper", XTD.ItemsTempered, flag)
        AddTextOption("$WDNPCCounter", XTD.NPCScanned, flag)
        AddTextOption("$WDChestCounter", XTD.ChestScanned, flag)
		AddTextOption("$XTDElixirUsed", pElixirsUsed, flag)
		AddTextOption("$XTDRefundsMade", refundsMade, flag)
        AddTextOption("$XTDABSORB#", totalAbsorbs, flag)
        AddTextOption("$XTDAUGMENT#", totalAugments, flag)
		AddTextOption("$AUGFAIL", failedAugments, flag)
        AddTextOption("$XTDLegend", "", flag)
        AddTextOption("", XTD.LastLegendary, flag)
        AddHeaderOption("")
		iWD[31] = AddInputOption("", "Debug")
    elseif (a_page == "$XTD_CharSheet")
        SetCursorFillMode(TOP_TO_BOTTOM)
        AddHeaderOption("$XTDStatistic")
		AddTextOption("$XTDHPRATE", ConvertAVToText(PlayerRef, "HealRateMult", nativeOffset = -100.0), flag)
        AddTextOption("$XTDMPRATE", ConvertAVToText(PlayerRef, "MagickaRateMult", nativeOffset = -100.0), flag)
        AddTextOption("$XTDSPRATE", ConvertAVToText(PlayerRef, "StaminaRateMult", nativeOffset = -100.0), flag)
        AddTextOption("$XTDRESDIS", ConvertAVToText(PlayerRef, "DiseaseResist"), flag)
        AddTextOption("$XTDRESFIRE", ConvertAVToText(PlayerRef, "FireResist"), flag)
        AddTextOption("$XTDRESFROST", ConvertAVToText(PlayerRef, "FrostResist"), flag)
        AddTextOption("$XTDRESSHOCK", ConvertAVToText(PlayerRef, "ElectricResist"), flag)
        AddTextOption("$XTDRESPOIS", ConvertAVToText(PlayerRef, "PoisonResist"), flag)
        AddTextOption("$XTDRESMAGIC", ConvertAVToText(PlayerRef, "MagicResist"), flag)
        AddTextOption("$XTDALTMOD", ConvertAVToText(PlayerRef, "AlterationMod", "-"), flag)
        AddTextOption("$XTDALTPOW", ConvertAVToText(PlayerRef, "AlterationPowerMod"), flag)
        AddTextOption("$XTDCONJMOD", ConvertAVToText(PlayerRef, "ConjurationMod", "-"), flag)
        AddTextOption("$XTDCONJPOW", ConvertAVToText(PlayerRef, "ConjurationPowerMod"), flag)
        AddTextOption("$XTDDESTMOD", ConvertAVToText(PlayerRef, "DestructionMod", "-"), flag)
        AddTextOption("$XTDDESTPOW", ConvertAVToText(PlayerRef, "DestructionPowerMod"), flag)
        AddTextOption("$XTDRESTMOD", ConvertAVToText(PlayerRef, "RestorationMod", "-"), flag)
        AddTextOption("$XTDRESTPOW", ConvertAVToText(PlayerRef, "RestorationPowerMod"), flag)
        AddTextOption("$XTDILUSMOD", ConvertAVToText(PlayerRef, "IllusionMod", "-"), flag)
        AddTextOption("$XTDILUSPOW", ConvertAVToText(PlayerRef, "IllusionPowerMod"), flag)
        AddTextOption("$XTDMAGCOST", ConvertAVToText(PlayerRef, "SpellCostDecrease", "-"), flag)
        AddTextOption("$XTDALCHMOD", ConvertAVToText(PlayerRef, "AlchemyMod"), flag)
        AddTextOption("$XTDALCHPOW", ConvertAVToText(PlayerRef, "AlchemyPowerMod"), flag)
        AddTextOption("$XTDABSORB", ConvertAVToText(PlayerRef, "AbsorbChance"), flag)
        AddTextOption("$XTDLUCKMOD", ChanceToString(PlayerRef, "MagicItemFindMod", XTDGV_MIF.GetValue(), prefix = ""), flag)
        AddTextOption("$XTDTEMPMOD", ChanceToString(PlayerRef, "TemperedItemFindMod", XTDGV_TIF.GetValue(), prefix = ""), flag)
        AddTextOption("$XTDAUGMMOD", ConvertAVToText(PlayerRef, "ExtraLootMod", prefix = ""), flag)
		AddTextOption("$XTDGOLDMOD", ConvertAVToText(PlayerRef, "GoldFindMod"), flag)
		AddTextOption("$XTDBARTER", ConvertAVToText(PlayerRef, "SpeechcraftMod"), flag)
        AddHeaderOption("")
        SetCursorPosition(1)
        AddHeaderOption("$XTDStatistic")
        AddTextOption("$XTDHPS", ConvertAVToText(PlayerRef, "HpS", suffix = ""), flag)
        AddTextOption("$XTDMPS", ConvertAVToText(PlayerRef, "MpS", suffix = ""), flag)
        AddTextOption("$XTDMOVESPD", ConvertAVToText(PlayerRef, "SpeedMult", nativeOffset = -100.0), flag)
        AddTextOption("$XTDATCKSPD", ConvertAVToText(PlayerRef, "DmgMitigation"), flag)
        AddTextOption("$XTDMAGMIT", ConvertAVToText(PlayerRef, "MagicDmgReduce"), flag)
        AddTextOption("$XTDBLOCK", ConvertAVToText(PlayerRef, "BlockMod"), flag)
        AddTextOption("$XTDCRITICAL", ConvertAVToText(PlayerRef, "CritChance"), flag)
        AddTextOption("$XTDCRITDMG", ConvertAVToText(PlayerRef, "CritDmgMod"), flag)
        AddTextOption("$XTD1HNDPOW", ConvertAVToText(PlayerRef, "OnehandedMod"), flag)
        AddTextOption("$XTD2HNDPOW", ConvertAVToText(PlayerRef, "TwohandedMod"), flag)
        AddTextOption("$XTDARCPOW", ConvertAVToText(PlayerRef, "MarksmanMod"), flag)
        AddTextOption("$XTDPHYSPOW", ConvertAVToText(PlayerRef, "AttackDamageMult", AVMult=100.0, nativeOffset=-1.0), flag)
        AddTextOption("$XTDBACKSTB", ConvertAVToText(PlayerRef, "Backstab"), flag)
		AddTextOption("$XTDPACOST", ConvertAVToText(PlayerRef, "PowerAttackStaminaMod", prefix="-"), flag)
		AddTextOption("$XTDPADAMG", ConvertAVToText(PlayerRef, "PowerAttackDmgMod"), flag) 
        AddTextOption("$XTDSHOUTRCV", ConvertAVToText(PlayerRef, "ShoutRecoveryMult", AVMult=100.0, bDecimal=TRUE), flag)
        AddTextOption("$XTDLOCKMOD", ConvertAVToText(PlayerRef, "LockpickingMod"), flag)
        AddTextOption("$XTDSKILADV", ConvertAVToText(PlayerRef, "AllXpMod"), flag)
        AddTextOption("$XTDPICKPOCK", ConvertAVToText(PlayerRef, "PickpocketMod"), flag)
        AddTextOption("$XTDREFLECT", ConvertAVToText(PlayerRef, "ReflectDamage"), flag)
        AddTextOption("$XTDTEMPER", ConvertAVToText(PlayerRef, "SmithingMod"), flag)
        AddTextOption("$XTDSNEAK", ConvertAVToText(PlayerRef, "SneakMod"), flag)
        AddTextOption("$XTDH2H", ConvertAVToText(PlayerRef, "UnarmedDamage", prefix="", suffix=""), flag)
        AddTextOption("$XTDDAMTHRS", ConvertAVToText(PlayerRef, "DamageThreshold", "", ""), flag)
        AddTextOption("$XTDOVER", ConvertAVToText(PlayerRef, "Overpower"), flag)
		AddTextOption("$XTDCA", ConvertAVToText(PlayerRef, "Counterattack", prefix = ""), flag)
		AddTextOption("$XTDEXEC", ConvertAVToText(PlayerRef, "Execution"), flag)
		AddTextOption("$WDARPen", ConvertAVToText(PlayerRef, "ArmorPenetration"), flag)
        AddHeaderOption("")
    elseif (a_page == "$XTD_Augment")
		InitMasks()
		SetCursorFillMode(TOP_TO_BOTTOM)
        AddHeaderOption("")
		GemCounter()
        iWD[12] = AddMenuOption("$XTDWORN", XTDAUGMMENU[iAUGMMENU])
		iWD[13] = AddMenuOption("$XTDCONS", XTDCONSMENU[iCONSMENU])
		AddTextOption("$AUGTODAY", todayAugments, flag)
		AddTextOption("$WDSUCCESS", F2S(GetSuccessChance())+"%", flag)
        AddHeaderOption("$XTDeffects")
		AddTextOption(effects[0], F2S(fxmag[0]), flag)
		AddTextOption(effects[1], F2S(fxmag[1]), flag)
		AddTextOption(effects[2], F2S(fxmag[2]), flag)
		AddHeaderOption("$XTDASENCH")
		AddTextOption(storedeffects[0], F2S(fxmagstored[0]), flag)
        AddTextOption(storedeffects[1], F2S(fxmagstored[1]), flag)
        AddTextOption(storedeffects[2], F2S(fxmagstored[2]), flag)
		AddHeaderOption("")
		SetCursorPosition(1)
		AddHeaderOption("$XTDOptions")
		iWD[14] = AddTextOption("", "$XTDAUGeffects", flags[1])
		iWD[15] = AddTextOption("", "$XTDSTORE", flags[2])
		iWD[16] = AddTextOption("", "$XTDRESTORE", flags[3])
		iWD[17] = AddInputOption("", "$XTDRename", flags[0])
		AddHeaderOption("$XTDAUGeffects")
		AddTextOption(effects[0], F2S(fxmagnew[0]), flag)	
		AddTextOption(effects[1], F2S(fxmagnew[1]), flag)	
		AddTextOption(effects[2], F2S(fxmagnew[2]), flag)	
		AddHeaderOption("")
    elseif (a_page == "$XTDCustomStats")
		string plus
		if (XTD_AttributePoints > 0)
			plus = "<font color='#5CFF57'>+</font>"
		endif
        SetTitleText("Available Points: "+XTD_AttributePoints)
        SetCursorFillMode(TOP_TO_BOTTOM)
        AddHeaderOption("")
        xtdStatOIDs[7] = AddTextOption("$XTDAttributes", "", flag)
        AddEmptyOption()
        xtdStatOIDs[0] = AddTextOption("$XTDStrength", plus)
        xtdStatOIDs[1] = AddTextOption("$XTDEndurance", plus)
        xtdStatOIDs[2] = AddTextOption("$XTDAgility", plus)
        xtdStatOIDs[3] = AddTextOption("$XTDDexterity", plus)
        xtdStatOIDs[4] = AddTextOption("$XTDIntellect", plus)
        xtdStatOIDs[5] = AddTextOption("$XTDWisdom", plus)
        xtdStatOIDs[6] = AddTextOption("$XTDPerson", plus)
        AddHeaderOption("")
		iWD[19] = AddToggleOption("$XTDConfirm", StatsConfirm)
        SetCursorPosition(1)
        AddHeaderOption("")
        xtdStatOIDs[8] = AddTextOption("$XTDBaseValue", "$XTDBonus", flag)
        AddEmptyOption()
        xtdStatOIDs[9] = AddTextOption(PrintBaseAndBonus(0), PrintTotal(0), flag)
        xtdStatOIDs[10] = AddTextOption(PrintBaseAndBonus(1), PrintTotal(1), flag)
        xtdStatOIDs[11] = AddTextOption(PrintBaseAndBonus(2), PrintTotal(2), flag)
        xtdStatOIDs[12] = AddTextOption(PrintBaseAndBonus(3), PrintTotal(3), flag)
        xtdStatOIDs[13] = AddTextOption(PrintBaseAndBonus(4), PrintTotal(4), flag)
        xtdStatOIDs[14] = AddTextOption(PrintBaseAndBonus(5), PrintTotal(5), flag)
        xtdStatOIDs[15] = AddTextOption(PrintBaseAndBonus(6), PrintTotal(6), flag)
        AddHeaderOption("")
		iWD[18] = AddTextOption("", "$XTDRefund")
    endIf
endevent

event OnConfigClose()
    iAUGMMENU = 0
    iCONSMENU = 0
    ClearAll(false)
endEvent

event OnOptionInputOpen(int option)
    if (option == iWD[17])
        SetInputDialogStartText(XTDAUGMMENU[iAUGMMENU])
	elseif (option == iWD[31])
		SetInputDialogStartText("Enter command")
    endIf
endEvent


event OnOptionInputAccept(int option, string name)
    if (option == iWD[17])
		int slot
		int handslot
		if (items[iAUGMMENU].GetType() == 26) ;armor
			slot = masks[iAUGMMENU]
		elseif (items[iAUGMMENU].GetType() == 41)
			handslot = 1
			if ((items[iAUGMMENU] as Weapon) == PlayerRef.GetEquippedWeapon(true))
				handslot = 0			
			endif
		endif
		if (name && name != " ")
			WornObject.SetDisplayName(PlayerRef, handslot, slot, name, true)
		endif
		ForcePageReset()
	elseif (option == iWD[31])
		if (name && name != " ")
			WDDebug(name)
		endif
    endIf
endEvent

event OnOptionSelect(int option)
		if (option == iWD[0])
			bModActive = !bModActive
			SetToggleOptionValue(option, bModActive)
		elseif (option == iWD[7])
			bScanChest = !bScanChest
			SetToggleOptionValue(option, bScanChest)
		elseif (option == iWD[8])
			bScanNPC = !bScanNPC
			SetToggleOptionValue(option, bScanNPC)
		elseif (option == iWD[9])
			bNoPotions = !bNoPotions
			SetToggleOptionValue(option, bNoPotions)
			XTD_NoPotions.SetValueInt(bNoPotions as int)
		elseif (option == iWD[14])
			AugmentEnchantment(iAUGMMENU)
		elseif (option == iWD[15])
			StoreEnchantment(iAUGMMENU)
		elseif (option == iWD[16])
			RestoreEnchantment(iAUGMMENU)
		elseif (option == iWD[18])
			RefundAttributePoints()
		elseif (option == iWD[19])
			StatsConfirm = !StatsConfirm
			SetToggleOptionValue(option, StatsConfirm)
		elseif (option == xtdStatOIDs[0])
			IncrementAttribute("Strength", 0, StatsConfirm)
		elseif (option == xtdStatOIDs[1])
			IncrementAttribute("Endurance", 1, StatsConfirm)
		elseif (option == xtdStatOIDs[2])
			IncrementAttribute("Agility", 2, StatsConfirm)
		elseif (option == xtdStatOIDs[3])
			IncrementAttribute("Dexterity", 3, StatsConfirm)
		elseif (option == xtdStatOIDs[4])
			IncrementAttribute("Intellect", 4, StatsConfirm)
		elseif (option == xtdStatOIDs[5])
			IncrementAttribute("Wisdom", 5, StatsConfirm)
		elseif (option == xtdStatOIDs[6])
			IncrementAttribute("Personality", 6, StatsConfirm)
		Endif
endEvent

event OnOptionSliderOpen(int option)
	if (option == iWD[4])
        SetSliderDialogStartValue(augmentCap)
        SetSliderDialogDefaultValue(3.0)
        SetSliderDialogRange(1.0, 5.0)
        SetSliderDialogInterval(1.0)
    elseif (option == iWD[5])
        SetSliderDialogStartValue(fScanRadius)
        SetSliderDialogDefaultValue(3000.0)
        SetSliderDialogRange(250.0, 10000.0)
        SetSliderDialogInterval(50.0)
    elseif (option == iWD[6])
        SetSliderDialogStartValue(fScanInterval)
        SetSliderDialogDefaultValue(2.0)
        SetSliderDialogRange(1.0, 10.0)
        SetSliderDialogInterval(0.1)
    endif
endevent

event OnOptionSliderAccept(int option, float value)
	if (option == iWD[4])
        augmentCap = value as int
        SetSliderOptionValue(option, augmentCap, "$XTDLimitValue")
	elseif (option == iWD[5])
        fScanRadius = value
        SetSliderOptionValue(option, fScanRadius, "{0}")
    elseif (option == iWD[6])
        fScanInterval = value
        SetSliderOptionValue(option, fScanInterval, "{1}")
    endif
endevent

event OnOptionMenuOpen(int option)
    if (option == iWD[1])
        SetMenuDialogOptions(XTDMIFMENU)
        SetMenuDialogStartIndex(iMIFMENU)
        SetMenuDialogDefaultIndex(1)
    elseif (option == iWD[2])
        SetMenuDialogOptions(XTDTEMPMENU)
        SetMenuDialogStartIndex(iTEMPMENU)
        SetMenuDialogDefaultIndex(1)
    elseif (option == iWD[3])
        SetMenuDialogOptions(xtdMENUs)
        SetMenuDialogStartIndex(XTD.RenameIndex)
        SetMenuDialogDefaultIndex(0)
    elseif (option == iWD[12])
        SetMenuDialogOptions(XTDAUGMMENU)
        SetMenuDialogStartIndex(iAUGMMENU)
        SetMenuDialogDefaultIndex(0)
    elseif (option == iWD[13])
        SetMenuDialogOptions(XTDCONSMENU)
        SetMenuDialogStartIndex(iCONSMENU)
        SetMenuDialogDefaultIndex(0)
    endIf
endEvent

event OnOptionMenuAccept(int option, int index)
    if (option == iWD[1])
        iMIFMENU = index
        SetMenuOptionValue(option, XTDMIFMENU[iMIFMENU])
        (XTD_CustomAttributes.GetAt(7) as GlobalVariable).SetValue(5.0 + iMIFMENU * 10.0)
        XTD.CalculateOdds(PlayerRef)
    elseif (option == iWD[2])
        iTEMPMENU = index
        SetMenuOptionValue(option, XTDTEMPMENU[iTEMPMENU])
        (XTD_CustomAttributes.GetAt(8) as GlobalVariable).SetValue(5.0 + iTEMPMENU * 10.0)
        XTD.CalculateOdds(PlayerRef)
    elseif (option == iWD[3])
        XTD.RenameIndex = index
        SetMenuOptionValue(option, xtdMENUs[XTD.RenameIndex])
    elseif (option == iWD[12])
        iAUGMMENU = index
        SetMenuOptionValue(option, XTDAUGMMENU[iAUGMMENU])
        GetWornFromList(iAUGMMENU)
    elseif (option == iWD[13])
        iCONSMENU = index
        SetMenuOptionValue(option, XTDCONSMENU[iCONSMENU])
        GetWornFromList(iAUGMMENU)
    endIf
endEvent

event OnOptionKeyMapChange(int option, int keyCode, string conflictControl, string conflictName)
        bool continue = true
        if (conflictControl != "")
            string msg
            if (conflictName != "")
                msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n(" + conflictName + ")\n\nAre you sure you want to continue?"
            else
                msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n\nAre you sure you want to continue?"
            endIf

            continue = ShowMessage(msg, true, "$Yes", "$No")
        endIf
    if (option == iWD[10])
        if (continue)
			UnregisterForKey(keyAbsorb)
			keyAbsorb = keyCode
			RegisterForKey(keyAbsorb)
            SetKeymapOptionValue(option, keyAbsorb)
        endIf
	elseif (option == iWD[11])
        if (continue)
			UnregisterForKey(keyAttMenu)
			keyAttMenu = keyCode
			RegisterForKey(keyAttMenu)
            SetKeymapOptionValue(option, keyAttMenu)
        endIf
    endIf
endEvent

Event OnMenuClose(String MenuName)
	If MenuName == "ContainerMenu"
		Dismantle(absINV as ObjectReference)
		Utility.WaitMenuMode(0.1)
		absINV.RemoveAllItems(PlayerRef, abRemoveQuestItems = true)
		busy = FALSE
		UnregisterForMenu(MenuName)
	EndIf
EndEvent

Event OnKeyUp(Int KeyCode, Float HoldTime)
    if (!Utility.IsInMenuMode() && Holdtime >= 0.1)
		int i
		if KeyCode == keyAbsorb && !busy
			if (PlayerRef.IsInCombat())
				XTDAbsorbConfirmMsg.Show()
			else
				busy = TRUE
				RegisterForMenu("ContainerMenu")
				absINV.OpenInventory(true)
			endif
		elseif KeyCode == keyAttMenu
			While i != 7
			i = XTDAttMsg.Show(XTD_AttributePoints,Attributes.GetTotalValue(0),Attributes.GetTotalValue(1),Attributes.GetTotalValue(2),Attributes.GetTotalValue(3),\
			Attributes.GetTotalValue(4),Attributes.GetTotalValue(5),Attributes.GetTotalValue(6))
			string s
			if (i == 0)
				s = "Strength"
			elseif (i == 1)
				s = "Endurance"
			elseif (i == 2)
				s = "Agility"
			elseif (i == 3)
				s = "Dexterity"
			elseif (i == 4)
				s = "Intellect"
			elseif (i == 5)
				s = "Wisdom"
			elseif (i == 6)
				s = "Personality"
			endif
			if (i < 7)
				IncrementAttribute(s, i)
			endif
			Endwhile
		endif
    EndIf
EndEvent

event OnOptionHighlight(int a_option)
		if (a_option == iWD[0])
			SetInfoText("$XLTooltip0")
		elseif (a_option == iWD[1])
			SetInfoText("$XLTooltip1")
		elseif (a_option == iWD[2])
			SetInfoText("$XLTooltip2")
		elseif (a_option == iWD[4])
			SetInfoText("$XLTooltip3")
		elseif (a_option == iWD[5])
			SetInfoText("$XLTooltip8")
		elseif (a_option == iWD[6])
			SetInfoText("$XLTooltip7")
		elseif (a_option == iWD[7])
			SetInfoText("$XLTooltip15")
		elseif (a_option == iWD[8])
			SetInfoText("$XLTooltip14")
		elseif (a_option == iWD[9])
			SetInfoText("$XLTooltip13")
		elseif (a_option == iWD[14])
			SetInfoText("$XLTooltip4")
		elseif (a_option == iWD[15])
			SetInfoText("$XLTooltip9")
		elseif (a_option == iWD[16])
			SetInfoText("$XLTooltip10")
		elseif (a_option == iWD[18])
			SetInfoText("$XTDRefundTip2")
		elseif (a_option == iWD[19])
			SetInfoText("$XTDConfirmTip")
		elseif (a_option == xtdStatOIDs[0])
			DynamicTooltip(0)
		elseif (a_option == xtdStatOIDs[1])
			DynamicTooltip(1)
		elseif (a_option == xtdStatOIDs[2])
			DynamicTooltip(2)
		elseif (a_option == xtdStatOIDs[3])
			DynamicTooltip(3)
		elseif (a_option == xtdStatOIDs[4])
			DynamicTooltip(4)
		elseif (a_option == xtdStatOIDs[5])
			DynamicTooltip(5)
		elseif (a_option == xtdStatOIDs[6])
			DynamicTooltip(6)
		endif
endevent

;*****************************************************************
;*************************** Functions ***************************
;*****************************************************************


function InitStrings()
    XTDStrings = Utility.CreateStringArray(6)
    XTDStrings[0] = "$XTDSettings,$XTDCustomStats,$XTD_Augment,$XTD_CharSheet"
    XTDStrings[1] = "$None,$byRarity,$RPG"
    XTDStrings[2] = "$XTDLOW,$XTDNORM,$XTDHIGH"
    XTDStrings[3] = "$XTDDEF,$XTDSTRONG,$XTDBEST"
	XTDStrings[4] = "$None,$None,$None"
    XTDStrings[5] = "$None,$None,$None"
endfunction

function InitMasks()
	CanAugmentToday()
	AssignMasksAndNames(PlayerRef)
endfunction

Function GemCounter()
	int i
	While i < 3
		XTDCONSMENU[i+1] = XTDCrystals.GetAt(i).GetName() + " (" + PlayerRef.GetItemCount(XTDCrystals.GetAt(i)) as string + ")"
		i += 1
	Endwhile
Endfunction

Float Function GetSuccessChance()
	Float f
	f = 100 - (20.0 + (Attributes.GetTotalValue(6) * -0.1))
	if f > 97.0
		f = 97.0
	endif
	Return f
Endfunction

; ************************************* Augmenting *************************************

function AssignMasksAndNames(Actor akTarget)
	masks = Utility.CreateIntArray(30)
	items = Utility.CreateFormArray(30)
	int index = 1
	int slotsChecked
	string namesMerged = "$None"
	slotsChecked += 0x00100000
	slotsChecked += 0x00200000
	slotsChecked += 0x80000000
	int thisSlot = 0x01
	while (thisSlot < 0x80000000)
        if (Math.LogicalAnd(slotsChecked, thisSlot) != thisSlot)
            Armor thisArmor = akTarget.GetWornForm(thisSlot) as Armor
            if (thisArmor && thisArmor.IsPlayable())
				masks[index] = thisSlot
				items[index] = thisArmor
				namesMerged = MergeString(akTarget, thisArmor, 0, thisSlot, namesMerged)
				index += 1
				slotsChecked += thisArmor.GetSlotMask()
			else
				slotsChecked += thisSlot
			endif
		endif
		thisSlot *= 2
	endWhile
	Weapon thisWeapon = akTarget.GetEquippedWeapon(true)
	debugConsole("Checking weapon slot #1 (left hand) "+thisWeapon)
	if (thisWeapon)
		items[index] = thisWeapon
		namesMerged = MergeString(akTarget, thisWeapon, 0, 0, namesMerged)
		thisWeapon = None
		index += 1
	endif
	thisWeapon = akTarget.GetEquippedWeapon()
	debugConsole("Checking weapon slot #2 (right hand) "+thisWeapon)
	if (thisWeapon)
		items[index] = thisWeapon
		namesMerged = MergeString(akTarget, thisWeapon, 1, 0, namesMerged)
	endif
	XTDAUGMMENU = (StringUtil.Split(namesMerged, "."))
	DebugConsole(namesMerged)
endfunction

string function MergeString(Actor akTarget, Form Item, int weapslot, int armorslot, string source)
	string merged = source
	string s = WornObject.GetDisplayName(akTarget, weapslot, armorslot)
	if (s)
		merged = source + "." + s		
	else
		if (armorslot == 0)
			merged = source + "." + (Item as Weapon).GetName()
		else
			merged = source + "." + (Item as Armor).GetName()
		endif
	endif
	Return merged
endfunction

function GetWornFromList(int index)
	if (index == 0)
		ClearAll()
	else
		enchantment ench
		DisableFlags(FALSE)
		if (items[index].GetType() == 26) ;armor
			ench = (WornObject.GetEnchantment(PlayerRef, 0, masks[index]))
			if (ench)
				EnableFlag(0)
				if (iCONSMENU > 0 && iAUGMMENU > 0 && PlayerRef.GetItemCount(XTDCrystals.GetAt(iCONSMENU - 1)) > 0 && CanAugmentToday() && !WDBlacklist_e.HasForm(ench as Form))
					EnableFlag(1)
				else
					EnableFlag(1,FALSE)
				endif
				if (PlayerRef.GetItemCount(XTDCrystals.GetAt(2)) > 0)
					EnableFlag(2)
				else
					EnableFlag(2,FALSE)
				endif
				DisplayEnchantValues(ench)
				DisplayAugmentValues(iCONSMENU)
			elseif (!(items[index] as Armor).GetEnchantment() && storedEnch && IsForArmor)
				ClearDisplayValues()
				EnableFlag(3)
			else
				ClearDisplayValues()
				DisableFlags()
			endif
		elseif (items[index].GetType() == 41) ;weapon
			int i
			if ((items[index] as Weapon) == PlayerRef.GetEquippedWeapon())
				i = 1	
			endif
			ench = (WornObject.GetEnchantment(PlayerRef, i, 0))
			if (ench)
				EnableFlag(0)
				if (iCONSMENU > 0 && iAUGMMENU > 0 && PlayerRef.GetItemCount(XTDCrystals.GetAt(iCONSMENU - 1)) > 0 && CanAugmentToday() && !WDBlacklist_e.HasForm(ench as Form))
					EnableFlag(1)
				else
					EnableFlag(1,FALSE)
				endif
				if (PlayerRef.GetItemCount(XTDCrystals.GetAt(2)) > 0)
					EnableFlag(2)
				else
					EnableFlag(2,FALSE)
				endif
				DisplayEnchantValues(ench)
				DisplayAugmentValues(iCONSMENU)
			elseif (!(items[index] as Weapon).GetEnchantment() && storedEnch && !IsForArmor)
				EnableFlag(3)
				ClearDisplayValues()
			else
				ClearDisplayValues()
				DisableFlags()	
			endif
		endif
		ForcePageReset()
	endif
endfunction

bool function CanAugmentToday()
	if (GameDaysPassed.GetValue() as int > today)
		today = GameDaysPassed.GetValue() as int
		todayAugments = 0
		WDBlacklist_e.Revert()
		Return TRUE
	else
		if (todayAugments < augmentCap)
			Return TRUE
		else
			Return FALSE
		endif
	endif
endfunction

Function DisplayEnchantValues(enchantment e)
    int i
    While i < 3
        mgefs[i] = e.GetNthEffectMagicEffect(i)
        if mgefs[i]
            effects[i] = mgefs[i].GetName()
            fxmag[i] = e.GetNthEffectMagnitude(i)
            effectsdur[i] = e.GetNthEffectDuration(i)
        else
            effects[i] = "$None"
            fxmag[i] = 0
            effectsdur[i] = 0
        endif
        i += 1
    Endwhile
endfunction

Function DisplayStoredValues(enchantment e)
    int i
    While i < 3
        if (e.GetNthEffectMagicEffect(i))
            storedeffects[i] = e.GetNthEffectMagicEffect(i).GetName()
            fxmagstored[i] = e.GetNthEffectMagnitude(i)
        else
            storedeffects[i] = "$None"
            fxmagstored[i] = 0
        endif
        i += 1
    Endwhile
endfunction

Function DisplayAugmentValues(int index)
    int i
    if (index == 0)
        While i < 3
            fxmagnew[i] = 0
            i += 1
        endWhile
    else
        While i < 3
            If mgefs[i]
                if mgefs[i].HasKeyword(MagicEnchNoMagnitude) || fxmag[i] == 0.0
                    fxmagnew[i] = fxmag[i]
                else
                    fxmagnew[i] = (fxmag[i] + (fxmag[i] * (index * 0.1)))
                endif
				if (mgefs[i].HasKeyword(XTDRounded))
					fxmagnew[i] = Math.Floor(fxmagnew[i])
				endif
            else
                fxmagnew[i] = fxmag[i]
            endif
            i += 1
        endWhile
    endif
endfunction

Function ClearDisplayValues()
    int i
    While i < 3
        mgefs[i] = none
        effects[i] = "$None"
        fxmag[i] = 0
        effectsdur[i] = 0
        fxmagnew[i] = 0
        i += 1
    Endwhile
endfunction

Function AugmentEnchantment(int index)
	form f	
	int i
	int num
	int slot
	int handslot
	int ai
	int j = items[index].GetType()
	if (j == 26) ;armor
		f = PlayerRef.GetWornForm(masks[index])
		slot = masks[index]
	elseif (j == 41)
		handslot = 1
		bool lefthanded
		if ((items[index] as Weapon) == PlayerRef.GetEquippedWeapon(true))
			lefthanded = TRUE
			handslot = 0
		endif
		f = PlayerRef.GetEquippedWeapon(lefthanded)
		fMaxCharge = WornObject.GetItemMaxCharge(PlayerRef, handslot, 0)
	endif
    float fChargeBoost = fMaxCharge * (1.0 + iCONSMENU * 0.1)
    Enchantment ench = WornObject.GetEnchantment(PlayerRef, handslot, slot)
	WDBlacklist_e.AddForm(WornObject.GetEnchantment(PlayerRef, handslot, slot) as Form)
    num = ench.GetNumEffects()
	Int[] aoes = Utility.CreateIntArray(num)
	Int[] durs = Utility.CreateIntArray(num)
	Float[] vals = Utility.CreateFloatArray(num)
	MagicEffect[] mags
	If num == 1
		mags = new MagicEffect[1]
	Elseif num == 2
		mags = new MagicEffect[2]
	Elseif num == 3
		mags = new MagicEffect[3]
	Endif
	float jinx = 20.0 + (Attributes.GetTotalValue(6) * -0.1)
	if (jinx <= 0.0)
		jinx = 3.0
	endif
	if (Utility.RandomFloat(0, 100) >= jinx)
		ai = 1
		if (iCONSMENU == 0)
			While i < num
				vals[i] = 0
				i += 1
			endWhile
		else
			While i < num
				durs[i] = ench.GetNthEffectDuration(i)
				mags[i] = ench.GetNthEffectMagicEffect(i)
				If mags[i]
					if mags[i].HasKeyword(MagicEnchNoMagnitude) || fxmag[i] == 0.0
						vals[i] = fxmag[i]
					else
						vals[i] = (fxmag[i] + (fxmag[i] * (iCONSMENU * 0.1)))
						if (mags[i].HasKeyword(XTDRounded))
							vals[i] = Math.Floor(vals[i])
						endif
					endif
				else
					vals[i] = fxmag[i]
				endif
				i += 1
			endWhile
		endif
		WornObject.SetEnchantment(PlayerRef, handslot, slot, None, 0.0)
		WornObject.CreateEnchantment(PlayerRef, handslot, slot, fChargeBoost, mags, vals, aoes, durs)
		WDBlacklist_e.AddForm(WornObject.GetEnchantment(PlayerRef, handslot, slot) as Form)
	else
		failedAugments += 1
		XTDMsg_FA.Show()
	endif
	absStorageRef.RemoveAllItems()
	PlayerRef.RemoveItem(f, 1, true, absStorageRef)
	absStorageRef.RemoveAllItems(PlayerRef)
	if (ConsumeMats)
		PlayerRef.RemoveItem(XTDCrystals.GetAt(iCONSMENU - 1))
	endif
    XTD_SFX[ai].Play(PlayerRef)
    totalAugments += 1
    curAugments += 1
    if curAugments >= accumAugments
        accumAugments *= 2
        Game.IncrementSkill("Enchanting")
    endif
	todayAugments += 1
	if (todayAugments >= augmentCap)
		XTDMsg_104.Show()
	endif
    ClearAll()
Endfunction

Function AbsorbEnchantment(Actor akActor, int index)

Endfunction

function StoreEnchantment(int index)
	bool continue = ShowMessage("$XTDASSIMMSG")
	if (continue)
		int j = items[index].GetType()
		if (j == 26) ;armor
			IsForArmor = TRUE
			storedEnch = WornObject.GetEnchantment(PlayerRef, 0, masks[index])
			fStoredCharge = 0.0
			PlayerRef.RemoveItem(PlayerRef.GetWornForm(masks[index]), abSilent = true)
		elseif (j == 41)
			int i
			bool lefhanded
			if ((items[index] as Weapon) == PlayerRef.GetEquippedWeapon())
				i = 1
			else
				lefhanded = TRUE
			endif
			IsForArmor = FALSE
			storedEnch = WornObject.GetEnchantment(PlayerRef, i, 0)
			fStoredCharge = WornObject.GetItemMaxCharge(PlayerRef, i, 0)
			PlayerRef.RemoveItem(PlayerRef.GetEquippedWeapon(lefhanded), abSilent = true)
		else
			Debug.Notification("Something went wrong...")
		endif
		if (storedEnch)
			PlayerRef.RemoveItem(XTDCrystals.GetAt(2))
			DisplayStoredValues(storedEnch)
		endif
		ClearAll()
	endif
endfunction

function RestoreEnchantment(int index)
	bool continue = ShowMessage("$XTDINJCTMSG")
	if (continue)
		int j = items[index].GetType()
		if (j == 26 && storedEnch && IsForArmor) ;armor
			WornObject.SetEnchantment(PlayerRef, 0, masks[index], storedEnch, 0.0)
			PlayerRef.UnequipItem(PlayerRef.GetWornForm(masks[index]), abSilent = true)
			ResetStoredEnchantment()
		elseif (j == 41 && storedEnch && !IsForArmor)
			int i
			bool lefhanded
			if ((items[index] as Weapon) == PlayerRef.GetEquippedWeapon())
				i = 1
			else
				lefhanded = TRUE				
			endif
			WornObject.SetEnchantment(PlayerRef, i, 0, storedEnch, fStoredCharge)
			PlayerRef.UnequipItem(PlayerRef.GetEquippedWeapon(lefhanded), abSilent = true)
			ResetStoredEnchantment()
		else
			Debug.Notification("Something went wrong...")
		endif
	ClearAll()
	endif
endfunction

function ResetStoredEnchantment()
	IsForArmor = FALSE
	storedEnch = None
	fStoredCharge = 0.0
	if !(storedEnch)
		storedeffects = StringUtil.Split(XTDStrings[4], ",")
		fxmagstored = new float[3]
	endif
endfunction

function MassAbsorb(Actor absActor)

endfunction

function Dismantle(ObjectReference akContainer)
	Bool DismantleSuccess
	Int amount
	Int perMult = Attributes.GetTotalValue(6)
	Int iFormIndex = akContainer.GetNumItems()
	string dis = "[DISMANTLE] "
	debugconsole(dis+(iFormIndex - 1)+" items to dismantle, current Personality: "+perMult)
	While iFormIndex > 0
		iFormIndex -= 1
		Form kForm = akContainer.GetNthForm(iFormIndex)
		debugconsole(dis+"Item #"+iFormIndex+" "+kForm.GetName())
		If (kForm.GetType() == 26 || kForm.GetType() == 41)
			int i
			DismantleSuccess = True
			Int iFormTier = iDismantleBonus.GetValue() as int
			Int iFormCost = kForm.GetGoldValue()
			Int iFormCount = akContainer.GetItemCount(kForm)
			if (iFormCost) >= 50 && (iFormCost) <= 350
				iFormTier += 1
			Elseif (iFormCost) > 350 && (iFormCost) < 1000
				iFormTier += 2
			Elseif (iFormCost) >= 1000
				iFormTier += 3
			Endif
			Float fGemChance = ((iFormTier + 1) * perMult) * 0.25
			debugconsole(dis+"Item #"+iFormIndex+" <"+kForm.GetName()+"> is valid. Quantity: "+iFormCount+", Tier:"+iFormTier+", Value: "+iFormCost+", Chance to extract gems: "+fGemChance+"%")
			totalAbsorbs += iFormCount
			curAugments += iFormCount
			While iFormCount > 0
				iFormCount -= 1
				If RNDF() < fGemChance
					Int j = 2
					bool done
					Float f = 2 * (2 + iFormTier)
					While j > 0 && !done
						If RNDF() <= f
							done = True
						Else
							f *= 3.0
						Endif
						j -= 1
					Endwhile
					PlayerRef.AddItem(XTDCrystals.GetAt(j), 1)
					debugconsole(dis+"Item #"+iFormIndex+" <"+kForm.GetName()+"> Gem extracted!")
				Else
					int k = Utility.RandomInt(iFormTier, (1+iFormTier))
					amount += k
					debugconsole(dis+"Item #"+iFormIndex+" <"+kForm.GetName()+"> Dust extracted: "+k+"; Total: "+amount)
				Endif
			Endwhile
			akContainer.RemoveItem(kForm, akContainer.GetItemCount(kForm))
			If curAugments >= accumAugments
				accumAugments *= 2
				Game.IncrementSkill("Enchanting")
			Endif
		Else
			debugconsole(dis+"Item #"+iFormIndex+" <"+kForm.GetName()+"> is invalid.")
		EndIf
	Endwhile
	If (DismantleSuccess && Amount > 0)
		PlayerRef.AddItem(XTDCrystals.GetAt(3), Amount)
	    XTD_SFX[0].Play(PlayerRef)
		debugconsole(dis+(iFormIndex - 1)+" items dismantled. Dust extracted: "+amount)
	Else
		XTDMsg_112.Show()
	Endif
endfunction

Function ClearAll(bool forcereset=true)
    int i
    While i < 3
        mgefs[i] = none
        effects[i] = "$None"
        fxmag[i] = 0
        effectsdur[i] = 0
        fxmagnew[i] = 0
        i += 1
    Endwhile
    fMaxCharge = 0.0
    if (iCONSMENU == 0)
        iConsumables = 0
    endif
	EnableFlag(0,FALSE)
	EnableFlag(1,FALSE)
	EnableFlag(2,FALSE)
	EnableFlag(3,FALSE)
	iAUGMMENU = 0
	if (forcereset)
		ForcePageReset()
	endif
Endfunction

Function EnableFlag(int index, bool enabled=true)
    if enabled
        flags[index] = OPTION_FLAG_NONE
    else
        flags[index] = OPTION_FLAG_DISABLED
    endif
Endfunction

Function DisableFlags(bool forcereset=true)
	EnableFlag(0,FALSE)
	EnableFlag(1,FALSE)
	EnableFlag(2,FALSE)
	EnableFlag(3,FALSE)
	if (forcereset)
		ForcePageReset()
	endif
Endfunction

; ************************************* Attributes *************************************

string[] function SetStringArrays(int StringIndex)
    return (StringUtil.Split(XTDStrings[StringIndex], ","))
endfunction

Function IncrementAttribute(string attribute, int index, bool IsMCM = False)
    if (XTD_AttributePoints > 0)
		if !(IsMCM)
			XTD_AttributePoints -= 1
			APtsSpent += 1
			XTD_SMFX03.Play(PlayerRef)
			AttributeInherentGlobal[index].Mod(1)
			SendModEvent("PlayerStatusUpdate")
			ForcePageReset()		
		else
			string s = "Are you sure you want to increase this attribute: "+attribute+"?"
			bool proceed = ShowMessage(s)
			if proceed
				XTD_AttributePoints -= 1
				APtsSpent += 1
				XTD_SMFX03.Play(PlayerRef)
				AttributeInherentGlobal[index].Mod(1)
				SendModEvent("PlayerStatusUpdate")
				ForcePageReset()
			endif
		endif
	endif
Endfunction

function DynamicTooltip(int index)
	int i
	int iTotal = Attributes.GetTotalValue(index)
	string summary
	string[] bonus = new string[4]
		
	if (index == 0)
		While i < 4
			if i == 1
				bonus[i] = F2S(Attributes.StrBonus[i] * 100)
			else
				bonus[i] = F2S(Attributes.StrBonus[i])
			Endif
			i += 1
		Endwhile
		summary = iTotal+" Strength grants: \n+"+bonus[0]+"% damage to targets at 50% health or above \n+"+bonus[1]+"% Damage with all weapons \n+"+bonus[2]+" Health per second \n+"+bonus[3]+"% Critical Damage"
	elseif (index == 1)
		While i < 4
			if i == 3
				bonus[i] = F2S(Attributes.EndBonus[i] * 100)
			else
				bonus[i] = F2S(Attributes.EndBonus[i])
			Endif
			i += 1
		Endwhile
		summary = iTotal+" Endurance grants: \n+"+bonus[0]+"% Stamina Recovery \n+"+bonus[1]+" Carrying Capacity \n+"+bonus[2]+" Damage Threshold \n+"+bonus[3]+"% Armor Rating"
	elseif (index == 2)
		While i < 4
			bonus[i] = F2S(Attributes.AgiBonus[i])
			i += 1
		Endwhile
		summary = iTotal+" Agility grants: \n+"+bonus[0]+"% Critical Hit Chance \n+"+bonus[1]+"% Movement Speed \n+"+bonus[2]+"% Sneaking Damage \n+"+bonus[3]+"% Armor Penetration"
	elseif (index == 3)
		While i < 4
			bonus[i] = F2S(Attributes.DexBonus[i])
			i += 1
		Endwhile
		summary = iTotal+" Dexterity grants: \n+"+bonus[0]+"% damage to targets below 50% health \n-"+bonus[1]+"% Power Attacks Stamina Cost \n+"+bonus[2]+"% Power Attacks Damage \n+"+bonus[3]+"% Physical Damage Mitigation"
	elseif (index == 4)
		While i < 4
			bonus[i] = F2S(Attributes.IntBonus[i])
			i += 1
		Endwhile
		summary = iTotal+" Intellect grants: \n+"+bonus[0]+"% Spell Damage \n+"+bonus[1]+" Magicka per second \n+"+bonus[2]+"% Hostile Spells Absorption \n+"+bonus[3]+"% Magic Skills Progress Rate"
	elseif (index == 5)
		While i < 4
			bonus[i] = F2S(Attributes.WisBonus[i])
			i += 1
		Endwhile
		summary = iTotal+" Wisdom grants: \n+"+bonus[0]+"% Magicka regeneration \n-"+bonus[1]+"% Magicka cost to cast spells \n+"+bonus[2]+"% Magic damage mitigation \n+"+bonus[3]+"% All Skills XP"
	elseif (index == 6)
		While i < 4
			bonus[i] = F2S(Attributes.PerBonus[i])
			i += 1
		Endwhile
		summary = iTotal+" Personality grants: \n+"+bonus[0]+"% Gold Found \n+"+bonus[1]+"% Tempered Items Find \n+"+bonus[2]+"% Magic Items Find \n"+bonus[3]+"% Extra Loot Chance"
	endif
	SetInfoText(summary)
endfunction

String Function PrintAttributeValue(string strArg)
    int i = (StringUtil.Find(strArg, ".", 0) + 2)
    Return (StringUtil.Substring(strArg, 0, i))
Endfunction 

; ************************************* Leveled Lists & Stuff *************************************

function AddToLList(LeveledItem LItem, Formlist ItemsList)
	LItem.Revert()
	form f
	int i = ItemsList.GetSize()
	While i > 0
		i -= 1
		f = ItemsList.GetAt(i) as Form
		LItem.AddForm(f, 1, 1)
	endWhile
endfunction

string function PrintBaseAndBonus(int index)
    string s
	int i = AttributeInherentGlobal[index].GetValue() as int
    int j = AttributeBonusGlobal[index].GetValue() as int
    if (j > 0)
        s = "<font color='#5CFF57'> +"+(j as string)+"</font>"
    endif
    Return (i as string + s)
endfunction

string function PrintTotal(int index)
    string s
	int i = Attributes.GetTotalValue(index)
    int j = AttributeBonusGlobal[index].GetValue() as int
    if (i > 0)
		if (j > 0)
			s = "<font color='#FFFF00'>"+(i as string)+"</font>"
		else
			s = "<font color='#F6FF00'>"+(i as string)+"</font>"
		endif
	else
		s = i as string
    endif
    Return s
endfunction

function RefundAttributePoints(Bool IgnoreConditions = False)
	If (IgnoreConditions)
		APtsSpent = 0 - pElixirsUsed
		XTD_AttributePoints = (PlayerRef.GetLevel() * pointsPerLevel) + pElixirsUsed
		ResetAttributes(AttributeInherentGlobal)
		ShowMessage("$XTDRefundDone", false)
		ForcePageReset()
	Else
		if (!PlayerRef.IsInCombat() && IsAllowedLocation())
			if (PlayerRef.GetActorValue("DragonSouls") > 0)
				bool continue = ShowMessage("$XTDRefundTip", true, "$Refund", "$Cancel")
				if (continue)
					refundsMade += 1
					APtsSpent = 0 - pElixirsUsed
					XTD_AttributePoints = (PlayerRef.GetLevel() * pointsPerLevel) + pElixirsUsed
					ResetAttributes(AttributeInherentGlobal)
					PlayerRef.ModActorValue("DragonSouls", -1)
					ShowMessage("$XTDRefundDone", false)
					ForcePageReset()
				endif
			Else
				ShowMessage("$XTDRefundFail2", false)
			Endif
		else
			ShowMessage("$XTDRefundFail", false)
		endif
	Endif
endfunction

function ResetAttributes(GlobalVariable[] attributeVars, int defaultValue = 5)
	Int i
	While i < 7
		attributeVars[i].SetValue(defaultValue)
		i += 1
	Endwhile
	SendModEvent("PlayerStatusUpdate")
endfunction

function DebugConsole(string debugstring)
	if (XTD_Debug.GetValue() as int > 0)
		MiscUtil.PrintConsole(debugstring)
	endif
endfunction

Bool Function IsAllowedLocation()
	Return PlayerRef.GetCurrentLocation().HasKeywordString("LocTypeInn") || PlayerRef.GetCurrentLocation().HasKeywordString("LocTypePlayerHouse") || PlayerRef.GetCurrentLocation().HasKeywordString("LocTypeTemple")
Endfunction

Function WDDebug(string debugstring)
	string string1
	string string2
	string string3
	int amount
	int i = StringUtil.Find(debugstring,",")
	If (i == -1)
		string1 = debugstring
	Else
		string1 = StringUtil.Substring(debugstring, 0, i)
		int j = StringUtil.Find(debugstring, ",", i + 1)
		If (j == -1)
			string2 = StringUtil.Substring(debugstring, i + 1)
		Else
			string2 = StringUtil.Substring(debugstring, i + 1, 3)
			string3 = StringUtil.Substring(debugstring, j + 1)
			if (StringUtil.IsDigit(string3))
				amount = StringUtil.AsOrd(string3) - 48
				if amount <= 0
					amount = 1
				endif
			Endif
		Endif
	Endif
	;MiscUtil.PrintConsole(WDDefault+" Command <"+string1+">, argument <"+string2+">, value <"+amount+">")
	If (string1 == "List")
		int k
		WDCommands = "Debug;Reset;Update;Madness;NoRegen,Player (optional);NoMats;NoEnch;NoTemp;NewDay;Set,PPL,Value;Adv,String;EPEvent,String,Value;Inc,String,Value;Dec,String,Value;Uninstall"
		string[] commands = StringUtil.Split(WDCommands, ";")
		MiscUtil.PrintConsole(WDDefault)
		While (k < commands.length)
			MiscUtil.PrintConsole(commands[k])
			k += 1
		Endwhile
	ElseIf (string1 == "Debug")
		XTD_Debug.SetValue(1)
		ShowMessage("Debug mode enabled > "+(XTD_Debug.GetValueInt() as bool), False, "$Ok")
	Elseif (string1 == "Reset")
		RefundAttributePoints(True)
	Elseif (string1 == "Adv")
		AdvancePlayerSkill(string2, amount)
	Elseif (string1 == "EPEvent")
		SendModEvent("ExtraPointsAdd", string2, amount)
	Elseif (string1 == "Update")
		ReregisterModEvent()
		SendModEvent("PlayerStatusUpdate")
	Elseif (string1 == "Madness")
		If (XTD.fMadness > 0.0)
			XTD.fMadness = 0.0
			ShowMessage("Madness is off.", False, "$Ok")
		Else
			XTD.fMadness = 1.0
			ShowMessage("All items are legendary.", False, "Sweet")
		Endif
	Elseif (string1 == "NoRegen")
		if (PlayerRef.HasSpell(XTD_AbHealPlayerHidden))
			PlayerRef.RemoveSpell(XTD_AbHealPlayerHidden)
			ShowMessage("Regeneration per second disabled.", False, "Soon I'll regret")
		else
			PlayerRef.AddSpell(XTD_AbHealPlayerHidden, false)
			ShowMessage("Regeneration per second enabled.", False, "$Ok")
		endif
	Elseif (string1 == "NoMats")
		ConsumeMats = !ConsumeMats
		ShowMessage("Consume materials when augmenting an item > "+ConsumeMats, False, "$Ok")
	Elseif (string1 == "NoEnch")
		XTD.BlockEnchanting = !XTD.BlockEnchanting
		ShowMessage("Allow enchantments > "+!XTD.BlockEnchanting, False, "$Ok")
	Elseif (string1 == "NoTemper")
		XTD.BlockTempering = !XTD.BlockTempering
		ShowMessage("Allow tempering > "+!XTD.BlockTempering, False, "$Ok")
	Elseif (string1 == "Set")
		if (string2 == "PPL")
			pointsPerLevel = amount
			RefundAttributePoints(True)
		endif
	Elseif (string1 == "NewDay")
		today = GameDaysPassed.GetValue() as int
		CanAugmentToday()
		ShowMessage("Resetting today's augmentations counter", False, "Good Morning")
	Elseif (string1 == "Uninstall")
		PlayerRef.RemoveSpell(XTD_AbHealPlayerHidden)
		ResetAttributes(AttributeInherentGlobal, 0)
		ResetAttributes(AttributeBonusGlobal, 0)
		XTD_Spell.Stop()
		Utility.WaitMenuMode(1.0)
		ShowMessage("World's Dawn is ready for uninstallation.", False, "Bye")
		UnregisterForAllModEvents()
		Stop()
	Elseif (string1 == "Inc")
		If (string2)
			int j = GetAttributeIndex(string2)
			If j == 7
				ModAttributes(amount)
			Elseif (j >= 0)
				ModAttribute(string2, j, amount)
			Endif
		Else
			ModAttributes()
		Endif
	Elseif (string1 == "Dec")
		If (string2)
			int j = GetAttributeIndex(string2)
			If j == 7
				ModAttributes(-amount)
			Elseif (j >= 0)
				ModAttribute(string2, j, -amount)
			Endif
		Else
			ModAttributes(-1)
		Endif
	Else
		MiscUtil.PrintConsole(WDDefault+debugstring+" is not a valid command..")
	Endif
Endfunction

Function AdvancePlayerSkill(string skill, int advBy)
	If (skill && PlayerRef.GetAV(skill))
		Game.IncrementSkillBy(skill, advBy)
	Else
		MiscUtil.PrintConsole(WDDefault+"Invalid skill <"+skill+">")
	Endif
Endfunction

Function ModAttributes(int ModBy = 1)
	int i
	While i < 7
		ModAttribute("", i, ModBy, True)
		i += 1
	Endwhile
	SendModEvent("PlayerStatusUpdate")
Endfunction

Function ModAttribute(string attribute, int index, int ModBy, bool noevent=False)
	AttributeInherentGlobal[index].Mod(ModBy)
	If !(noevent)
		SendModEvent("PlayerStatusUpdate", attribute)
	Endif
Endfunction

Int Function GetAttributeIndex(string str)
	int id
			If (str == "All")
				id = 7
			Elseif (str == "Str")
				id = 0
			Elseif (str == "End")
				id = 1
			Elseif (str == "Agi")
				id = 2
			Elseif (str == "Dex")
				id = 3
			Elseif (str == "Int")
				id = 4
			Elseif (str == "Per")
				id = 6
			Elseif (str == "Wis")
				id = 5
			Else
				MiscUtil.PrintConsole(WDDefault+"Invalid attribute..")
				id = -1
			Endif
	Return id
Endfunction

; ************************************* Endfunctions *************************************

Actor Property PlayerRef  Auto  
Actor Property absINV  Auto 

ObjectReference Property absStorageRef Auto

XTD_BaseScript Property XTD Auto
XTD_Attributes Property Attributes Auto

Quest Property XTD_Spell Auto

Float Property fScanInterval = 2.0 Auto  
Float Property fScanRadius = 3000.0 Auto 
 
Bool Property bScanNPC = True Auto  
Bool Property bScanChest = True Auto 
Bool Property bModActive Auto 
Bool Property StatsConfirm = True Auto

GlobalVariable Property XTDGV_MIF Auto
GlobalVariable Property XTDGV_TIF Auto
GlobalVariable[] Property AttributeInherentGlobal Auto
GlobalVariable[] Property AttributeBonusGlobal Auto
GlobalVariable Property GameDaysPassed auto
GlobalVariable Property UsesWintermyst  Auto
GlobalVariable Property XTD_NoPotions  Auto
GlobalVariable Property XTD_Debug  Auto
GlobalVariable Property XTD_NoRegen  Auto
GlobalVariable Property iDismantleBonus  Auto

Keyword Property XTDRounded  Auto  
Keyword Property MagicEnchNoMagnitude  Auto 
 
FormList Property XTDCrystals  Auto
FormList Property XTDPotions  Auto
FormList Property XTDPotionsMisc  Auto
Formlist Property XTD_CustomAttributes  Auto
Formlist Property WDBlacklist_e  Auto
FormList Property WDContainersBlacklist  Auto

LeveledItem Property LItemApothecaryRecipesRare50 Auto
LeveledItem Property LItemApothecaryIngredientsCommon75 Auto

Perk Property XTDPerk_Cumulative  Auto 

Sound Property XTD_SMFX01  Auto  
Sound Property XTD_SMFX02  Auto 
Sound Property XTD_SMFX03  Auto
Sound[] Property XTD_SFX  Auto

SPELL Property XTD_AbHealPlayerHidden  Auto

Int Property XTD_AttributePoints Auto

Message Property XTDAbsorbConfirmMsg  Auto  
Message Property XTDMsg_104  Auto
Message Property XTDMsg_111  Auto
Message Property XTDMsg_112  Auto
Message Property XTDMsg_203  Auto
Message Property XTDMsg_FA  Auto
Message Property XTDAttMsg  Auto
 
VisualEffect Property VFX0  Auto

string WDDefault = "World's Dawn: "
string WDCommands

int internalVersion = 210
int pointsPerLevel = 2
int totalAugments
int totalAbsorbs
int todayAugments
int failedAugments
int augmentCap = 3
int today
int curAugments
int accumAugments=3
int iConsumables
int APtsSpent
int pElixirsUsed
int flag
int keyAbsorb = 82 ;NUM0
int keyAttMenu = 78 ;NUM+
int iMIFMENU=1
int iMIAMENU=0
int iTEMPMENU=1
int iAUGMMENU=0
int iCONSMENU=0
int refundsMade
int noconfirmOID
int debugOID
bool enableAugment
bool bNoPotions
int[] flags
int[] iWD
int[] xtdStatOIDs
int[] effectsmag
int[] effectsdur
int[] effectsmagnew
int[] effmagstored
int[] masks
float[] fxmag
float[] fxmagnew
float[] fxmagstored
form[] items
string[] XTDStrings
string[] xtdMENUs
string[] XTDMIFMENU
string[] XTDTEMPMENU
string[] XTDMIAMENU
string[] XTDAUGMMENU
string[] XTDCONSMENU
string[] effects
string[] storedeffects
MagicEffect[] mgefs 
float fMaxCharge
float fStoredCharge
Enchantment storedEnch
bool IsForArmor
bool busy
bool bDebug
bool ConsumeMats = True