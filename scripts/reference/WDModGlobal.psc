Scriptname WDModGlobal extends activemagiceffect 
 
Actor Property PlayerRef Auto
GlobalVariable Property GlobalToMod  Auto 

Float mag

Event onEffectStart(Actor akTarget, Actor akCaster)
	If (akTarget == PlayerRef)
		mag = GetMagnitude()
		GlobalToMod.SetValue(GlobalToMod.GetValue() + mag)
	endif
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	If (akTarget == PlayerRef)
		GlobalToMod.SetValue(GlobalToMod.GetValue() - mag)
	endif
Endevent