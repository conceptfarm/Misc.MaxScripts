-------------------------------------------------------------------------------
-- TrimPath.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Feb 16th 2019
-- A modifier that is added to the NURBS curve to do a trim path like function
-- like in AfterEffects.
-------------------------------------------------------------------------------
plugin modifier TrimPath
name:"Trim Path"
category:"ilya_s Scripts"
classID:#(0x52abffc9, 0x677691ad)
extends:EmptyModifier
replaceUI:true
version:0.11
(
	
	local buttonWidth = 135

	parameters main rollout:params
	(

		startPercent_spn type:#float animatable:true ui:startPercent_spn default:50
		endPercent_spn type:#float animatable:true ui:endPercent_spn default:10
		segLength_spn type:#float animatable:true ui:segLength_spn default:4.5
		length_float type:#float animatable:true
		startObj_val type:#node 
		endObj_val type:#node 
	)

	rollout params "Submitter Properties"
	(
		group "Trim Path Geometry"
		(
			dropdownlist shape_dd "Section/3D Form" items:#("Round/Cylinder","Round/Round Caps","Square/Box","Hollow/Tube","Flat/Ribbon") selection:1 width:buttonWidth
			spinner segLength_spn "Seg. Length"  type:#float range:[0,1000000,4.5]
			
		)

		group "Start/End Objects"
		(
			pickbutton startObj_btn "Pick Start Obj" width:buttonWidth
			pickbutton endObj_btn "Pick End Obj" width:buttonWidth
		)

		group "Generate"
		(
			button create_btn "Create Geometry" width:buttonWidth	
		)

		group "Animate"
		(
			spinner startPercent_spn "Start %" type:#float range:[0,100.0,50.0]
			spinner endPercent_spn   "  End %" type:#float range:[0,100.0,10.0]
		)

		on params open do
		(
			if startObj_val != undefined then startObj_btn.text = startObj_val.name
			if endObj_val != undefined then endObj_btn.text = endObj_val.name

			/*if  classof $ != NURBSCurveshape then
			(
				messageBox "Non-NURBS spline detected - Start/End objects option will be disabled\nUse a NURBS spline for that."
				endObj_btn.enabled = false
				startObj_btn.enabled = false
			)*/
		)

		on create_btn pressed do
		(
			if  ($.modifiers[#TrimPath].'startPercent_spn'.controller == undefined) then
			(
 				$.modifiers[#TrimPath].'startPercent_spn'.controller = bezier_float()
			)

			if  ($.modifiers[#TrimPath].'endPercent_spn'.controller == undefined) then
			(
 				$.modifiers[#TrimPath].'endPercent_spn'.controller = bezier_float()
			)

			if  ($.modifiers[#TrimPath].'segLength_spn'.controller == undefined) then
			(
 				$.modifiers[#TrimPath].'segLength_spn'.controller = bezier_float()
			)

			if  ($.modifiers[#TrimPath].'length_float'.controller == undefined) then
			(
 				$.modifiers[#TrimPath].'length_float'.controller = float_script()
 				$.modifiers[#TrimPath].'length_float'.controller.addNode "o" $
 				$.modifiers[#TrimPath].'length_float'.controller.script = "curveLength o 1"
			)


			local shapeLength = curveLength $ 1
			local heightSegs = shapeLength/segLength_spn.value
			local shapeSelection = shape_dd.selection -- case of changes the actual variable or resets it, somthing happens after xform creation, probably UI gets reset
			length_float = shapeLength

			local trimObj = undefined

			case shapeSelection of 
			(
				1:(trimObj = Cylinder smooth:on heightsegs:heightSegs capsegs:1 sides:25 height:shapeLength radius:(shapeLength/160.0) mapcoords:on realWorldMapSize:on pos:[0,0,0] )
				2:(trimObj = OilTank radius:(shapeLength/160.0) Cap_Height:((shapeLength/160.0)*0.99) height:shapeLength Blend:0.0 sides:35 Height_Segments:heightSegs Smooth_On:1 Slice_On:0 Slice_From:0 Slice_To:0 mapcoords:1 realWorldMapSize:on pos:[0,0,0])
				3:(trimObj = Box lengthsegs:1 widthsegs:1 heightsegs:heightSegs length:(shapeLength/160.0) width:(shapeLength/160.0) height:shapeLength mapcoords:on realWorldMapSize:on pos:[0,0,0] )
				4:(trimObj = Tube smooth:on heightsegs:heightSegs capsegs:1 sides:25 height:shapeLength radius1:(shapeLength/160.0) radius2:(shapeLength/165.0) mapcoords:on realWorldMapSize:on pos:[0,0,0])
				5:(trimObj = Plane realWorldMapSize:on length:shapeLength width:(shapeLength/160.0) pos:[0,0,0];)
			)
			
			xf = XForm()
			addModifier trimObj xf
			trimObj.modifiers[#XForm].Gizmo.scale.controller = scale_script()

			trimObj.modifiers[#XForm].Gizmo.scale.controller.AddTarget "percent" $.modifiers[#TrimPath].'startPercent_spn'.controller
			trimObj.modifiers[#XForm].Gizmo.scale.controller.AddTarget "percentEnd" $.modifiers[#TrimPath].'endPercent_spn'.controller
			if (shapeSelection == 5) then 
			(
				trimObj.modifiers[#XForm].Center = [0,(trimObj.length/2.0),0]
				trimObj.pivot.y = trimObj.min.y
				trimObj.modifiers[#XForm].Gizmo.scale.controller.script = "xy = 1;if (abs(percent-percentEnd)) < 1 then xy = (abs(percent-percentEnd)) else xy = 1;[xy, (percent-percentEnd)/100.0,xy]"
			)
			else
			(
				trimObj.modifiers[#XForm].Gizmo.scale.controller.script = "xy = 1;if (abs(percent-percentEnd)) < 1 then xy = (abs(percent-percentEnd)) else xy = 1;[xy, xy, (percent-percentEnd)/100.0]"
			)
			
			if (shapeSelection == 1 or shapeSelection == 3 or shapeSelection== 4) then
			(
				trimObj.heightsegs.controller = float_script()
				trimObj.heightsegs.controller.AddTarget "length" $.modifiers[#TrimPath].'length_float'.controller
				trimObj.heightsegs.controller.AddTarget "percent" $.modifiers[#TrimPath].'startPercent_spn'.controller
				trimObj.heightsegs.controller.AddTarget "percentEnd" $.modifiers[#TrimPath].'endPercent_spn'.controller
				trimObj.heightsegs.controller.AddTarget "segLength" $.modifiers[#TrimPath].'segLength_spn'.controller
				trimObj.heightsegs.controller.script = "length*(abs((percent-percentEnd)/100.0))/segLength"
			)
			else if (shapeSelection == 2) then
			(
				trimObj.Height_Segments.controller = float_script()
				trimObj.Height_Segments.controller.AddTarget "length" $.modifiers[#TrimPath].'length_float'.controller
				trimObj.Height_Segments.controller.AddTarget "percent" $.modifiers[#TrimPath].'startPercent_spn'.controller
				trimObj.Height_Segments.controller.AddTarget "percentEnd" $.modifiers[#TrimPath].'endPercent_spn'.controller
				trimObj.Height_Segments.controller.AddTarget "segLength" $.modifiers[#TrimPath].'segLength_spn'.controller
				trimObj.Height_Segments.controller.script = "length*(abs((percent-percentEnd)/100.0))/segLength"
			)
			else if (shapeSelection == 5) then
			(
				trimObj.lengthsegs.controller = float_script()
				trimObj.lengthsegs.controller.AddTarget "length" $.modifiers[#TrimPath].'length_float'.controller
				trimObj.lengthsegs.controller.AddTarget "percent" $.modifiers[#TrimPath].'startPercent_spn'.controller
				trimObj.lengthsegs.controller.AddTarget "percentEnd" $.modifiers[#TrimPath].'endPercent_spn'.controller
				trimObj.lengthsegs.controller.AddTarget "segLength" $.modifiers[#TrimPath].'segLength_spn'.controller
				trimObj.lengthsegs.controller.script = "length*(abs((percent-percentEnd)/100.0))/segLength"
			)
			
			if (shapeSelection != 5) then
			(
				trimObj.height.controller = float_script()
				trimObj.height.controller.AddTarget "l" $.modifiers[#TrimPath].'length_float'.controller
				trimObj.height.controller.script = "l"
			)
			else
			(

				trimObj.length.controller = float_script()
				trimObj.length.controller.AddTarget "l" $.modifiers[#TrimPath].'length_float'.controller
				trimObj.length.controller.script = "l"
			)

			pathDeformMod = SpacePathDeform()
			addModifier trimObj pathDeformMod
			pathDeformMod.path = $
			if (shapeSelection == 5) then (pathDeformMod.axis = 1) else (pathDeformMod.axis = 2)
			trimObj.transform = $.transform
			pathDeformMod.percent_along_path.controller = float_script()
			pathDeformMod.percent_along_path.controller.AddTarget "percentEnd" $.modifiers[#TrimPath].'endPercent_spn'.controller
			pathDeformMod.percent_along_path.controller.script = "percentEnd/100.0"
			

			--endObj = Point pos:[0,0,0]
			if endObj_val != undefined then
			(
				endObj = instance endObj_val
				endObj.pos.controller = Path_Constraint()
				endObj.pos.controller.path = $
				endObj.pos.controller.axis = 2
				endObj.pos.controller.constantVel = true
				endObj.pos.controller.follow = true
				endObj.pos.controller.loop = true
				endObj.pos.controller.percent.controller = float_script()
				endObj.pos.controller.percent.controller.AddTarget "percent" $.modifiers[#TrimPath].'startPercent_spn'.controller
				endObj.pos.controller.percent.controller.script = "percent/100.0"
				
				endObj.scale.controller = scale_script()
				endObj.scale.controller.AddTarget "percent" $.modifiers[#TrimPath].'startPercent_spn'.controller
				endObj.scale.controller.AddTarget "percentEnd" $.modifiers[#TrimPath].'endPercent_spn'.controller
				endObj.scale.controller.script = "xy = 1;if (abs(percent-percentEnd)) < 5 then xy = ((percent-percentEnd))/5.0 else xy = 1;[xy, xy, xy]"
				--"xy = 1;if percent < 5 then xy = percent/5 else xy = 1;[xy, xy, xy]"
			)

			--startObj = Point pos:[0,0,0]
			if startObj_val != undefined then
			(
				startObj = instance startObj_val
				startObj.pos.controller = Path_Constraint()
				startObj.pos.controller.path = $
				startObj.pos.controller.axis = 2
				startObj.pos.controller.constantVel = true
				startObj.pos.controller.follow = true
				startObj.pos.controller.loop = true
				startObj.pos.controller.percent.controller = float_script()
				startObj.pos.controller.percent.controller.AddTarget "percentEnd" $.modifiers[#TrimPath].'endPercent_spn'.controller
				startObj.pos.controller.percent.controller.script = "percentEnd/100.0"

				startObj.scale.controller = scale_script()
				startObj.scale.controller.AddTarget "percent" $.modifiers[#TrimPath].'startPercent_spn'.controller
				startObj.scale.controller.AddTarget "percentEnd" $.modifiers[#TrimPath].'endPercent_spn'.controller
				startObj.scale.controller.script = "xy = 1;if (abs(percent-percentEnd)) < 5 then xy = ((percent-percentEnd))/5.0 else xy = 1;[xy, xy, xy]"
				--"xy = 1;if percent < 5 then xy = percent/5 else xy = 1;[xy, xy, xy]"
				--"xy = 1;if (abs(percent-percentEnd)) < 5 then xy = (abs(percent-percentEnd))/5.0 else xy = 1;[xy, xy, abs(percent-percentEnd)/100.0]"
			)

			trimObj.parent = $
		)

		on startObj_btn picked obj do
		(
			if obj != undefined do
			(
				startObj_btn.text = obj.name
				startObj_val = obj
			)
		)

		on endObj_btn picked obj do
		(
			if obj != undefined do
			(
				endObj_btn.text = obj.name
				endObj_val = obj
			)
		)

		on startPercent_spn changed n do
		(
			if (n < endPercent_spn.value) then (startPercent_spn.value = endPercent_spn.value)
		)
		
		on endPercent_spn changed n do
		(
			if (n > startPercent_spn.value) then (endPercent_spn.value = startPercent_spn.value)
		)

	)--end rollout


	on attachedToNode this do
 	(
 		if this != undefined then
 		(
			if (classof this == NURBSCurveshape or classof this == SplineShape or classof this == line) then
			(
				result = for i=1 to this.modifiers.count where (classof this.modifiers[i] == TrimPath) collect i
				
				if (result.count > 1) then 
				(
					local qb = QueryBox "There are more than one Trim Path Modifiers added to this object.\nOverwrite?\nYES - Delete old replace with new\nNO - Do not add the new modifier, leave as is."
					if qb == true then
					(
						for i = result.count to 2 by -1 do
						(
							print ("false - deleting " + i as string)
							deleteModifier this (result[i])
						)
					)
					else 
					(
						for i = result.count - 1 to 1 by -1 do
						(
							print ("true - deleting " + i as string)
							deleteModifier this (result[i])
						)
					)
				)

			)
			else
			(
				messageBox "This should be a NURBS, Line or Editable Spline curve."
			)
		)
 	)
)
