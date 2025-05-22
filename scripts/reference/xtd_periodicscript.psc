Scriptname XTD_PeriodicScript extends Quest 
 
XTD_Config Property Config Auto
WDActorScript Property Actors Auto
WDContainerScript Property Containers Auto

ObjectReference Property PlayerRef Auto

Actor[] NearbyActors
ObjectReference[] NearbyChests

Event OnInit()
	Utility.Wait(1.0)
	ScanArea()
Endevent

Event OnUpdate()
	ScanArea()
Endevent

Function ScanArea()
	if self.IsRunning()
		StoneBase = Game.QueryStat("Standing Stones Found")
		if (StoneBase > StoneCurrent)
			int i = StoneBase - StoneCurrent
			StoneCurrent = StoneBase
			SendModEvent("ExtraPointsAdd", "Standing Stone(s) Found.", i)
		endif
		MQBase = Game.QueryStat("Main Quests Completed")
		if (MQBase > MQCurrent)
			int i = MQBase - MQCurrent
			MQCurrent = MQBase
			SendModEvent("ExtraPointsAdd", "Main Quest(s) Completed.", i)
		endif
		if Config.bModActive
			if Config.bScanNPC
				NearbyActors = MiscUtil.ScanCellNPCs(PlayerRef, Config.fScanRadius, IgnoreDead = FALSE)
				Actors.Validate(NearbyActors)
			endif
			if Config.bScanChest
				NearbyChests = MiscUtil.ScanCellObjects(28, PlayerRef, Config.fScanRadius)
				Containers.Validate(NearbyChests)
			endif
		endif
		RegisterForSingleUpdate(Config.fScanInterval)
	Endif
Endfunction

int StoneBase
int StoneCurrent
int MQBase
int MQCurrent
