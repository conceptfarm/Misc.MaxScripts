-------------------------------------------------------------------------------
-- Max to AE v.0.9.7.ms
-- Original Author Unknown
-- Edite by Ilya Floussov (ilya@conceptfarm.ca)
-- June 6th 2020
-- Export selected object to an AE script for import in AE
-------------------------------------------------------------------------------
macroScript MaxtoAE
category:"ilya_s Scripts"
tooltip:"MtoAE"
buttontext:"MtoAE"
(
	Try destroyDialog Sk_CameraExport_Main 
	catch()

	fn SelectionFilter = 
	(
		Sel = getCurrentSelection() as array
				
		for f = 1 to Sel.count do 
		(
			Selname = Sel [f].name
			if superclassof Sel[f] == camera then
			(		
				Sk_CameraExport_Main.Cameralist.items = append Sk_CameraExport_Main.Cameralist.items Selname
			)
			if superclassof Sel[f] == Light then
			(		
				Sk_CameraExport_Main.LightList.items = append Sk_CameraExport_Main.LightList.items Selname
			)
			
			if superclassof Sel[f] != Light and superclassof Sel[f] != Camera and classof Sel[f] != Targetobject then
			(		
				if classof Sel[f] != DaylightAssemblyHead then 
				(
					Sk_CameraExport_Main.ObjectList.items = append Sk_CameraExport_Main.ObjectList.items Selname
				)
			)
		)
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
			StartAnimation =animationrange.start as integer/TicksPerFrame
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

	fn AeExport Exportname AEItems =
	(	
		-- Make Array and it's info
		ItemArray= AEItems as array
		Newarray = append ItemArray ItemCount
		ItemCount = Newarray.count-1
		
		--Check Duration	
		for n = 1 to ItemCount do
		(
			ItemNo = Newarray[n]
			Item = Execute  ("$'"+ItemNo+"'")
			selectmore Item
		)

		AnimationCheckArray = AnimationCheckfn ()
		CompDuration = AnimationCheckArray[3]
		if (CompDuration < animationrange.end as integer/TicksPerFrame) then (CompDuration = animationrange.end as integer/TicksPerFrame)

		--Start Write File
		Scriptfile = openFile exportname  mode:"w+"	
		
		-- Comp creation	
		Format ("//Camera Export Max to AE by Sk-Films \n\n" as string) to: Scriptfile
		Format  "var NewComp = app.project.items.addComp(\"%\", %, %, 1, (%/%), %) //Make comp \n" (getFilenamefile exportname) renderwidth renderheight CompDuration framerate framerate    to: Scriptfile


		
		for n = 1 to ItemCount do
		(
			--Vars
			RadiusState = 0
			RollState = 1 -- (on)	
			RotationState = 1
			ScaleState = 0
				
			--Rotation states:
			--0 = None
			--1 = Normal
			--2 = Target
			--3 = Fake Target

				
			ItemNo = Newarray[n]
			Item = Execute  ("$'"+ItemNo+"'")
			select Item

			--Animation Check
			AnimationCheckArray = AnimationCheckfn ()
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
			-- if Object  - Null Creation
			
			if superclassof Item != Light and superclassof Item != Camera and classof Item != Targetobject then		
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
			
			-- If Light - Light Creation
			
			if superclassof Item == Light then		
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

			--Check Animation
			for i = StartAnimation to EndAnimation do 	
			(
				--Scale
				if ScaleState == 1  then		
				(
					Scale = (at time i Item.scale)*100
					format "%%.property(\"Scale\").setValueAtTime((%/%),[%,%,%])\n" JsxItem n i framerate Scale.x Scale.y Scale.z to:Scriptfile
				)
				
				--Position 
				if (Sk_CameraExport_Main.bakechk.state== on) then
				(
					slidertime = i
					Position = Item.transform.position
					format "%%.property(\"Position\").setValueAtTime((%/%),[%,%,%])\n" JsxItem n i framerate Position.x -Position.z Position.y to:Scriptfile
				)
				else
				(
					Position = at time i Item.transform.row4
					format "%%.property(\"Position\").setValueAtTime((%/%),[%,%,%])\n" JsxItem n i framerate Position.x -Position.z Position.y to:Scriptfile
				)
				--Rotation
				case of
				(
					(RotationState == 0):  Print "No Rotation"
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
							format "%%.property(\"Point of Interest\").setValueAtTime((%/%),[%,%,%])\n" JsxItem n i framerate Targetpos.x -Targetpos.z Targetpos.y to:Scriptfile
							if RollState != 0 then
							(format "%%.property(\"Z Rotation\").setValueAtTime((%/%),[%])\n" JsxItem n i framerate RollAngleAtTime to:Scriptfile)	
						)
					(RotationState == 3): 
						(
							Print "Rotation 3"
							GettingTarget = at time i  in coordsys World Item.transform
							preTranslate GettingTarget [0,0,-50] 
							Targetpos = GettingTarget.translation
							format "%%.property(\"Point of Interest\").setValueAtTime((%/%),[%,%,%])\n" JsxItem n i framerate Targetpos.x -Targetpos.z Targetpos.y to:Scriptfile
						)
					default: Print "No Rotation/Or object not included by Author"
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
		) --end for items count

		close Scriptfile
		messageBox "Export Done" title:"Sk-Films: Camera Export"
	)-- end function

	rollout Sk_CameraExport_Main "Sk-Films: Camera Export  v.0.9.7" width:384 height:280
	(
		button btnExp "Export" pos:[288,224] width:85 height:46 enabled:true
		listbox CameraList "Cameras" pos:[16,24] width:112 height:8
		pickbutton btnPick "Pick" pos:[72,216] width:48 height:48 
		button btnRemoveCam "Del" pos:[56,160] width:40 height:24
		button btnList "List" pos:[128,216] width:48 height:48
		listbox LightList "Lights" pos:[136,24] width:112 height:8
		listbox ObjectList "Objects" pos:[256,24] width:112 height:8
		button btnRemoveLight "Del" pos:[178,160] width:40 height:24
		button btnRemoveObj "Del" pos:[296,160] width:40 height:24
		button btnAddSel "AddSel" pos:[16,216] width:48 height:48
		GroupBox grpExportItems "Export Items" pos:[8,8] width:368 height:184
		GroupBox grpGlobalButtons "Add Items" pos:[8,200] width:176 height:72
		checkbox rangechk "Playback Range" pos:[192,230] width:97 height:18
		checkbox bakechk "Bake Animation" pos:[192,255] width:97 height:18
			
		on Sk_CameraExport_Main open do
		(
			SelectionFilter()
		)
		
		on btnExp pressed do
		(	
			theSaveName = getSaveFileName caption:"Export Camera:" types:"Java Script(*.jsx)|*.jsx"
			theItems = CameraList.items + ObjectList.items + LightList.items
			Print "check"
			Print theItems
			Print "check"
			
			if theSaveName != undefined then
			(
				AeExport theSaveName theItems 
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
		
		on btnRemoveCam pressed do
		(
			if CameraList.items.count > 0 and CameraList.selection > 0 then
			CameraList.items = deleteItem CameraList.items CameraList.selection
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
		
		on btnRemoveLight pressed do
		(
			if LightList.items.count > 0 and LightList.selection > 0 then
			LightList.items = deleteItem LightList.items LightList.selection
		)
		
		on btnRemoveObj pressed do
		(
			if ObjectList.items.count > 0 and ObjectList.selection > 0 then
			ObjectList.items = deleteItem ObjectList.items ObjectList.selection
		)
		
		on btnAddSel pressed do
		(
			SelectionFilter()
		)
	)-- end rollout
createDialog Sk_CameraExport_Main 
)
