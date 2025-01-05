macroScript UVWBitmapFit
category:"ilya_s Scripts"
tooltip:"UVW Bitmap Fit"
buttontext:"UVW Fit"
(
	
	local bitmapFiles = #()
	local bitmapMaps = #()
	
	local layerNameSelector = rollout layerNameSelector "Select Bitmaps to Fit" width:500 height:200
	(
		local result = 0

		ListBox  layerSelection_lb "Fit Bitmaps:" items:bitmapFiles height:10
		button addSelected_btn "Bitmap Fit" across:2 width:80
		button cancelAdding_btn "Cancel" width:80
		
		fn init val:undefined =
		(
			try destroyDialog layerNameSelector catch()
			result = val
			print("init")
			print("bitmapFiles " + bitmapFiles as string)
			createDialog layerNameSelector modal:true
			result
		)
			
		on layerNameSelector open do 
		(
			local listDisplay = #()
			for i=1 to bitmapFiles.count do
			(
				append listDisplay (bitmapMaps[i].name + " : " + getFilenameFile bitmapFiles[1] + getFilenameType bitmapFiles[1])
			)
			layerSelection_lb.items = listDisplay
			setFocus layerNameSelector						
		)

		on cancelAdding_btn pressed do
		(
			result = 0
			destroydialog layerNameSelector
		)

		on addSelected_btn pressed do
		(
			result = layerSelection_lb.selection
			destroydialog layerNameSelector
		)
	)
	
	local selObjects = selection as array
	max modify mode
	for o in selObjects as array do
	(

		local allBitmaps = (getclassinstances bitmaptexture target:o.material)
		local allVrayBitmaps = (getclassinstances VRayBitmap target:o.material)

		bitmapFiles = for m in allBitmaps where doesFileExist m.filename collect m.filename
		bitmapMaps =  for m in allBitmaps where doesFileExist m.filename collect m

		bitmapFiles = bitmapFiles + (for m in allVrayBitmaps where doesFileExist m.HDRIMapName collect m.HDRIMapName)
		bitmapMaps = bitmapMaps + (for m in allVrayBitmaps where doesFileExist m.HDRIMapName collect m)

		--Can't access mod panel with multiple objects selected, need to get the modifier from obect
		local selMod = (modPanel.getCurrentObject())

		if classof selMod == Uvwmap or classof o == VRayDecal then 
		(
			if bitmapMaps.count > 0 then
			(
				--Insert dialog for selecting which map
				local chosenIndex = 1
				
				if bitmapFiles.count > 1 then
				(
					chosenIndex = layerNameSelector.init()
				)
				
				if chosenIndex > 0 then
				(
					local bitmapFile = openBitMap bitmapFiles[chosenIndex]
					local bitmapMap = bitmapMaps[chosenIndex]
					
					w = bitmapFile.width
					h = bitmapFile.height
					/*
					.cropplace_on : boolean
					.cropplace_mode : integer
					.cropplace_u : float
					.cropplace_v : float
					.cropplace_width : float
					.cropplace_height : float
					
					.clipu (Clip_U_Offset) : float
					.clipv (Clip_V_Offset) : float
					.clipw (Clip_U_Width) : float
					.cliph (Clip_V_Width) : float
					.jitter (Jitter_Placement) : float
					.apply : boolean
					.cropPlace : integer
					*/
					if classof bitmapMap == bitmaptexture then
					(
						if bitmapMap.apply == true and bitmapMap.cropPlace == 0 then
						(
							w = w * bitmapMap.clipw
							h = h * bitmapMap.cliph
						)
					)
					else if classof bitmapMap == VRayBitmap then
					(
						if bitmapMap.cropplace_on == true and bitmapMap.cropplace_mode == 0 then
						(
							w = w * bitmapMap.cropplace_width
							h = h * bitmapMap.cropplace_height
						)
					)

					selMod.length = (h * selMod.Width)/w
					close bitmapFile
					free bitmapFile
				)
			)
			else
			(
				print("The selected object's material doesn't have Bitmap or VrayBitmap for object " + o.name)
			)
		)
		else
		(
			print("The selected modifier is not a UVWMap Modifier or a VrayDecal for object " + o.name)
		)
	)
)