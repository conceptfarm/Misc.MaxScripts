macroScript ProcessCosmosAssets
category:"ilya_s Scripts"
internalcategory:"ilya_s Scripts"
tooltip:"ProcessCosmosAssets"
buttontext:"ProcessCosmosAssets"
(
	/*
	when parsing need to replace the illegal & character with the legal &amp; character for the xml vraymat file
	*/
	global processCosmos_RO
	local assetSubtypeList = #("--")
	
	fn getFilesRecursive root pattern =
 	( 
		if root[root.count] == "\\" then root = substring root 1 (root.count-1)
		
		local dir_array = GetDirectories (root+"/*")
 
		for d in dir_array do
		(
			join dir_array (GetDirectories (d+"/*"))
		)
 
		join dir_array (GetDirectories root)
 
		local my_files = #()
		
		for f in dir_array do
		(
			join my_files (getFiles (f + pattern))
		)
		
		my_files
 	)
	
	fn diffArray a b =
	(
		local retArray = #()
		for element in a do
		(
			local idx = finditem b element
			if idx == 0 then
			append retArray element
		)
		retArray
	)
	
	fn processPreviewImage maxPath =
	(
		local previewImage = (getFilenamePath maxPath) + "Previews\\" + (getFilenameFile maxPath) + ".png"
				
		if doesFileExist previewImage == false then
		(
			local images = getFilesRecursive (getFilenamePath previewImage) "*.*"
			
			/*
			-- Using largest doesn't always work --
			
			local largestImage = undefined
			local largestSize = 0
			
			for f in images do
			(
				if (getFileSize f) > largestSize then
				(
					largestImage = f
					largestSize = (getFileSize f)
				)
			)
			
			if (largestImage != undefined and largestSize > 0L ) then
			(
				copyFile largestImage previewImage
			)
			*/
			if images.count > 0 then
			(
				copyFile images[1] previewImage
			)
		)		
	)
	
	fn repathVrmatMaterial_v2 matPath =
	(
		--file_location = @"Y:\Models\___Libraries___\VrayCosmos\Packages\3D_Models\People\Alison_Posed_012_5b23266b\5b23266b_3dl_Alison_Posed_012 - Copy.vrmat"
		--txFilesPath =  @"Y:\Models\___Libraries___\VrayCosmos\Packages\3D_Models\People\Claudia_Posed_013_b4d036ee\Assets\"
		
		/*
		<parameter handler="default" label="file" name="file" listType="none" type="string">
			<value>Y:\Models\___Libraries___\VrayCosmos\Packages\3D_Models\People\Petra_Posed_010_13a6bd83\Assets\13a6bd83_IOR_1k_raw.tx</value>
		</parameter>
		*/	
		
		
		local XmlDoc = dotNetObject "System.Xml.XmlDocument"
		XmlDoc.Load matPath
		local root = XmlDoc.DocumentElement

		local fileNodeList = root.SelectNodes("//parameter[@label='file']/value")

		local allFiles = getFilesRecursive (getFilenamePath matPath) "*"
				
		for i = 0 to fileNodeList.count-1 do
		(
			local fileItem = filenameFromPath (fileNodeList.itemof i).innerText
			for f in allFiles do
			(
				if (matchpattern f pattern:("*" + fileItem) ignoreCase:true) then 
				(
					--print (fileNodeList.itemof i).innerText
					--print fileItem
					--print f
					(fileNodeList.itemof i).innerText = f
					exit
				)
			)
		)
		XmlDoc.Save matPath
	)
		
	fn repathVrmatMaterial matPath =
	(
		--file_location = @"Y:\Models\___Libraries___\VrayCosmos\Packages\3D_Models\People\Alison_Posed_012_5b23266b\5b23266b_3dl_Alison_Posed_012 - Copy.vrmat"
		--txFilesPath =  @"Y:\Models\___Libraries___\VrayCosmos\Packages\3D_Models\People\Claudia_Posed_013_b4d036ee\Assets\"
		
		/*
		<parameter handler="default" label="file" name="file" listType="none" type="string">
			<value>Y:\Models\___Libraries___\VrayCosmos\Packages\3D_Models\People\Petra_Posed_010_13a6bd83\Assets\13a6bd83_IOR_1k_raw.tx</value>
		</parameter>
		*/	
		
		
		local XmlDoc = dotNetObject "System.Xml.XmlDocument"
		XmlDoc.Load matPath
		local root = XmlDoc.DocumentElement

		local fileNodeList = root.SelectNodes("//parameter[@label='file']/value")

		local txFilesPath = (getFilenamePath matPath) + "Assets\\"
		local txFiles = getFiles (txFilesPath + "*.tx")

		--Get a list of available channels (Diff, Gloss, Refl....)
		local txChannels = for f in txfiles collect (substring (getFilenameFile f) ((findString (getFilenameFile f) "_")+1) -1)

		for i = 0 to fileNodeList.count-1 do
		(
			local fileItem = fileNodeList.itemof i
			for c = 1 to txChannels.count do
			(
				if (matchpattern fileItem.innerText pattern:("*/textures/" + txChannels[c] +"*") ignoreCase:true) then 
				(
					--print fileItem.innerText 
					--print txChannels[c]
					--print txFiles[c]
					fileItem.innerText = txFiles[c]
				)
			)
		)
		XmlDoc.Save matPath
	)
 
	fn processVrayProxy location overwrite =
	(
		--local location = getSavePath caption:"Files to process..."
		--local location = @"Y:\Models\___Libraries___\VrayCosmos\Packages\3D_Models\People"
		--local location = @"Y:\Models\___Libraries___\VrayCosmos\Packages\3D_Models\People\10731_Lisa_a0dfbf55"
		
		--get all .vrmesh files from the specified folder  --and all its subfolders:
		local vrMeshFiles = getFilesRecursive location "*3dh*.vrmesh"  -- change the folder here
		
		local iter = 1
		
		for f in vrMeshFiles do
		(
			local cleanName = (substring (getFilenameFile f ) ((findString (getFilenameFile f ) "_3dh_") + 5) -1)
			local maxSaveFileName = ((getFilenamePath f) + cleanName + "_01.max")
				
			if doesFileExist maxSaveFileName == false or overwrite == true then 
			(
				resetMaxFile #noPrompt
					
				local newProxy = VrayProxy pos:[0,0,0]
				newProxy.filename = f
				local lowResProxyPath = (getFilenamePath f) + (substituteString (getFilenameFile f ) "_3dh_" "_3dm_") + ".vrmesh"
				if doesFileExist lowResProxyPath then ( newProxy.fileNamePreview = lowResProxyPath )
				newProxy.proxy_scale  = 0.3937
				newProxy.display = 3
				newProxy.name = "VrayProxy_" + cleanName + "_001"
				
				local matPath = (getFilenamePath f) + (getFilenameFile f ) + ".vrmat"
				
				if doesFileExist matPath then
				(
					repathVrmatMaterial_v2 matPath
					local oldMatEditormode = MatEditor.mode
					MatEditor.mode = #advanced
					importVRmatMaterial(matPath)
					local newMat = sme.GetMtlInParamEditor() 
					
					newProxy.material = newMat
					MatEditor.Close() 
					MatEditor.mode = oldMatEditormode
					setmeditmaterial 1 newMat
					
					--delete SME Views
					for i = sme.GetNumViews() to 1 by -1 do sme.DeleteView i false
					
					--Simplify MultiMat with 1 Element
					if classof newMat == Multimaterial then
					(
						if newMat.count == 1 then
						(
							replaceInstances newMat newMat[1]
						)
					)
				)
				
				backgroundColor = color 255 255 255
				actionMan.executeAction 0 "310"  -- Tools: Zoom Extents Selected
				saveMaxFile  ((getFilenamePath f) + cleanName + "_01.max") clearNeedSaveFlag:true quiet:true
				
			)
			
			processPreviewImage maxSaveFileName
			
			iter = iter + 1
			
			if mod iter 10 == 0.0 then gc()
		)
	)
	
	fn processMaterials location overwrite = 
	(
		--local location = getSavePath caption:"Files to process..."
		local vrMatFiles = getFilesRecursive location "*3dh*.vrmat"  -- change the folder here
		
		local iter = 1
		
		for f in vrMatFiles do
		(
			local cleanName = (substring (getFilenameFile f ) ((findString (getFilenameFile f ) "_3dh_") + 5) -1)
			local maxSaveFileName = ((getFilenamePath f) + cleanName + "_01.max")
				
			if doesFileExist maxSaveFileName == false or overwrite == true then 
			(
				resetMaxFile #noPrompt
					
				local newSphere = Sphere realWorldMapSize:on radius:39.3701 pos:[0.0,0.0,0]
				newSphere.name = "VrMat_" + cleanName + "_001"
				newSphere.segs = 24
				newSphere.mapCoords = true
				
				repathVrmatMaterial_v2 f
				try
				(
					local oldMatEditormode = MatEditor.mode
					MatEditor.mode = #advanced
					importVRmatMaterial(f)
					local newMat = sme.GetMtlInParamEditor() 
					
					newSphere.material = newMat
					MatEditor.Close() 
					MatEditor.mode = oldMatEditormode
					setmeditmaterial 1 newMat
					
					for i = sme.GetNumViews() to 1 by -1 do sme.DeleteView i false 
					
					--Sometimes the material names include the realworld measurement of the texture ie: 945f0c2d_3dh_Brick_Wall_01_200cm.vrmat
					--Lets exctract that and size the VRayUVWRandomizer accordingly
					local VRayUVWRandos = getClassInstances VRayUVWRandomizer
					local VRayBitmaps = getClassInstances VrayBitmap
					--go through all peices of the file and test for integer and unit convertability, collect only non-integer string and convertable strings
					local u = for s in (filterstring  (getFilenameFile f ) "_") where (try(units.decodeValue s; s as integer == undefined)catch(false) != false) collect (units.decodeValue s)
					if VRayUVWRandos.count > 0 and u.count > 0  then
					(
						u = u[1]
						for m in VRayUVWRandos do
						(
							m.coords.coords.realWorldScale = true 
							m.coords.coords.realWorldHeight = u
							m.coords.coords.realWorldWidth = u
						)
					)
					else if VRayUVWRandos.count == 0 and u.count > 0  and VRayBitmaps.count > 0 then
					(
						u = u[1]
						for m in VRayBitmaps do
						(
							m.coords.realWorldScale = true 
							m.coords.realWorldHeight = u
							m.coords.realWorldWidth = u
						)
					)
					--get VRayUVWRandomizer by class and change the coords to real world and try and extract coord info from f -> try(units.decodeValue "200cm")catch("not a unit")
					
					backgroundColor = color 255 255 255
					actionMan.executeAction 0 "310"  -- Tools: Zoom Extents Selected
					saveMaxFile  ((getFilenamePath f) + cleanName + "_01.max") saveAsVersion:2020 clearNeedSaveFlag:true quiet:true
				)
				catch 
				(
					print ("Error in file: " + f)
					print("Failed to create: " + maxSaveFileName)
				)
			)
			iter = iter + 1
			
			if mod iter 10 == 0.0 then gc()
		)
	)
	
	fn processHDRI location overwrite =
	(
		--local location = getSavePath caption:"Files to process..."

		local allVrMatFiles = getFilesRecursive location "*3dh*.vrmat"  -- change the folder here
		local vrMatLightFiles = getFilesRecursive location "*3dh*_light.vrmat"  -- change the folder here
		
		local vrMatFiles = diffArray allVrMatFiles vrMatLightFiles
		
		local iter = 1
		
		for f in vrMatFiles do
		(
			local cleanName = (substring (getFilenameFile f ) ((findString (getFilenameFile f ) "_3dh_") + 5) -1)
			local maxSaveFileName = ((getFilenamePath f) + cleanName + "_01.max")
			local vrMatLight = (getFilenamePath f) + (getFilenameFile f) + "_light.vrmat"
			
			if (doesFileExist maxSaveFileName == false or overwrite == true) and doesFileExist vrMatLight then 
			(
				resetMaxFile #noPrompt
				
				repathVrmatMaterial_v2 f
				
				try
				(
					local oldMatEditormode = MatEditor.mode
					MatEditor.mode = #advanced
					importVRmatMaterial(f)
					local newMat = sme.GetMtlInParamEditor()
					
					if classof newMat == VRayBitmap then 
					(
						newMat.ground_on = true
						newMat.coords.realWorldScale = false 
						newMat.coords.u_tiling =  1.0
						newMat.coords.v_tiling = 1.0
					)
					
					importVRmatMaterial(vrMatLight)
					
					local l = (for o in lights collect o)[1]
					
					if l != undefined then
					(
						l.texmap_on = true
						l.texmap = newMat

					)
					
					--newSphere.material = newMat
					MatEditor.Close() 
					MatEditor.mode = oldMatEditormode
					setmeditmaterial 1 newMat
					
					for i = sme.GetNumViews() to 1 by -1 do sme.DeleteView i false 
									
					backgroundColor = color 255 255 255
					actionMan.executeAction 0 "310"  -- Tools: Zoom Extents Selected
					saveMaxFile  ((getFilenamePath f) + cleanName + "_01.max") saveAsVersion:2020 clearNeedSaveFlag:true quiet:true
				)
				catch 
				(
					print ("Error in file: " + f)
					print ("Failed to create: " + maxSaveFileName)
				)
			)
			iter = iter + 1
			
			if mod iter 10 == 0.0 then gc()
		)
		
	)
	
	-- Fake functions for testing
	fn processHDRI_f location overwrite =
	(
		local allVrMatFiles = getFilesRecursive location "*3dh*.vrmat"  -- change the folder here
		local vrMatLightFiles = getFilesRecursive location "*3dh*_light.vrmat"  -- change the folder here
		print allVrMatFiles
	)
	
	fn processMaterials_f location overwrite =
	(
		local vrMatFiles = getFilesRecursive location "*3dh*.vrmat"  -- change the folder here
		print vrMatFiles
	)
	
	fn processVrayProxy_f location overwrite =
	(
		local vrMeshFiles = getFilesRecursive location "*3dh*.vrmesh"  -- change the folder here
		print vrMeshFiles
	)
	
	rollout processCosmos_RO "Process Cosmos Assets v4" width:340
	(
		editText cosmosRootPath_edit "Cosmos Root: " width:320 height:15 text: @"Y:\Models\___Libraries___\VrayCosmos\Packages" enabled:false
		dropdownlist assetType_dd "Asset Type: " items:#("3D_Models", "HDRIs", "Materials")
		dropdownlist assetSubtype_dd "Asset Sub-type: " items:assetSubtypeList
		checkbox overwrite_chb "Overwrite?" checked:false
		button process_btn "Process"

		on processCosmos_RO open do
		(
			assetSubtypeList = for d in (GetDirectories (cosmosRootPath_edit.text + "\\3D_Models" + "/*")) collect (pathConfig.stripPathToLeaf d)
			assetSubtype_dd.items = join #("--ALL SUBFOLDERS--") assetSubtypeList
		)
		
		on assetType_dd selected i do
		(
			assetSubtypeList = for d in (GetDirectories (cosmosRootPath_edit.text + "\\" + assetType_dd.items[i] + "/*")) collect (pathConfig.stripPathToLeaf d)
			assetSubtype_dd.items = join #("--ALL SUBFOLDERS--") assetSubtypeList
			assetSubtype_dd.selection = 1	
		)
		
		on process_btn pressed do
		(
			local location = cosmosRootPath_edit.text + "\\" + assetType_dd.selected + "\\" + assetSubtype_dd.selected
			if assetSubtype_dd.selection == 1 then location = cosmosRootPath_edit.text + "\\" + assetType_dd.selected 
			
			case assetType_dd.selected of 
			(
				"3D_Models": processVrayProxy location overwrite_chb.checked
				"HDRIs": processHDRI location overwrite_chb.checked
				"Materials": processMaterials location overwrite_chb.checked
			)
		)
	)
	
	on execute do 
	(
		try(destroyDialog processCosmos_RO)catch()
		createDialog processCosmos_RO
	)
	--processHDRI true
	--processMaterials true
	--processVrayProxy false
)