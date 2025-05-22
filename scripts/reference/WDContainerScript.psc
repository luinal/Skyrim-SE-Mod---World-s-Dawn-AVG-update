Scriptname WDContainerScript extends Quest  

Function Validate(ObjectReference[] ValidContainers)
	int i
	While i < ValidContainers.length
		If ValidContainers[i] && !(WDContainersBlacklist.HasForm(ValidContainers[i].GetBaseObject() as Form)) && !(ValidContainers[i].IsDisabled()) && (ValidContainers[i].GetItemCount(WDToken) < 1)
			XTD.ChestScanned += 1
			SetContainerRef(ValidContainers[i])
		Endif
		i += 1
	Endwhile
Endfunction 

Function SetContainerRef(ObjectReference afContainer)
	int i
	While i < RefAliases.length
		If RefAliases[i].GetRef()
			i += 1
		Else
			afContainer.AddItem(WDToken,1)
			RefAliases[i].ForceRefTo(afContainer)
			RefAliases[i].RegisterForModEvent("ObjRefFill", "OnObjRefFill")
			SendModevent("ObjRefFill")
			i = 100
		Endif
	Endwhile
Endfunction

MiscObject Property WDToken  Auto 
XTD_BaseScript Property XTD Auto
FormList Property WDContainersBlacklist  Auto  
ReferenceAlias[] Property RefAliases  Auto  
