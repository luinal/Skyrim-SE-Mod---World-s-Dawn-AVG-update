Scriptname XTD_WeaponProcVisual extends activemagiceffect  

Event onEffectStart(Actor akTarget, Actor akCaster)
	VisualFX.Play(akTarget, FXDur)
Endevent

VisualEffect Property VisualFX  Auto  
Float Property FXDur=1.0 Auto