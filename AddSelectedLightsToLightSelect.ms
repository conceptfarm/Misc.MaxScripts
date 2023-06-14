macroScript AddLightsToLightSelect
category:"ilya_s Scripts"
tooltip:"AddLightsToLS"
buttontext:"AddLightsToLS"
(
	-- Not the best way to do this
	-- Basically gets the "Enable Filter" checkbox and gets the next element which is the field with the name of the selected render element
	-- from there we find the render element object with that name
	fn getSelectedRendEle =
	(
		local result = undefined
		local hWnd = for i in (windows.getChildrenHWND (windows.getDesktopHWND())) where matchpattern i[5] pattern:"Render Setup*" do (exit with i[1])

		if hWnd then
		(
			local renderWindChild = windows.getChildrenHWND hWnd
			local index = for i=1 to renderWindChild.count where matchpattern renderWindChild[i][5] pattern:"Enable Filtering*" do (exit with i)
			local rendEleName = renderWindChild[index+1][5]
			
			if rendEleName != "" then
			(
				local re =  MaxOps.GetCurRenderElementMgr() 
				local rendEleObj = for i = 0 to re.NumRenderElements() - 1 where (re.GetRenderElement i).elementName == rendEleName do (exit with re.GetRenderElement i)
				
				if rendEleObj != undefined and classof rendEleObj == VRayLightSelect then result = rendEleObj
			)
		)
		result
	)


	if (tabbedDialogs.getPageTitle #render (tabbedDialogs.getCurrentPage #render) == "Render Elements") then
	(
		local rendEleObj = getSelectedRendEle()
		if rendEleObj != undefined then
		(
			if rendEleObj.lights.count > 0 then
			(
				local qb = yesNoCancelBox "Lights found in the selected renderer element.\nAppend?\n\n[Yes] -  Append selected to list\n[No]   - Overwrite list"
				
				if qb == #yes then 
				(
					local arr = makeUniqueArray (join (rendEleObj.lights as array) (for o in selection as array where superclassof o == light collect o ))
					rendEleObj.lights = arr
				)
				else if qb == #no then (rendEleObj.lights = for o in selection as array where superclassof o == light collect o)
			)
			else
			(
				rendEleObj.lights = for o in selection as array where superclassof o == light collect o
			)
			
		)
		else
		(
			messageBox "Select a VRayLightSelect render element to add lights to"
		)
	)
	else
	(
		messageBox "Open the Render Setup dialog and select a VRayLightSelect render element"
	)
)