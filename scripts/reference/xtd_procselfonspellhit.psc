Scriptname XTD_ProcSelfOnSpellHit extends activemagiceffect  

actor caster
actor attacker
Bool IsOnCooldown
Float ChanceForEffect
SPELL Property BuffSpell  Auto
MagicEffect Property AnotherInstance  Auto

Float Property Cooldown Auto

Event onEffectStart(Actor akTarget, Actor akCaster)
    caster = akTarget
    ChanceForEffect = GetMagnitude()
Endevent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, \
  bool abBashAttack, bool abHitBlocked)
	if !IsOnCooldown && (akSource as Spell) && (akSource as Spell).IsHostile() && !caster.IsDead() && !caster.HasMagicEffect(AnotherInstance)
		if (Utility.RandomFloat(0,100) <= ChanceForEffect)
			IsOnCooldown = true
			BuffSpell.Cast(caster)
			SFX1.Play(caster)
			RegisterForSingleUpdate(Cooldown)
		endif
	endif
endevent

Event onUpdate()
    IsOnCooldown = false
Endevent
Sound Property SFX1  Auto  
