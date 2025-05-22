Scriptname WDProcOnAttack extends activemagiceffect  

SPELL Property RemoteSpell  Auto
Activator Property FXEmptyActivator  Auto

Event onEffectStart(Actor akTarget, Actor akCaster)
	If XTDUtil.RNDF() < GetMagnitude()
		CastSpellOnAttack(akTarget, akCaster)
	Endif
Endevent

Function CastSpellOnAttack(Actor akTarget, Actor akCaster)
	if FXEmptyActivator
		objectReference obj = akTarget.PlaceAtMe(FXEmptyActivator)
		obj.SetPosition(akTarget.X, akTarget.Y, akTarget.Z + 300.0)
		RemoteSpell.RemoteCast(obj, akCaster, akTarget)
		Cleanup(obj, 1.0)
	else
		RemoteSpell.RemoteCast(akCaster, akCaster, akTarget)
	endif
Endfunction

function Cleanup(ObjectReference ObjToClean, float WaitTime)
    Utility.Wait(WaitTime)
    ObjToClean.disable()
    ObjToClean.delete()
endfunction