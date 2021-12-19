fn setUnwrapChannel ch = 
(
	local allobj = for o in selection where  classof o.modifiers[1] == Unwrap_UVW collect o

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
	
	clearSelection()
	
	for o in allobj do with redraw off
	(
		if classof o.material == Shell_Material then
		(		
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


-- if getSaveRequired() == true then 
-- (
-- 	local qb = queryBox "File unsaved, save file before processing?" beep:false
-- 	if qb then saveMaxFile (maxfilepath + maxfilename)  clearNeedSaveFlag:true quiet:true
-- )	

-- convertAndSetMapChannel 1
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

exportCamDataToJSON()