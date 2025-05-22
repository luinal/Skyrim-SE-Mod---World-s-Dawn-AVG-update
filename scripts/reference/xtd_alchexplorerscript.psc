Scriptname XTD_AlchExplorerScript extends activemagiceffect
 
Actor Imbiber
Int LocBaseNum
Int LocCurNum
Float ProcChance

Event onEffectStart(Actor akTarget, Actor akCaster)
    if (akTarget != Game.GetPlayer())
		Return
	else
		Imbiber = akTarget
		ProcChance = GetMagnitude()/100
		LocBaseNum = Game.QueryStat("Locations Discovered")
    endif
    RegisterForUpdate(1.0)
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
Endevent

Event OnUpdate()
	LocCurNum = Game.QueryStat("Locations Discovered")
	if (LocCurNum > LocBaseNum)
		LocBaseNum = LocCurNum
		if (Utility.RandomFloat() <= ProcChance)
			Game.AddPerkPoints(1)
			FXS1.Play(Imbiber,2)
			debug.Notification("You learnt something new from your travels. 1 perk point is available!")
		endif
	endif
Endevent

EffectShader Property FXS1  Auto 
