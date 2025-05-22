Scriptname XTD_ProcSelf_Flag extends activemagiceffect  

Event onEffectStart(Actor akTarget, Actor akCaster)
	if akTarget != Game.GetPlayer()
		if !(akTarget.GetLeveledActorBase().IsInvulnerable())
			akTarget.GetLeveledActorBase().SetInvulnerable()
		endif
	endif
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	if akTarget != Game.GetPlayer()
		if akTarget.GetLeveledActorBase().IsInvulnerable()
			akTarget.GetLeveledActorBase().SetInvulnerable(false)
		endif
	endif
Endevent
