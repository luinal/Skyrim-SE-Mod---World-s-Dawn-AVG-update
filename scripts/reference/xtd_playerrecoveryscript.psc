Scriptname XTD_PlayerRecoveryScript extends activemagiceffect 
 
Float hps
float mps
float sps
Float mainhanddamage
int debugging
Actor target
Actor attacker
Bool IsOnCooldown 
bool RegenEnabled = True
bool PlayerOnly

Event onEffectStart(Actor akTarget, Actor akCaster)
	target = akTarget
	target.ForceActorValue("VoiceRate", 0)
	debugging = (XTD_Debug.GetValue() as int)
	PeriodicHeal()
	RegisterForSingleUpdate(1)
Endevent

;Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, \
;  bool abBashAttack, bool abHitBlocked)
;	if (akSource as Spell) && !((akSource as Spell).IsHostile())
;		Return
;	endif
;	if (akAggressor as Actor && !IsOnCooldown && target.GetActorValue("OneHandedSkillAdvance") > 0.0 && Utility.RandomFloat(0,100) < 33.0)
;		if !target.IsDead() && target.GetEquippedWeapon() && !abHitBlocked && target.GetDistance(akAggressor) <= 220.0
;			IsOnCooldown = true
;			attacker = akAggressor as actor
;			if TFX1
;				TFX1.Play(target, 0.5)
;			endif
;			mainhanddamage = ((target.GetActorValue("OneHandedSkillAdvance")/100.0) * target.GetEquippedWeapon().GetBaseDamage())
;			if mainhanddamage < 0
;				mainhanddamage = 1.0
;			endif
;			If attacker.GetActorValue("Health") <= mainhanddamage
;				attacker.Kill(target)
;			else
;				attacker.DamageActorValue("Health", mainhanddamage)
;			endif
;			DebugConsole(target.GetLeveledActorBase().GetName()+" > "+attacker.GetLeveledActorBase().GetName()+": Counterattack for "+mainhanddamage as int+" damage.")
;			SFX1.Play(attacker)
;		endif
;	endif
;endevent

Event OnUpdate()
	if self && target && !target.IsDead() && target.Is3DLoaded()
		PeriodicHeal()
		RegisterForSingleUpdate(1)
	endif
	if target.IsDead()
		target.RemoveSpell(abRecovery)
	endif
	if IsOnCooldown
		IsOnCooldown = False
	Endif
Endevent

function PeriodicHeal()
	hps = target.GetActorValue("DetectLifeRange")
	mps = target.GetActorValue("EnchantingSkillAdvance")
	target.RestoreActorValue("health", hps)
	target.RestoreActorValue("magicka", mps)
endfunction

function DebugConsole(string debugstring)
	if (debugging > 0)
		MiscUtil.PrintConsole(debugstring)
	endif
endfunction

Sound Property SFX1  Auto 
SPELL Property abRecovery  Auto  
VisualEffect Property TFX1  Auto 
GlobalVariable Property XTD_Debug  Auto 