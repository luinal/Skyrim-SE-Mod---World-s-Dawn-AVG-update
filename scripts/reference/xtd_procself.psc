Scriptname XTD_ProcSelf extends activemagiceffect  

actor victim
actor attacker

Event onEffectStart(Actor akTarget, Actor akCaster)
    victim = akTarget
    ChanceForEffect = self.GetMagnitude()/100.0
Endevent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, \
  bool abBashAttack, bool abHitBlocked)
	if (akSource as Spell) && !(akSource as Spell).IsHostile()
		Return
	endif
	if !IsOnCooldown && (akAggressor as Actor) && (akAggressor as Actor).IsHostileToActor(victim) && !victim.IsDead() && !abHitBlocked
		if Utility.RandomFloat() <= ChanceForEffect
			if TargetSelf
				IsOnCooldown = true
				BuffSpell.Cast(victim)
				if SFX1
					SFX1.Play(victim)
				endif
				RegisterForSingleUpdate(Cooldown)
			else
				IsOnCooldown = true
				if FXS1
					FXS1.Play(victim, 2.0)
				endif
				attacker = akAggressor as actor
				if FXEmptyActivator
					objectReference obj = attacker.PlaceAtMe(FXEmptyActivator)
					obj.SetPosition(attacker.GetPositionX(), attacker.GetPositionY(), attacker.GetPositionZ() + 300.0)
					BuffSpell.RemoteCast(obj, victim, attacker)
					Cleanup(obj, 2.0)
				else
					BuffSpell.RemoteCast(attacker, victim, attacker)
				endif
				RegisterForSingleUpdate(Cooldown)
			endif
		endif
	endif
endevent

Event onUpdate()
	IsOnCooldown = false
Endevent

function Cleanup(ObjectReference ObjToClean, float WaitTime)
    Utility.WaitMenuMode(WaitTime)
    ObjToClean.disable()
    ObjToClean.delete()
endfunction

SPELL Property BuffSpell  Auto
Activator Property FXEmptyActivator  Auto
Bool Property TargetSelf  Auto
Float Property Cooldown Auto
Bool IsOnCooldown
Float ChanceForEffect
EffectShader Property FXS1  Auto  

Sound Property SFX1  Auto  
