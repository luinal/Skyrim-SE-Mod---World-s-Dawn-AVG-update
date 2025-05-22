Scriptname XTD_ApplyStatTreshhold extends activemagiceffect  

Actor target
Bool bApplied

Event onEffectStart(Actor akTarget, Actor akCaster)
    target = akTarget
    if decimalBonus
        baseBonus = GetMagnitude()/100.0
    else
        baseBonus = GetMagnitude()
    endif
    ModStatEffect()
    RegisterForUpdate(1.0)
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	CancelBuff() 
Endevent

Event OnUpdate()
    ModStatEffect()
    if (!target || target.IsDead())
        UnregisterForUpdate()
    endif
Endevent

function ModStatEffect()
    if LessOrEqual
        if !bApplied && target.GetActorValuePercentage(baseStat) <= (baseThreshold/100.0)
			ApplyBuff()
        elseif (bApplied && target.GetActorValuePercentage(baseStat) > (baseThreshold/100.0))
			CancelBuff()            
        endif
    else
        if !bApplied && target.GetActorValuePercentage(baseStat) >= (baseThreshold/100.0)
			ApplyBuff()
        elseif (bApplied && target.GetActorValuePercentage(baseStat) < (baseThreshold/100.0))
			CancelBuff()           
        endif
    endif
endfunction

function PlayFX()
    FXS01.play(target)
    VFX1.Play(target)
endfunction

function StopFX()
        VFX1.stop(target)
endfunction

function ApplyBuff()
	bApplied = true
	target.ModActorValue(ValueToMod, baseBonus)
	PlayFX()
endfunction

function CancelBuff()
	bApplied = false
	target.ModActorValue(ValueToMod, -baseBonus)
	StopFX()
endfunction

String Property baseStat  Auto  
String Property ValueToMod  Auto  
Bool Property LessOrEqual  Auto
Bool Property decimalBonus  Auto
Float Property baseThreshold  Auto
Float Property baseBonus  Auto

Sound Property FXS01  Auto  
VisualEffect Property VFX1  Auto   
