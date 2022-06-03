-------------------------------------------------------------------------------
-- ColourUtilss.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Jan 19 2022
-- Expanding on Andrei's massGammColor script to provide a better UI
-- additng hex colour conversion and linear colour conversion
-------------------------------------------------------------------------------
macroScript ColourUtils
category:"ilya_s Scripts"
tooltip:"ColourUtils"
buttontext:"ColourUtils"
(
	--- maxscript - massGammaColor

	-- andrei kletskov (111) - http://andklv.narod.ru - andklv@mail.ru
	--- 09 jan 2007 - v0.1 - initial version
	--- 09 jan 2007 - v0.2 - some mess in code fixed
	--- 09 jan 2007 - v0.3 - bug with multimaterials fixed
	--- 10 jan 2007 - v0.4 - bug with multiple color processing fixed
	--- 01 may 2007 - v0.5 - some try-catch blocks added
	--- 22 july 2008 - v0.6 - UI slightly changed, picked color processing added
	--- 11 june 2009 - v0.7 - a bug with 3dsmax2010 fixed
	--- 23 august 2010 - v0.8 - reflection color excluded from calculation (add more items to list_of_bad_colors if needed)
	--- 25 august 2010 - v0.9 - checkbox for processing reflections added to UI; changed selection behavior for processing only material in active meditor slot; fixed a bug introduced in v0.8
	--- 18 january 2022 - v1.0 - Colour Utils Edited by Ilya Floussov

	---  this script will convert all colors from one gamma space to another
	---  search areas can be SCENE, SELECTED OBJECTS or MATERIAL EDITOR

	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	global ColourUtils_floater
	
	local list_of_bad_colors = #("reflection", "refl_color", "Reflection Color")

	local old_gamma = 1.0
	local new_gamma = 2.2

	local my_initial_state = #()
	local global_counter = 0

	local skip_refl = true
	
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
	
	fn hexStringToColour hexStr = 
	(
		local legalCharsSet = "1234567890ABCDEF"
		local hexArray= #("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F")
		--hexStr = "#DA70D6"
		
		hexStr = trimLeft (trimRight hexStr)
		if hexStr[1] == "#" then hexStr = substring hexStr 2 hexStr.count
			
		local result = undefined
		for i=1 to hexStr.count while result == undefined do
		(
				if ((matchpattern legalCharsSet pattern:("*"+hexStr[i]+"*") caseSensitive:false) == false) then (messageBox "Not a hex colour."; result = (color 0 0 0 ))
		)
		
		if result == undefined then
		(

			local R1 = ((findItem hexArray hexStr[1]) - 1) * 16
			local R2 = (findItem hexArray hexStr[2]) - 1
			local R = R1 + R2
			
			local G1 = ((findItem hexArray hexStr[3]) - 1) * 16
			local G2 = (findItem hexArray hexStr[4]) - 1
			local G = G1 + G2
						
			local B1 = ((findItem hexArray hexStr[5]) - 1) * 16
			local B2 = (findItem hexArray hexStr[6]) - 1
			local B = B1 + B2
			
			result = (color R G B)
		)
		result
	)
		
	fn gammaConvert c fromGamma toGamma = 
	(
		local nr = (255.0 * ((c.r / 255.0) ^ (toGamma / fromGamma)))
		local ng = (255.0 * ((c.g / 255.0) ^ (toGamma / fromGamma)))
		local nb = (255.0 * ((c.b / 255.0) ^ (toGamma / fromGamma)))
		(color nr ng nb)
	)
	
	fn rec_ini_state mat =
	(
		for i = 1 to mat.numsubs do
		(
			try
			(
				if ((classof(mat[i].value) == color) and ((findItem list_of_bad_colors mat[i].name == 0) or (skip_refl==true)))  then 
				(
					append my_initial_state mat[i].value
				)
			)
			catch()
			rec_ini_state mat[i]
		) -- end for
	) -- end fn


	fn rec mat =
	(
		for i = 1 to mat.numsubs do
		(
			try
			(
				if ((classof(mat[i].value) == color) and ((findItem list_of_bad_colors mat[i].name == 0) or (skip_refl==true))) then 
				(
					global_counter = global_counter + 1
					--print  global_counter
					if my_initial_state[global_counter] == mat[i].value then
					(
						local nr = (255.0 * ((mat[i].value.r / 255.0) ^ (new_gamma / old_gamma)))
						local ng = (255.0 * ((mat[i].value.g / 255.0) ^ (new_gamma / old_gamma)))
						local nb = (255.0 * ((mat[i].value.b / 255.0) ^ (new_gamma / old_gamma)))
						mat[i].value = (color nr ng nb)
						print ("mGCprocessed: " + mat[i].name as string)
					)
				)
			)
			catch()
			rec mat[i]
		)
	)

	rollout ColourUtils_floater "ColourUtils v1.0" width:200 height:350
	(
		groupBox grp1 "Convert Gamma For:" height: 210
		radiobuttons rdo_sel "" columns:1 labels:#("Scene Materials", "Selected Objects", "Current Meditor Slot", "Color Picker") default:2 pos:[grp1.pos.x + 15, grp1.pos.y + 20] 
		colorPicker cp1 "" enabled:false color:(color 128 128 128) offset:[27,0]
		label fromGamma_lbl "From Gamma: " across:2 offset:[10,0]
		spinner fromGamma_spn "" width:50 height:16 scale:0.1 range:[0.01,100,1.0] offset:[-40,0]
		label toGamma_lbl "     To Gamma: " across:2 offset:[10,0]
		spinner toGamma_spn "" width:50 height:16 scale:0.1 range:[0.01,100,2.2] offset:[-40,0]
		button swap_btn "S" width:15   pos:[fromGamma_spn.pos.x + 20, fromGamma_spn.pos.y + 9] 
		checkbox skipRefl_chk "Skip Reflections" checked:false offset:[15,8]
		button go_btn "Convert" width:108 height:24
		
		GroupBox grp2 "Hex Colour Convert" pos:[grp1.pos.x , grp1.pos.y +grp1.height + 10]  height: 110
		edittext hexCode_txt "#" multiLine:false text:"FFFFFF" width:90 pos:[grp2.pos.x + 15, grp2.pos.y + 20] 
		colorPicker cp2 "" enabled:true color:(color 255 255 255) offset:[20,8] pos:[hexCode_txt.pos.x + hexCode_txt.width + 10, hexCode_txt.pos.y - 2]
		checkbox linear_chk "Linear Workflow" checked:true offset:[15,0]
		button createMat_btn "Create VrayMtl" width:108 height:24 offset:[0,5]
		
		on rdo_sel changed state do
		(
			if state == 4 then 
			(
				cp1.enabled = true 
			)
			else
			(
				cp1.enabled = false
			)
		)
		
		on swap_btn pressed do -- SWAPPING VALUES
		(
			local t = fromGamma_spn.value
			fromGamma_spn.value = toGamma_spn.value
			toGamma_spn.value = t		
		)
		
		on skipRefl_chk changed a do
		(
			skip_refl = not a
		)

		
		on go_btn pressed  do
		(
			old_gamma = fromGamma_spn.value
			new_gamma = toGamma_spn.value
				
			if rdo_sel.state == 4 then
			(
				cp1.color = gammaConvert cp1.color fromGamma_spn.value toGamma_spn.value
			)
			if rdo_sel.state == 2 then
			(		
				global_counter = 0
				for i in selection do
				(
					mat = i.material
					try(rec_ini_state mat) catch()
				)
				for i in selection do
				(
					mat = i.material
					try(rec mat) catch()
				)
				my_initial_state = #()
			)
			if rdo_sel.state == 1 then
			(
				global_counter = 0
				for mat in scenematerials do 
				(
					try(rec_ini_state mat) catch()
				)
				for mat in scenematerials do 
				(
					try(rec mat) catch()
				)
				my_initial_state = #()
			)
			if rdo_sel.state == 3 then
			(
				global_counter = 0
				mat = meditMaterials[activeMeditSlot]
				try(rec_ini_state mat) catch()
				try(rec mat) catch()
				my_initial_state = #()
			)
		)
		
		on hexCode_txt changed txt do
		(
			local oldText = copy hexCode_txt.text
			if txt.count < 7 then (hexCode_txt.text = toUpper txt)
			else (hexCode_txt.text = substring oldText 1 6)
		)
		
		on hexCode_txt entered txt do
		(
			local oldText = copy hexCode_txt.text
			if txt.count < 7 then (hexCode_txt.text = toUpper txt)
			else (hexCode_txt.text = substring oldText 1 6)
			
			local hexColour = hexStringToColour hexCode_txt.text
			if linear_chk.checked then cp2.color = gammaConvert hexColour 1.0 2.2
			else cp2.color = hexColour
		)
		
		on createMat_btn pressed do
		(
			local hexColour = hexStringToColour hexCode_txt.text
			if linear_chk.checked then hexColour = gammaConvert hexColour 1.0 2.2
			
			if isClass VrayMtl then
			(
				local newMat = VrayMtl()
				newMat.name = "Hex Colour #" + hexCode_txt.text
				local newColor = VrayColor()
				newColor.name = "Hex Colour #" + hexCode_txt.text
				newColor.rgb_primaries = 1
				newColor.color = hexColour
				newMat.texmap_diffuse = newColor
				
				setmeditmaterial 1 newMat
				MatEditor.Open()  
			)
			else
			(
				messageBox "No Vray Material Class."
			)
		)
		
	) -- end rollout
	
	on execute do 
	(
		try(destroydialog ColourUtils_floater)catch()
		createDialog ColourUtils_floater
	) --end execute
)