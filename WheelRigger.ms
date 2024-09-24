macroScript WheelRigger
category:"ilya_s Scripts"
tooltip:"WheelRigger"
buttontext:"WheelRigger"
(

--global wheelrad
global WheelRigger

	
fn deleteCustAtt =
(
	for i = (custAttributes.count $ baseobject:false) to i=1 by -1 do 
	(
		if (custAttributes.getDef $ i baseobject:false).name == "dist" then 
		(
			custAttributes.delete $ i baseobject:false
		)
	)
)	

fn wheelrigfn rotAxis= 
(	
	-- Delete if already exists
	deleteCustAtt()
	
	distCA = attributes "dist"
	(
		parameters main (dist1 type:#float)
	)

	custAttributes.add $ distCA #unique BaseObject:False
	
	-- Need to figure out which of the sides to take radus from
	bbox = nodeGetBoundingBox $ $.transform
	size = [(bbox[2][1]-bbox[1][1]),(bbox[2][2]-bbox[1][2]),(bbox[2][3]-bbox[1][3])]
	wheelrad = size[2]
	
	print(rotAxis + " rot axis")
	print(wheelrad as string + " wheelrad")
	
	rotController = float_script()
	rotController.addNode "self" $
	rotController.addNode "p0" $.parent
	rotController.addConstant "wheelrad" wheelrad

	scriptstring = "radius=wheelrad * p0.scale[1]\n" +
	"val = 360/(3.14*radius*2)\n" +
	"at time (f-1)\n" +
	"(\n" +
	"  p1 = p0.transform\n" +
	"  oldPos = p0.pos\n" +
	")\n" +
	"newPos = p0.pos\n" +
	"dist = distance oldPos newPos\n" +	
	"mult = (normalize (p1 * inverse p0.transform).pos).x\n" +
	"if mult <= 0 then mult = -1 else mult = 1\n" +
	"with animate off(\n" +
	"self.dist1 += dist*mult)\n"
	
	if rotAxis == "X" or rotAxis == "Y" or rotAxis == "Z" then
	(
		scriptstring = scriptstring + "-(degtorad self.dist1*val)"
	)
	else
	(
		scriptstring = scriptstring + "(degtorad self.dist1*val)"
	)
	

	rotController.script = scriptstring
	
	if rotAxis == "X" or rotAxis == "-X" then
	(
		$.rotation.controller[1].controller = rotController
	)
	else if rotAxis == "Y" or rotAxis == "-Y" then
	(
		$.rotation.controller[2].controller = rotController
	)
	else if rotAxis == "Z" or rotAxis == "-Z" then
	(
		$.rotation.controller[3].controller = rotController
	)

) --end function
	
	rollout WheelRigger "Wheel Rigger" width:220 height:160
	(
		
		Label wheelrig_lbl "Wheel object must be linked to a chasis \nobject first. Both objects must have their \npivot points aligned to World." align:#left height:50
		dropDownList axis_dd "Wheel Rotation Axis" items:#("X","Y","Z","-X","-Y","-Z") enabled:true
		button rig_btn "Rig"
		button unrig_btn "Un-Rig"
			
		on axis_dd selected i do
		(
			print(axis_dd.selected)
		)
		
		on rig_btn pressed do 
		(
			if $.parent != undefined then 
			( 
				undo on (
					wheelrigfn axis_dd.selected
				)
			)
			else (Messagebox "The object you selected had not been linked.")
		)	
		
		on unrig_btn pressed do
		(
			if classof $.rotation.controller[1].controller == float_script then
			(
				$.rotation.controller[1].controller = bezier_float()
			)
			if classof $.rotation.controller[2].controller == float_script then
			(
				$.rotation.controller[2].controller = bezier_float()
			)
			if classof $.rotation.controller[3].controller == float_script then
			(
				$.rotation.controller[3].controller = bezier_float()
			)
			
			deleteCustAtt()
		)
	)--end rollout


	on execute do 
	(
		try( DestroyDialog WheelRigger) catch ()
		createDialog WheelRigger
	)--end on execute
)--end script