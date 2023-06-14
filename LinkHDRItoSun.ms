macroScript LinkHDRItoSun
category:"ilya_s Scripts"
tooltip:"LinkHDRItoSun"
buttontext:"LinkHDRItoSun"
(
	-- Gets maximum value of a given colour object
	fn getMax col =
	(
		(sort #(col.r, col.g, col.b))[3]
	)
	
	-- Gets the brightest pixel coordinate of a given bitmap object
	fn getBrightestPixelCoord bm = 
	(
		local sampleRate = 40
		local everyX = 40 --floor (bm.width/sampleRate)
		local everyY = 40 --floor (bm.height/sampleRate)
		local brightestPixCoord = undefined
		local brightestPixValue = 0
		
		for i = 0 to bm.height by everyY do
		(
			local pixelRow = getPixels bm [0,i] bm.width linear:true
			
			for j = 1 to pixelRow.count by everyX do
			(
				local colorValue = getMax pixelRow[j]
				if colorValue > brightestPixValue then 
				(
					brightestPixValue = colorValue
					brightestPixCoord = [j-1,i]
				)
			)
		)		
		brightestPixCoord
	)
	
	
	local test = querybox "Link selected HDRI map to VraySun?" title:"Link VrayHDRI to Sun" beep:false
	if test == true then
	(
		local allSuns = for o in objects where classof o == VraySun collect o
		local hdriMap =  medit.GetCurMtl()
		
		if ( allSuns.count == 1 ) then
		(
			if (classof hdriMap == VrayHDRI) then
			(			
				hdriMap.mapType = 2 --spherica mapping
				hdriMap.cropplace_u.controller = float_script()
				
				local sun = allSuns[1]
				local sunTarget = sun.target
			
				hdriMap.cropplace_on = true
				hdriMap.cropplace_u.controller.AddTarget "t_x_pos" sun.pos.controller.'X Position'.controller
				hdriMap.cropplace_u.controller.AddTarget "t_y_pos" sun.pos.controller.'Y Position'.controller
				hdriMap.cropplace_u.controller.AddTarget "s_x_pos" sunTarget.pos.controller.'X Position'.controller
				hdriMap.cropplace_u.controller.AddTarget "s_y_pos" sunTarget.pos.controller.'Y Position'.controller
				
				--issue: when copy and pasted the link will be broken
				scriptstring =  "(mod ((atan2 (t_y_pos-s_y_pos) (s_x_pos-t_x_pos))) 360 )/360.0"
				hdriMap.cropplace_u.controller.script = scriptstring
				
				local adjustTest = querybox "Adjust HDRI Horizontal Rotation?" title:"Adjust Rotation" beep:false
				if adjustTest then
				(
					
					local bm = openBitMap hdriMap.HDRIMapName
					local coords = getBrightestPixelCoord bm
					local mapRot = coords.x / bm.width * 360.0
					hdriMap.horizontalRotation = mapRot
					close bm
					free bm
				)
			)
			else
			(
				MessageBox "Selected map is not a VrayHDRI map."
			)
		)
		else if (allSuns.count > 1) then (MessageBox "There are " + allSuns.count as string + " in the scene.\nThere can only be one.")
		else (MessageBox "No VraySun in the scene.")
	)
)