-------------------------------------------------------------------------------
-- TrimPath.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Feb 16th 2018
-- A modifier that is added to the NURBS curve to do a trim path like function
-- like in AfterEffects.
-------------------------------------------------------------------------------
plugin modifier TrimPath
name:"Trim Path"
category:"ilya_s Scripts"
classID:#(0x52abffc9, 0x677691ad)
extends:EmptyModifier
replaceUI:true
version:0.1
(
	
	local buttonWidth = 135

	parameters main rollout:params
	(

		percent_spn type:#float animatable:true ui:percent_spn default:0
		segLength_spn type:#float animatable:true ui:segLength_spn default:4.5
		length_float type:#float animatable:true 


	)

	rollout params "Submitter Properties"
	(
		group "Generate"
		(
			dropdownlist shape_dd "Section" items:#("Round/Cylinder","Square/Rectangle","Hollow/Tube","Flat/Ribbon") selection:1 width:buttonWidth
			spinner segLength_spn "Seg. Length"  type:#float range:[0,1000000,4.5]
			button create_btn "Create Geometry" width:buttonWidth
			
		)
		
		group "Animate"
		(
			spinner percent_spn "Percent"
		)

		on create_btn pressed do
		(
			if  ($.modifiers[#TrimPath].'percent_spn'.controller == undefined) then
			(
 				$.modifiers[#TrimPath].'percent_spn'.controller = bezier_float()
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
			
			length_float = shapeLength

			local trimObj = case shape_dd.selection of 
			(
				1:(Cylinder smooth:on heightsegs:heightSegs capsegs:1 sides:25 height:shapeLength radius:(shapeLength/160.0) mapcoords:on realWorldMapSize:on pos:[0,0,0] )
				2:(Box lengthsegs:1 widthsegs:1 heightsegs:heightSegs length:(shapeLength/160.0) width:(shapeLength/160.0) height:shapeLength mapcoords:on realWorldMapSize:on pos:[0,0,0] )
				3:(Tube smooth:on heightsegs:heightSegs capsegs:1 sides:25 height:shapeLength radius1:(shapeLength/160.0) radius2:(shapeLength/165.0) mapcoords:on realWorldMapSize:on pos:[0,0,0])
				4:()
			)



						
			xf = XForm()
			addModifier trimObj xf
			trimObj.modifiers[#XForm].Gizmo.scale.controller = scale_script()

			trimObj.modifiers[#XForm].Gizmo.scale.controller.AddTarget "percent" $.modifiers[#TrimPath].'percent_spn'.controller
			trimObj.modifiers[#XForm].Gizmo.scale.controller.script = "xy = 1;if percent < 1 then xy = percent else xy = 1;[xy, xy, percent/100.0]"

			trimObj.heightsegs.controller = float_script()
			trimObj.heightsegs.controller.AddTarget "length" $.modifiers[#TrimPath].'length_float'.controller
			trimObj.heightsegs.controller.AddTarget "percent" $.modifiers[#TrimPath].'percent_spn'.controller
			trimObj.heightsegs.controller.AddTarget "segLength" $.modifiers[#TrimPath].'segLength_spn'.controller
			trimObj.heightsegs.controller.script = "length*(percent/100.0)/segLength"
			
			trimObj.height.controller = float_script()
			trimObj.height.controller.AddTarget "l" $.modifiers[#TrimPath].'length_float'.controller
			trimObj.height.controller.script = "l"

			pathDeformMod = SpacePathDeform()
			addModifier trimObj pathDeformMod
			pathDeformMod.path = $
			pathDeformMod.axis = 2
			trimObj.transform = $.transform

			trimObj.parent = $

			endObj = Point pos:[0,0,0]
			endObj.pos.controller = Path_Constraint()
			endObj.pos.controller.path = $
			endObj.pos.controller.axis = 2
			endObj.pos.controller.constantVel = true
			endObj.pos.controller.follow = true
			endObj.pos.controller.loop = true
			endObj.pos.controller.percent.controller = float_script()
			endObj.pos.controller.percent.controller.AddTarget "percent" $.modifiers[#TrimPath].'percent_spn'.controller
			endObj.pos.controller.percent.controller.script = "percent/100.0"
			
			endObj.scale.controller = scale_script()
			endObj.scale.controller.AddTarget "percent" $.modifiers[#TrimPath].'percent_spn'.controller
			endObj.scale.controller.script =  "xy = 1;if percent < 5 then xy = percent/5 else xy = 1;[xy, xy, xy]"
		)


		

		
	)--end rollout


	on attachedToNode this do
 	(
 		if this != undefined then
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
 	)
)
