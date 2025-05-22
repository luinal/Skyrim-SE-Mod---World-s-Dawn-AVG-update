Scriptname XTD_VolcanicBombScript extends activemagiceffect  

Event onEffectStart(Actor akTarget, Actor akCaster)
	float f = 10.0 + (1.0 * (Attributes.GetTotalValue(4)* 0.01))
	if (Utility.RandomFloat(0,100) <= f)
		akTarget.PlaceAtMe(BombExplosion)
	endif
Endevent

XTD_Attributes Property Attributes Auto
Explosion Property BombExplosion Auto