Scriptname XTD_LonewolfScript extends activemagiceffect 

SPELL Property CDSpell  Auto
String Property RestoreStat = "health" Auto

Event onEffectStart(Actor akTarget, Actor akCaster)
	CDSpell.cast(akTarget)
	akTarget.RestoreAV(RestoreStat,250)
Endevent