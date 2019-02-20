-------------------------------------------------------------------------------
-- VrayRenderElements.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- June 267h 2017
-- Adds a set of vray render elements, clears existing.
-------------------------------------------------------------------------------
macroScript VrayRenderElements
category:"ilya_s Scripts"
tooltip:"Add Vray Render Elements"
buttontext:"VrayRenderElements"
(
	materialElements = #(MultiMatteElement , MultiMatteElement , MultiMatteElement , MultiMatteElement ,MultiMatteElement, MultiMatteElement ,MultiMatteElement)
	objectElements = #(MultiMatteElement , MultiMatteElement, MultiMatteElement, MultiMatteElement, MultiMatteElement)
	otherElementsStill =#(VRayZDepth, VRayBumpNormals, VRayRawReflection, VRayRawRefraction, VRayRawLighting, VRayRawShadow,VRaySelfIllumination,VRaySpecular,VRayDiffuseFilter,VrayDenoiser,VRayLightSelect,VRayLightSelect,VRayLightSelect)
	otherElementsAni = #(VRayZDepth, VRayBumpNormals, VRayRawReflection, VRayRawLighting, VRaySelfIllumination,VRaySpecular,VRayDiffuseFilter, VrayGlobalIllumination, VRayReflection,VRayRefraction,VrayLighting,VrayRawGlobalIllumination,VrayDenoiser)

	global re 
		
	fn getRenderElementByClass elementClass = 
	(
		result = #()
		re = maxOps.GetCurRenderElementMgr()
		for n = 0 to (re.numrenderelements() - 1) do 
		(
			thisElement = re.getrenderelement n
			if ((classof thisElement) as string == elementClass as string) then (append result thisElement)
		)
		
		return result
	)
		
	fn baseMaterialElements = 
	(
		 -- get the current render element manager
		re.removeallrenderelements() -- remove all renderelements

		for i = 1 to materialElements.count do 
		(
			re.addrenderelement (materialElements[i] elementname:("MtlMatte" + (i as string)+"_"))
			thisElement = re.GetRenderElement (i-1)
			thisElement.enabled = true
			thisElement.filterOn = true
			thisElement.R_gbufIDOn = true
			thisElement.R_gbufID = (3*(i-1)+1)
			thisElement.G_gbufIDOn = true
			thisElement.G_gbufID = (3*(i-1)+2)
			thisElement.B_gbufIDOn = true
			thisElement.B_gbufID = (3*(i-1)+3)
			thisElement.MatID = true
		)

		for i = 1 to objectElements.count do 
		(
			re.addrenderelement (objectElements[i] elementname:("ObjMatte" + (i as string)+"_"))
			thisElement = re.GetRenderElement (i+(materialElements.count - 1))
			thisElement.enabled = true
			thisElement.filterOn = true
			thisElement.R_gbufIDOn = true
			thisElement.R_gbufID = (3*(i-1)+1)
			thisElement.G_gbufIDOn = true
			thisElement.G_gbufID = (3*(i-1)+2)
			thisElement.B_gbufIDOn = true
			thisElement.B_gbufID = (3*(i-1)+3)
			thisElement.MatID = false
		)
	)


	rollout AddRendElements "Add Render Elements" 
	(
		
		button still_btn "Still Image"  width:80 height:16
		button ani_btn "Animation"  width:80 height:16

		
		on still_btn pressed do 
		(
		
			baseMaterialElements()
			for n in otherElementsStill do (re.addrenderelement (n elementname:(n as string)))
			zdepthArray = getRenderElementByClass VrayZDepth
			for i = 1 to zdepthArray.count do 
			(
				zdepthArray[i].zdepth_use_camera_clip_boudaries = true
				if zdepthArray.count > 1 then (zdepthArray[i].elementName = zdepthArray[i].elementName + "_" + i as string)
			)

			lightSelArray = getRenderElementByClass VrayLightSelect
			for i = 1 to lightSelArray.count do 
			(
				lightSelArray[i].mode = 1
				if lightSelArray.count > 1 then (lightSelArray[i].elementName = lightSelArray[i].elementName + "_" + i as string)
			)
			
			DenoiseArray = getRenderElementByClass VrayDenoiser
			for i = 1 to DenoiseArray.count do 
			(
				DenoiseArray[i].mode = 2
				if DenoiseArray.count > 1 then (DenoiseArray[i].elementName = DenoiseArray[i].elementName + "_" + i as string)
			)
				
			DestroyDialog AddRendElements 
		)
		
		on ani_btn pressed do 
		(
		
			baseMaterialElements()
			for n in otherElementsAni do (re.addrenderelement (n elementname:(n as string)))
			zdepthArray = getRenderElementByClass VrayZDepth
			for i = 1 to zdepthArray.count do 
			(
				zdepthArray[i].zdepth_use_camera_clip_boudaries = true
				if zdepthArray.count > 1 then (zdepthArray[i].elementName = zdepthArray[i].elementName + "_" + i as string)
			)
			
			DenoiseArray = getRenderElementByClass VrayDenoiser
			for i = 1 to DenoiseArray.count do 
			(
				DenoiseArray[i].mode = 2
				if DenoiseArray.count > 1 then (DenoiseArray[i].elementName = DenoiseArray[i].elementName + "_" + i as string)
			)
			
			DestroyDialog AddRendElements 
		)
	
	)

	on execute do 
	(
		createDialog AddRendElements 
		re = maxOps.GetCurRenderElementMgr()
	)
)