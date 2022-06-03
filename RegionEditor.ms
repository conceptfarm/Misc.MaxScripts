-------------------------------------------------------------------------------
-- RegionEditor.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- November 18th 2020
-- Start and stop viewport region editing
-------------------------------------------------------------------------------
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
		
		on disableRR picked do 
		(
			if getRenderType() != #view then setRenderType #view else setRenderType #region
		)
		
		on editRR picked do 
		(
			EditRenderRegion.EditRegion() 
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