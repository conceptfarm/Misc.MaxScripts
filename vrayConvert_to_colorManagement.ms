-----------------------------------------------------------------------------
-- MODIFIED FROM VRAYUTILS.MS ---------------------------------
-----------------------------------------------------------------------------
fn padNumber nr padLen = (local n = (nr as string)	for x = 1 to (padLen - n.count) do n = "0" + n 	return n)	

fn timeNow =
(	
	local result = ""
	local timenow = getlocaltime()
	result = timenow[1] as string + "_" + (padnumber timenow[2] 2) as string + "_" + (padnumber timenow[4] 2) as string + "_" + (padnumber timenow[5] 2) as string + "_" + (padnumber timenow[6] 2) as string + "_" + (padnumber timenow[7] 2) as string
	result
)

fn setRendererToVray =
(
	local result = false
	
	if (renderers.current.classID[1] != 1941615238 and renderers.current.classID[2] != 2012806412 ) then
	(
		local vrayRenderClass = (for _class in RendererClass.classes where (_class.classID[1] == 1941615238 and  _class.classID[2] == 2012806412 ) collect _class)[1] as string
		
		if vrayRenderClass != "undefined" then 
		(
			renderers.current = execute(vrayRenderClass+"()")
			if (renderers.current.classID[1] == 1941615238 and renderers.current.classID[2] == 2012806412 ) then (result = true)
		)
	)
	else 
	(
		result = true
	)
	result
)

fn ilyaConvertBitmapToPng mapPath =
(
	local result = #(mapPath, mapPath)
	local listOfSuppFormats = #(".bmp", ".tga", ".sgi", ".rgb", ".rgba", ".jpg", ".jpeg", ".jpe", ".pic", ".tif", ".tiff", ".psd")
	
	if (finditem listOfSuppFormats (tolower(getFilenameType mapPath))) > 0 then
	(
		local savePath = (getFilenamePath mapPath)+(getFilenameFile mapPath)+"_tempConvert.png"
		local bitmapObj = openBitMap mapPath -- not saveable 
		local copyBitmap = copy bitmapObj
		copyBitmap.filename = savePath
		local saved = save copyBitmap quiet:true
		close copyBitmap
		free copyBitmap
		
		if saved then result = #(mapPath, savePath)
	)
	
	result
)

fn ilyaConvertBitmapToPngMagic mapPath =
(
	local result = #(mapPath, mapPath, false)
	local magickPath = @"\\fs-01\DeadlineRepository10\submission\ImageMagic_7.0.11.6\magick.exe"
	local listOfSuppFormats = #(".bmp", ".tga", ".sgi", ".rgb", ".rgba", ".jpg", ".jpeg", ".jpe", ".pic", ".tif", ".tiff", ".psd")
	
	if (finditem listOfSuppFormats (tolower(getFilenameType mapPath))) > 0 and doesFileExist magickPath then
	(
		local savePath = (getFilenamePath mapPath)+(getFilenameFile mapPath)+"_tempConvert.png"
		local cmdString = magickPath + " convert \"" + mapPath + "\" -colorspace sRGB \"" +  savePath +"\""
		hiddenDOSCommand cmdString exitCode:&exitcode
		print (cmdString)
		print ("imageMagick returned code is " + exitcode as string)
		if exitcode == 0 then 
		(
			result = #(mapPath, savePath, true)
		)
	)
	else if (tolower(getFilenameType mapPath)) == ".png" then
	(
		result = #(mapPath, mapPath, true)
	)
	
	result
)

-- overwrite: overwrites existing tx file
-- preProcess: converts the exisitng jpg file to png using imageMagick
-- fileLockCheck: checks if the resulting tx file is locked, which likely resulted in a corrupt file

fn ilyaConvertImgToTX overwrite:false preProcess:false fileLockCheck:false = 
(
	--print "********** START CONVERSION  Image --> Tiled, MIP-mapped textures ****************"
	local start = timeStamp()
	if (convertPath == undefined) do 
	(
		local ver = getMaxReleaseAsString()
		convertPath = getVRayInstallPath ver
	)
	
	--The following method is used to collect a list of the bitmap file paths used in a scene
	--and sets them to mapfiles array using the mapped addmap function
	mapfiles = #()
	
	/*
	fn addmap mapfile =
	(
		local mapfileN = mapfile as name
		local index = finditem mapfiles mapfileN
		if index == 0 do append mapfiles mapfileN
	)
	*/
	
	if selection.count > 0 then
	(
		for o in selection as array do 
		(
			enumeratefiles o addmap 
		)
	)
	else
	(
		enumeratefiles addmap
	)
	local iImg = 0
	local mapfilesCount = mapfiles.count
	print ("mapfilesCount " + mapfilesCount as string)
	
	--The real conversion done by 'maketx.exe' for each mapfile from list - mapfiles
	--We make a batch file with a list of conversion commands 
	local batchFilePath = (getdir #temp) + "\\" + maxfilename + "_" + timeNow() + ".bat"
	local batchFile = createFile batchFilePath
	--test batchFile to make sure its created
		
	
	for mapfile in mapfiles do 
	(
		windows.processPostedMessages()
		local originalImgPath = mapPaths.getFullFilePath mapfile
		print ("originalImgPath " + originalImgPath)
		
		if ((classof originalImgPath) == String) then 
		(
			if ((stricmp (getFilenameType originalImgPath) ".tx") != 0) do 
			(
				local outpath=(getFilenamePath originalImgPath)+(getFilenameFile originalImgPath)+".tx"
				local tempPath = (getdir #temp) + "\\" + (getFilenameFile originalImgPath)+".tx"
				
				if (not (doesFileExist outpath)) or overwrite == true do 
				(
					if ((classof convertPath) == String) do 
					(
						if preProcess == true then 
						(
							local fullImgPath = ilyaConvertBitmapToPngMagic originalImgPath
							
							if fullImgPath[3] == true then
							(
								local cmdConverter=("\""+convertPath+"\" -v \"" + fullImgPath[2] + "\" -o \"" + outpath + "\" --tile 64 64")
								local delCommand = ("del /F /Q " + "\"" + fullImgPath[2] + "\"")
								format (cmdConverter + "\n") to: batchFile
								if fullImgPath[1] != fullImgPath[2] then format (delCommand + "\n") to: batchFile
							)
						)
						else
						(
							local cmdConverter=("\""+convertPath+"\" -v \"" + originalImgPath + "\" -o \"" + tempPath + "\" --tile 64 64")
							local copyCommand = ("echo f | xcopy " + "\"" + tempPath + "\" " + "\"" + outpath + "\" /r /y")
							local delCommand = ("del /F /Q " + "\"" + tempPath + "\"")
							format (cmdConverter + "\n") to: batchFile
							format (copyCommand + "\n") to: batchFile
							format (delCommand + "\n") to: batchFile
						)
					)
				)
			)
		)
		iImg = iImg + 1
		convertB2HDRI_Rollout.prog_convert.value = 100.*iImg/mapfilesCount
	)
	
	--format ("taskkill /f /t /im maketx.exe") to: batchFile
	close batchFile
	free batchFile
	

	local runBatchFile = DOSCommand ("\"" + batchFilePath +"\"")
	--print ("Batch cmd result is " + runBatchFile as string)
	
	iImg = 0
	local corruptFileNames = #()
	if fileLockCheck then
	(
		for mapfile in mapfiles do 
		(
			windows.processPostedMessages()
			local fullImgPath = mapPaths.getFullFilePath mapfile
			if ((classof fullImgPath) == String) then 
			(
				if ((stricmp (getFilenameType fullImgPath) ".tx") != 0) do 
				(
					local outpath = (getFilenamePath fullImgPath)+(getFilenameFile fullImgPath)+".tx"

					if (not (doesFileExist outpath)) then
					(
						format "Failed to convert % to TX,\n please check if you have write permissions for %\n" fullImgPath outpath
					)
					else
					(
						local renameTest = renameFile outpath (outpath + "2")
						if renameTest then 
						(
							renameFile (outpath + "2") outpath
						)
						else 
						( 
							print (outpath + " file is corrupt.")
							append corruptFileNames outpath 
						)
					)
				)
			)
			iImg = iImg + 1
			convertB2HDRI_Rollout.prog_convert.value = 100.*iImg/mapfilesCount
		)
	)
	convertB2HDRI_Rollout.prog_convert.value = 0
	local end = timeStamp()
	format "Converting took % seconds\n" ((end - start) / 1000.0)
	
	mapfiles=#()
	gc lite:true
		
	corruptFileNames
	--print "**********   END CONVERSION  Image --> Tiled, MIP-mapped textures ****************"
)

--Convert Max Standard Bitmap texture to Vray Bitmap (formerly Vray HDRI)
fn ilyaConvertB2HDRI_Texmap texmap isPropLinear isInCorruptList =
(
	if (texmap != undefined) then 
	(
		--TODO:
		--Insert here a process to process VrayBitmaps as well
		
		local tex = undefined
		local texmapFilename = undefined
		
		if classof texmap == Bitmaptexture then texmapFilename = texmap.fileName
		else if classof texmap == VrayBitmap then texmapFilename = texmap.HDRIMapName
		
		local mapFileNameIsValid = (texmapFilename != undefined and texmapFilename != "")
		--tex.gamma=1/2.2
		--tex.color_space=3 --Lele: set VRayBitmap's Color space to "From Max"

		convertB2HDRI_Rollout.replaceImgCounter = convertB2HDRI_Rollout.replaceImgCounter + 1
		convertB2HDRI_Rollout.prog_convert.value = 100.*convertB2HDRI_Rollout.replaceImgCounter/convertB2HDRI_Rollout.replaceImgNums
		
		convertB2HDRI_ConvertEXR = true
		

		--print("tex is a tx")
		--Here we would like to create VRayBitmap texture with Bitmaptexture file converted to EXR/TX bitmap file.
		convertB2HDRI_ErrorsInTXExisting = 0
		local convertB2HDRI_ConvertLinear = convertB2HDRI_Rollout.convertLinear
		
		--not sure we need this here anymore, all texture files should be preconverted already
		local resultHDRIMapName = if(mapFileNameIsValid) then convertB2HDRI_img2TX texmapFilename else undefined

		--If there isn't successful file conversion to EXR/TX or Bitmaptexture file name is not valid,
		--the original Bitmaptexture won't be replaced with VRayBitmap
		if (convertB2HDRI_ErrorsInTXExisting == 0 and resultHDRIMapName != undefined and classof texmap == Bitmaptexture) then 
		(
			tex = VRayBitmap()
			tex.name = texmap.name + "_VRay"
			tex.HDRIMapName = resultHDRIMapName
			
			if (tex.HDRIMapName != undefined) do 
			(
				if isPropLinear then
				(
					tex.color_space = 0 --color space transform is none
					tex.rgbColorSpace = 3 -- rgb primaries Raw
				)
				else
				(
					tex.color_space = 2 --color space transform is sRGB
					tex.rgbColorSpace = 1 -- rgb primaries sRGB
				)
			)
		)
		else if (convertB2HDRI_ErrorsInTXExisting == 0 and resultHDRIMapName != undefined and classof texmap == VrayBitmap) then 
		(		
			texmap.HDRIMapName = resultHDRIMapName
			
			if (texmap.HDRIMapName != undefined) do 
			(
				if isPropLinear then
				(
					texmap.color_space = 0 --color space transform is none
					texmap.rgbColorSpace = 3 -- rgb primaries Raw
				)
				else
				(
					texmap.color_space = 2 --color space transform is sRGB
					texmap.rgbColorSpace = 1 -- rgb primaries sRGB
				)
			)
			tex = texmap
		)
		else 
		(
			--print("tex is not tx")
			--Here we would like to create VRayBitmap texture without Bitmaptexture file convertion.
			tex = VRayBitmap()
			tex.name = texmap.name + "_VRay"
			
			if (mapFileNameIsValid) then 
			(
				tex.HDRIMapName = texmapFilename
				
				if isPropLinear then
				(
					tex.color_space = 0 --color space transform is none
					tex.rgbColorSpace = 3 -- rgb primaries Raw
				)
				else
				(
					tex.color_space = 2 --color space transform is sRGB
					tex.rgbColorSpace = 1 -- rgb primaries sRGB
				)
			) 
			else 
			(
				format "Image path for % does not exist.\n" texmap
			)
		)


		if (tex != undefined and classof texmap == Bitmaptexture) then 
		(
			--print("tex is not undefined")
			tex.mapType=4
			tex.UVGen.blur=texmap.coords.blur
			tex.UVGen.mapping=texmap.coords.mapping
			tex.UVGen.mapChannel=texmap.coords.mapChannel
			tex.UVGen.mappingType=texmap.coords.mappingType
			tex.UVGen.UVW_Type=texmap.coords.UVW_Type
			tex.UVGen.U_Mirror=texmap.coords.U_Mirror
			tex.UVGen.V_Mirror=texmap.coords.V_Mirror
			tex.UVGen.U_Tile=texmap.coords.U_Tile
			tex.UVGen.V_Tile=texmap.coords.V_Tile
			tex.UVGen.showMapOnBack=texmap.coords.showMapOnBack
			tex.UVGen.Noise_On=texmap.coords.Noise_On
			tex.UVGen.Noise_Animate=texmap.coords.Noise_Animate
			tex.UVGen.realWorldScale=texmap.coords.realWorldScale
			tex.UVGen.realWorldHeight=texmap.coords.realWorldHeight
			tex.UVGen.realWorldWidth=texmap.coords.realWorldWidth
			tex.UVGen.phase=texmap.coords.phase
			tex.UVGen.U_Angle=texmap.coords.U_Angle
			tex.UVGen.V_Angle=texmap.coords.V_Angle
			tex.UVGen.W_Angle=texmap.coords.W_Angle
			tex.UVGen.Noise_Amount=texmap.coords.Noise_Amount
			tex.UVGen.Noise_Size=texmap.coords.Noise_Size
			tex.UVGen.Noise_Levels=texmap.coords.Noise_Levels
			tex.UVGen.Blur_Offset=texmap.coords.Blur_Offset
			tex.UVGen.u_tiling=texmap.coords.u_tiling
			tex.UVGen.v_tiling=texmap.coords.v_tiling
			tex.UVGen.u_offset=texmap.coords.u_offset
			tex.UVGen.v_offset=texmap.coords.v_offset
			
			--Convert channel output
			tex.rgbOutput = texmap.rgbOutput
			tex.monoOutput = texmap.monoOutput
			tex.alphaSource = texmap.alphaSource
			
			--Convert crop/placement
			tex.cropplace_on = texmap.apply
			tex.cropplace_mode = texmap.cropPlace
			tex.cropplace_u = texmap.clipu
			tex.cropplace_v = texmap.clipv
			tex.cropplace_width = texmap.clipw
			tex.cropplace_height = texmap.cliph

			--Convert output parameters including curve control
			replaceInstances tex.output (copy texmap.output)

			--Frees up all the memory used by the image file bitmap caches.
			--This is useful if memory is fragmented with a lot of different bitmaps and you want to have just the ones currently active reloaded.
			freescenebitmaps()

		)
		--invokes the garbage collector without flush the undo system
		gc lite:true
		tex
	)
	else 
	(
		undefined
	)
)

-----------------------------------------------------------------------------
-- END FROM VRAYUTILS.MS   ----------------------------------------
-----------------------------------------------------------------------------

	
--gets properties of the material where the texturemap slot has a texturemap
--we don't get bitmaps just yet because they might not be the immediate texture maps
fn getTextureProperties mat = 
(
	local result = #()
	propArray = getpropnames mat 
	for p in propArray do
	(
		local _class = classof (getproperty mat p)
		local _superclass = superclassof (getproperty mat p)
		if _superclass == texturemap and _class != UndefinedClass do append result p
	)
	result
)

/*
fn removeFromBitmapArrayPropery fromArray usingArray prop =
(
	for o in usingArray where classof (getproperty o prop) == Bitmaptexture do
	(
		local index = findItem fromArray (getproperty o prop)
		if index != 0 then deleteItem fromArray index
	)		
)
*/

fn subtractArrays fromArray minusArray =
(
	local result = for o in fromArray where (findItem minusArray o) == 0 collect o
	result 
)

--Take arr and empty out array, flatten arr to out array
fn breakNestedArrays arr out = 
(
	for a in arr do
	(
		if classof a == Array then
		(
			breakNestedArrays a out
		)
		else
		(
			appendIfUnique out a
		)
	)
)

fn isGray c =
(
	local result = (c.r == c.g and c.g == c.b)
	result
)

fn isClass _class =
(
	local result = false
	try
	(
		local temp = getClassInstances _class
		result = true
	)
	catch
	(
		result = false
	)
	result
)

fn convertToVrayNormal tex = 
(
	local newTex = VrayNormalMap()
	newTex.name = tex.name + "_vray"
	newTex.normal_map = tex.normal_map
	newTex.normal_map_on = tex.map1on
	newTex.normal_map_multiplier = tex.mult_spin
	newTex.bump_map = tex.bump_map
	newTex.bump_map_on = tex.map2on
	newTex.bump_map_multiplier = tex.bump_spin
	newTex.flip_red = tex.flipred
	newTex.flip_green = tex.flipgreen
	newTex.swap_red_and_green = tex.swap_rg
	newTex
)

-- Converts all materials in the material colllection by class
-- requires colorMapPairs for that material class, to know which color swatches relate to what texture maps
-- requires texmapColorProps for that material class, to know which texmaps need sRGB conversion
-- requires Bitmap collection of CityScape Map to skip conversion
fn convertMaterialClass _class colorMapPairs texmapColorProps csBitmapMaps corruptFileNames =
(
	local classMatCollection = #()
	if selection.count > 0 then 
	(
		for o in selection as array do join classMatCollection (getclassinstances _class processchildren:true target:o)
	)
	else
	(
		classMatCollection = getclassinstances _class processchildren:true
	)
	
	for m in classMatCollection do
	(
			
		--cycle trough color properties here
		for propGroup in colorMapPairs do
		(
			-- check the color swatch if the color is not gray and if there is no map applied to it's pair
			-- make a vraycolor map with the color in srgb mode
			if not isGray (getproperty m propGroup[1]) and (getproperty m propGroup[2]) == undefined then
			(
				local newColor = VrayColor()
				newColor.rgb_primaries = 1
				newColor.color = (getproperty m propGroup[1])
				--newColor.color_gamma = 2.2
				
				setProperty m propGroup[2] newColor
			)
		)
		
		--props with texture maps present in the material
		local props = getTextureProperties m
		
		for prop in props do
		(
			--bitmap is linear, otherwise srgb conversion is needed
			local isPropLinear = true
			if findItem texmapColorProps prop != 0 then isPropLinear = false
				
			--get map instances from material's property
			local propBitmaps = getclassinstances Bitmaptexture target:(getproperty m prop)
			join propBitmaps (getclassinstances VrayBitmap target:(getproperty m prop))
			--local csMaps = getclassinstances CityscapeMap target:(getproperty m prop)
			
			--workaround for cityscape, can't use vraybitmaps, we need to leave those bitmaps as is
			--we are removing csBitmaps from the bitmap collection
			local propBitmapsMinusCS = subtractArrays propBitmaps csBitmapMaps
			
			with redraw off 
			(
				for iTex in propBitmapsMinusCS do 
				(
					local isInCorruptList = false
					--if (findItem corruptFileNames iTex.fileName) == 0 then isInCorruptList = false
					
					local new_tex = ilyaConvertB2HDRI_Texmap iTex isPropLinear isInCorruptList
					
					if new_tex != undefined then 
					(
						replaceinstances iTex new_tex 
					)
					else format "Converting Bitmap % to VRayBitmap was unsuccessful\n" iTex
				)
			)
		)
	)
	classMatCollection = undefined
	gc()
)

-- main converter function
-- overwrite: overwrites existing tx file
-- preProcess: converts the exisitng jpg file to png using imageMagick
-- fileLockCheck: checks if the resulting tx file is locked, which likely resulted in a corrupt file

fn ilyaConvertSceneToColorManaged overwrite:false preProcess:false fileLockCheck:false =
(
	--disablesceneredraw()
	local convertPath = undefined
	local OCIOPath = @"Y:\Resources\23_OCIO\aces_1.2\config.ocio"
	local magickPath = @"\\fs-01\DeadlineRepository10\submission\ImageMagic_7.0.11.6\magick.exe"
	local convertB2HDRI_ConverterErrors = 0
	
	-- Convert standard normal maps to vray normal maps
	local maxNormalMaps = getclassinstances Normal_Bump processChildren:true
	for m in maxNormalMaps do 
	(
		local vrayNmlMap = convertToVrayNormal m
		replaceinstances m vrayNmlMap
	)
	

	--Start file conversion to .tx file type
	createDialog convertB2HDRI_Rollout
	--convertB2HDRI_Rollout.check_convertEXR.visible = true
	convertB2HDRI_Rollout.check_convertEXR.checked = true
	convertB2HDRI_Rollout.check_convertEXR.enabled = false
	--convertB2HDRI_Rollout.check_convertEXR.visible = true
	convertB2HDRI_Rollout.check_convertObjectsInScene.checked = true
	convertB2HDRI_Rollout.check_convertObjectsInScene.enabled = false
	convertB2HDRI_Rollout.btn_start.visible = false
	convertB2HDRI_Rollout.btn_cancel.visible = false
	
	--converts bitmaps to tx file format outputs a list of files that were not converted
	local corruptFileNames = ilyaConvertImgToTX overwrite:overwrite preProcess:preProcess fileLockCheck:fileLockCheck
	--convertImgToTX() --old converter from vray

	local start = timeStamp()
	--convertB2HDRI_Rollout is used just for consistency, to keep correct value for convertLinear and prevent division by zero in ilyaConvertB2HDRI_Texmap
	convertB2HDRI_Rollout.replaceImgCounter = 0
	convertB2HDRI_Rollout.replaceImgNums = (getclassinstances Bitmaptexture processChildren:true).count + (getclassinstances VRayBitmap processChildren:true).count
	convertB2HDRI_Rollout.convertLinear = convertLinear


	---------------------------------------------------------------------
	--TEXTURE MAPS THAT REQUIRE SRGB CONVERSION ---
	---------------------------------------------------------------------
	--metalness? probably linear
	--env? linear if hdri/exr, srgb if other
	--these textures need sRGB to linear conversion
	--in bitmap setting these to automatic, if your 3dsmax gamma input is 2.2
	--in vrayBitmap , color transfer function is sRGB, with srgb prims to sRGB

	--textures NOT in this list are considered data textures and as such are linear and don't need sRGB to linear conversion
	--in bitmap these are set as override with gamma 1.0
	--in vraybitmap these are set as color transfer function is None, with srgb prims to Raw
	local vrayMats_TexmapColorProps =#( \
	#texmap_diffuse, \
	#texmap_reflection, \
	#texmap_refraction, \
	#texmap_translucent, \
	#texmap_environment, \
	#texmap_refraction_fog, \
	#texmap_self_illumination, \
	#texmap_sheen, \
	#texmap_coat_color)
	
	local vrayBlendMats_TexmapColorProps = #( \
	#texmap_blend_0, \
	#texmap_blend_1, \
	#texmap_blend_2, \
	#texmap_blend_3, \
	#texmap_blend_4, \
	#texmap_blend_5, \
	#texmap_blend_6, \
	#texmap_blend_7, \
	#texmap_blend_8)
	
	local vrayLightMats_TexmapColorProps = #(#texmap)
	local vray2SidedMats_TexmapColorProps = #(#texmap_translucency)
	local vrayBumpMats_TexmapColorProps = #()
	local vrayCarPaintMats_TexmapColorProps = #( #texmap_base_color,  #texmap_flake_color, #texmap_coat_color )
	local vrayCarPaint2Mats_TexmapColorProps = #( #texmap_base_color,  #texmap_flake_color, #texmap_coat_color, #texmap_flake_random_color )
	
	local VRayHairNextMats_TexmapColorProps = #( \
	#texmap_dye_color , \
	#texmap_diffuse_color , \
	#texmap_primary_tint, \
	#texmap_secondary_tint, \
	#texmap_transmission_tint)
	
	local vrayHairMats_TexmapColorProps = #( \
	#texmap_overall , \
	#texmap_diffuse , \
	#texmap_primary_specular, \
	#texmap_secondary_specular, \
	#texmap_transmission)

	local VRayFastSSS2Mats_TexmapColorProps = #( \
		#texmap_diffuse_color, \
		#texmap_overall_color, \
		#texmap_sss_color, \
		#texmap_scatter_color, \
		#texmap_specular_color)
	
	-----------------------------------------
	--COLOR / TEXTURE MAP PAIRS---
	-----------------------------------------
	-- Texture Colour properties of each material class
	-- If texture is not defined the colour value is used
	
	local vrayMats_ColorMapPairs = #( \
	#(#diffuse , #texmap_diffuse), \
	#(#selfIllumination, #texmap_self_illumination), \
	#(#reflection, #texmap_reflection), \
	#(#refraction, #texmap_refraction), \
	#(#refraction_fogColor, #texmap_refraction_fog), \
	#(#translucency_color, #texmap_translucent), \
	#(#sheen_color, #texmap_sheen), \
	#(#coat_color, #texmap_coat_color))
	
	local vrayBlendMats_ColorMapPairs = #( \
	#(#blend_0, #texmap_blend_0), \
	#(#blend_1, #texmap_blend_1), \
	#(#blend_2, #texmap_blend_2), \
	#(#blend_3, #texmap_blend_3), \
	#(#blend_4, #texmap_blend_4), \
	#(#blend_5, #texmap_blend_5), \
	#(#blend_6, #texmap_blend_6), \
	#(#blend_7, #texmap_blend_7), \
	#(#blend_8, #texmap_blend_8))
	
	local vrayLightMats_ColorMapPairs = #( #(#color,#texmap) )
	local vray2SidedMats_ColorMapPairs = #( #(#translucency,#texmap_translucency) )
	local vrayBumpMats_ColorMapPairs = #(#())
	
	local vrayCarPaintMats_ColorMapPairs = #( \
		#(#base_color, #texmap_base_color ), \
		#(#flake_color, #texmap_flake_color ), \
		#(#coat_color, #texmap_coat_color ))
	
	local vrayCarPaint2Mats_ColorMapPairs = #( \
		#(#base_color, #texmap_base_color ), \
		#(#flake_color, #texmap_flake_color ), \
		#(#coat_color, #texmap_coat_color ))
		
		
	local VRayHairNextMats_ColorMapPairs = #( \
		#(#dye_color, #texmap_dye_color ), \
		#(#diffuse_color, #texmap_diffuse_color ), \
		#(#primary_tint, #texmap_primary_tint), \
		#(#secondary_tint, #texmap_secondary_tint), \
		#(#transmission_tint, #texmap_transmission_tint))
		
	local VRayHairMats_ColorMapPairs = #( \
		#(#overall_multiplier, #texmap_overall ), \
		#(#diffuse, #texmap_diffuse ), \
		#(#primary_specular, #texmap_primary_specular), \
		#(#secondary_specular, #texmap_secondary_specular), \
		#(#transmission, #texmap_transmission))

	local VRayFastSSS2Mats_ColorMapPairs = #( \
		#(#diffuse_color, #texmap_diffuse_color), \
		#(#overall_color, #texmap_overall_color), \
		#(#sub_surface_color, #texmap_sss_color), \
		#(#scatter_color, #texmap_scatter_color), \
		#(#specular_color, #texmap_specular_color))
	

	--All bitmap maps belonging to Cityscape maps
	local csBitmapMaps = #()
	if isClass CityscapeMap then
	(
		local csBitmapMapsTemp = for t in (getclassinstances CityscapeMap) collect (getclassinstances Bitmaptexture target:t)
		breakNestedArrays csBitmapMapsTemp csBitmapMaps
	)
	
	convertMaterialClass vraymtl vrayMats_ColorMapPairs vrayMats_TexmapColorProps csBitmapMaps corruptFileNames
	convertMaterialClass vraylightmtl vrayLightMats_ColorMapPairs vrayLightMats_TexmapColorProps csBitmapMaps corruptFileNames
	convertMaterialClass vray2sidedmtl vray2SidedMats_ColorMapPairs vray2SidedMats_TexmapColorProps csBitmapMaps corruptFileNames
	--TODO:
	----convertMaterialClass vrayBumpMtl vrayBumpMats_ColorMapPairs vrayBumpMats_TexmapColorProps csBitmapMaps
	convertMaterialClass vrayBlendMtl vrayBlendMats_ColorMapPairs vrayBlendMats_TexmapColorProps csBitmapMaps corruptFileNames
	convertMaterialClass vrayCarPaintMtl vrayCarPaintMats_ColorMapPairs vrayCarPaintMats_TexmapColorProps csBitmapMaps corruptFileNames
	convertMaterialClass vrayCarPaintMtl2 vrayCarPaint2Mats_ColorMapPairs vrayCarPaint2Mats_TexmapColorProps csBitmapMaps corruptFileNames
	convertMaterialClass vrayHairNextMtl vrayHairNextMats_ColorMapPairs vrayHairNextMats_TexmapColorProps csBitmapMaps corruptFileNames
	convertMaterialClass VRayHairMtl vrayHairMats_ColorMapPairs vrayHairMats_TexmapColorProps csBitmapMaps corruptFileNames
	convertMaterialClass VRayFastSSS2 VRayFastSSS2Mats_ColorMapPairs VRayFastSSS2Mats_TexmapColorProps csBitmapMaps corruptFileNames
	print("finished conversion")
	
	/*
	local setToVray = setRendererToVray()
	print("finished set to vray")
	if doesFileExist OCIOPath and setToVray then
	(
		--set vray frame buffer controls
		vfbControl #ocio true
		vfbControl #loadocio OCIOPath
		vfbControl #ocioinputcolorspace "ACES - ACEScg"
		vfbControl #ociodisplaydevice "ACES"
		vfbControl #ocioviewtransform "sRGB"	
		
		--set rgb primaries to acescg
		renderers.current.options_rgbColorSpace = 2
		renderers.current.options_useColorSpaceForBitmaps = true
	)
	*/
	
	local end = timeStamp()
	format "Replacing took % seconds\n" ((end - start) / 1000.0)
	
	if (convertB2HDRI_ConverterErrors > 0) do 
	(
		print ("There were "+(convertB2HDRI_ConverterErrors as String)+" images that did not convert successfully to tiled EXR format.\n They are listed in MAXScript Listener.\n The original images were left in place.")
	)
	print("pre destroy")
	destroyDialog convertB2HDRI_Rollout
	--setSaveRequired true
	
	--enablesceneredraw()
	--completeredraw()
	print ("end")
)
--disablesceneredraw()
with undo off ilyaConvertSceneToColorManaged overwrite:false preProcess:false fileLockCheck:false
--enablesceneredraw()
--gc()
