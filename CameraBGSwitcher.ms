macroScript CameraBgSwitcher
category:"ilya_s Scripts"
tooltip:"CameraBgSwitcher v.1.0"
buttontext:"CameraBgSwitcher"

(
	global CameraBgSwitcherDia
	local mycams
	local mycamsnames_array
	local bgImagePath = ""
	
	fn setBGFromCam cam bgImagePath =
	(
		try(backgroundImageFileName = bgImagePath + cam + ".jpg")catch()
	)
	
	rollout CameraBgSwitcherDia "Camera Bg Switcher v.1.0" width:600 height:120
	(
		editText rootPath_ed "BG Image Location (Optional):" labelOnTop:true text:bgImagePath width: 540 across:2 align:#left offset:[0,5]
		button getPath_bn "..." width: 30 align:#right offset:[0,20]
		dropDownList camSelection "Scene Cameras" width:250 height:40 items:mycamsnames_array enabled:true
		
		on getPath_bn pressed do
		(
			rp = getSavePath caption:"Select BG Image Location" initialDir:"X:\\"
			if rp != undefined then
			(
				rootPath_ed.text = rp
				bgImagePath = rp
			)
		)
		
		on camSelection selected i do
		(
			if (camSelection.selection != 1) then 
			(
				cam_select = getnodebyname mycamsnames_array[i]
				viewport.setCamera cam_select
				currCam = mycamsnames_array[i] as string
				print ("Current camera is " + currCam as string)
				setBGFromCam currCam rootPath_ed.text
			)
		)
	)
			
	on execute do
	(
		mycams = for o in cameras where (superclassof o == camera) collect o
		mycamsnames_array_temp = for o in mycams collect o.name
		mycamsnames_array = sort mycamsnames_array_temp
		print ("Found " + mycams.count as string + " cameras in the scene.")
		spacer = #("Select Camera")
		mycamsnames_array = join spacer mycamsnames_array
		
		try(destroydialog CameraBgSwitcherDia)catch()
		createDialog CameraBgSwitcherDia
	
	)
)