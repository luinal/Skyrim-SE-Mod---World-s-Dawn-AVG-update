Scriptname XTD_BreakEffectOnHit extends activemagiceffect  

Actor target
Bool keepRunning = TRUE

Event onEffectStart(Actor akTarget, Actor akCaster)
    target = akTarget
Endevent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, \
  bool abBashAttack, bool abHitBlocked)
  if keepRunning && akAggressor && (akAggressor as Actor).IsHostileToActor(target)
	if DispelOnHit
		Target.dispelspell(ThisSpell)
	else
		keepRunning = FALSE
		akAggressor.PushActorAway(target, 1.0)
		RegisterForSingleUpdate(EffectCooldown)
	endif
  endif
Endevent

Event OnUpdate()
	keepRunning = TRUE
Endevent

SPELL Property ThisSpell  Auto 
Float Property EffectCooldown  Auto 
Bool Property DispelOnHit = TRUE Auto 
