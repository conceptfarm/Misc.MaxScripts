-------------------------------------------------------------------------------
-- EditTextureInPS.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Aug 21 2016
-- Edit currently selected map in Photoshop, must be either Bitmap or VRayBitmap
-------------------------------------------------------------------------------
macroScript EditTexInPS
Category: "ilya's Scripts"
Tooltip: "Edit Texure in PS"
buttontext:"EditTexInPS"
(
	
	fn editInPS_fn psPath =
	(
		print psPath
		tex = medit.GetCurMtl()
		if (classof tex == Bitmaptexture ) then
		( 
			local bm = tex.filename
			if doesFileExist bm then ShellLaunch psPath  bm
		)
		else if (classof tex == VRayBitmap ) then
		( 
			local bm = tex.HDRIMapName
			if doesFileExist bm then ShellLaunch psPath  bm
		)
		else MessageBox ("Texture is not a bitmap or VRayBitmap.")
	)
	
	
	local f = ((getdir #scripts) + "\\Startup\\" + "EditInPS3.ini")
	check_f = doesFileExist f
	if check_f == false then
	(
		MessageBox ("Set the path to your Photoshop.exe")
		psExe = getOpenFileName types:"Executable(*.exe)|*.exe"
		if psExe != undefined then
		(
			print psExe
			setINISetting f "PATHS" "PSPath" psExe
			
			editInPS_fn psExe
		)	
	)
	
	else if ((check_f == true) and (doesFileExist (getINISetting f "PATHS" "PSPath") != true )) then
	(
		MessageBox ("Set the path to your Photoshop.exe")
		psExe = getOpenFileName types:"Executable(*.exe)|*.exe"
		if psExe != undefined then
		(
			setINISetting f "PATHS" "PSPath" psExe
		
			editInPS_fn psExe
		)	
	)
	
	else 
	(
		psExe = (getINISetting f "PATHS" "PSPath")
		print psEXE
		editInPS_fn psEXE
	)
	
	

)