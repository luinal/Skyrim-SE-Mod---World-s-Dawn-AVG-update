Scriptname XTD_VanishScript extends activemagiceffect  

Actor Caster
Bool triggered

SPELL Property Vanish  Auto
SPELL Property VanishCooldown  Auto

Event onEffectStart(Actor akTarget, Actor akCaster)
    Caster = akTarget
Endevent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, \
  bool abBashAttack, bool abHitBlocked)
    if (!triggered && (akAggressor as Actor) && (akAggressor as Actor).GetFlyingState() == 0 && !Caster.IsDead() && (Caster as ObjectReference).GetDistance(akAggressor) >= 200.0 && (Caster as ObjectReference).GetDistance(akAggressor) <= 2000.0)
        triggered = true
        dispel()
        VanishCooldown.Cast(Caster)
        Vanish.Cast(Caster)
        PerformVanish(akAggressor, (Caster as ObjectReference))
    endif
endevent

function PerformVanish(ObjectReference akTarget, ObjectReference akCaster)
    akCaster.MoveTo(akTarget, -100.0 * Math.Sin(akTarget.GetAngleZ()), -100.0 * Math.Cos(akTarget.GetAngleZ()), akTarget.GetHeight() + 1.0)
endfunction
