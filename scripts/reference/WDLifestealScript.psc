Scriptname WDLifestealScript extends activemagiceffect  

Event onEffectStart(Actor akTarget, Actor akCaster)
	If (akTarget.IsDead() || akCaster.IsInKillMove())
		Return
	Endif
	String stat = StolenStat
	If (bUseSecondStat)
		stat = RestoredStat
	Endif
	Float mag = (akTarget.GetActorValue(StolenStat) * (GetMagnitude() * 0.01))
	If (bRestore)
		akCaster.RestoreActorValue(RestoredStat, mag * fRestoreRatio)
	Elseif (bHarmful)
		akTarget.DamageActorValue(StolenStat, mag * fRestoreRatio)
	Endif
	If (stat == "health")
		If (akTarget.GetActorValue(stat) > mag)
			akTarget.DamageAV(stat, mag)
		Else
			akTarget.Kill(akCaster)
		Endif
	Else
		akTarget.DamageAV(stat, mag)
	Endif
	If (FXShader)
		FXShader.Play(akCaster,0.2)
	Endif
Endevent

Bool Property bRestore = TRUE Auto
Bool Property bHarmful Auto 
Bool Property bUseSecondStat Auto 
String Property StolenStat = "health" Auto
String Property RestoredStat = "health" Auto
EffectShader Property FXshader  Auto
Float Property fRestoreRatio = 2.0 Auto  
