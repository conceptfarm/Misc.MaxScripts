-------------------------------------------------------------------------------
-- SpecialSelect.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Dec 16 2019
-- Different selection filters for 3dsmax and vray
-------------------------------------------------------------------------------
macroScript SpecialSelect
category:"ilya_s Scripts"
internalcategory:"ilya_s Scripts"
tooltip:"SpecialSelect"
buttontext:"SpecialSelect"

(
	local matLib = sceneMaterials
	local mat_string = ""
	local obj_id = 1
	
	local eff_set = #()
	local mat_select = #()
	local fillerSet = #()
	local matLib_clean=#()
	local from_val = 1
	local to_val = 3
	local use_range = false
	
	fn fill_array = 
	(
		eff_set = #()
		if (to_val != from_val) then
		(
			eff_set = #(from_val, to_val)
			fill_amt = (to_val - from_val) - 1
			for i = 1 to fill_amt do 
			(
				n = from_val + i
				append eff_set n
				--print eff_set
			)
		)
		else eff_set = #(to_val)
	)
	
	fn SelectUnique =
	(
		local allObj = for o in selection where superclassof o == GeometryClass collect o
		--clearSelection()
		for o in allObj do
		(
			if InstanceMgr.GetInstances o &instances > 1 then
			(	
				InstanceMgr.GetInstances o &instances
				local otherInst = for p in instances where p!=o collect p
				for r in otherInst do 
				(
					local deleteIndex = findItem allObj r
					if deleteIndex !=0 then deleteitem allObj deleteIndex
				)
			)
		)
		allOBJ
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
			local qb = queryBox "Select Forest dependencies for ALL Forests in the scene?\nPress No for get dependencies of selected Forests."
		
			if qb == true then processObjects = for o in objects where classof o == Forest_Pro collect o
			else processObjects = for o in selection where classof o == Forest_Pro collect o
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
			if o.camera != undefined then append objectsToSelect o.camera-- : node
			if o.lookat != undefined then append objectsToSelect o.lookat-- (Look_At_Target) : node
			if o.light != undefined then append objectsToSelect o.light-- : node
			if o.reserved2 != undefined then append objectsToSelect o.reserved2-- (Surface) : node
	
		)
		objectsToSelect = makeUniqueArray objectsToSelect
		objectsToSelect
	)

	fn selectForestJunkDeps = 
	(
		local objectsToSelect = #()
		local processObjects = selectForestDeps forestObject:false doAll:true
		local forestLayer = layermanager.getLayerFromName "forest_templates"
 		forestLayer.nodes &forestObjects

 		for o in forestObjects do
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
		local qb = queryBox "Select RailClone dependencies for ALL RailClones in the scene?\nPress No for get dependencies of selected RailClones."
		
		if qb==true then processObjects = for o in objects where classof o == RailClone_Pro collect o
		else processObjects = for o in selection where classof o == RailClone_Pro collect o

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
		objectsToSelect
	)
	
	fn selectMissingProxies = 
	(
		local proxies = for o in objects where classof o == VrayProxy collect o
		local objectsToSelect = for o in proxies where ((doesfileexist o.filename) == false) collect o
		objectsToSelect		
	)


	rollout specialSelect "Special Select" width:240
	(
		
		groupBox grp1 "Select by Object ID" pos:[8,8] width:224 height:56
		spinner objspinner "Object ID" range:[0,1000,obj_id] pos:[40,32] width:88 height:16 type:#integer
		button selectobj "Select" pos:[136,32] width:80 height:16
		
		on objspinner changed n do
		(
			obj_id = n
			--print obj_id
		)
	
		on selectobj pressed do 
		(
			clearselection()
			for o in objects where o.gbufferChannel == obj_id do selectmore o
		)
		
		groupBox grp2 "Select by Material ID" pos:[8,75] width:224 height:120
		radioButtons singular_sel "" pos:[16,100] width:124 height:16 labels:#("Objects w/ Mat ID") default: 1
		radioButtons range_sel "" pos:[16,131] width:23 height:16 labels:#("") default: 0 
		editText material_box "" pos:[121,100] width:95 height:15 text: "1,2,6,9"
		spinner from_mat "From " pos:[81,131] width:61 height:16 range:[1,15,from_val] type:#integer scale:1 enabled: false
		spinner to_mat "To " pos:[160,131] width:53 height:16 range:[1,15,to_val] type:#integer scale:1  enabled: false
		button selectid "Select" pos:[76,166] width:80 height:16
	
		on singular_sel changed state do
		(
			from_mat.enabled = false
			to_mat.enabled = false
			range_sel.state = 0
			material_box.enabled=true
			use_range = false
		)
		
		on range_sel changed state do
		(
			from_mat.enabled = true
			to_mat.enabled = true
			singular_sel.state = 0
			material_box.enabled=false
			fill_array()
			use_range = true
		)
		
		on from_mat changed n do
		(
			if (n>to_val) then (n = to_val)
			from_val = n
			from_mat.value = n
			fill_array()
		)
		
		on to_mat changed n do
		(
			if (n<from_val) then (n = from_val)
			to_val = n
			to_mat.value = n
			fill_array()
		)
		
		on material_box changed txt do
		(	
			tempstring = ""
			allowed = #("0","1","2","3","4","5","6","7","8","9",","," ")
			for i=1 to txt.count do
			(
				tempchar = txt[i] as string
				if (finditem allowed tempchar != 0) then (tempstring = tempstring + tempchar)
			)
			material_box.text = tempstring
			--print tempstring
		)
		
		on material_box entered txt do
		(
			mat_string = material_box.text	
		)
		
		on selectid pressed do
		(
			clearselection()
			if (use_range == false) then (eff_set = filterString mat_string ", ")
			mat_select = #()
				
			for i = 1 to eff_set.count do
			( 
				temp = for m in matLib_clean where m.effectsChannel == eff_set[i] as integer collect m
				join mat_select temp 
				mat_select = makeUniqueArray mat_select
				--print mat_select
			)
			
			for i = 1 to mat_select.count do
			(
				for o in objects where o.material == mat_select[i] do selectmore o
			)
		)
		
		groupbox gp3 "Select by Material Type" pos:[8,202] width:224 height:314
		button select_no_mat "No Material" width: 150 pos:[45,226]
		button select_standard "Standard"  width: 150 pos:[45,250]
		button select_multi "Multi/Sub-Object" width: 150 pos:[45,274]
		button select_nonvray "Non Vray" width: 150 pos:[45,298]
		button select_novert "Zero Vert Objects" width: 150 pos:[45,322]
		button select_unique "Unique Objects" width: 150 pos:[45,346]
		button select_FPDeps "Forest Depends" width: 150 pos:[45,370]
		button select_FPJunkDeps "Unused Forest Depends" width: 150 pos:[45,394]
		button select_RCDeps "RailClone Depeds" width: 150 pos:[45,418]
		button select_oldProxies "Old Proxies" width: 150 pos:[45,442]
		button select_MissingProxies "Proxies w/ Missing Path" width: 150 pos:[45,466]
		
		
		on select_no_mat pressed do
		(
			objs = #()
			for o in geometry where o.material == undefined do (append objs o)
			select objs
		)
		
		
		
		on select_standard pressed do
		(
			for o in objects where (classof o.material as string == "Standardmaterial") do selectmore o  
		)
		
		
		
		on select_multi pressed do
		(
			for o in objects where (classof o.material as string == "Multimaterial") do selectmore o  
		)
		
		
		on select_nonvray pressed do
		(
			for o in objects where (classof o.material as string != "VRayMtl" and 
				classof o.material as string != "VRayLightMtl" and
				classof o.material as string != "VRayFastSSS2" and 
				classof o.material as string != "VRayFastSSS" and
				classof o.material as string != "VRayBlendMtl" and
				classof o.material as string != "VRay2SidedMtl" and
				classof o.material as string != "VRayOverrideMtl" and
				classof o.material as string != "VRayMtlWrapper" and
				classof o.material as string != "Multimaterial") do selectmore o  
		)
		
		on select_novert pressed do
		(
			try (for o in objects where (o.mesh.numverts == 0) do selectmore o) catch()
			
		)
		
		on select_unique pressed do
		(
			local allob = SelectUnique()
			clearselection()
			select allob
		)

		on select_FPDeps pressed do
		(
			local allob = selectForestDeps()
			clearselection()
			select allob
		)

		on select_FPJunkDeps pressed do
		(
			local allob = selectForestJunkDeps()
			clearselection()
			select allob
		)

		on select_RCDeps pressed do
		(
			local allob = selectRailCloneDeps()
			clearselection()
			select allob
		)
		
		on select_oldProxies pressed do
		(
			local allob = selectOldProxies()
			clearselection()
			select allob
		)
		
		on select_MissingProxies pressed do
		(
			local allob = selectMissingProxies()
			clearselection()
			select allob
		)

	)
	
	
	on execute do 
	(
		--if obj_id == undefined then obj_id = 1
		for i=1 to matlib.count do ( try( if (matlib[i].effectschannel != undefined) then (append matlib_clean matlib[i])) catch())
		createDialog specialSelect
	)
)
