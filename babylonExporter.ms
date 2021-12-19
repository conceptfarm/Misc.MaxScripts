macroScript BabylonExporter
category:"ilya_s Scripts"
tooltip:"Babylon Exporter"
buttontext:"BabylonExporter"
(
	global BabylonExporter
	
	local asseblyPath = @"C:\Program Files\Autodesk\3ds Max 2020\bin\assemblies\Max2Babylon.dll"
	local testPath = "C:\\temp\\test.babylon" 
	local rootDir = @"X:\21-1930_LV Interactive Map\02_Exported\2021-11-17"
	
	fn exportSelected pathModel pathTex exportAnimation exportClones overwriteTex bakeType =
	(
		local Assembly = dotNetClass "System.Reflection.Assembly"
		Assembly.loadfrom asseblyPath
		local maxScriptManager = dotNetObject "Max2Babylon.MaxScriptManager"

		-- UPDATE YOUR OUTPUT PATH
		-- Use \\ or / to separate folder.
		-- Use \\\ or // for network path. Ex: "\\\192.168.0.1\\my\\docs\\test.babylon"
		local param = maxScriptManager.InitParameters testPath
		--showproperties param
		
		param.animgroupExportNonAnimated =  TRUE
		param.applyPreprocessToScene = 	FALSE
		param.autoSaveSceneFile = 	FALSE
		
		if bakeType == 2 then 
		(
			param.usePreExportProcess = 	exportAnimation
			param.bakeAnimationFrames = 	exportAnimation
			param.bakeAnimationType = 	(dotnetclass "Max2Babylon.BakeAnimationType").BakeAllAnimations
		)
		
		param.createDefaultSkybox = 	FALSE
		--param.customGLTFMaterialExporter = 	undefined
		param.dracoCompression = 	TRUE
		--param.dracoParams = 	undefined
		param.enableKHRLightsPunctual = 	FALSE
		param.enableKHRMaterialsUnlit = 	FALSE
		param.enableKHRTextureTransform = 	FALSE
		param.exportAnimations = exportAnimation
		param.exportAnimationsOnly = 	FALSE
		--param.exporterVersion = 	undefined
		param.exportHiddenObjects = 	FALSE
		param.exportKeepNodePosition = 	FALSE
		--param.exportLayers = 	undefined
		param.exportMaterials = 	TRUE
		param.exportMorphNormals = 	TRUE
		param.exportMorphTangents = 	TRUE
		--param.exportNode = 	undefined
		param.exportOnlySelected = 	TRUE
		param.exportSkins = 	TRUE
		param.exportTangents = 	TRUE
		param.exportTextures = 	TRUE
		param.flattenScene = 	FALSE
		param.generateManifest = 	FALSE
		param.mergeAO = 	TRUE
		param.mergeContainersAndXRef = 	FALSE
		--param.ModelFilePathProperty = 	"modelFilePathProperty"
		param.optimizeAnimations = 	FALSE
		param.optimizeVertices = 	TRUE
		param.outputFormat = 	"gltf"
		param.outputPath = 	pathModel
		param.overwriteTextures = overwriteTex
		param.pbrEnvironment = ""
		--param.PBREnvironmentPathPropertyName = 	"babylonjs_pbr_environmentPathProperty"
		param.pbrFull = FALSE
		--param.PBRFullPropertyName = 	"babylonjs_pbr_full"
		param.pbrNoLight = 	FALSE
		--param.PBRNoLightPropertyName = 	"babylonjs_pbr_nolight"
		param.rebuildMorphTarget = 	TRUE
		param.scaleFactor = 	1
		--param.softwarePackageName = 	undefined
		--param.softwareVersion = 	undefined
		param.textureFolder = 	pathTex
		--param.TextureFolderPathProperty = 	"textureFolderPathProperty"
		--param.textureFormatExportPolicy = 	dotNetObject:BabylonExport.Entities.TextureFormatExportPolicy
		param.tryToReuseOpaqueAndBlendTexture = 	FALSE
		param.txtQuality = 	100L
		param.useClone = 	exportClones
		param.useMultiExporter = 	FALSE
		
		param.writeTextures = 	TRUE

		maxScriptManager.Export param true -- <-- Uncomment to enable logging
	)
	
	/*Collapse Transform 0.2 [2010-09-06] by Anubis [project3d.narod.ru]*/
	fn collapseAnimation objArray nthFrame = 
	(
		with undo "Collapse" on 
		(
			redrawFlag = keyboard.controlPressed
			with redraw redrawFlag 
			(
				for obj in objArray do 
				(
					local tmp = Point()
					for t = animationRange.start to animationRange.end by nthFrame do 
					(
						if redrawFlag do sliderTime = t -- update
						with animate on at time t tmp.transform = obj.transform
					)
					
					obj.transform.controller = tmp.transform.controller -- instance
					delete tmp
				)
			) 
			redrawViews()
		)
	)
	
	fn collapseAnimation2 objArray = 
	(
		with undo "Collapse" on 
		(
			redrawFlag = keyboard.controlPressed
			with redraw redrawFlag 
			(
				local points = for o in objArray collect (Point())
				for t = animationRange.start to animationRange.end do 
				(
					for i=1 to objArray.count do 
					(
						if redrawFlag do sliderTime = t -- update
						with animate on at time t points[i].transform = objArray[i].transform
					)
				)
				
				for i=1 to objArray.count do 
				(
					objArray[i].transform.controller = points[i].transform.transform.controller -- instance
				)
				delete points
			)
			redrawViews()
		)
	)
	
	fn setUnwrapChannel ch = 
	(
		local allobj = for o in selection where  classof o.modifiers[1] == Unwrap_UVW collect o
		
		if allObj.count == 0 then (messageBox "No objects selected.")
		
		clearSelection()

		for o in allobj do with redraw off
		(
			max modify mode
			select o
			
			o.modifiers[1].setMapChannel ch
		)
	)

	fn repackUVLayout = 
	(
		local allobj = for o in selection where  classof o.modifiers[1] == Unwrap_UVW collect o
		
		if allObj.count == 0 then (messageBox "No objects selected.")
		
		clearSelection()

		for o in allobj do with redraw off
		(
			max modify mode
			select o
			
			o.modifiers[1].setMapChannel 3
			o.modifiers[1].pack 0 0.005 true true true
		)
	)

	fn convertAndSetMapChannel ch =
	(
		local allobj = for o in selection collect o
		
		if allObj.count == 0 then (messageBox "No objects selected.")
		
		clearSelection()
		
		for o in allobj do with redraw off
		(
			if classof o.material == Shell_Material then
			(		
				if classof o.material.bakedMaterial == Multimaterial then
				(
					o.material.bakedMaterial = o.material.bakedMaterial[1]
				)
				
				
				if classof o.material.bakedMaterial == VrayMtl then
				(
					local diffTex = o.material.bakedMaterial.texmap_diffuse
					
					if classof diffTex == bitmapTex then
					(
						diffTex.coords.mapchannel = ch
					)
					
					o.material.bakedMaterial = StandardMaterial name: o.material.bakedMaterial.name
					o.material.bakedMaterial.diffuseMap = diffTex
				)
				else if classof o.material.bakedMaterial == Standardmaterial then
				(
					local diffTex = o.material.bakedMaterial.diffuseMap
					
					if classof diffTex == bitmapTex then
					(
						diffTex.coords.mapchannel = ch
					)
				)
				o.material = o.material.bakedMaterial
			)
			
			if classof o.modifiers[1] == Unwrap_UVW then
			(
				max modify mode
				select o
				o.modifiers[1].setMapChannel ch
			)
		)
	)

	fn selectUnwrapped = 
	(
		local allObj = for o in objects where o.isHidden == false and classof o.modifiers[1] == Unwrap_UVW collect o
		clearSelection()
		select allObj		
	)
	
	fn writeNurbsPoints =
	(
		getSet = getNURBSSet $ #relational

		for i=1 to getset.count-1 do 
		(
			local pos = (getObject getSet i).pos
			print ("new THREE.Vector3(" + pos[1] as string +", "+ pos[2] as string + ", " + pos[3] as string + "),")
		)
	)
	
	-----------------------------------------------------------------------------------------------------------------------------------------
	-- file should be camera per line with comma separated coordinates for camera position followd by target positionController
	-----------------------------------------------------------------------------------------------------------------------------------------
	fn createCamerasFromTextFile = 
	(
		local f = openFile @"X:\21-1930_LV Interactive Map\03_Client\01_Download\21-11-30\cams.txt"
		local s = 39.3701
		try(
				while not eof f do 
				(
					print "Parsing FrameRange.txt"
					local parsedLine = readline f
					local filterArr = FilterString parsedLine ","
					
					for i=2 to filterArr.count do filterArr[i] = trimRight (trimLeft filterArr[i]) as integer
					
					-- from babylon [x,y,z] to max [x, -z, y] also apply scaling, babylon exports pure numbers disregarding units
					local cam = Targetcamera fov:60 pos:[filterArr[2]*s,-1.0*filterArr[4]*s,filterArr[3]*s] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [filterArr[5]*s,-1.0*filterArr[7]*s,filterArr[6]*s])) name:(filterArr[1]	+ "_old")
					cam.target.name = filterArr[1] + "_old.Target"
				)
			)
			catch("end of file")
	)
	
	-----------------------------------------------------------------------------------------------------------------------------------------
	-- prints json formated string to console
	-----------------------------------------------------------------------------------------------------------------------------------------
	fn exportCamDataToJSON = 
	(
		local camsPort = ""
		local targetsPort = ""
		
		local camsLand = ""
		local targetsLand = ""
		
		local portString = "\tportrait: {\n"
		local landString = "\tlandscape: {\n"
		
		local camString = "\nexport const focusPositions = {\n"
		local targetString = "export const focusLookAt = {\n"
		
		--glTF takes unit values without conversion, but position returns max unit values - need to convert
		local s = 39.3701
		
		for o in cameras where (matchpattern o.name pattern:"*old*" casesensitive:false != true) do 
		(
			local filterName = (FilterString o.name "_")[1]
			
			if classof o == Targetobject then
			(	
				if matchpattern o.name pattern:"*land*" casesensitive:false == true then
				(
					targetsLand = targetsLand + "\t\t" + ( filterName + ": {x: " + (o.pos.x/s) as string + ", y: " + (o.pos.z/s) as string + ", z: " + (-1.0*o.pos.y/s) as string + "},\n")
				)
				else if matchpattern o.name pattern:"*port*" casesensitive:false == true then
				(
					targetsPort = targetsPort + "\t\t" + ( filterName + ": {x: " + (o.pos.x/s) as string + ", y: " + (o.pos.z/s) as string + ", z: " + (-1.0*o.pos.y/s) as string + "},\n")
				)
			)
			else
			(
				if matchpattern o.name pattern:"*land*" casesensitive:false == true then
				(
					camsLand = camsLand + "\t\t" + ( filterName + ": {x: " + (o.pos.x/s) as string + ", y: " + (o.pos.z/s) as string + ", z: " + (-1.0*o.pos.y/s) as string + "},\n")
				)
				else if matchpattern o.name pattern:"*port*" casesensitive:false == true then
				(
					camsPort = camsPort + "\t\t" + ( filterName + ": {x: " + (o.pos.x/s) as string + ", y: " + (o.pos.z/s) as string + ", z: " + (-1.0*o.pos.y/s) as string + "},\n")
				)
			)
		)
		
		--Fix trailing comma and line break
		camsLand = (substring camsLand 1 (camsLand.count - 2)) + "\n"
		targetsLand = (substring targetsLand 1 (targetsLand.count - 2)) + "\n"
		
		camsPort = portString + camsPort + "\t},\n"
		targetsPort = portString + targetsPort + "\t},\n"
		camsLand = landString + camsLand + "\t}\n"
		targetsLand = landString + targetsLand + "\t}\n"
		
		local final = camstring + camsPort + camsLand + "}\n\n" + targetString + targetsPort + targetsLand + "}\n"
		print final
		ok
	)

	rollout BabylonExporter "Babylon Exporter" width:500 height:250
	(
		button path_btn "..." pos:[10,10] tooltip:"Set the Custom path for your render output."
		editText path_lbl "" text:rootDir pos:[40,12] width:440 height:18 enabled:true multiline:false
		
		checkbox overwriteTex_chk "Overwrite Textures" checked:true across:2 offset:[0,10]
		checkbox exportClones_chk "Use Clones (Experimental)" checked:true  offset:[0,10]
		
		checkbox exportAni_chk "Export Animation" checked:false across:2 offset:[0,5]
		spinner aniNthFrame_spn "Key every nth frame:" enabled:true range:[1,100,1] type:#integer scale:1  offset:[-10,5] width:80
		
		radiobuttons bakeType_rdb "Bake Keys Type:" labels: #("Bake Transforms", "Bake Skin Animation") default: 1 columns:2 offset:[0,5] enabled:exportAni_chk.checked align:#left
		
		button export_btn "Export Visible" offset:[0,15]
		--button exportAni_btn "Export Visible Animation"
		label tools_lbl "UV and Channel tools:" offset:[0,25]
		button selectUnwrapped_btn "Select Unwrapped Objects" 
		button repackUV_btn "Repack Unwrapped UVs" 
		button setChannel_btn "Set Unwrap Channel to 1" 
		button convertSet_btn "Convert Materials and Set Map Channel" 
		
		on BabylonExporter open do
		(
			if rootDir == "" or rootDir == undefined then
			(
				export_btn.enabled = false
				exportAni_btn.enabled = false
			)
		)
		
		on path_lbl changed txt do
		(
			rootDir = txt
		)
		
		on path_btn pressed do
		(
			try 
			(
				rootDir = getBitmapSaveFileName  caption:"Click OK" filename:"Go to Dir an Click Save.tga"
				if true then
				(	
					path_lbl.text = getFilenamePath rootDir
					rootDir = getFilenamePath rootDir
					export_btn.enabled = true
				)
				else 
				(
					path_lbl.text = ""
					export_btn.enabled = false
					rootDir = ""
				)
			)
			catch 
			(		
				path_lbl.text = ""
				export_btn.enabled = false
				rootDir = ""
			)
		)
		
		on exportAni_chk changed n do
		(
			bakeType_rdb.enabled = n
		)
		
		--on bakeType_rdb changed n do print bakeType_rdb.state
		
		on export_btn pressed do
		(
			if doesFileExist asseblyPath then
			(
				
				autosave.Enable = false 
				
				clearSelection()
				actionMan.executeAction 0 "40021"  -- Selection: Select All
				
				if exportAni_chk.checked == true and bakeType_rdb.state == 1 then (collapseAnimation selection aniNthFrame_spn.value )
				else if exportAni_chk.checked == true and bakeType_rdb.state == 2 then 
				(
					local pathAnimationObjects = for o in objects where classof o.position.controller == Path_Constraint collect o
					collapseAnimation pathAnimationObjects aniNthFrame_spn.value
				)
				
				local obj = selection[1]
				local layerName = obj.layer.name
				
				if (filterstring layerName ".").count > 1 then
				(
					layerName = (filterstring layerName ".")[2]
				)
				
				
				local pathModel = rootDir + "\\glTF_" + layerName + "\\" + layerName + ".gltf"
				local pathTex = rootDir + "\\glTF_" + layerName + "\\"
				
				local md = makeDir pathTex
				
				if md == true or  doesFileExist asseblyPath == true then
				(	
					-- exportSelected pathModel pathTex exportAnimation exportClones overwriteTex bakeType
					exportSelected pathModel pathTex exportAni_chk.checked exportClones_chk.checked overwriteTex_chk.checked bakeType_rdb.state
				)
				else
				(
					messageBox ("Can't create export directory.")
				)
				
				if exportAni_chk.checked == true then	max undo
				
				clearSelection()
				
				autosave.Enable = true

				
			)
			else
			(
				messageBox ("Max 2 Babylon Assembly DLL is missing at\n"+asseblyPath)
			)
		)
		
		/*
		on exportAni_btn pressed do
		(
			if doesFileExist asseblyPath then
			(
				clearSelection()
				actionMan.executeAction 0 "40021"  -- Selection: Select All
				
				collapseAnimation selection
				
				local obj = selection[1]
				local layerName = obj.layer.name
				
				if (filterstring layerName ".").count > 1 then
				(
					layerName = (filterstring layerName ".")[2]
				)
				
				local pathModel = rootDir + "\\glTF_" + layerName + "\\" + layerName + ".gltf"
				local pathTex = rootDir + "\\glTF_" + layerName + "\\"
				
				local md = makeDir pathTex
				
				if md == true or  doesFileExist asseblyPath == true then
				(	
					exportSelected pathModel pathTex true false
				)
				else
				(
					messageBox ("Can't create export directory.")
				)
				clearSelection()
				max undo
			)
			else
			(
				messageBox ("Max 2 Babylon Assembly DLL is missing at\n"+asseblyPath)
			)
		)
		*/
		
		on selectUnwrapped_btn pressed do
		(
			selectUnwrapped()
		)
		
		on repackUV_btn pressed do
		(
			repackUVLayout()
		)
		
		on setChannel_btn pressed do
		(
			setUnwrapChannel 1
		)
		
		on convertSet_btn pressed do
		(
			if getSaveRequired() == true then 
			(
				local qb = queryBox "File unsaved, save file before processing?" beep:false
				if qb then saveMaxFile (maxfilepath + maxfilename)  clearNeedSaveFlag:true quiet:true
			)	
			
			convertAndSetMapChannel 1
		)
	)
	
	on execute do
	(
		try(DestroyDialog BabylonExporter) catch ()
		
		createDialog BabylonExporter
	)--end on execute
)