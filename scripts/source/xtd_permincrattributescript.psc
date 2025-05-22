Scriptname XTD_PermIncrAttributeScript extends activemagiceffect 
 
GlobalVariable Property AttGlobal  Auto
Bool Property PointInstead = false  Auto 

Event onEffectStart(Actor akTarget, Actor akCaster)
    if (akTarget == Game.GetPlayer())
        if (PointInstead)
            ; Send event to add an attribute point with numArg = 1.0 to indicate 1 point
            SendModEvent("PlayerUseElixir", "AddPoint", 1.0)
        else
            AttGlobal.Mod(1)
            SendModEvent("PlayerStatusUpdate")
            SendModEvent("PlayerUseElixir", "", 1.0)
        endif
    endif
Endevent 