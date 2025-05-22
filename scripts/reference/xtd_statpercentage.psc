Scriptname XTD_StatPercentage extends activemagiceffect  

Event onEffectStart(Actor akTarget, Actor akCaster)
	target = akTarget
	if bUseAll
		ModBy = new float[3]
		ModBy[0] = target.GetBaseActorValue("Health") * (GetMagnitude() * 0.01)
		ModBy[1] = target.GetBaseActorValue("Magicka") * (GetMagnitude() * 0.01)
		ModBy[2] = target.GetBaseActorValue("Stamina") * (GetMagnitude() * 0.01)
	else
		ModBy = new float[1]
		ModBy[0] = target.GetBaseActorValue(StatToMod) * (GetMagnitude() * 0.01)
	endif
	ModStatPercent()
	RegisterForModEvent("XTDPlayerLevelUp", "OnPlayerLevelUpEx")
Endevent

Event OnPlayerLevelUpEx(string eventName, string strArg, float numArg, Form sender)
	ModStatPercent(True)
	if bUseAll
		ModBy[0] = target.GetBaseActorValue("Health") * (GetMagnitude() * 0.01)
		ModBy[1] = target.GetBaseActorValue("Magicka") * (GetMagnitude() * 0.01)
		ModBy[2] = target.GetBaseActorValue("Stamina") * (GetMagnitude() * 0.01)
	else
		ModBy[0] = target.GetBaseActorValue(StatToMod) * (GetMagnitude() * 0.01)
	endif
	ModStatPercent()
endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	ModStatPercent(True)
Endevent

Function ModStatPercent(bool bSubstract = False)
	if bSubstract
		if bUseAll
			target.ModActorValue("Health", -ModBy[0])
			target.ModActorValue("Magicka", -ModBy[1])
			target.ModActorValue("Stamina", -ModBy[2])
		else
			target.ModActorValue(StatToMod, -ModBy[0])
		endif	
	else
		if bUseAll
			target.ModActorValue("Health", ModBy[0])
			target.ModActorValue("Magicka", ModBy[1])
			target.ModActorValue("Stamina", ModBy[2])
		else
			target.ModActorValue(StatToMod, ModBy[0])
		endif
	endif
Endfunction

Actor target

float[] ModBy

Bool Property bUseAll  Auto 
String Property StatToMod  Auto  
