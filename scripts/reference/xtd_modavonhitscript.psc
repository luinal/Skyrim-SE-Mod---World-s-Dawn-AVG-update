Scriptname XTD_ModAVOnHitScript extends activemagiceffect  

actor caster
actor attacker
Bool IsOnCooldown
Float InitialValue
Float AegisPower

String Property TargetAV  Auto
Spell Property BuffSpell  Auto

Event onEffectStart(Actor akTarget, Actor akCaster)
	caster = akTarget
	AegisPower = 110.0
	caster.ModActorValue(TargetAV, 100.0)
Endevent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, \
  bool abBashAttack, bool abHitBlocked)
	if !IsOnCooldown && (akSource as Spell) && (akSource as Spell).IsHostile() && !caster.IsDead()
		if (AegisPower >= 10.0)
			IsOnCooldown = true
			AegisPower -= 10.0
			RegisterForSingleUpdate(0.5)
		else
			caster.DispelSpell(BuffSpell)
			AegisPower = 0.0
			IsOnCooldown = false
		endif
	endif
endevent

Event onUpdate()
    IsOnCooldown = false
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	AegisPower = 0.0
	caster.ModActorValue(TargetAV, -100.0)
Endevent