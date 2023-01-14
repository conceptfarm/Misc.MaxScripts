-------------------------------------------------------------------------------
-- SlicerRigger.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- June 08 2022
-- Rigs slice modifers based on object's child Points
-------------------------------------------------------------------------------
macroScript SliceRigger
category:"ilya_s Scripts"
tooltip:"SliceRigger"
buttontext:"SliceRigger"
(
	global sliceDataAttribute
	sliceDataAttribute = attributes sliceData attribID:#(0x3dadac47, 0x79752f33) version:1
	(
		parameters main rollout:params
		(
			offset_val type: #float ui:offset_spn default:1.0 animatable: true
		)
		
		rollout params "Slice Parameters"
		( 
			spinner offset_spn "Slice Offset" type: #float
		)
	)
	
	fn checkChildObjects obj = 
	(
		local result = false
		local points = for o in obj.children where classof o == Deflector collect o
		
		if points.count == obj.children.count and obj.children.count != 0 then result = true
		
		result
	)
	
	if selection.count == 1 and superclassof selection[1] == GeometryClass then
	(
		local masterObj = selection[1]
		clearSelection()
		
		if checkChildObjects masterObj == true then
		(
			addModifier masterObj (EmptyModifier())
			masterObj.modifiers[1].name = "Slice Offset"
			
			custAttributes.add masterObj.modifiers[1] sliceDataAttribute
			masterObj.modifiers[#Slice_Offset].sliceData.offset_val.controller = bezier_float()
				
			local prevModifiers = #()
			for i=1 to masterObj.children.count+1 do
			(
				local sliceSection = reference masterObj
				local childIndex = i
				
				if i > masterObj.children.count then childIndex = masterObj.children.count
				
				if i != 1 then 
				(
					for m = 1 to prevModifiers.count do
					(
						addModifier sliceSection (copy prevModifiers[m])
						sliceSection.modifiers[1].name = "Slice " + m as string
						sliceSection.modifiers[1].Slice_Type = 3
					)
				)
				
				addModifier sliceSection (SliceModifier()) 
				sliceSection.modifiers[1].name = "Slice " + (prevModifiers.count + 1) as string
				sliceSection.modifiers[1].Slice_Type = if i > masterObj.children.count then 3 else 2
				sliceSection.modifiers[1].slice_plane.controller = transform_script()
				sliceSection.modifiers[1].slice_plane.controller.addTarget "h" masterObj.children[childIndex].transform.controller
				sliceSection.modifiers[1].slice_plane.controller.addTarget "offset_val" masterObj.modifiers[#Slice_Offset].sliceData.offset_val.controller
				sliceSection.modifiers[1].slice_plane.controller.script = "Translate h ([0, 0, offset_val] * h.rotation)"
				
				append prevModifiers sliceSection.modifiers[1]
					
				addModifier sliceSection (SliceModifier()) 
				sliceSection.modifiers[1].name = "Slice " + (prevModifiers.count + 1) as string
				sliceSection.modifiers[1].Slice_Type = if i > masterObj.children.count then 3 else 2
				sliceSection.modifiers[1].slice_plane.controller = transform_script()
				sliceSection.modifiers[1].slice_plane.controller.addTarget "h" masterObj.children[childIndex].transform.controller
				sliceSection.modifiers[1].slice_plane.controller.addTarget "offset_val" masterObj.modifiers[#Slice_Offset].sliceData.offset_val.controller
				sliceSection.modifiers[1].slice_plane.controller.script = "Translate h ([0, 0, -offset_val] * h.rotation)"
				
				append prevModifiers sliceSection.modifiers[1]
			)
		)
		else
		(
			messageBox "Deflector helpers, that will be used as slice guides, must be parented to the object."
		)
	)
	else
	(
		messageBox "Select one geometry object. Deflector helpers must be parented to the object."
	)
)