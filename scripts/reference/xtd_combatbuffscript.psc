Scriptname XTD_CombatBuffScript extends activemagiceffect  

actor target
bool StillInCombat
bool BuffIsOn

Event onEffectStart(Actor akTarget, Actor akCaster)
    target = akTarget
    RegisterForSingleUpdate(1.0)
Endevent

Event onUpdate()
if target && target != NONE
	 if target.IsInCombat() && !StillInCombat
		StillInCombat = true
		If SFX1
			SFX1.Play(target)
		Endif
		SpellVisual.Cast(target)
	elseif !target.IsInCombat() && StillInCombat
		StillInCombat = false
		target.DispelSpell(SpellVisual)
	endif
	RegisterForSingleUpdate(1.0)
endif
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	target.DispelSpell(SpellVisual)
Endevent

Sound Property SFX1  Auto  
SPELL Property SpellVisual  Auto  
