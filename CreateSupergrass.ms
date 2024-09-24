macroScript CreateSupergrass
category:"ilya_s Scripts"
internalcategory:"ilya_s Scripts"
tooltip:"CreateSupergrass"
buttontext:"CreateSupergrass"
(

	global createSupergrass_RO
	
	local ml = loadTempMaterialLibrary @"Y:\Software\01_3ds Max\03_Plugins\CityscapePro\LibraryVray5\Materials\Vray\supergrass.mat"

	fn createDir = 
	(
		local nMap = Noise()
		nMap.type = 2
		nMap.size = 50
		nMap.levels = 10
		nMap.phase = 3.7
		nMap.color1 = color 58 58 58
		nMap.color2 = color 255 255 255
		nMap.name = "DirectionMap"
		nMap
	)

	fn createLength = 
	(
		local nMap = Noise()
		nMap.type = 2
		nMap.size = 100
		nMap.levels = 10
		nMap.phase = 3.7
		nMap.color1 = color 255 255 255
		nMap.color2 = color 79 79 79
		nMap.name = "LengthMap"
		nMap
	)


	fn setLawnSummer id = 
	(
		--Lawn summer
		$.gravity = 0
		$.Taper = 0.7
		$.overrideMtlID_on = off
		$.lod_on = on
		$.lod_startDistance = 1181.1
		$.lod_rate = 1181.1
		$.thicknessVar = 0.2
		$.curlVar = 0
		$.Distribution = 1
		$.referenceFrame = 0
		$.placement = 2
		$.materialID = id
		$.generateWcoord = on
		$.curl_enabled = off
		$.perArea = 1
		$.length = 3.93701
		$.thickness = 0.23622
		$.numKnots = 3
		$.directionVar = 1
		$.lengthVar = 0.2
		$.gravityVar = 0.393701
		$.Bend = 1
		n = createDir()
		$.map_direction = createDir()
		$.map_length = createLength()
		/*
		.coords.realWorldScale = on
		.coords.u_tiling = 0.00127
		.coords.v_tiling = 0.00127
		.coords.realWorldScale = on
		.coords.u_tiling = 0.0001
		.coords.v_tiling = 0.0001
		.output.RGB_Offset = -0.08
		.output.RGB_Level = 1.6
		*/
		$.material = ml["Lawn Summer"]
	)

	fn setLawnFall id = 
	(
		--lawn fall
		$.gravity = 0
		$.Taper = 0.7
		$.overrideMtlID_on = off
		$.lod_on = on
		$.lod_startDistance = 1181.1
		$.lod_rate = 1181.1
		$.thicknessVar = 0.2
		$.curlVar = 0
		$.Distribution = 1
		$.referenceFrame = 0
		$.placement = 2
		$.materialID = id
		$.generateWcoord = on
		$.curl_enabled = off
		$.perArea = 1
		$.length = 3.93701
		$.thickness = 0.23622
		$.numKnots = 3
		$.directionVar = 1
		$.lengthVar = 0.2
		$.gravityVar = 0.393701
		$.Bend = 1
		$.map_direction = createDir()
		$.map_length = createLength()
		/*
		.coords.realWorldScale = on
		.coords.u_tiling = 0.00127
		.coords.v_tiling = 0.00127
		.coords.realWorldScale = on
		.coords.u_tiling = 0.0001
		.coords.v_tiling = 0.0001
		.output.RGB_Offset = -0.08
		.output.RGB_Level = 1.6
		*/
		$.material = ml["Lawn Fall"]
	)

	fn setTallFall id = 
	(
		--tall grass falll
		$.gravity = 0
		$.Taper = 0.7
		$.overrideMtlID_on = off
		$.lod_on = on
		$.lod_startDistance = 1181.1
		$.lod_rate = 1181.1
		$.thicknessVar = 0.2
		$.curlVar = 0
		$.Distribution = 1
		$.referenceFrame = 0
		$.placement = 2
		$.materialID = id
		$.generateWcoord = on
		$.curl_enabled = off
		$.perArea = 1
		$.length = 19.685
		$.thickness = 0.23622
		$.numKnots = 5
		$.directionVar = 0.3
		$.lengthVar = 1
		$.gravityVar = 0
		$.Bend = 0.6
		$.map_direction = createDir()
		$.map_length = createLength()
		/*
		.coords.realWorldScale = on
		.coords.u_tiling = 0.00127
		.coords.v_tiling = 0.00127
		.coords.realWorldScale = on
		.coords.u_tiling = 0.0001
		.coords.v_tiling = 0.0001
		.output.RGB_Offset = -0.08
		.output.RGB_Level = 1.6
		*/
		$.material = ml["Tall Fall"]
	)

	fn setTallSummer id = 
	(
		--tall grass summer
		$.gravity = 0
		$.Taper = 0.7
		$.overrideMtlID_on = off
		$.lod_on = on
		$.lod_startDistance = 1181.1
		$.lod_rate = 1181.1
		$.thicknessVar = 0.2
		$.curlVar = 0
		$.Distribution = 1
		$.referenceFrame = 0
		$.placement = 2
		$.materialID = id
		$.generateWcoord = on
		$.curl_enabled = off
		$.perArea = 1
		$.length = 19.685
		$.thickness = 0.23622
		$.numKnots = 5
		$.directionVar = 0.3
		$.lengthVar = 1
		$.gravityVar = 0
		$.Bend = 0.6
		$.map_direction = createDir()
		$.map_length = createLength()
		/*
		.coords.realWorldScale = on
		.coords.u_tiling = 0.00127
		.coords.v_tiling = 0.00127
		.coords.realWorldScale = on
		.coords.u_tiling = 0.0001
		.coords.v_tiling = 0.0001
		.output.RGB_Offset = -0.08
		.output.RGB_Level = 1.6
		*/
		$.material = ml["Tall Summer"]
	)
	
	rollout createSupergrass_RO "Create Supergrass" width:230
	(
		
		dropdownlist assetType_dd "Template:" items:#("Lawn Summer", "Lawn Fall", "Tall Summer", "Tall Fall")
		spinner id_spn "Placement ID" range:[1,500,1] type:#integer
		button create_btn "Create"

		on createSupergrass_RO open do
		(
		)
		
		on assetType_dd selected i do
		(
		)
		
		on create_btn pressed do
		(
			
			if superclassof $ == GeometryClass and classof $ != Vrayfur then
			(
				local vf = vrayfur()
				vf.sourceNode = $
				vf.name = "Supergrass_Fur_0" + (random 0 100) as string
				select vf
			)
			
			if classof $ == VRayFur then
			(
				case assetType_dd.selected of 
				(
					"Lawn Summer": setLawnSummer id_spn.value
					"Lawn Fall": setLawnFall id_spn.value
					"Tall Summer": setTallSummer id_spn.value
					"Tall Fall": setTallFall id_spn.value
				)
			)
			else
			(
				Messagebox "Select either a VrayFur object or a geometry object on which to place grass."
			)
		)
	)
	
	on execute do 
	(
		try(destroyDialog createSupergrass_RO)catch()
		createDialog createSupergrass_RO
	)
)