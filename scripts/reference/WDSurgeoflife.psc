Scriptname WDSurgeoflife extends activemagiceffect  

Actor caster

Sound Property SFX1  Auto  
Keyword Property MagicRestoreHealth Auto
XTD_Attributes Property Attributes Auto
GlobalVariable Property XTD_Debug  Auto  

Event onEffectStart(Actor akTarget, Actor akCaster)
	caster = akCaster
Endevent

Event OnSpellCast(Form akSpell)
	Spell spellCast = akSpell as Spell
	if spellCast
		string critMsg = "."
		MagicEffect mgef = spellCast.GetNthEffectMagicEffect(0)
		if (mgef.GetAssociatedSkill() == "Restoration" && mgef.HasKeyword(MagicRestoreHealth))
				float mag = (Attributes.GetTotalValue(5) * 0.25) * (1 + caster.GetAV("RestorationPowerMod") * 0.01)
				if Utility.RandomFloat(0, 100) <= caster.GetAV("CritChance")
					mag *= 2
					critMsg = " (critical!)"
				endif
				caster.RestoreAV("Health", mag)
				if SFX1
					SFX1.Play(caster)
				endif
				if (XTD_Debug.GetValue() as int == 1)
					MiscUtil.PrintConsole("World's Dawn: [Surge of Life] restored "+mag as int+" health to "+caster.GetLeveledActorBase().GetName()+critMsg)
				endif
		endIf
	endif
endEvent
