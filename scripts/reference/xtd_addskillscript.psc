Scriptname XTD_AddSkillScript extends activemagiceffect  

Event onEffectStart(Actor akTarget, Actor akCaster)
	If akTarget.HasSpell(GrantedSkill)
		If RemoveOnRecast
			akTarget.RemoveSpell(GrantedSkill)
		else
			AlreadyHas = true
		endif
	else
		akTarget.AddSpell(GrantedSkill, bAnnounce)
	endif
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	If !AlreadyHas && !RemoveOnRecast
		akTarget.RemoveSpell(GrantedSkill)
	Endif
	If !AlreadyHas && RemoveEffectOfEffect
		akTarget.RemoveSpell(SecondaryGrantedSkill)
	Endif
Endevent

Bool AlreadyHas

SPELL Property GrantedSkill  Auto 
 
SPELL Property SecondaryGrantedSkill  Auto 

Bool Property bAnnounce = TRUE Auto  

Bool Property RemoveOnRecast = FALSE Auto 

Bool Property RemoveEffectOfEffect = FALSE Auto
