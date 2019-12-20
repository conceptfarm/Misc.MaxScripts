-------------------------------------------------------------------------------
-- AdjustRenderFrame.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Dec 16 2019
-- Adjusts 3dsmax render frame by changing camera's lens and perspective offset
-- a few issues vertical shift
-------------------------------------------------------------------------------
macroScript AdjustRenderFrame
category:"ilya_s Scripts"
tooltip:"Adjust Render Frame"
buttontext:"AdjRenFrame"
(

	global keep_btn

	fn camera_filter o = 
	(
		ClassOf o == Physical	
	)


	fn calcShift opt Wo Wn So =
	(
		/*
		Wn = 740.0 
		Wo = 640.0
		So = -10.0
		*/
		
		local Sn = 0
		if (opt == 2) then (Sn = 100.0 * ((((Wn-Wo)/2.0) + (So/100.0 * Wo)) / Wn)) 
		else if (opt == 0) then (Sn = 100.0 * ((((Wo-Wn)/2.0) + (So/100.0 * Wo)) / Wn))
		else (Sn = So * Wo / Wn)
		return Sn
	)

	renderSceneDialog.close()
	
	rollout AdjustWidth "AdjustRenderFrame v 2.0" width:350 
	(
		pickbutton choosecam "Pick Camera" align:#center width:140 height:20 filter:camera_filter
		radiobuttons keep_btn "Keep: "	labels:#("TL","TC", "TR","ML","MC","MR","BL","BC","BR") default:5 columns:3 
		
		spinner old_F_spin "Old Focal:" type:#float range:[0.01,5000,0.01] enabled:false across:2
		spinner new_F_spin "New Focal:" type:#float range:[0,900000000,0] enabled:false
		
		spinner old_W_spin "Old Width:" type:#float range:[0,900000000,0] enabled:false across:2
		spinner old_H_spin "Old Height:" type:#float range:[0,900000000,0] enabled:false 
		
		spinner old_Sh_spin "Old H Shift:" type:#float range:[-900000000,900000000,0] enabled:false across:2
		spinner old_Sv_spin "Old V Shift:" type:#float range:[-900000000,900000000,0] enabled:false  
		
		spinner new_W_spin "New Width:" type:#integer range:[0,500000,0] enabled:false across:2
		spinner new_H_spin "New Height:" type:#integer range:[0,500000,0] enabled:false  
		
		
		spinner new_Sh_spin "New H Shift:" type:#float range:[-900000000,900000000,0] enabled:false  across:2
		spinner new_Sv_spin "New V Shift:" type:#float range:[-900000000,900000000,0] enabled:false 
		
		
		button Apply_btn "Apply" align:#center width:140 height:20 enabled:false
		
			
		on AdjustWidth open do
		(
			if classof $ == Physical then
			(
				choosecam.text = $.name
				old_F_spin.value = $.focal_length_mm
				old_Sh_spin.value = $.horizontal_shift
				old_W_spin.value = renderWidth
				old_H_spin.value = renderHeight
				new_W_spin.value = renderWidth
				new_H_spin.value = renderHeight
				new_W_spin.enabled = true
				new_H_spin.enabled = true
			)
			else
			(
				camerapick = selectByName title:"Please select a single a Physical Camera" buttonText:"This one!" filter:camera_filter showHidden:true single:true
				if classof camerapick == Physical then
				(
					select camerapick
					choosecam.text = $.name
					old_F_spin.value = $.focal_length_mm
					old_W_spin.value = renderWidth
					old_H_spin.value = renderHeight
					old_Sh_spin.value = $.horizontal_shift
					new_W_spin.value = renderWidth
					new_H_spin.value = renderHeight
					new_W_spin.enabled = true
					new_H_spin.enabled = true
				)
				else
				( 
					messagebox "Please pick a single Physical :)"
				)
			)
		)
			
		on choosecam picked obj do
		(
			select obj
			choosecam.text = obj.name
			old_F_spin.value = $.focal_length_mm
			old_W_spin.value = renderWidth
			new_W_spin.value = renderWidth
			new_W_spin.enabled = true
		)

		on new_W_spin changed spinvalue do 
		(
			spinvalue = new_W_spin.value
			new_F_spin.value = (old_W_spin.value/new_W_spin.value)*old_F_spin.value
			columnState = ((mod (keep_btn.state-1) 3) + 0) as integer
			--rowState = ((keep_btn.state - 1) / 3) as integer
			rowState = abs ((keep_btn.state-1)/3 - 2)
			new_Sh_spin.value = calcShift columnState old_W_spin.value new_W_spin.value old_Sh_spin.value
			new_Sv_spin.value = calcShift rowState old_H_spin.value new_H_spin.value old_Sv_spin.value
			Apply_btn.enabled = true
		)
		
		on new_H_spin changed spinvalue do 
		(
			spinvalue = new_H_spin.value
			new_F_spin.value = (old_W_spin.value/new_W_spin.value)*old_F_spin.value
			columnState = ((mod (keep_btn.state-1) 3) + 0) as integer
			--rowState = ((keep_btn.state - 1) / 3) as integer
			rowState = abs ((keep_btn.state-1)/3 - 2)
			new_Sh_spin.value = calcShift columnState old_W_spin.value new_W_spin.value old_Sh_spin.value
			new_Sv_spin.value = calcShift rowState old_H_spin.value new_H_spin.value old_Sv_spin.value
			Apply_btn.enabled = true
		)
		
			
		on keep_btn changed state do
		(
			columnState = ((mod (keep_btn.state-1) 3) + 0) as integer
			rowState = ((keep_btn.state - 1) / 3) as integer
			print columnState
			print rowState
			
			new_Sh_spin.value = calcShift columnState old_W_spin.value new_W_spin.value old_Sh_spin.value
			new_Sv_spin.value = calcShift rowState old_H_spin.value new_H_spin.value old_Sv_spin.value
		)
		
		on Apply_btn pressed do
		(
			if classof $ == Physical then
			(
				with undo on
				( 
					$.focal_length_mm = new_F_spin.value
					renderWidth = new_W_spin.value
					renderHeight = new_H_spin.value
					$.horizontal_shift = new_Sh_spin.value
					$.vertical_shift = new_Sv_spin.value
				)
				destroydialog AdjustWidth
			)
			else
			(
				choosecam.text = "Pick"
				messagebox "Please pick again a Physical Camera"
			)
		)
	)

	createdialog AdjustWidth fgcolor:[220,150,0] style:#(#style_toolwindow, #style_sysmenu) pos:[10,100]

)