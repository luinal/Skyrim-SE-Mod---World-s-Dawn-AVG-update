Scriptname XTD_AlchAttributePercent extends activemagiceffect  

Int ModBy
Actor Target
Float[] Mults
String[] Values

String Property StatArg Auto
Int Property AttributeIndex Auto
XTD_Attributes Property Attributes Auto
GlobalVariable Property XTDAttribute  Auto

Event onEffectStart(Actor akTarget, Actor akCaster)
	ModBy = GetMagnitude() as int
	if (akTarget == Game.GetPlayer())
		XTDAttribute.Mod(ModBy)
		Utility.WaitMenuMode(0.1)
		SendModEvent("PlayerStatusUpdate", StatArg)
	else
		Target = akTarget
		If (AttributeIndex == 0)
			Mults = Attributes.StrBonus
			Values = Attributes.StrAV
		Elseif (AttributeIndex == 1)
			Mults = Attributes.EndBonus
			Values = Attributes.EndAV
		Elseif (AttributeIndex == 2)
			Mults = Attributes.AgiBonus
			Values = Attributes.AgiAV
		Elseif (AttributeIndex == 3)
			Mults = Attributes.DexBonus
			Values = Attributes.DexAV
		Elseif (AttributeIndex == 4)
			Mults = Attributes.IntBonus
			Values = Attributes.IntAV
		Elseif (AttributeIndex == 5)
			Mults = Attributes.WisBonus
			Values = Attributes.WisAV
		Elseif (AttributeIndex == 6)
			Mults = Attributes.PerBonus
			Values = Attributes.PerAV
		Endif
		ModAttributes(Target, ModBy)
    endif
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
    if (akTarget == Game.GetPlayer())
		XTDAttribute.Mod(-ModBy)
		Attributes.ResetOnEffectFinish(StatArg)
	else
		ModAttributes(Target, -ModBy)
    endif
Endevent

Function ModAttributes(Actor akActor, int value)
	int i
	While i < 4
		akActor.ModActorValue(Values[i], (Mults[i] * value))
		i += 1
	endwhile
Endfunction
