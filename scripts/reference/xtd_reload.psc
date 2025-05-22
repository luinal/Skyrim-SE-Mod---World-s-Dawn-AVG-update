Scriptname XTD_Reload extends ReferenceAlias 
 
event OnPlayerLoadGame()
    (GetOwningQuest() as XTD_Config).ReregisterModEvent()
endEvent

;Event OnCellLoad()
;MiscUtil.PrintConsole("Every object in this cell has loaded its 3d")
;Endevent