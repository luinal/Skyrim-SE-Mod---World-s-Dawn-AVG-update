Scriptname WDBuffOnEffectFinish extends activemagiceffect 
 
SPELL Property BuffSpell  Auto

Event onEffectFinish(Actor akTarget, Actor akCaster)
	If !(akTarget.IsDead())
		BuffSpell.Cast(akTarget)
	endif
Endevent