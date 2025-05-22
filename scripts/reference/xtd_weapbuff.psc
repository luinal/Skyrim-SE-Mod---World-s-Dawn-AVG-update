Scriptname XTD_WEAPBuff extends activemagiceffect 

Actor Caster
Float ModValue

Event onEffectStart(Actor akTarget, Actor akCaster)
	if (akCaster)
		Caster = akCaster
		If bOnKillRestore
			ModValue = GetMagnitude()
		endif
    endif
Endevent

Event OnDying(Actor akKiller)
	if (akKiller && akKiller == Caster)
		If bOnKillRestore
			Caster.RestoreActorValue(AVtoMod, ModValue)
			FXS1.Play(Caster, FXS1Dur)
			SFX1.Play(Caster)
		endif
		If bOnKillBuff
			BuffSpell.Cast(Caster)
		endif
	endif
endevent

Bool Property bOnKillRestore  Auto
Bool Property bOnKillBuff  Auto
String Property AVtoMod  Auto
EffectShader Property FXS1  Auto
Float Property FXS1Dur  Auto  
Sound Property SFX1  Auto 
SPELL Property BuffSpell  Auto
