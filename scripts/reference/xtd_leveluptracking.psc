Scriptname XTD_LevelUpTracking extends Quest 
 
Event OnStoryIncreaseLevel(int aiLevel)
	SendModEvent("XTDPlayerLevelUp")
	Stop()
EndEvent