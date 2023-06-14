macroScript ZeroAllIDs
category:"ilya_s Scripts"
tooltip:"Zero All IDs"
buttontext:"ZeroIDs"
(
	global zeroallids_dialog
	matLib = sceneMaterials

	simpleMtlClasses = #(
		VRayLightMtl,
		VP_WALLS_AND_TILES,
		Standardmaterial,
		Arch___Design__mi,
		RaytraceMaterial,
		VRayCarPaintMtl,
		VRayVectorDisplBake,
		VRaySimbiontMtl,
		VRayHairMtl,
		VRayGLSLMtl,
		VRayMDLMtl,
		Architectural,
		Autodesk_Material,
		InkNPaint,
		VP_WALLS_AND_TILES_STD,
		VRayFastSSS,
		VRayFastSSS2,
		VRayFlakesMtl
		)
		
	fn zeroMtlIDs m =
	(
		if (findItem simpleMtlClasses (classof m)) != 0 then (m.effectsChannel = 0)
		
		else if (classof m == VRayMtl) then
		(
			m.effectsChannel = 0
			m.effect_id = 0
			m.override_effect_id = false
		)
		
		else if ( classof m == VRay2SidedMtl) then
		(
			m.effectsChannel = 0
			zeroMtlIDs (m.frontMtl)
			zeroMtlIDs (m.backMtl)
		)
		
		else if (classof m == VRayBlendMtl) then
		(
			m.effectsChannel = 0
			zeroMtlIDs (m.baseMtl)
			Blendmtls = m.coatMtl
			for o in BlendMtls where o != undefined do (zeroMtlIDs o)
		)
		
		else if (classof m == VRayMtlWrapper) then 
		(
			m.effectsChannel = 0
			m.matte_giSurfaceID = 0
			zeroMtlIDs m.baseMtl
		)
		
		else if (classof m == VRayOverrideMtl) then
		(
			m.effectsChannel = 0
			zeroMtlIDs m.baseMtl
			zeroMtlIDs m.giMtl
			zeroMtlIDs m.reflectMtl
			zeroMtlIDs m.refractMtl
			zeroMtlIDs m.shadowMtl
		)
		
		else if (classof m == Multimaterial) then
		(
			m.effectsChannel = 0
			for o in m.materialList do (zeroMtlIDs o)		
		)
	)

	rollout zeroallids_dialog "Zero All IDs" 
	(
		button mtl_all_btn "All Material IDs"  width:120 height:16
		button obj_all_btn "All Object IDs"  width:120 height:16
		
		button mtl_sel_btn "Selected Material IDs"  width:120 height:16
		button obj_sel_btn "Selected Object IDs"  width:120 height:16

		on mtl_all_btn pressed do 
		(
			for o in matLib do zeroMtlIDs o
		)
		
		on obj_all_btn pressed do 
		(
			for o in objects do (o.gbufferchannel = 0)
		)
		
		on mtl_sel_btn pressed do 
		(
			for o in selection do zeroMtlIDs o.material
		)
		
		on obj_sel_btn pressed do 
		(
			for o in selection do (o.gbufferchannel = 0)
		)
	)	

	on execute do 
	(
		try( DestroyDialog zeroallids_dialog) catch ()
		createDialog zeroallids_dialog
	)

)