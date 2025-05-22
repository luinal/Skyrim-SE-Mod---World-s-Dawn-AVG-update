Scriptname XTD_ProcSelfDynamic extends activemagiceffect  

actor victim
actor attacker
bool HasWeapEquipped

Event onEffectStart(Actor akTarget, Actor akCaster)
    victim = akTarget
Endevent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, \
  bool abBashAttack, bool abHitBlocked)
	if (victim.GetEquippedWeapon() && akAggressor && !victim.IsDead() && !abHitBlocked && !IsOnCooldown && victim.GetDistance(akAggressor) <= 200.0)
		IsOnCooldown = true
		attacker = akAggressor as actor
		if TFX1
			TFX1.Play(victim, 0.5)
		endif
		BaseMag = (GetMagnitude() as int) * victim.GetEquippedWeapon().GetBaseDamage()
		if BaseMag < 0
			BaseMag = 1
		endif
		If attacker.GetActorValue("Health") <= BaseMag
			attacker.Kill(victim)
		else
			attacker.DamageActorValue("Health", BaseMag)
		endif
		SFX1.Play(attacker)
		RegisterForSingleUpdate(Cooldown)
	endif
endevent

Event onUpdate()
    IsOnCooldown = false
Endevent

Float Property Cooldown Auto
Bool IsOnCooldown
int BaseMag 
VisualEffect Property TFX1  Auto  
Sound Property SFX1  Auto  