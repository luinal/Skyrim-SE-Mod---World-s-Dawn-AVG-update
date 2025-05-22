Scriptname XTD_BaseScript extends Quest

Function RegisterNames()
	simpleNames = new string[4]
	armorNames		=	Utility.CreateStringArray(XTDArmorEffects.GetSize())
	armorNamesRare	=	Utility.CreateStringArray(XTDArmorEffectsRare.GetSize())
	weaponNames		=	Utility.CreateStringArray(XTDWeaponEffects.GetSize())
	weaponNamesRare	=	Utility.CreateStringArray(XTDWeaponEffectsRare.GetSize())
	weaponNamesLegend	=	Utility.CreateStringArray(WDAffixW.GetSize())
	armorNamesLegend	=	Utility.CreateStringArray(WDAffixA.GetSize())
	If JsonUtil.Load("../Worlds Dawn/strings")
;		MiscUtil.PrintConsole("Loading strings")
		InitGearStrings(simpleNames, "simpleNames")
		InitGearStrings(armorNames, "armorNames")
		InitGearStrings(armorNamesRare, "armorNamesRare")
		InitGearStrings(armorNamesLegend, "armorNamesLegend")
		InitGearStrings(weaponNames, "weaponNames")
		InitGearStrings(weaponNamesRare, "weaponNamesRare")
		InitGearStrings(weaponNamesLegend, "weaponNamesLegend")
	Else
		Debug.Notification("Worlds Dawn: String file not found!")
		Return
	Endif
Endfunction

Function InitGearStrings(string[] gearNames, string gearKey)
	int i
	While i < gearNames.length
		gearNames[i] = JsonUtil.StringListGet("../Worlds Dawn/strings", gearKey, i)
		;MiscUtil.PrintConsole("String index "+i+": "+armorNames[i])
		i += 1
	Endwhile
Endfunction

function ApplyPlayerMadeEnchantment(Actor akActor, int weaponSlot, int equipmentSlot, bool specialLoot = FALSE)
	if BlockEnchanting
		Return
	endif
    bool isRare
    bool isWeapon
    int tierIndex = GetRarity(specialLoot)
    Formlist[] effectsList = new formlist[2]
    int variation
    int[] effectIndex
    int[] aoes
    int[] durs
    float[] mags
    float fMaxCharge
    string[] names
    MagicEffect[] mgefs
    if (equipmentSlot > 0)
        ArmorsEnchanted += 1
		If (tierIndex == 3)
			effectsList[0] = WDAffixesA
		Else
			effectsList[0] = XTDArmorEffects
		Endif
        effectsList[1] = XTDArmorEffectsRare
    else
        WeaponsEnchanted += 1
        isWeapon = TRUE
		If (tierIndex == 3)
			effectsList[0] = WDAffixesW
		Else
			effectsList[0] = XTDWeaponEffects
		Endif
        effectsList[1] = XTDWeaponEffectsRare
        fMaxCharge = Utility.RandomFloat(500.0, 600) * (1 + tierIndex)
    endif
    if (tierIndex < 2)
        isRare = (tierIndex as bool)
        effectIndex = new int[2]
        aoes = new int[2]
        durs = new int[2]
        mags = new float[2]
        names = new string[2]
        mgefs = new MagicEffect[2]
    elseif (tierIndex == 2)
        isRare = True
        effectIndex = new int[3]
        aoes = new int[3]
        durs = new int[3]
        mags = new float[3]
        names = new string[3]
        mgefs = new MagicEffect[3]
	else
        isRare = True
        effectIndex = new int[3]
        aoes = new int[3]
        durs = new int[3]
        mags = new float[3]
        names = new string[1]
        mgefs = new MagicEffect[3]
    endif
	If (tierIndex < 3)
	    int i
		int j
		While (i < aoes.length)
			if (i == 2 && tierIndex == 2 && Utility.RandomFloat(0,100) <= 50.0)
				j = 1
			endif
			mgefs[i] = SetEffect(effectsList[j], mgefs, i)
			mags[i] = SetEffectMagnitude(akActor, mgefs[i], tierIndex, isRare)
			names[i] = GetEffectName(effectsList[j], mgefs[i], i, j, isWeapon)
			durs[i] = SetEffectDuration(mgefs[i], tierIndex)
			i += 1
		Endwhile
	Else
		Int i
		Int eIndex
		String[] sIndex
		FormList tForm
		If (isWeapon)
			sIndex = weaponNamesLegend
		Else
			sIndex = armorNamesLegend
		Endif
		eIndex = Utility.RandomInt(0, sIndex.Length - 1)
		names[0] = sIndex[eIndex]
		While i < 3
			tForm = effectsList[0].GetAt(i) as FormList
			mgefs[i] = tForm.GetAt(eIndex) as MagicEffect
			mags[i] = SetEffectMagnitude(akActor, mgefs[i], tierIndex, isRare)
			durs[i] = SetEffectDuration(mgefs[i], tierIndex)
			i += 1
		Endwhile
	Endif
    WornObject.CreateEnchantment(akActor, weaponSlot, equipmentSlot, fMaxCharge, mgefs, mags, aoes, durs)
    if (RenameIndex > 0)
        ChangeDisplayName(akActor, equipmentSlot, weaponSlot, tierIndex, names)
    endif
endfunction

MagicEffect function SetEffect(Formlist Source, MagicEffect[] SourceEffects, int NthEffect)
	int index1
	int index2
	int index3
	MagicEffect mgefbase
	if (NthEffect == 0)
		mgefbase = Source.GetAt(Utility.RandomInt(0, (Source.GetSize() - 1))) as MagicEffect
	elseif (NthEffect == 1)
		index1 = Source.Find(SourceEffects[0])
		index2 = Utility.RandomInt(0, (Source.GetSize() - 1))
		if (index2 == index1)
			index2 += (Utility.RandomInt(-5,5))
		endif
		if (index2 <= 0)
			index2 = Utility.RandomInt(0,3)
		elseif (index2 >= Source.GetSize())
			index2 = Utility.RandomInt((Source.GetSize() - 5),(Source.GetSize() - 1))
		endif
		mgefbase = Source.GetAt(index2) as MagicEffect
	elseif (NthEffect == 2)
		index1 = Source.Find(SourceEffects[0])
		index2 = Source.Find(SourceEffects[1])
		index3 = Utility.RandomInt(0, (Source.GetSize() - 1))
		if (index3 == index1) || (index3 == index2)
			int i
			bool done
			While (!done && i < 10)
				index3 = Utility.RandomInt(0, (Source.GetSize() - 1))
				if (index3 != index1) && (index3 != index2)
					done = true
				endif
				i += 1
			Endwhile
		endif
		mgefbase = Source.GetAt(index3) as MagicEffect
	endif
	Return mgefbase
endfunction

Float Function SetEffectMagnitude(actor akActor, MagicEffect ThisEffect, int index, bool IsRare=true)
        float Mag
        float RareMult = 1.0 + ((akActor.GetLevel() + PlayerRef.GetActorValue("Enchanting")) * 0.008)
        if IsRare
            RareMult += 0.25
        endif
        if ThisEffect.HasKeywordString("MagicEnchNoMagnitude")
            Mag = 1.0
			RareMult = 1.0
		elseif ThisEffect.HasKeywordString("XTDLowest")
            Mag = Utility.RandomFloat(1.0, 2.0)
        elseif ThisEffect.HasKeywordString("XTDLow")
            Mag = Utility.RandomFloat(1.0, 5.0)
        elseif ThisEffect.HasKeywordString("XTDAverage")
            Mag = Utility.RandomFloat(6.0, 8.0)
        elseif ThisEffect.HasKeywordString("XTDHigh")
            Mag = Utility.RandomFloat(15.0, 25.0)
        elseif ThisEffect.HasKeywordString("XTDHighest")
            Mag = Utility.RandomFloat(25.0, 50.0)
        elseif ThisEffect.HasKeywordString("XTDRnd")
            Mag = Utility.RandomFloat(1.0, 33.0)
        elseif ThisEffect.HasKeywordString("XTDDecimal")
            Mag = Utility.RandomFloat(0.1, 0.5)
        else
            Mag = Utility.RandomFloat(9.0, 15.0)
        endif
		float f
		if (ThisEffect.HasKeywordString("XTDRounded"))
			f = Math.Floor(Mag * RareMult)
		else
			f = (Mag * RareMult)
		endif
		if (f <= 0.0)
			if (ThisEffect.HasKeywordString("XTDDecimal"))
				f = 0.1
			else
				f = 1.0
			endif
		endif
		Return f
Endfunction

Int Function SetEffectDuration(MagicEffect ThisEffect, int index)
    if ThisEffect.HasKeywordString("XTDLasts")
        Return (Utility.RandomInt(2, 4) + index)
    elseif ThisEffect.HasKeywordString("XTDPoisoned")
        Return (Utility.RandomInt(3, 6) + index)
    else
        Return 0
    endif
Endfunction

String Function GetEffectName(Formlist Source, MagicEffect mgef, int NthEffect, int NthEffectEx, bool IsWeaponEffect=false)
    string s
	int i = Source.Find(mgef)
    if IsWeaponEffect
		if (NthEffectEx == 0)
			s = weaponNames[i]
		else
			s = weaponNamesRare[i]
		endif
    else
		if (NthEffectEx == 0)
			s = armorNames[i]
		else
			s = armorNamesRare[i]
		endif
    endif
    string[] names = StringUtil.Split(s, ",")
    if names.Length > 1
        s = names[NthEffect]
    else
        s = names[0]
    endif
	Return s
Endfunction

function ChangeDisplayName(Actor akActor, int armorSlot, int handSlot, int tierIndex, string[] namesList)
    string newName
    string oldName
	int variant
    form equippedForm
    if (armorSlot) > 0
        equippedForm = akActor.GetWornForm(armorSlot)
    else
        equippedForm = akActor.GetEquippedWeapon()
    endif
    if (RenameIndex == 1)
        newName = simpleNames[tierIndex] + " " + equippedForm.GetName()
    else
        oldName = equippedForm.GetName()
        if (tierIndex == 3)
			newName = namesList[0]
		elseif (tierIndex == 0) || (tierIndex == 1)
			variant = Utility.RandomInt(0, 2)
            if (variant == 0)
                newName = namesList[0] + " " + namesList[1] + " " + oldName
            elseif (variant == 1)
                newName = namesList[0] + " " + oldName
			elseif (variant == 2)
                newName = namesList[1] + " " + oldName
            endif
		elseif (tierIndex == 2)
			variant = Utility.RandomInt(0, 2)
            if (variant == 0)
                newName = namesList[0] + " " + namesList[1] + " " + oldName + " of " + namesList[2] 
            elseif (variant == 1)
                newName = namesList[0] + " " + oldName + " of " + namesList[2] 
			elseif (variant == 2)
                newName = namesList[1] + " " + oldName + " of " + namesList[2] 
            endif
        endif
    endif
    WornObject.SetDisplayName(akActor, handSlot, armorSlot, newName)
    if (tierIndex == 3)
        LastLegendary = newName
    endif
endfunction

Function TemperItem(Actor akActor, int handSlot, int Mask)
	if BlockTempering
		Return
	endif
    float temperMax
    if (akActor.GetLevel() <= 15)
        temperMax = 1.2
    elseif (akActor.GetLevel() > 15 && akActor.GetLevel() <= 25)
        temperMax = 1.4
    else
        temperMax = 2.0
    endif
	ItemsTempered += 1
    WornObject.SetItemHealthPercent(akActor, handSlot, Mask, Utility.RandomFloat(1.1, temperMax))
Endfunction

int Function GetRarity(bool IsBoss=false)
    bool done
    int i = 3
    int iMult = 1
    if IsBoss
        iMult += 1
    endif
    While i > 0 && !done
        if Utility.RandomFloat() <= (odds[i] * iMult)
            done = true
        else
            i -= 1
        endif
    Endwhile
    return i
Endfunction

Function CalculateOdds(Actor akActor)
	odds = new float[4]
    odds[1] = 0.35
    odds[2] = 0.21
    odds[3] = 0.02 + fMadness
Endfunction

;***********************************************************************
;***********************************************************************
;***********************************************************************

float[] odds

string[] simpleNames
string[] armorNames
string[] armorNamesRare
string[] weaponNames
string[] weaponNamesRare
string[] armorNamesLegend
string[] weaponNamesLegend

Int Property RenameIndex Auto
Int Property ArmorsEnchanted Auto
Int Property WeaponsEnchanted Auto
Int Property ItemsTempered Auto
Int Property NPCScanned Auto
Int Property ChestScanned Auto

Bool Property BlockTempering Auto
Bool Property BlockEnchanting Auto

Float Property fMadness Auto

String Property LastLegendary Auto

Actor Property PlayerRef  Auto

FormList Property XTDArmorEffects  Auto
FormList Property XTDArmorEffectsRare  Auto
FormList Property XTDWeaponEffects  Auto
FormList Property XTDWeaponEffectsRare  Auto

FormList Property WDAffixesA  Auto
FormList Property WDAffixesW  Auto
FormList Property WDAffixA  Auto
FormList Property WDAffixW  Auto