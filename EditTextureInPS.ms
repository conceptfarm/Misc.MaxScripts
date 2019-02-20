-------------------------------------------------------------------------------
-- EditTextureInPS.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- June 267h 2017
-- Opens Photoshop and opens the map from the current Material Editor Window.
-------------------------------------------------------------------------------
macroScript EditTexInPS
Category: "ilya_s Scripts"
Tooltip: "Edit Texure in PS"
buttontext:"EditTexInPS"
(
	
	fn editInPS_fn psPath =
	(
		tex = medit.GetCurMtl()
		if (classof tex == Bitmaptexture ) then
		( 
			bm = tex.filename
			ShellLaunch psPath  bm
		)
		else MessageBox ("Texture is not a bitmap.")
	)
	
	
	local f = ((getdir #scripts) + "\\Startup\\" + "EditInPS3.ini")
	check_f = doesFileExist f
	if check_f == false then
	(
		MessageBox ("Set the path to your Photoshop.exe")
		psExe = getOpenFileName types:"Executable(*.exe)|*.exe"
		if psExe != undefined then
		(
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
		editInPS_fn psEXE
	)
)