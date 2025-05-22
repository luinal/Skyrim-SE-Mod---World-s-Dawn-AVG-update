Scriptname XTD_FortifyDecimal extends activemagiceffect 

Event onEffectStart(Actor akTarget, Actor akCaster)
    ValueMod = self.GetMagnitude()/100.0
    if IsNegative
        ValueMod = -ValueMod
    Endif
	If AffectsGV
		If akTarget == Game.GetPlayer() || akTarget.IsPlayerTeammate()
			Kicked = true
			affectedGV.Mod(ValueMod)
		Endif
	else
		if StatToMod == "weaponSpeedMult" && akTarget.GetActorValue(StatToMod) == 0.0
			ValueMod += 1.0
		endif
		akTarget.ModActorValue(StatToMod, ValueMod)
	endif
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	If Kicked
		affectedGV.Mod(-ValueMod)
	else
		akTarget.ModActorValue(StatToMod, -ValueMod)
	endif
Endevent

Float ValueMod
Bool Kicked

String Property StatToMod  Auto  
Bool Property IsNegative  Auto
Bool Property AffectsGV  Auto
GlobalVariable Property affectedGV  Auto  
