Scriptname XTD_ProcOnBlockBuff extends activemagiceffect  

actor caster

Event onEffectStart(Actor akTarget, Actor akCaster)
	caster = akTarget
	BuffValue = GetMagnitude()
	BuffChance = ChanceForEffect/100.0
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	if (IsOnCooldown)
		IsOnCooldown = false
		if !(AppliesSpell) || (UsePercent)
			caster.ModActorValue(TargetStat,-BuffValue)
		endif
		caster.DispelSpell(SpellVisual)
	endif
Endevent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, \
  bool abBashAttack, bool abHitBlocked)
	if !IsOnCooldown && (akAggressor as Actor) && abHitBlocked
		if (abPowerAttack)
			BuffChance *= 1.25
		endif
		if (UsePercent)
			if Utility.RandomFloat() <= BuffChance
				IsOnCooldown = true
				BuffValue = (caster.GetActorValue(SourceStat) * GetMagnitude())/100.0
				SpellVisual.Cast(caster)
				caster.ModActorValue(TargetStat,BuffValue)
				RegisterForSingleUpdate(BuffCooldown)
			endif		
		else
			if Utility.RandomFloat() <= BuffChance
				IsOnCooldown = true				
				if (AppliesSpell)
					SpellVisual.Cast(caster)
				else
					SpellVisual.Cast(caster)
					caster.ModActorValue(TargetStat,BuffValue)
				endif
				RegisterForSingleUpdate(BuffCooldown)
			endif
		endif
	endif
endevent

Event onUpdate()
	IsOnCooldown = false
	if !(AppliesSpell) || (UsePercent)
		caster.ModActorValue(TargetStat,-BuffValue)
	endif
Endevent

Float BuffValue
Float BuffChance
Bool IsOnCooldown

Bool Property AppliesSpell  Auto
Bool Property UsePercent  Auto
String Property TargetStat Auto
String Property SourceStat Auto
Float Property ChanceForEffect=21.0 Auto
Float Property BuffCooldown=1.0	Auto
SPELL Property SpellVisual  Auto  
Sound Property SFX1  Auto  
