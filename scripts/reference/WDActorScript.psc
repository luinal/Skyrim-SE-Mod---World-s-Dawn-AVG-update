Scriptname WDActorScript extends Quest  

Function Validate(Actor[] ValidActors)
	int i
	While i < ValidActors.length
		If (ValidActors[i] != PlayerRef) && IsValidNPC(ValidActors[i]) && (ValidActors[i].GetItemCount(xtdToken) < 1)
			XTD.NPCScanned += 1
			SetNPCRef(ValidActors[i])
		Endif
		i += 1
	Endwhile
Endfunction 

Function SetNPCRef(Actor akActor)
	int i
	While i < RefAliases.length
		If RefAliases[i].GetActorRef()
			i += 1
		Else
			akActor.AddItem(xtdToken,1)
			RefAliases[i].ForceRefTo(akActor)
			RefAliases[i].RegisterForModEvent("ActorAliasFill", "OnActorAliasFill")
			SendModevent("ActorAliasFill")
			i = 100
		Endif
	Endwhile
Endfunction

bool Function IsValidNPC(Actor akActor)
	Return !(akActor.IsDisabled() || akActor.IsGhost() || akActor.IsPlayerTeammate() || akActor.IsCommandedActor())
Endfunction

Actor Property PlayerRef Auto
XTD_BaseScript Property XTD Auto
MiscObject Property xtdToken  Auto
ReferenceAlias[] Property RefAliases  Auto  