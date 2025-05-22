Scriptname XTD_WEAPDebuff extends activemagiceffect  

Event onEffectStart(Actor akTarget, Actor akCaster)
		If bHarm
			if akTarget.HasKeyword(FEKeyword)
				float fDamage = Game.QueryStat(FEString)/10.0
				If fDamage < 1.0
					fDamage = 1.0
				elseif fDamage > (akTarget.GetBaseActorValue("Health") * 0.15)
					fDamage = (akTarget.GetBaseActorValue("Health") * 0.15)
				endif
				If akTarget.GetActorValue("Health") <= fDamage
					FXS01.Play(akTarget, 0.25)
					akTarget.Kill(akCaster)
				else
					FXS01.Play(akTarget, 1.0)
					akTarget.DamageActorValue("Health", fDamage)
				endif
			endif
		Elseif bTargetSelf
			DeBuffSpell.Cast(akCaster, akCaster)
		else
			DeBuffSpell.RemoteCast(akTarget, akCaster, akTarget)
		endif
Endevent

SPELL Property DeBuffSpell  Auto
Bool Property bHarm  Auto  
Bool Property bTargetSelf  Auto 
Keyword Property FEKeyword  Auto 
String Property FEString  Auto 
EffectShader Property FXS01  Auto  
