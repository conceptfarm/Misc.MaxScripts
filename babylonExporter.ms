-------------------------------------------------------------------------------
-- BabylonExporters.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Oct 28 2021
-- Babylon exporter piggybacking on Max2Babylon plugin
-------------------------------------------------------------------------------
macroScript BabylonExporter
category:"ilya_s Scripts"
tooltip:"Babylon Exporter"
buttontext:"BabylonExporter"
(
	global BabylonExporter_RO
	persistent global BabylonExporter_rootDir
	
	local asseblyPath = (getDir #maxRoot) + "bin\\assemblies\\Max2Babylon.dll"
	local testPath = "C:\\temp\\test.babylon" 
	local fileFormats = #(".gltf",".glb")

	
	fn exportSelected pathModel pathTex fileformat exportAnimation exportClones overwriteTex bakeType useDraco dracoCompLevel =
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
		
		param.dracoCompression = useDraco
		if useDraco then
		(
			if dracoCompLevel >= 0 then 
			(
				local dracoParams = (dotNetObject "BabylonExport.Entities.DracoParameters")
				dracoParams.compressionLevel = dracoCompLevel
				param.dracoParams = dracoParams
			)
		)
		
	
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
		param.outputFormat = 	(substring fileFormat 2 10) --remove the leading period
		param.outputPath = 	pathModel
		param.writeTextures = 	TRUE
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
		param.txtQuality = 100L
		param.useClone = exportClones
		param.useMultiExporter = 	FALSE
		
		maxScriptManager.Export param true -- <-- Uncomment to enable logging
	)
	
	fn padNumber nr padLen = (local n = (nr as string)	for x = 1 to (padLen - n.count) do n = "0" + n 	return n)
	
	fn useToday =
	(	
		local todayDate = ""
		local timenow = getlocaltime()
		todayDate = timenow[1] as string + "-" + (padnumber timenow[2] 2) as string + "-" + (padnumber timenow[4] 2) as string
		todayDate
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
	
	/* Ignore certain transforms , but i think glb export sets those keys anyway*/
	fn collapseAnimation3 objArray nthFrame = 
	(
		with undo "Collapse" on 
		(
			local redrawFlag = keyboard.controlPressed
			with redraw redrawFlag 
			(

				for obj in objArray do 
				(
					local doScale = if obj.scale.controller.keys.count > 0 then true else false
					local doPos = if obj.position.controller.keys.count > 0 then true else false
					local doRot = if obj.rotation.controller.keys.count > 0 then true else false
				
					local tmp = Point()
					for t = animationRange.start to animationRange.end by nthFrame do 
					(
						if redrawFlag do sliderTime = t -- update
						with animate on at time t tmp.transform = obj.transform
					)
					
					--obj.transform.controller = tmp.transform.controller -- instance
					if doPos then obj.position.controller = tmp.position.controller
					if doRot then obj.rotation.controller = tmp.rotation.controller
					if doScale then obj.scale.controller = tmp.scale.controller
					
					delete tmp
				)
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
	
	/* Best not to use NURBs, there is a strage tangent interpolation in three.js that breaks path follow functions */
	fn writeNurbsPoints selArr=
	(
		local s = 39.3701
		for o in selArr as array where (classof o.baseobject == NURBSCurveshape) do 
		(
			local objectTM = o.transform
			local getSet = getNURBSSet o #relational

			format ("const " + o.name + " = new THREE.CatmullRomCurve3([\n")
			for i=1 to getset.count-1 do 
			(
				local pos = (getObject getSet i).pos * objectTM
				local p = point()
				p.pos = pos
				format ("\tnew THREE.Vector3(" + (pos[1]/s) as string +", "+ (pos[3]/s) as string + ", " + (-1.0*(pos[2]/s)) as string + "),\n")
				--print ("new THREE.Vector3(" + pos[1] as string +", "+ pos[2] as string + ", " + pos[3] as string + "),")
			)
			format ("]);\n")
		)
	)
	
	/*
	Exports a CurvePath object with predeclared segments, ready to go
	Not as compact as exporting just the points
	*/
	fn writeSplinePoint selArr = 
	(
		local scl = 39.3701
		for o in selArr as array where (classof o.baseobject == line or classof o.baseobject == SplineShape) do 
		(
			for s = 1 to (numSplines o) do
			(
				local curveName = o.name +"_"+ s as string
				format("const " + curveName + " = new THREE.CurvePath();\n")
				for k = 1 to (numSegments  o s) do
				(
					local knt1_i = k
					local knt2_i = if (knt1_i+1) > (numknots o s) then 1 else knt1_i+1
					local knt1 = (getKnotPoint o s knt1_i)/scl
					local knt2 = (getKnotPoint o s knt2_i)/scl
					local out_vec1 = (getOutVec o s knt1_i)/scl
					local in_vec2 = (getInVec o s knt2_i)/scl
					
					format ("const segment" + k as string + " = new THREE.CubicBezierCurve3(\n")
					format ("\tnew THREE.Vector3("+knt1.x as string +", " + knt1.z as string + ", " + (-knt1.y) as string + "),\n")
					format ("\tnew THREE.Vector3("+out_vec1.x as string +", " + out_vec1.z as string + ", " + (-out_vec1.y) as string + "),\n")
					format ("\tnew THREE.Vector3("+in_vec2.x as string +", " + in_vec2.z as string + ", " + (-in_vec2.y) as string + "),\n")
					format ("\tnew THREE.Vector3("+knt2.x as string +", " + knt2.z as string + ", " + (-knt2.y) as string + ")\n")
					format (");\n")
					format(curveName + ".add(segment"+ k as string+");\n")
				)--end k loop
			)--end s loop
		)
	)
	
	/*
	Exports a list of points, will need to create a CurvePath assembly/parser script in javascript
	p1, cP1, cP2, p2, cP2, cP3, p3 ....
	*/
	fn writeSplinePoint2 selArr = 
	(
		local scl = 39.3701
		for o in selArr as array where (classof o.baseobject == line or classof o.baseobject == SplineShape) do 
		(
			for s = 1 to (numSplines o) do
			(
				local curveName = if (numSplines o == 1) then (o.name) else (o.name +"_"+ s as string)
				format("const " + curveName + " = [\n")
				for k = 1 to (numSegments  o s) do
				(
					local knt1_i = k
					local knt2_i = if (knt1_i+1) > (numknots o s) then 1 else knt1_i+1
					local knt1 = (getKnotPoint o s knt1_i)/scl
					local knt2 = (getKnotPoint o s knt2_i)/scl
					local out_vec1 = (getOutVec o s knt1_i)/scl
					local in_vec2 = (getInVec o s knt2_i)/scl
					local trailingComma = if (k != numSegments o s ) or (isClosed o s == false) then ("),\n") else (")\n")
					
					format ("\tnew THREE.Vector3("+knt1.x as string +", " + knt1.z as string + ", " + (-knt1.y) as string + "),\n")
					format ("\tnew THREE.Vector3("+out_vec1.x as string +", " + out_vec1.z as string + ", " + (-out_vec1.y) as string + "),\n")
					format ("\tnew THREE.Vector3("+in_vec2.x as string +", " + in_vec2.z as string + ", " + (-in_vec2.y) as string + trailingComma)
					
					if (isClosed o s == false) and (k == numSegments o s ) then
					(
						--format "last open point"
						format ("\tnew THREE.Vector3("+knt2.x as string +", " + knt2.z as string + ", " + (-knt2.y) as string + ")\n")
					)
				)--end k loop
				format ("];\n")
			)--end s loop
		)
	)
	
	fn groupInstances selArr =
	(
		local result = #()
		local allObj = for o in selArr as array where superclassof o == GeometryClass collect o
		--clearselection as array()
		for o in allObj do
		(
			
			local instanceGroup = #(o.name, #(o.pos))
			InstanceMgr.GetInstances o &instances
			for p in instances where p != o do 
			(
				append instanceGroup[2] p.pos
				local deleteIndex = findItem allObj p
				if deleteIndex !=0 then deleteitem allObj deleteIndex
			)
			append result instanceGroup
		)
		result
	)


	fn writeObjectPos selArr = 
	(
		local scl = 39.3701
		local instanceGroups = groupInstances selArr
		
		for instGroup in instanceGroups do 
		(
			format("const " + instGroup[1] + " = [\n")
			
			for i = 1 to instGroup[2].count do
			(
					local oPos = instGroup[2][i]/scl
					local trailingComma = if (i != instGroup[2].count) then (",") else ("")
					
					format (oPos.x as string +"," + oPos.z as string + "," + (-oPos.y) as string + trailingComma)
					
			)--end k loop
			format ("\n];\n")
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

	rollout BabylonExporter_RO "Babylon Exporter" width:580 height:280
	(
		button path_btn "..." pos:[10,10] tooltip:"Set the Custom path for your render output." 
		editText path_lbl text:BabylonExporter_rootDir pos:[40,12] width:440 height:18 enabled:true multiline:false
		button date_btn "date" pos:[path_lbl.pos.x + path_lbl.width + 5,10] tooltip:"Last folder name set to today's date"
		button openDir_btn ">>>" pos:[date_btn.pos.x + date_btn.width + 5,10] tooltip:"Explore folder"
		
		radiobuttons fileFormat_rdb "File Format:" labels: fileFormats default: 1 columns:2  align:#left  --offset:[-70,5]
				
		checkbox overwriteTex_chk "Overwrite Textures" checked:true across:4 offset:[0,10]
		checkbox exportClones_chk "Use Clones (Experimental)" checked:true offset:[0,10]
		checkbox useDraco_chk "Use Draco" checked:true offset:[30,10]
		spinner dracoLevel_spn "Level:" range:[-1,10,7] type:#integer scale:1  offset:[-50,10] width:80 enabled:useDraco_chk.checked
		
		checkbox exportAni_chk "Export Animation" checked:false width:100 across:3 offset:[0,5]
		spinner aniNthFrame_spn "Key nth frame:" range:[1,100,1] type:#integer scale:1  offset:[-70,6] width:80 enabled:exportAni_chk.checked
		radiobuttons bakeType_rdb "Bake Keys Type:" labels: #("Bake Transforms", "Bake Skin Animation") default: 1 columns:2 offset:[-70,5] enabled:exportAni_chk.checked align:#left
		
		button export_btn "Export Visible" offset:[0,15]
		--button exportAni_btn "Export Visible Animation"
		label tools_lbl "Other Tools:" offset:[0,25]
		button selectUnwrapped_btn "Select Unwrapped Objects" across:3
		button repackUV_btn "Repack Unwrapped UVs" 
		button setChannel_btn "Set Unwrap Channel to 1"
		button convertSet_btn "Convert Materials and Set Channel" across:3
		button bezierToJS_btn "Convert Bezier to JS"
		
		on BabylonExporter_RO open do
		(
			if BabylonExporter_rootDir == "" or BabylonExporter_rootDir == undefined then
			(
				export_btn.enabled = false
				--exportAni_btn.enabled = false
			)
			else
			(
				print("root dir " + BabylonExporter_rootDir)
				path_lbl.text = BabylonExporter_rootDir
				export_btn.enabled = true
			)
		)
		
		on path_lbl changed txt do
		(
			BabylonExporter_rootDir = txt
		)
				
		on bezierToJS_btn pressed do
		(
			writeSplinePoint2 selection
		)
		
		on path_btn pressed do
		(
			try 
			(
				BabylonExporter_rootDir = getBitmapSaveFileName  caption:"Click OK" filename:"Go to Dir an Click Save.tga"
				if true then
				(	
					path_lbl.text = getFilenamePath BabylonExporter_rootDir
					BabylonExporter_rootDir = getFilenamePath BabylonExporter_rootDir
					export_btn.enabled = true
				)
				else 
				(
					path_lbl.text = ""
					export_btn.enabled = false
					BabylonExporter_rootDir = ""
				)
			)
			catch 
			(		
				path_lbl.text = ""
				export_btn.enabled = false
				BabylonExporter_rootDir = ""
			)
		)
		
		on date_btn pressed do
		(
			local dir = useToday()
			local newDir = (pathConfig.removePathLeaf BabylonExporter_rootDir) + "\\" + dir
			BabylonExporter_rootDir = newDir
			path_lbl.text = newDir
		)
		
		on openDir_btn pressed do
		(
			if doesDirectoryExist BabylonExporter_rootDir then
			(
				local cmd = "explorer.exe " + "\"" + BabylonExporter_rootDir + "\""
				HiddenDOSCommand  (cmd)
			)
			else
			(
				if queryBox "Folder does not exist.\nCreate the folder?" beep:false then
				(
					local makeFolder = makedir BabylonExporter_rootDir
					if makeFolder then
					(
						local cmd = "explorer.exe " + "\"" + BabylonExporter_rootDir + "\""
						HiddenDOSCommand  (cmd)
					)
					else
					(
						messageBox "Failed to create the folder"
					)
				)
			)
		)
		
		on exportAni_chk changed n do
		(
			bakeType_rdb.enabled = n
			aniNthFrame_spn.enabled = n
		)
		
		on useDraco_chk changed n do
		(
			dracoLevel_spn.enabled = n
		)
		
		on fileFormat_rdb changed n do print fileFormats[fileFormat_rdb.state]--print fileFormat_rdb.labels[state]
		
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
				
				
				local pathModel = BabylonExporter_rootDir + "\\glTF_" + layerName + "\\" + layerName + fileFormats[fileFormat_rdb.state]
				local pathTex = BabylonExporter_rootDir + "\\glTF_" + layerName + "\\"
				
				local md = makeDir pathTex
				
				if md == true or  doesFileExist asseblyPath == true then
				(	
					-- exportSelected pathModel pathTex exportAnimation exportClones overwriteTex bakeType
					exportSelected pathModel pathTex fileFormats[fileFormat_rdb.state] exportAni_chk.checked exportClones_chk.checked overwriteTex_chk.checked bakeType_rdb.state useDraco_chk.checked dracoLevel_spn.value
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
				
				local pathModel = BabylonExporter_rootDir + "\\glTF_" + layerName + "\\" + layerName + ".gltf"
				local pathTex = BabylonExporter_rootDir + "\\glTF_" + layerName + "\\"
				
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
		if BabylonExporter_rootDir == undefined then BabylonExporter_rootDir = @"X:\21-1930_LV Interactive Map\02_Exported\2021-11-17"
		try(DestroyDialog BabylonExporter_RO) catch()
		createDialog BabylonExporter_RO
	)--end on execute
)