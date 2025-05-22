Scriptname XTD_CustomAV extends activemagiceffect  

Int ModBy
Actor Target
Float[] Mults
String[] Values

XTD_Attributes Property Attributes Auto
GlobalVariable[] Property AttributeBonusGlobal Auto

Event onEffectStart(Actor akTarget, Actor akCaster)
	int i
	ModBy = GetMagnitude() as int
	if (akTarget == Game.GetPlayer())
		While i < 7
			AttributeBonusGlobal[i].Mod(ModBy)
			i += 1
		Endwhile
		Utility.WaitMenuMode(0.1)
		SendModEvent("PlayerStatusUpdate")
	else
		Target = akTarget
		While (i < 7)
			If (i == 0)
				Mults = Attributes.StrBonus
				Values = Attributes.StrAV
			Elseif (i == 1)
				Mults = Attributes.EndBonus
				Values = Attributes.EndAV
			Elseif (i == 2)
				Mults = Attributes.AgiBonus
				Values = Attributes.AgiAV
			Elseif (i == 3)
				Mults = Attributes.DexBonus
				Values = Attributes.DexAV
			Elseif (i == 4)
				Mults = Attributes.IntBonus
				Values = Attributes.IntAV
			Elseif (i == 5)
				Mults = Attributes.WisBonus
				Values = Attributes.WisAV
			Elseif (i == 6)
				Mults = Attributes.PerBonus
				Values = Attributes.PerAV
			Endif
			ModAttributes(Target, ModBy)
			i += 1
		Endwhile
    endif
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	Int i
    if (akTarget == Game.GetPlayer())
		While i < 7
			AttributeBonusGlobal[i].Mod(-ModBy)
			i += 1
		Endwhile
		Attributes.ResetOnEffectFinish()
	else
		While (i < 7)
			If (i == 0)
				Mults = Attributes.StrBonus
				Values = Attributes.StrAV
			Elseif (i == 1)
				Mults = Attributes.EndBonus
				Values = Attributes.EndAV
			Elseif (i == 2)
				Mults = Attributes.AgiBonus
				Values = Attributes.AgiAV
			Elseif (i == 3)
				Mults = Attributes.DexBonus
				Values = Attributes.DexAV
			Elseif (i == 4)
				Mults = Attributes.IntBonus
				Values = Attributes.IntAV
			Elseif (i == 5)
				Mults = Attributes.WisBonus
				Values = Attributes.WisAV
			Elseif (i == 6)
				Mults = Attributes.PerBonus
				Values = Attributes.PerAV
			Endif
			ModAttributes(Target, -ModBy)
			i += 1
		Endwhile
    endif
Endevent

Function ModAttributes(Actor akActor, int value)
	int i
	While i < 4
		akActor.ModActorValue(Values[i], (Mults[i] * value))
		i += 1
	endwhile
Endfunction