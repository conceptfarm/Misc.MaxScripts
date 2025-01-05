macroScript RegionEditor
category:"ilya_s Scripts"
internalcategory:"ilya_s Scripts"
tooltip:"RegionEditor"
buttontext:"REGION"
(	
	rcmenu ComboRC
	(
		menuitem disableRR "Disable Region Rendering"
		menuitem editRR "Start Region Editing"
		menuitem resetRR "Reset Region"
		
		on disableRR picked do 
		(
			if getRenderType() != #view then setRenderType #view else setRenderType #region
		)
		
		on editRR picked do 
		(
			EditRenderRegion.EditRegion() 
		)
		
		on resetRR picked do
		(
			local w = renderWidth
			local h = renderHeight
			viewport.setRegionRect viewport.activeviewport ( Box2 (w*0.1) (h*0.1) (w*0.8) (h*0.8) )
		)
		
		on ComboRC open do
		(
			if getRenderType() != #view then 
			(
				disableRR.text = "Disable Region Rendering" 
			)
			else
			(
				disableRR.text =  "Enable Region Rendering"
			)
			
			if EditRenderRegion.IsEditing then
			(
				editRR.text = "Stop Region Editing"
			)
			else
			(
				editRR.text = "Start Region Editing"
			)
			
		)
	)
	popupmenu ComboRC

)--end script