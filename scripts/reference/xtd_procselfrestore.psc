Scriptname XTD_ProcSelfRestore extends activemagiceffect  

actor victim
actor attacker

Event onEffectStart(Actor akTarget, Actor akCaster)
	victim = akTarget
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)

Endevent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, \
  bool abBashAttack, bool abHitBlocked)
	if (akSource as Spell) && !(akSource as Spell).IsHostile()
		Return
	endif
	if (akAggressor as Actor) && !victim.IsDead() && !abHitBlocked && !IsOnCooldown
		if Utility.RandomFloat() <= BuffChance
			IsOnCooldown = true
			if (IsBuff)
				SpellVisual.Cast(victim)
				RegisterForSingleUpdate(BuffDur)
			else
				FXS1.Play(victim, 1)
				victim.RestoreAV(AVToRestore, GetMagnitude())
				RegisterForSingleUpdate(BuffCooldown)
			endif
		endif
	endif
endevent

Event onUpdate()
	IsOnCooldown = false
	if (FXS1)
		FXS1.Stop(victim)
	endif
Endevent

Float BuffChance
Bool IsOnCooldown

Bool Property IsBuff  Auto
String Property AVToRestore  Auto
Float Property ChanceForEffect Auto
EffectShader Property FXS1  Auto 
Float Property BuffDur=1.0	Auto
Float Property BuffCooldown=1.0	Auto
SPELL Property SpellVisual  Auto  
