-------------------------------------------------------------------------------
-- CopyPasteKeys.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Feb 23 2019
-- Copies keys from source object to a list of target objects keeping target
-- object's position and key offset
-------------------------------------------------------------------------------
macroScript CopyAndPasteKeys 
category:"ilya_s Scripts"
tooltip:"Copy/Paste Keys"
buttontext:"Copy/Paste Keys"
(

	global cpKeys_floater
	local controller_dd_value = 1
	local target_lb_list = #()
	local targetObjList = #()
	local buttonWidth = 135


	rollout cpKeys_floater "Copy/Paste Keys"
	(
		label label1 "Source Object: " offset:[0,10] align:#left
		pickbutton sourceObj_btn "Pick Source Object" offset:[0,3] width:buttonWidth
		
		label label2 "Controller: " offset:[0,10] align:#left
		dropdownlist controller_dd "" items:#("Position", "Rotation", "Scale") selection:controller_dd_value width:buttonWidth align:#left
		checkbox replace_chb "Replace target's keys" checked:true enabled:false
		checkbox relative_chb "Relative" checked:true enabled:false
		checkbox match_chb "Match time" checked:true enabled:false
		
		listbox target_lb "Paste Keys to Objects:" items:#() height:5 offset:[0,15]
		button addObjects_btn "Add Scene Selected"width:buttonWidth 
		button remObjects_btn "Remove Selected" width:buttonWidth 
		
		button cpKeys_btn "Copy/Paste Keys" offset:[0,10] width:buttonWidth
		label spacer_lbl " " offset:[0,5] align:#left
		
		
		on sourceObj_btn picked obj do
		(
			if obj != undefined do
			(
				sourceObj_btn.text = obj.name
			)
		)
		
		on addObjects_btn pressed do
		(
			targetObjList = for o in selection collect o
			target_lb.items = for o in targetObjList collect o.name
				
		)
		
		on remObjects_btn pressed do
		(
			deleteItem targetObjList target_lb.selection 
			--deleteItem target_lb_list target_lb.selection 
			target_lb.items = for o in targetObjList collect o.name
		)
		
		on cpKeys_btn pressed do 
		(
			local sourceObj = sourceObj_btn.object 
			
			for o in targetObjList do
			(
				local sourceFirstFrame =  0f
				local targetFirstFrame = 0f
				
				local sourceFirstKeyValue = undefined
				local targetFirstKeyValue = undefined
				
				
				case controller_dd.selection  of
				(
					1:(
						sortKeys sourceObj.position.controller
						sortKeys o.position.controller
					
						sourceFirstFrame =  try(getKeyTime (sourceObj.position.controller) 1)catch(0f)
						targetFirstFrame = try (getKeyTime (o.position.controller) 1)catch(0f)

						local timeOffset = targetFirstFrame - sourceFirstFrame
					
						sourceFirstKeyValue = at time sourceFirstFrame sourceObj.position.controller.value
						targetFirstKeyValue = at time targetFirstFrame o.position.controller.value

						local valueOffset = targetFirstKeyValue - sourceFirstKeyValue

						o.position.controller = copy sourceObj.position.controller
						o.position = (o.position + valueOffset)
						insertTime o.position.controller (sourceFirstFrame) timeOffset
					)
					2:(
						sortKeys sourceObj.rotation.controller
						sortKeys o.rotation.controller
					
						sourceFirstFrame =  try(getKeyTime (sourceObj.rotation.controller) 1)catch(0f)
						targetFirstFrame = try (getKeyTime (o.rotation.controller) 1)catch(0f)

						local timeOffset = targetFirstFrame - sourceFirstFrame
					
						sourceFirstKeyValue = at time sourceFirstFrame sourceObj.rotation.controller.value
						targetFirstKeyValue = at time targetFirstFrame o.rotation.controller.value

						local valueOffset = targetFirstKeyValue - sourceFirstKeyValue

						o.rotation.controller = copy sourceObj.rotation.controller
						o.rotation = (o.rotation + valueOffset)
						insertTime o.rotation.controller (sourceFirstFrame) timeOffset
					)
					3:(
						sortKeys sourceObj.scale.controller
						sortKeys o.scale.controller
					
						sourceFirstFrame =  try(getKeyTime (sourceObj.scale.controller) 1)catch(0f)
						targetFirstFrame = try (getKeyTime (o.scale.controller) 1)catch(0f)
						
						local timeOffset = targetFirstFrame - sourceFirstFrame
						
						sourceFirstKeyValue = at time sourceFirstFrame sourceObj.scale.controller.value
						targetFirstKeyValue = at time targetFirstFrame o.scale.controller.value

						local valueOffset = targetFirstKeyValue - sourceFirstKeyValue

						o.scale.controller = copy sourceObj.scale.controller
						o.scale = (o.scale + valueOffset)
						insertTime o.scale.controller (sourceFirstFrame) timeOffset
					)
				)
			)
		)		
	)

	on execute do 
	(
		try(destroydialog cpKeys_floater)catch()
		createDialog cpKeys_floater
	) --end execute
)