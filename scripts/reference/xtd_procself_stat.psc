Scriptname XTD_ProcSelf_Stat extends activemagiceffect  

Event onEffectStart(Actor akTarget, Actor akCaster)
	if IsPercent
		AmountToMod = akTarget.GetActorValue(StatToMod) * (self.GetMagnitude()/100.0)
	else
		AmountToMod = self.GetMagnitude()
	endif
	if IsNegative
		AmountToMod = -AmountToMod
	endif
	akTarget.ModActorValue(StatToMod, AmountToMod)
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.ModActorValue(StatToMod, -AmountToMod)
Endevent

Float AmountToMod

String Property StatToMod  Auto
Bool Property IsNegative  Auto
Bool Property IsPercent  Auto 
