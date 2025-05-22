Scriptname XTD_RecoveryScript extends activemagiceffect  

Actor ThisActor

Event onEffectStart(Actor akTarget, Actor akCaster)
	ThisActor = akTarget
	if !(ThisActor.HasSpell(abRecovery))
		RecoveryValue = GetMagnitude()
		ThisActor.RestoreActorValue(StatToRecover, RecoveryValue)
		RegisterForSingleUpdate(1)
	endif
Endevent

Event OnUpdate()
	if self && ThisActor &&  !ThisActor.IsDead() && ThisActor.Is3DLoaded()
		ThisActor.RestoreActorValue(StatToRecover, RecoveryValue)
		RegisterForSingleUpdate(1)
	endif
Endevent

Float RecoveryValue 
String Property StatToRecover  Auto

SPELL Property abRecovery  Auto  
