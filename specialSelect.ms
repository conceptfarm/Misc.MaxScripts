-------------------------------------------------------------------------------
-- SpecialSelect.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Aug 21 2016
-- Various object selectors
-------------------------------------------------------------------------------
macroScript SpecialSelect
category:"ilya_s Scripts"
internalcategory:"ilya_s Scripts"
tooltip:"SpecialSelect"
buttontext:"SpecialSelect"
(
	--local matLib = sceneMaterials
	local matLib_clean=#()

	
	fn fill_array fromN toN = 
	(
		local result = for i = fromN to toN collect i
		result
	)
	
	fn stringToIntArray str =
	(
		local arr = filterString str ", "
		local result = for o in arr collect o as integer
		result
	)
		
	fn selectUnique =
	(
		local allObj = for o in selection as array where superclassof o == GeometryClass collect o
		--clearselection as array()
		for o in allObj do
		(
			
			InstanceMgr.GetInstances o &instances
			for p in instances where p != o do 
			(
				local deleteIndex = findItem allObj p
				if deleteIndex !=0 then deleteitem allObj deleteIndex
			)
		)
		allOBJ
	)
	
	fn getUnique instanceOnly:false =
	(
		local result = #()
		local resultInstaceOnly = #()
		local instanceOnlyHandle = #()
		local handles = #()
		local allObj = #()
		
		if selection == undefined then allObj = for o in objects as array collect o
		else allObj = for o in selection as array collect o
		
		for o in allObj do
		(
			local h = GetHandleByAnim  o.baseobject
			if findItem handles h == 0 then 
			(
				append result o
				append handles h
			)
			else
			(
				--if handles have been found before that means the object is an instance,
				--we add the object only if it has not been added already to keep the array unique
				if findItem instanceOnlyHandle h == 0 then 
				(
					append instanceOnlyHandle h
					append resultInstaceOnly o
				)
			)
		)
		if instanceOnly then result = resultInstaceOnly
		result
	)


	fn collectValidNodes fromArr = 
	(
		--local result = for o in fromArr where o != undefined collect o
		local result = for o in fromArr where isValidNode o collect o
		result 
	)


	fn selectForestDeps forestObject:true doAll:false =
	(
		local objectsToSelect = #()
		local processObjects = #()
		if doAll == false then
		(
			local qb = queryBox "Select Forest dependencies for ALL Forests in the scene?\n\nNO  - get dependencies of SELECTED Forests.\nYES - get dependencies of ALL Forests."
		
			if qb == true then processObjects = for o in objects where classof o == Forest_Pro collect o
			else processObjects = for o in selection as array where classof o == Forest_Pro collect o
		)
		else processObjects = for o in objects where classof o == Forest_Pro collect o

		for o in processObjects do 
		(
			objectsToSelect = join objectsToSelect (collectValidNodes o.cobjlist)
			objectsToSelect = join objectsToSelect (collectValidNodes o.arnodelist)
			objectsToSelect = join objectsToSelect (collectValidNodes o.surflist)
			objectsToSelect = join objectsToSelect (collectValidNodes o.efpainode)-- : node array
			objectsToSelect = join objectsToSelect (collectValidNodes o.distpathnodes)-- (Distribution_Reference_Nodes) : node array
			objectsToSelect = join objectsToSelect (collectValidNodes o.distrefnodes)-- (Distribution_Reference_Nodes) : node array
			objectsToSelect = join objectsToSelect (collectValidNodes o.distpflownodes)-- (Distribution_Particle_Flow_Nodes) : node array
			objectsToSelect = join objectsToSelect (collectValidNodes o.distpfloweventslist)-- (Distribution_PFlow_Events_List) : node array
			
			if forestObject == true then (if o != undefined then append objectsToSelect o)
			if o.reserved12 != undefined then append objectsToSelect o.reserved12-- (Spline_Inc) : node
			if o.reserved13 != undefined then append objectsToSelect o.reserved13-- (Spline_Exc) : node
			if o.reserved14 != undefined then append objectsToSelect o.reserved14-- (Spline_Following) : node
			if o.reserved24 != undefined then append objectsToSelect o.reserved24-- : node
			if o.lookat != undefined then append objectsToSelect o.lookat-- (Look_At_Target) : node
			if o.light != undefined then append objectsToSelect o.light-- : node
			if o.reserved2 != undefined then append objectsToSelect o.reserved2-- (Surface) : node
	
		)
		objectsToSelect = makeUniqueArray objectsToSelect
		objectsToSelect
	)
	
	fn selectForestFromObject objArr =
	(
		local objectsToSelect = #()
		
		for o in objArr do
		(
			for fp in objects where classof fp == Forest_Pro do
			(
				local foundObj = for obj in (collectValidNodes fp.cobjlist) where obj == o collect obj
				if foundObj.count > 0 then append objectsToSelect fp; break
			)
		)
		objectsToSelect
	)

	fn selectForestJunkDeps = 
	(
		local objectsToSelect = #()
		local processObjects = selectForestDeps forestObject:false doAll:true
		local forestLayer = layermanager.getLayerFromName "forest_templates"
 		forestLayer.nodes &forestObjects

 		for o in forestObjects where (matchpattern o.name pattern:"_forest_template*" casesensitive:false ) == false do
 		(
 			if (findItem processObjects o) == 0 then
 			(
 				append objectsToSelect o
 			)

 		)
 		objectsToSelect
	)

	fn selectRailCloneDeps = 
	(
		local objectsToSelect = #()
		local processObjects = #()
		local qb = queryBox "Select RailClone dependencies for ALL RailClones in the scene?\nNO  - dependencies of selected RailClones\nYES - dependencies of ALL RailClones"
		
		if qb==true then processObjects = for o in objects where classof o == RailClone_Pro collect o
		else processObjects = for o in selection as array where classof o == RailClone_Pro collect o

		for o in processObjects do 
		(
			objectsToSelect = join objectsToSelect (collectValidNodes o.banode)-- (NONE) : node array
			objectsToSelect = join objectsToSelect (collectValidNodes o.sobjnode)-- (NONE) : node array
			
			if o != undefined then append objectsToSelect o
			if o.spline != undefined then append objectsToSelect o.spline-- (NONE) : node
			if o.stylelink != undefined then append objectsToSelect o.stylelink-- (Style_Linked_to) : node
			
		)
		objectsToSelect = makeUniqueArray objectsToSelect
		objectsToSelect
	)
	
	fn selectOldProxies = 
	(
		local proxies = for o in objects where classof o == VrayProxy collect o
		local objectsToSelect = for o in proxies where o.object_list_names.count == 0 collect o
		--( ( ( (dotnetclass "System.IO.File").GetLastWriteTime(ico) ).ticks)
		
		objectsToSelect
	)
	
	fn selectMissingProxies = 
	(
		local proxies = for o in objects where (classof o == VrayProxy) collect o
		local objectsToSelect = #()
		for o in proxies do
		(
			if o.filename == undefined then
			(
				append objectsToSelect o
			)
			else if doesFileExist o.filename == false then
			(
				append objectsToSelect o
			)
		)
		objectsToSelect		
	)


	rollout specialSelect "Special Select" width:240
	(
		
		groupBox grp1 "Select by Material/Object ID" pos:[8,8] width:224 height:140
		radioButtons objMtlSelect_sel labels:#("Material ID", "Object ID") pos:[44,32] width:200 height:16
		radioButtons idList_sel "" pos:[16,60] width:124 height:16 labels:#("ID List") default: 1
		editText idList_edit "" pos:[92,60] width:120 height:15 text: "1,2,6,9"
		radioButtons range_sel "" pos:[16,90] width:23 height:16 labels:#("") default: 0 
		spinner fromID_spn "From " pos:[81,90] width:61 height:16 range:[1,100000,1] type:#integer scale:1 enabled: false
		spinner toID_spn "To " pos:[160,90] width:53 height:16 range:[1,100000,3] type:#integer scale:1  enabled: false
		button selectObjByID "Select" pos:[76,120] width:80 height:16
		
		
		on selectObjByID pressed do 
		(
			clearselection()
			
			local idList = #()
			
			if (idList_sel.state == 1) then 
			(
				idList = stringToIntArray idList_edit.text 
			)
			else 
			(
				idList = fill_array fromID_spn.value toID_spn.value
			)
						
			case objMtlSelect_sel.state of
			(
				1: 
				(
					--MATERIAL--
					local matSelect = #()
					local objSelect = #()
						
					for id in idList do
					( 
						for m in matLib_clean do
						(
							if m.effectsChannel == id then
							(
								append matSelect m
							)
								
							if classof m == vraymtl then
							(
								   if m.effect_id == id and m.override_effect_id == true then
								   (
									   append matSelect m
								   )
							)
						)
					)
					
					matSelect = makeUniqueArray matSelect
					
					for m in matSelect do
					(
						local refsDeps = refs.dependents m
						local refObj = for o in refsDeps where superClassOf o == GeometryClass and isValidNode o == true collect o
						join objSelect refObj
					)
					
					select objSelect
				)
				
				2:
				(
					--OBJECT--
					local objSelect = #()
					for id in idList do 
					(
						local temp = for o in objects where o.gbufferChannel == id collect o
						join objSelect temp
					)
					select objSelect
				)
			)
		)
		
		on idList_sel changed state do
		(
			fromID_spn.enabled = false
			toID_spn.enabled = false
			range_sel.state = 0
			idList_edit.enabled=true
		)
		
		on range_sel changed state do
		(
			fromID_spn.enabled = true
			toID_spn.enabled = true
			idList_sel.state = 0
			idList_edit.enabled=false
		)
		
		on fromID_spn changed n do
		(
			if (n > toID_spn.value) then (n = toID_spn.value)
			fromID_spn.value = n
		)
		
		on toID_spn changed n do
		(
			if (n < fromID_spn.value) then (n = fromID_spn.value)
			toID_spn.value = n
		)
		
		on idList_edit changed txt do
		(	
			local tempstring = ""
			local allowed = #("0","1","2","3","4","5","6","7","8","9",","," ")
			for i = 1 to txt.count do
			(
				local tempchar = txt[i] as string
				if (finditem allowed tempchar != 0) then (tempstring = tempstring + tempchar)
			)
			idList_edit.text = tempstring
		)
		
		groupbox grp2 "Select by Material Type" pos:[8, grp1.pos.y + grp1.height + 10] width:224 height:(4*30+20)
		button select_no_mat "No Material" width: 150 pos:[45,grp2.pos.y + 20]
		button select_standard "Standard"  width: 150 --pos:[45,250]
		button select_multi "Multi/Sub-Object" width: 150 --pos:[45,274]
		button select_nonvray "Non Vray" width: 150 --pos:[45,298]
		
		groupbox grp3 "Select by Geometry" pos:[8, grp2.pos.y + grp2.height + 10] width:224 height:(2*30+20)
		button select_novert "Zero Vert Objects" width: 150 pos:[45, grp3.pos.y + 20]
		button select_unique "Unique Objects" width: 150 --pos:[45,346]
		
		groupbox grp4 "Select Forest Pro/RailClone" pos:[8, grp3.pos.y + grp3.height + 10] width:224 height:(4*30+20)
		button select_FPDeps "Forest Depends" width: 150 pos:[45, grp4.pos.y + 20]
		button select_FPJunkDeps "Unused Forest Depends" width: 150 --pos:[45,394]
		button select_FPFromObj "Select Forest From Obj" width: 150 
		button select_RCDeps "RailClone Depends" width: 150 
		
		groupbox grp5 "Select Proxies" pos:[8, grp4.pos.y + grp4.height + 10] width:224 height:(2*30+20)
		button select_oldProxies "Old Proxies" width: 150 pos:[45, grp5.pos.y + 20]
		button select_MissingProxies "Proxies w/ Missing Path" width: 150 
		
		
		on select_no_mat pressed do
		(
			clearselection()
			select (for o in (#() + shapes + geometry) where o.material == undefined collect o)
		)
		
		on select_standard pressed do
		(
			clearselection()
			select (for o in objects where (classof o.material == Standardmaterial) collect o)
		)
		
		on select_multi pressed do
		(
			clearselection()
			select (for o in objects where (classof o.material == Multimaterial) collect o)
		)

		on select_nonvray pressed do
		(
			local obj = for o in (#() + shapes + geometry) where (classof o.material as string != "VRayMtl" and 
				classof o.material != VRayLightMtl and
				classof o.material != VRayFastSSS2 and 
				classof o.material != VRayFastSSS and
				classof o.material != VRayBlendMtl and
				classof o.material != VRay2SidedMtl and
				classof o.material != VRayOverrideMtl and
				classof o.material != VRayMtlWrapper and
				classof o.material != Multimaterial and
				o.material != undefined) collect o 
			clearselection()
			select obj
		)
		
		on select_novert pressed do
		(
			clearselection()
			local meshObj = #()
			for o in objects where classof o.baseobject == Editable_mesh do
			(
				if o.mesh.numverts <=2 do append meshObj o
			)

			local polyObj = #()
			for o in objects where classof o.baseobject == Editable_Poly do
			(
				if o.numverts <=2 do append polyObj o
			)
			join polyObj meshObj
			select polyObj
		)
		
		on select_unique pressed do
		(
			local allobj = getUnique()
			clearselection()
			select allobj
		)

		on select_FPDeps pressed do
		(
			local allobj = selectForestDeps()
			clearselection()
			select allobj
		)
		
		on select_FPFromObj pressed do
		(
			local allobj = selectForestFromObject (selection as array)
			clearselection()
			select allobj
		)
		
		on select_FPJunkDeps pressed do
		(
			local allobj = selectForestJunkDeps()
			clearselection()
			select allobj
		)

		on select_RCDeps pressed do
		(
			local allobj = selectRailCloneDeps()
			clearselection()
			select allobj
		)
		
		on select_oldProxies pressed do
		(
			local allobj = selectOldProxies()
			clearselection()
			select allobj
		)
		
		on select_MissingProxies pressed do
		(
			local allobj = selectMissingProxies()
			clearselection()
			select allobj
		)

	)
	
	
	on execute do 
	(
		matlib_clean = for m in sceneMaterials where (try (m.effectschannel != undefined)catch(false)) != false collect m
		createDialog specialSelect
	)
)