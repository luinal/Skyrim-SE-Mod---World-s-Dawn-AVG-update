Scriptname XTD_PermIncrAttributeScript extends activemagiceffect 
 
GlobalVariable Property AttGlobal  Auto
Bool Property PointInstead = false  Auto 

Event onEffectStart(Actor akTarget, Actor akCaster)
	if (akTarget == Game.GetPlayer())
		if (PointInstead)
			SendModEvent("PlayerUseElixir", "AddPoint")
		else
			AttGlobal.Mod(1)
			SendModEvent("PlayerStatusUpdate")
			SendModEvent("PlayerUseElixir")
		endif
	endif
Endevent
