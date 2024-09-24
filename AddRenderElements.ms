macroScript VrayRenderElements
category:"ilya_s Scripts"
tooltip:"Add Render Elements"
buttontext:"Add Render Elements"
(
	materialElements =  #(MultiMatteElement, MultiMatteElement, MultiMatteElement, MultiMatteElement, MultiMatteElement, MultiMatteElement, MultiMatteElement)
	carMaterialElements =  #(MultiMatteElement, MultiMatteElement)
	objectElements =    #(MultiMatteElement, MultiMatteElement, MultiMatteElement, MultiMatteElement, MultiMatteElement, MultiMatteElement, MultiMatteElement)
	nonDenoiseElements = #(VRayZDepth, VRayBumpNormals, VRayDiffuseFilter, VrayDenoiser)
	otherElementsStill = #(VRayRawReflection, VRayRawRefraction, VRayRawLighting, VRayRawShadow, VRaySelfIllumination, VRaySpecular, VRayLightSelect, VRayLightSelect, VRayLightSelect,VRayCryptomatte,VRayAO)
	otherElementsAni =  #(VRayRawReflection, VRayRawLighting, VRaySelfIllumination, VRaySpecular, VRayReflection, VRayRefraction, VrayLighting, VrayRawGlobalIllumination)

	local re = undefined
	local mtlNumber = 5
	local objNumber = 5
		
	fn getRenderElementByClass elementClass = 
	(
		result = #()
		re = maxOps.GetCurRenderElementMgr()
		for n = 0 to (re.numrenderelements() - 1) do 
		(
			thisElement = re.getrenderelement n
			if ((classof thisElement) as string == elementClass as string) then (append result thisElement)
		)
		
		result
	)
		
	fn baseMaterialElements addCarElements= 
	(
		 -- get the current render element manager
		re.removeallrenderelements() -- remove all renderelements

		for i = 1 to mtlNumber do 
		(
			re.addrenderelement (MultiMatteElement elementname:("MtlMatte" + (i as string)+"_"))
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
		
		if addCarElements then
		(
			for i = 1 to carMaterialElements.count do 
			(
				re.addrenderelement (carMaterialElements[i] elementname:("MtlMatte" + ((i+mtlNumber) as string)+"_"))
				thisElement = re.GetRenderElement (re.NumRenderElements()-1)
				thisElement.enabled = true
				thisElement.filterOn = true
				thisElement.R_gbufIDOn = true
				thisElement.R_gbufID = (3*(i-1)+1)+29
				thisElement.G_gbufIDOn = true
				thisElement.G_gbufID = (3*(i-1)+2)+29
				thisElement.B_gbufIDOn = true
				thisElement.B_gbufID = (3*(i-1)+3)+29
				thisElement.MatID = true
			)
		)

		for i = 1 to objNumber do 
		(
			re.addrenderelement (MultiMatteElement elementname:("ObjMatte" + (i as string)+"_"))
			thisElement = re.GetRenderElement (re.NumRenderElements()-1)
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


	rollout AddRendElements "Add Render Elements" width:200 height: 160
	(
		
		spinner mtlNumber_spn "# of MtlMatte" range:[1,100,mtlNumber] type:#integer
		spinner objNumber_spn "# of ObjMatte" range:[1,100,objNumber] type:#integer

		checkbox denoiseEle_chk "Denoise Elements?" width:160 height:20 align:#center
		checkbox carEle_chk "Car Mtl Elements (30-35)?" width:160 height:20 align:#center
		
		button still_btn "Still Image"  width:160 height:20 align:#center
		button ani_btn "Animation"  width:160 height:20 align:#center

		on mtlNumber_spn changed arg do (mtlNumber = arg)
		on objNumber_spn changed arg do (objNumber = arg)
		
		on still_btn pressed do 
		(
		
			baseMaterialElements carEle_chk.checked
			for n in nonDenoiseElements do (re.addrenderelement (n elementname:(n as string)))
			for n in otherElementsStill do 
			(
				local addEle = re.addrenderelement (n elementname:(n as string))
				if addEle and denoiseEle_chk.checked then
				(
					local thisEle = re.GetRenderElement (re.NumRenderElements()  - 1 )
					try(thisEle.denoise = true)catch()
				)
			)
			zdepthArray = getRenderElementByClass VrayZDepth
			for i = 1 to zdepthArray.count do 
			(
				zdepthArray[i].zdepth_use_camera_clip_boudaries = false
				
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
		
			baseMaterialElements carEle_chk.checked
			for n in nonDenoiseElements do (re.addrenderelement (n elementname:(n as string)))
			for n in otherElementsAni do 
			(
				local addEle = re.addrenderelement (n elementname:(n as string))
				if addEle and denoiseEle_chk.checked then
				(
					local thisEle = re.GetRenderElement (re.NumRenderElements()  - 1 )
					try(thisEle.denoise = true)catch()
				)
			)
			zdepthArray = getRenderElementByClass VrayZDepth
			for i = 1 to zdepthArray.count do 
			(
				zdepthArray[i].zdepth_use_camera_clip_boudaries = false
				zdepthArray[i].zdepth_min = units.decodeValue "2.0m"
				zdepthArray[i].zdepth_max = units.decodeValue "250.0m"
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