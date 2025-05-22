Scriptname XTD_DetectNewCellLoad extends activemagiceffect  

Actor Caster
Actor[] NearbyActors

Event onEffectStart(Actor akTarget, Actor akCaster)
	Caster = akCaster
Endevent

Event OnSpellCast(Form akSpell)
	if (VisionsOfDeath)
		VisionsOfDeathEffect(akSpell)
	elseif (Alchemist)
		AlchemistEffect(akSpell)
	endif
endEvent

Function AlchemistEffect(Form source)
	ingredient spellCast = source as ingredient
	if spellCast
		float mag = getMagnitude()
		If XTDUtil.RNDF() <= mag
		spell akBuff = FormsPack.GetAt(Utility.RandomInt(0, 6)) as Spell
		akBuff.Cast(Caster)
		AbGranted.Cast(Caster)
		Endif
	endIf
Endfunction

Function VisionsOfDeathEffect(Form source)
	MagicEffect mgef
	Spell spellCast = source as Spell
	if spellCast
		mgef = spellCast.GetNthEffectMagicEffect(0)
		if (mgef.GetAssociatedSkill() == "Conjuration" && mgef.GetDeliveryType() == 4)
			Utility.Wait(1)
			NearbyActors = MiscUtil.ScanCellNPCs(Caster)
			FilterNearbyActors(NearbyActors)
		endIf
	endIf
Endfunction

Function FilterNearbyActors(Actor[] akActors)
	int i
	While i < akActors.length
		if (!akActors[i].HasSpell(AbGranted) && akActors[i].IsCommandedActor() && !akActors[i].IsHostileToActor(Caster))
			akActors[i].AddSpell(AbGranted)
			if FXS01
				FXS01.Play(akActors[i], 1)
			endif
		endif
		i += 1
	Endwhile
Endfunction

SPELL Property AbGranted  Auto

EffectShader Property FXS01  Auto

Bool Property VisionsOfDeath  Auto
Bool Property Alchemist  Auto

FormList Property FormsPack  Auto  
