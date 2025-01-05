macroScript UVWExport
category:"ilya_s Scripts"
tooltip:"UVWExport Export UVW as ai and tga"
buttontext:"UVWExport"
(
/*


*/
	global UVWExport_RO
	
	fn testRenderResult = 
	(
		local hwnd = dialogMonitorOps.getWindowHandle()
		local windText = UIAccessor.GetWindowText hwnd 
		
		if windText != undefined then 
		(
			print windText
			if MatchPattern windText pattern:"Render Map*" then
			(
				UIAccessor.CloseDialog hwnd
				true
			)
		)
		else false
	)
		
	fn renderUVW res = 
	(
		if selection.count != 1 then
		(
			messageBox "Please select only one object"
		)
		else
		(
			max modify mode
			local unwrapMod = (for m in $.modifiers where classof m == UVWUnwrap collect m)[1]
			
			--DialogMonitorOPS.unRegisterNotification id:#unwrap_render
			
			if unwrapMod != undefined then 
			(
				
				local f = getSaveFileName types:"Targa(*.tga)|*.tga|All|*.*|"
				if MatchPattern f pattern:"*.tga" != true then f = f + ".tga"
				if f != undefined then
				(
					--DialogMonitorOPS.enabled = true
					--DialogMonitorOPS.interactive = false
					--DialogMonitorOPS.registerNotification testRenderResult id:#unwrap_render
					modPanel.setCurrentObject unwrapMod node:$ ui:true
					unwrapMod.renderuv_width = res
					unwrapMod.renderuv_height = res
					unwrapMod.renderuv_force2sided = true
					unwrapMod.renderuv_fillmode = 1
					subobjectLevel = 3
					unwrapMod.renderUV f
					subobjectLevel = 0
					
					--DialogMonitorOPS.enabled = false
					--DialogMonitorOPS.unRegisterNotification id:#unwrap_render
					

					local obj = copy $
					clearSelection()
					select obj
					channelInfo.CopyChannel obj 3 1
					channelInfo.PasteChannel obj 1 0
					channelInfo.NameChannel obj 1 0 "-none-"
					obj.rotation = (quat 0 0 0 1)
					obj.position = [0,0,0]
					macros.run "Modifier Stack" "Convert_to_Poly"
					subobjectLevel = 3 -- Select Boundries
					actionMan.executeAction 0 "40021"  -- Selection: Select All
					$.EditablePoly.createShape "ShapeForExport" off $
					subobjectLevel = 0
					local ShapeForExport = $ShapeForExport
					
					--Create a rectangle which will be the bounds of the rendered UVW map
					local boundryRect = Rectangle length:1 width:1 cornerRadius:0 pos:[0.5,0.5,0] isSelected:off
					convertToSplineShape boundryRect
					addAndWeld ShapeForExport boundryRect 0.0
					
					--Rescale the UVW shape to be the correct res in Illustrator
					ShapeForExport.scale = [res/72.0, res/72.0, res/72.0]
					ResetXForm ShapeForExport
					convertToSplineShape ShapeForExport
					select ShapeForExport
					exportFile ((getfilenamepath f) + (getfilenamefile f) + ".ai") #noPrompt selectedOnly:true using:Adobe_Illustrator
					
					--Clean up
					delete ShapeForExport
					delete obj
				)
			)
			else
			(
				messageBox "No UVWUnwrap modifer found in selected object"
			)
		)
	)
	
	rollout UVWExport_RO "Render and Export UVW" width:500 height:200
	(
		local res = 4*1024
		dropdownList renderRes_dd "Render Resolution:" items:#("4K","6K","8K","10K","12K","14K")
		button render_btn "Render" across:2 width:80
		button cancel_btn "Cancel" width:80
		
		on renderRes_dd selected i do
		(
			local iRes = (substring renderRes_dd.items[i] 1 (renderRes_dd.items[i].count - 1)) as integer
			res = 1024 * iRes
		)
			
		on cancel_btn pressed do
		(
			destroydialog UVWExport_RO
		)

		on render_btn pressed do
		(
			renderUVW res
			--destroydialog UVWExport_RO
		)
	)
	
	on execute do
	(
		try(DestroyDialog UVWExport_RO)
		catch()
		CreateDialog UVWExport_RO
	)
	
)