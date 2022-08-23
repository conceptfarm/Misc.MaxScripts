-------------------------------------------------------------------------------
-- Max to AE v.0.9.8.ms
-- Original Author Sergei Kozin
-- Edite by Ilya Floussov (ilya@conceptfarm.ca)
-- June 6th 2020
-- Export selected object to an AE script for import in AE
-- Added shape export
-------------------------------------------------------------------------------
macroScript MaxtoAE
category:"ilya_s Scripts"
tooltip:"MtoAE"
buttontext:"MtoAE"
(
	local CameraObjList = #()
	local LightObjList = #()
	local ObjectObjList = #()
	local ShapeObjList = #()

	--Shape creator javascript function	
local functionString = "
function createShapeLayer(thisComp, verts, inTang, outTang, isClosed)
{
	var shapeLayer = thisComp.layers.addShape();
	var shapeGroup = shapeLayer.property(\"ADBE Root Vectors Group\");\n
	for (i = 0; i < verts.length; i++)
	{	
		var pathGroup = shapeGroup.addProperty(\"ADBE Vector Shape - Group\");
		var myShape = new Shape();
		myShape.vertices = verts[i];
		myShape.inTangents = inTang[i];
		myShape.outTangents = outTang[i];
		myShape.closed = isClosed[i];
		shapeGroup.property(i+1).property(\"ADBE Vector Shape\").setValue(myShape);
	}
	var strokeProp = shapeGroup.addProperty(\"ADBE Vector Graphic - Stroke\");
	var fillProp = shapeGroup.addProperty(\"ADBE Vector Graphic - Fill\");
	return shapeLayer
}\n\n"
	
	Try (destroyDialog Sk_CameraExport_Main)
	catch()
	
	struct AEShape
	(
		vertArray=#(),
		inVecArray=#(),
		outVecArray=#(),
		shapeClosed,
		
		fn printVertArray =
		(
			local result = "["
			for i=1 to vertArray.count do 
			(
				if i != vertArray.count then	result = result + vertArray[i] as string + ","
				else result = result + vertArray[i] as string
			)
			result = result + "]"
			result
		),
		
		fn printInVecArray =
		(
			local result = "["
			for i=1 to inVecArray.count do 
			(
				if i != inVecArray.count then 
				(
					if inVecArray[i] != undefined then
					(
						result = result + (inVecArray[i] - vertArray[i]) as string + ","
					)
					else result = result + "[]" + ","
				)
				else 
				(
					if inVecArray[i] != undefined then
					(
						result = result +  (inVecArray[i] - vertArray[i]) as string
					)
					else result = result + "[]"
				)
			)
			result = result + "]"
			result
		),
		
		fn printOutVecArray =
		(
			local result = "["
			for i=1 to outVecArray.count do 
			(
				if i != outVecArray.count then 
				(
					if outVecArray[i] != undefined then
					(
						result = result + (outVecArray[i] - vertArray[i]) as string + ","
					)
					else result = result + "[]" + ","
				)
				else 
				(
					if outVecArray[i] != undefined then
					(
						result = result +  (outVecArray[i] - vertArray[i]) as string
					)
					else result = result + "[]"
				)
			)
			result = result + "]"
			result
		)
	)

	struct AEShapeCollection
	(
		shapeCollection = #(),
		initSpline,
		
		fn printArrayType arrType =
		(
			local result = "["
			for i = 1 to shapeCollection.count do 
			(
				arr = ""
				if arrType == "vert" then arr = shapeCollection[i].printVertArray()
				else if arrType == "invec" then arr = shapeCollection[i].printInVecArray()
				else if arrType == "outvec" then arr = shapeCollection[i].printOutVecArray()
				else if arrType == "closure" then arr = shapeCollection[i].shapeClosed as string
				
				if i != shapeCollection.count then	result = result + arr + ","
				else result = result + arr
			)
			result = result + "]"
			result
		),
		
		fn getSpineVertArray spl =
		(
			local result = #()
			local vert2DArray = #()
			local inVec2DArray = #()
			local outVec2DArray = #()
			local _shape = copy spl
			convertToSplineShape _shape
			
			for s = 1 to (numSplines _shape) do
			(
				local _AEShape = AEShape()
				
				_AEShape.shapeClosed = isClosed _shape s
				
				for k = 1 to (numKnots _shape s) do
				(
					if getKnotType _shape s k == #smooth then setKnotType _shape s k #bezierCorner
					
					in coordsys ((_shape.transform))
					local knt = getKnotPoint _shape s k
					append _AEShape.vertArray [knt.x, knt.y]

					in coordsys ((_shape.transform))
					local in_vec = getInVec _shape s k
					append _AEShape.inVecArray [in_vec.x, in_vec.y]
					
					in coordsys ((_shape.transform))
					local out_vec = getOutVec _shape s k
					append _AEShape.outVecArray [out_vec.x, out_vec.y]			

				)
				append shapeCollection _AEShape
			)
			delete _shape
			result = shapeCollection --#(vert2DArray , inVec2DArray, outVec2DArray)
			result
		),
		
		on create do getSpineVertArray initSpline
	)

	/*
	--USE:
	b = AEShapeCollection initSpline:$

	b.printArrayType "vert"
	b.printArrayType "invec"
	b.printArrayType "outvec"
	b.printArrayType "closure"
	*/
	fn SelectionFilter = 
	(	
		sel = getCurrentSelection() as array
				
		for obj in sel do 
		(
			if superclassof obj == camera then
			(		
				--Sk_CameraExport_Main.Cameralist.items = append Sk_CameraExport_Main.Cameralist.items obj.name
				appendIfUnique CameraObjList obj
			)
			else if superclassof obj == Light then
			(		
				--Sk_CameraExport_Main.LightList.items = append Sk_CameraExport_Main.LightList.items obj.name
				appendIfUnique LightObjList obj
			)
			else if superclassof obj == shape then
			(
				--Sk_CameraExport_Main.ShapeList.items = append Sk_CameraExport_Main.ShapeList.items obj.name
				appendIfUnique ShapeObjList obj
			)
			else if classof obj != Targetobject then
			(		
				if classof obj != DaylightAssemblyHead then 
				(
					--Sk_CameraExport_Main.ObjectList.items = append Sk_CameraExport_Main.ObjectList.items obj.name
					appendIfUnique ObjectObjList obj
				)
			)
		)
		
		Sk_CameraExport_Main.CameraList.items = for o in CameraObjList collect o.name
		Sk_CameraExport_Main.LightList.items = for o in LightObjList collect o.name
		Sk_CameraExport_Main.ShapeList.items = for o in ShapeObjList collect o.name
		Sk_CameraExport_Main.ObjectList.items = for o in ObjectObjList collect o.name
	)
	
	fn AnimationCheckfn =
	(
		AnimationCheck =	
		(
			try
			FirstKeyframe = (at time -1 trackbar.getNextKeyTime() as integer/TicksPerFrame)
			catch ()
		)

		if Sk_CameraExport_Main.rangechk.state== on then
		(
			StartAnimation = animationrange.start as integer/TicksPerFrame
			EndAnimation = animationrange.end as integer/TicksPerFrame
			Duration =  animationrange.end as integer/TicksPerFrame+1
		)
		else
		(
			if AnimationCheck != undefined  then 
			(
				PlayrangeEnd = animationrange.end as integer/TicksPerFrame
				Print "Animation Found"
				StartAnimation = FirstKeyframe
				EndAnimation = (at time 9999999999999999999999 trackbar.getPreviousKeyTime() as integer/TicksPerFrame)
				Duration = EndAnimation+1
			)
			else 
			(
				Print "No Animation Found"
				StartAnimation =0
				EndAnimation = 0
				Duration =  animationrange.end as integer/TicksPerFrame+1
			)
		)	
		#(StartAnimation, EndAnimation, Duration)
	)
	
	fn AniCheck_fn obj=
	(
		if (superclassof obj == camera) then
		(
			result = #()
			mapkeys obj (fn CollectKeys t k = (append k t; t)) (keys=#()) #allkeys
			if obj.target != undefined then
			(
				mapkeys obj.target (fn CollectKeys t k = (append k t; t)) (keys2=#()) #allkeys
				result =  #(amin (join keys keys2) , amax (join keys keys2))
			)
			else result =  #(amin keys, amax keys)
			if result[1] == undefined or result[2] == undefined then return undefined
			else return result
		)
		else return undefined
	)
	
	fn AeExport exportScriptPath exportObjList sceneScale=
	(	
		--Get full animation range 
		select exportObjList
		local AnimationCheckArray = AnimationCheckfn()
		local CompDuration = AnimationCheckArray[3]
		if (CompDuration < animationrange.end as integer/TicksPerFrame) then (CompDuration = animationrange.end as integer/TicksPerFrame)
		clearSelection()
		
		--Start Write File
		local Scriptfile = openFile exportScriptPath  mode:"w+"	
		
		-- Comp creation	
		Format ("//Camera Export Max to AE by Sk-Films \n\n" as string) to: Scriptfile
		Format functionString to: Scriptfile
		Format  "var NewComp = app.project.items.addComp(\"%\", %, %, 1, (%/%), %) //Make comp \n" (getFilenamefile exportScriptPath) renderwidth renderheight CompDuration framerate framerate    to: Scriptfile


		local n = 1
		for Item in exportObjList do
		(
			--Vars
			local RadiusState = 0
			local RollState = 1 -- (on)	
			local RotationState = 1
			local ScaleState = 0
				
			--Rotation states:
			--0 = None
			--1 = Normal
			--2 = Target
			--3 = Fake Target

			select Item

			--Animation Check
			AnimationCheckArray = AnimationCheckfn()
			StartAnimation = AnimationCheckArray[1]
			EndAnimation = AnimationCheckArray[2]
			Duration = AnimationCheckArray[3]

			--If Duration< CompDuration then (Duration = CompDuration)
			Print StartAnimation
			Print EndAnimation
			Print Duration

			

			-- if camera - Camerea Creation
			if superclassof Item == camera then		
			(
				RotationState = 2
					
				JsxItem = "NewCamera"
				Format "var NewCamera% = NewComp.layers.addCamera(\"%\",[0,0]);\n" n Item.name to: Scriptfile
				Format "NewCamera%.inPoint = %/%;\n" n StartAnimation framerate to: Scriptfile
				Format "NewCamera%.outPoint = %/%;\n" n Duration framerate to: Scriptfile
				--Set Frame Marker	
				Format "var StartMark = new MarkerValue(\"MaxFrame:%\")\n" StartAnimation to: Scriptfile
				Format "NewCamera%.property(\"Marker\").setValueAtTime((%/%),(StartMark))\n " n StartAnimation framerate to: Scriptfile
			
				if Item.target == undefined then
				(
					Print "Free Camera (No Target)"
					
					RotationState = 1
					Format "NewCamera%.autoOrient = AutoOrientType.NO_AUTO_ORIENT;\n" n to: Scriptfile
				)
			)
			-- If Light - Light Creation
			else if superclassof Item == Light then		
			(
				RotationState = 0 
				JsxItem = "NewLight"
				Format "NewLight% = NewComp.layers.addLight(\"%\",[0,0])\n" n item.name to: Scriptfile
				Format "NewLight%.property(\"Color\").setValue([%,%,%])\n" n (Item.color.r/255.) (Item.color.g/255.) (Item.color.b/255.) to: Scriptfile
				Format "NewLight%.inPoint = %/%;\n" n StartAnimation framerate to: Scriptfile
				Format "NewLight%.outPoint = %/%;\n\n" n Duration framerate to: Scriptfile
					
				case of
				(
					(classof Item == TargetDirectionallight): (Format "NewLight%.lightType = LightType.PARALLEL;\n" n to: Scriptfile
								RotationState = 2
								RollState = 0
								RadiusState = 0)
					(classof Item == Directionallight): (Format "NewLight%.lightType = LightType.PARALLEL;\n" n to: Scriptfile 
								RotationState = 3
								RollState = 0
								RadiusState = 0)
					(classof Item == targetSpot): (Format "NewLight%.lightType = LightType.SPOT;\n" n to: Scriptfile
								RotationState = 2
								RadiusState = 1)
					(classof Item == freeSpot): (Format "NewLight%.lightType = LightType.SPOT;\n" n to: Scriptfile
								RotationState = 3
								RadiusState = 1)
					(classof Item == Omnilight): 	(Format "NewLight%.lightType = LightType.POINT;\n" n to: Scriptfile)
					default: 	(Format "NewLight%.lightType = LightType.POINT;\n" n to: Scriptfile
						RotationState = 0)
				)		
			)
			else if superclassof Item == shape then
			(
				
				local itemShape = AEShapeCollection initSpline:Item

				local verts = itemShape.printArrayType "vert"
				local inTang = itemShape.printArrayType "invec"
				local outTang = itemShape.printArrayType "outvec"
				local closure = itemShape.printArrayType "closure"
				/*
				verts =  "[[[-40.1042,44.5833],[-20.9375,-52.9167],[61.9792,-44.1667],[-0.9375,52.5]],[[29.4792,47.5],[21.5625,-26.6667],[81.5625,-22.0833]]];"
				inTang = "[[[13.0556,2.63889],[-6.38889,32.5],[-27.6389,-2.91667],[20.9722,-32.2222]],[[21.3853,-12.7923],[-22.5,16.6667],[-10.8333,-18.75]]];"
				outTang = "[[[6.38889,-32.5],[27.6389,2.91666],[-20.9722,32.2222],[-13.0556,-2.63889]],[[-22.5,-26.6667],[22.5,-16.6667],[10.8333,18.75]]];"
				closure = "[true,true];"

				createShapeLayer(verts, inTang, outTang, true)
				*/
				RotationState = 1
				ScaleState = 1
				JsxItem = "NewObj"
				Format "var NewObj%_verts = %\n" n verts to: Scriptfile
				Format "var NewObj%_inTang = %\n" n inTang to: Scriptfile
				Format "var NewObj%_outTang = %\n" n outTang to: Scriptfile
				Format "var NewObj%_closure= %\n" n closure to: Scriptfile
				Format "var NewObj% = createShapeLayer(NewComp, NewObj%_verts, NewObj%_inTang, NewObj%_outTang, NewObj%_closure)\n" n n n n n to: Scriptfile
				Format "NewObj%.name = \"%\"\n" n Item.name to: Scriptfile
				Format "NewObj%.threeDLayer = true\n" n to: Scriptfile

				Format "NewObj%.transform.position.setValue([-498.134,-301.333,-1.31717e-005])\n" n to: Scriptfile
				Format "NewObj%.inPoint = %/%;\n" n StartAnimation framerate to: Scriptfile
				Format "NewObj%.outPoint = %/%;\n\n" n Duration framerate to: Scriptfile
			)
			-- if Object  - Null Creation
			else if classof Item != Targetobject then		
			(
				RotationState = 1
				ScaleState = 1
				JsxItem = "NewObj"
				Format "var NewObj% = NewComp.layers.addNull(NewComp.duration)\n" n to: Scriptfile
				Format "NewObj%.name = \"%\"\n" n Item.name to: Scriptfile
				Format "NewObj%.threeDLayer = true\n" n to: Scriptfile

				Format "NewObj%.transform.position.setValue([-498.134,-301.333,-1.31717e-005])\n" n to: Scriptfile
				Format "NewObj%.inPoint = %/%;\n" n StartAnimation framerate to: Scriptfile
				Format "NewObj%.outPoint = %/%;\n\n" n Duration framerate to: Scriptfile
			)


			--Check Animation
			for i = StartAnimation to EndAnimation do 	
			(
				--Scale
				if ScaleState == 1  then		
				(
					Scale = (at time i Item.scale)*100.0
					format "%%.property(\"Scale\").setValueAtTime((%/%),[%,%,%])\n" JsxItem n i framerate (Scale.x* sceneScale) (-Scale.y* sceneScale) (Scale.z* sceneScale) to:Scriptfile
				)
				
				--Position 
				if (Sk_CameraExport_Main.bakechk.state== on) then
				(
					slidertime = i
					Position = Item.transform.position 
					format "%%.property(\"Position\").setValueAtTime((%/%),[%,%,%])\n" JsxItem n i framerate (Position.x* sceneScale) (-Position.z* sceneScale) (Position.y* sceneScale) to:Scriptfile
				)
				else
				(
					Position = at time i Item.transform.row4
					format "%%.property(\"Position\").setValueAtTime((%/%),[%,%,%])\n" JsxItem n i framerate (Position.x* sceneScale) (-Position.z* sceneScale) (Position.y* sceneScale) to:Scriptfile
				)
				--Rotation
				case of
				(
					(RotationState == 0): Print "No Rotation"
					(RotationState == 1): 
						(
							ItemRotation = at time i in coordsys World Item.rotation  as eulerAngles 
							Print "Rotation 1"
							Print ItemRotation
							Format "%%.transform.orientation.setValue([270.0,0.0,0.0])\n"  JsxItem n to: Scriptfile
							
							format "%%.property(\"X Rotation\").setValueAtTime((%/%),[%])\n" JsxItem n i framerate -ItemRotation.x to:Scriptfile
							format "%%.property(\"Y Rotation\").setValueAtTime((%/%),[%])\n" JsxItem n i framerate ItemRotation.y to:Scriptfile
							format "%%.property(\"Z Rotation\").setValueAtTime((%/%),[%])\n" JsxItem n i framerate ItemRotation.z to:Scriptfile
							--format "%%.transform.orientation.setValueAtTime((%/%),[%,%,%])\n" JsxItem n i framerate  ItemRotation.x ItemRotation.y ItemRotation.z to: Scriptfile
						)
					(RotationState == 2): 
						( 
							--Print "Rotation 2"
							Targetpos = at time i  in coordsys World Item.Target.Position
							RollAngleAtTime = at time i  -Item.controller.roll_angle
							
							--Print RollAngleAtTime
							format "%%.property(\"Point of Interest\").setValueAtTime((%/%),[%,%,%])\n" JsxItem n i framerate (Targetpos.x* sceneScale) (-Targetpos.z* sceneScale) (Targetpos.y* sceneScale) to:Scriptfile
							if RollState != 0 then
							(
								format "%%.property(\"Z Rotation\").setValueAtTime((%/%),[%])\n" JsxItem n i framerate RollAngleAtTime to:Scriptfile
							)	
						)
					(RotationState == 3): 
						(
							Print "Rotation 3"
							GettingTarget = at time i  in coordsys World Item.transform
							preTranslate GettingTarget [0,0,-50] 
							Targetpos = GettingTarget.translation
							format "%%.property(\"Point of Interest\").setValueAtTime((%/%),[%,%,%])\n" JsxItem n i framerate (Targetpos.x* sceneScale) (-Targetpos.z* sceneScale) (Targetpos.y* sceneScale) to:Scriptfile
						)
					
					default: 
						(
							Print "No Rotation/Or object not included by Author"
						)
				)
				
				--Zoom
				if superclassof Item == camera then	
				(
					CameraLens = at time i (renderWidth/2.0 ) / ( tan (Item.fov/2))
					format "%%.property(\"Zoom\").setValueAtTime((%/%),[%])\n" JsxItem n i framerate CameraLens to:Scriptfile
				)
				
				--Light Radius
				if RadiusState == 1 then
				(
					AEHotspot = Item.falloff 
					AEFalloff = ($.falloff-$.hotspot)/($.falloff/100)
					
					format "%%.property(\"coneAngle\").setValueAtTime((%/%),[%])\n" JsxItem n i framerate AEHotspot to:Scriptfile
					format "%%.property(\"coneFeather\").setValueAtTime((%/%),[%])\n" JsxItem n i framerate AEFalloff to:Scriptfile
				)
			) --end for start animation
			n = n + 1
		) --end for items count

		close Scriptfile
		messageBox "Export Done" title:"Sk-Films: Camera Export"
	)-- end function

	rollout Sk_CameraExport_Main "Sk-Films: Camera Export  v.0.9.8" width:516 height:280
	(
		listbox CameraList "Cameras" offset:[8,16] width:112 height:8 across:4
		listbox LightList "Lights"  width:112 height:8 offset:[8,16]
		listbox ObjectList "Objects"  width:112 height:8 offset:[8,16]
		listbox ShapeList "Shapes"  width:112 height:8 offset:[8,16]
		
		button btnRemoveCam "Del" offset:[4,4] width:40 height:24 across:4
		button btnRemoveLight "Del" offset:[4,4] width:40 height:24
		button btnRemoveObj "Del" offset:[4,4] width:40 height:24	
		button btnRemoveShape "Del" offset:[4,4] width:40 height:24
		
		GroupBox grpExportItems "Export Items" pos:[8,8] width:500 height:184
		
		GroupBox grpGlobalButtons "Add Items" pos:[8,200] width:176 height:72
			button btnAddSel "AddSel" pos:[16,216] width:48 height:48
			pickbutton btnPick "Pick" pos:[72,216] width:48 height:48 
			button btnList "List" pos:[128,216] width:48 height:48
		
		spinner scale_spn "Scale:" range:[.000001, 1.0, .001] pos:[215,210] width:70
		checkbox rangechk "Playback Range" pos:[192,232] width:97 height:18
		checkbox bakechk "Bake Animation" pos:[192,255] width:97 height:18
		button btnExp "Export" pos:[288,224] width:85 height:46 enabled:true
			
		on Sk_CameraExport_Main open do
		(
			SelectionFilter()
		)
		
		on btnExp pressed do
		(	
			local exportScriptPath = getSaveFileName caption:"Export Camera:" types:"Java Script(*.jsx)|*.jsx"
			if exportScriptPath != undefined then
			(
				local exportObjList = CameraObjList + ObjectObjList + LightObjList + ShapeObjList
				local sceneScale = scale_spn.value
				Print exportObj
			
				AeExport exportScriptPath exportObjList sceneScale
			)
		)
		
		on btnPick picked cam do
		(
			if cam != undefined then
			(
				Select cam
				SelectionFilter()
			)
		)
		
		on btnList pressed do
		(
			SelList = selectByName title:"Select any Object for Export"  buttonText:"Add to Lists"  
			if (SelList != undefined) then 
			(
				Select SelList
				SelectionFilter()
			)
		)
		
		on btnRemoveCam pressed do
		(
			local itemNumber = CameraList.selection
			if CameraList.items.count > 0 and itemNumber > 0 then
			(
				CameraList.items = deleteItem CameraList.items itemNumber
				deleteItem CameraObjList itemNumber
			)
		)
		
		on btnRemoveLight pressed do
		(
			local itemNumber = LightList.selection
			if LightList.items.count > 0 and itemNumber > 0 then
			(
				LightList.items = deleteItem LightList.items itemNumber
				deleteItem LightObjList itemNumber
			)
		)
		
		on btnRemoveShape pressed do
		(
			local itemNumber = ShapeList.selection
			if ShapeList.items.count > 0 and itemNumber > 0 then
			(
				ShapeList.items = deleteItem ShapeList.items itemNumber
				deleteItem ShapeObjList itemNumber
			)
		)
		
		on btnRemoveObj pressed do
		(
			local itemNumber = ObjectList.selection
			if ObjectList.items.count > 0 and itemNumber > 0 then
			(
				ObjectList.items = deleteItem ObjectList.items itemNumber
				deleteItem ObjectObjList itemNumber
			)
		)
		
		on btnAddSel pressed do
		(
			SelectionFilter()
		)
	)-- end rollout
	
	createDialog Sk_CameraExport_Main 
)