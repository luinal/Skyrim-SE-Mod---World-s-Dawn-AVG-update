Scriptname WDAttributesPercent extends activemagiceffect  

Int ModBy
Actor Target

String Property StatArg Auto
Int Property AttributeIndex Auto
XTD_Attributes Property Attributes Auto
GlobalVariable Property XTDAttribute  Auto

Event onEffectStart(Actor akTarget, Actor akCaster)
	ModBy = (Attributes.GetTotalValue(AttributeIndex) * (GetMagnitude() *0.01)) as int
	XTDAttribute.Mod(ModBy)
	Utility.WaitMenuMode(0.1)
	SendModEvent("PlayerStatusUpdate", StatArg)
Endevent

Event onEffectFinish(Actor akTarget, Actor akCaster)
	XTDAttribute.Mod(-ModBy)
	Attributes.ResetOnEffectFinish(StatArg)
Endevent