macroScript MatIDTools
Category: "ilya_s Scripts"
Tooltip: "Material ID Tools"
buttontext:"MatIDTool"

(
global MatSwitcher
global allObj
global spns
	

fn SelectUniqueB allObj =
(
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
	return allObj
)	
	
fn buildTMatrix a b =
(
	local tMatrix = #()

	for i=1 to a.count do
	(
		for j=1 to b.count do
		(
			if a[i] as string ==b[j] as string then
			(
				tMatrix[i] = #(i,j)
				exit()
			)
		)
	)
	return tMatrix
)

	
fn updateSceneMaterials =
(
	tempFile = GetDir #temp + "\\_temp.max"
	saveNodes #() tempFile
	deleteFile tempFile
)

fn SelectUnique =
(
	allObj = for o in selection collect o
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
)

fn compareFN v1 v2 =
(
	local d = (v1.name < v2.name)
	case of
	(
		(d == true ): -1
		(d == false ): 1
		default: 0
	)
)
fn MaterialCompare = 
(
	local multimats = for m in SceneMaterials where classof m == Multimaterial collect m
	local c=1
	macros.run "Medit Tools" "clear_medit_slots"

	for i=1 to multimats.count do
	(
		local f = multimats[i]
		local matListf = f.materiallist as array	
		qsort matListf compareFN
		for j = i+1 to multimats.count do
		(
			
			local t = multimats[j]
			local matListt = t.materiallist as array	
			qsort matListt compareFN
			
			if ((with PrintAllElements on matlistf as string == matlistt as string)==true and c<24) then (setMeditMaterial c f ; setMeditMaterial (c+1) t ; c=c+2) 
		)	
	)
)

fn MatSwitchB = 
(
	--fn material compare
	local multimats = for m in SceneMaterials where classof m == Multimaterial collect m

	for i=1 to multimats.count do
	(
		local f = multimats[i]
		local matListf = f.materiallist as array	
		local matListf_sorted = deepcopy matListf
		qsort matListf_sorted compareFN
		for j = i+1 to multimats.count do
		(
			
			local t = multimats[j]
			local matListt = t.materiallist as array	
			local matListt_sorted = deepcopy matListt
			qsort matListt_sorted compareFN
			--compare to find similar material
			if ((with PrintAllElements on matlistf_sorted  as string == matlistt_sorted  as string)==true ) then 
			(
				-- switch function
				obj = for o in objects where o.material == t collect o
				obj_all = deepcopy obj
				SelectUniqueB obj
				TMatrix = buildTMatrix matListt matListf
				
				for o in obj do
				(
					local allIDs= for i = 1 to o.numfaces collect getFaceMatID o i
					local allIDs = sort(makeUniqueArray allIDs)

					local face_id_array = #()
					for k in allIDs do
					(
						face_id_array[k]= for p=1 to o.numFaces where (getfacematID o p == k) collect p
					)
					--o.wirecolor = color 255 0 0

					for k=1 to TMatrix.count do
					(
						--print "in the loop"
						--Replacers
						local original_ID = TMatrix[k][2]
						local target_ID =  TMatrix[k][1]
						for l=1 to face_id_array[original_ID].count do ( try (setFaceMatID o face_id_array[original_ID][l] target_ID) catch(print "out of IDs"))
					)
					update o
				)
				obj_all.material = f
			) 
		)	
	)
	updateSceneMaterials()
)



fn FixDupsA = 
(
	 multimats = for m in SceneMaterials where (classof m == Multimaterial AND (m.materiallist as array).count != (makeUniqueArray (m.materiallist as array)).count) collect m
	
	-- find replace multimaterials with the same material
	local b=0
	for o in objects where classof o.material == Multimaterial do
	(
		local matListf = o.material.materiallist as array	
		if (makeUniqueArray matlistf).count == 1 then 
		(
			b=b+1
			o.material = matListf[1]
		)
	)
-- 	
-- 	local multimats = for m in SceneMaterials where classof m == Multimaterial collect m
-- 	
-- 	local c=0
-- 	
-- 	for i=1 to i=(multimats.count - 1) do
-- 	(
-- 		for j=i+1 to multimats.count do
-- 		(
-- 			local f = multimats[i]
-- 			local matListf = f.materiallist as array	
-- 			local t = multimats[j]
-- 			local matListt = t.materiallist as array	
-- 			if (with PrintAllElements on matlistf as string == matlistt as string) then 
-- 			(
-- 				c=c+1
-- 				for o in objects where o.material == t do
-- 				(
-- 					o.material = f
-- 				)
-- 			)
-- 		)
-- 	)
-- 	updateSceneMaterials()
-- 	MessageBox ("Fixed " + b as string + " same materials and " + c as string + " duplicate materials.")
)


-- THIS IS BACKUP
-- fn FixDupsB =
-- (
-- 	for o in selection where classof o.material == Multimaterial do
-- 	(
-- 		local matListf = o.material.materiallist
-- 		local matListIDs = o.material.materialIDList
-- 		for i = 1 to i = (o.material.materiallist.count - 1) do -- all materials except the last one 
-- 		(
-- 			for j = i+1 to j = o.material.materiallist.count do -- all materials except the current one
-- 			(	
-- 				if o.material.materiallist[i].name == o.material.materiallist[j].name then
-- 				(
-- 					--print o
-- 					local allIDs= for k = 1 to o.numfaces collect getFaceMatID o k
-- 					local allIDs = sort(makeUniqueArray allIDs)
-- 					
-- 					if (findItem allIDs matListIDs[i] >0) then
-- 					(
-- 						local face_id_array = #()
-- 						
-- 						for k in matListIDs do -- builds a sorted matrix of face collections with corresponding IDs 
-- 						(
-- 							face_id_array[k]= for h=1 to o.numFaces where (getfacematID o h == k) collect h
-- 						)

-- 						local original_ID = allIDs[j] as integer
-- 						local target_ID = allIDs[i] as integer
-- 						for k=1 to face_id_array[original_ID].count do ( setFaceMatID o face_id_array[original_ID][k] target_ID)
-- 					)
-- 				)
-- 			)
-- 		)
-- 	)
-- )
fn FixDupsB =
(
	for o in selection where classof o.material == Multimaterial do
	(
		local matListf = o.material.materiallist
		local matListIDs = o.material.materialIDList
		
		local allIDs= for k = 1 to o.numfaces collect getFaceMatID o k
		local allIDs = sort(makeUniqueArray allIDs)
		
		local face_id_array = #()
						
		for k in matListIDs do -- builds a sorted matrix of face collections with corresponding IDs 
		(
			face_id_array[k]= for h=1 to o.numFaces where (getfacematID o h == k) collect h
		)
		
		for i = 1 to i = (o.material.materiallist.count - 1) do -- all materials except the last one 
		(
			if (findItem allIDs matListIDs[i] >0) then -- if ID exists in the object than start comparing
			(
				for j = i+1 to j = o.material.materiallist.count do -- all materials except the current one
				(	
					if o.material.materiallist[i].name == o.material.materiallist[j].name then
					(
						local original_ID = matListIDs[j] as integer
						local target_ID = matListIDs[i] as integer
						for k=1 to face_id_array[original_ID].count do ( setFaceMatID o face_id_array[original_ID][k] target_ID)
						id_to_delete = finditem allIDs original_ID
						deleteItem allIDs id_to_delete
						--face_id_array[original_ID] = undefined
					)
				)
			)	
		)
	)
)

fn ExplodeByMaterial =
(
	selectedObj = for o in selection where classof o.material == Multimaterial collect o
	
	for o in selectedObj do
	(
		local mat = o.material
		local matListf = o.material.materiallist
		local matListIDs = o.material.materialIDList
		
		local allIDs= for k = 1 to o.numfaces collect getFaceMatID o k
		local allIDs = sort(makeUniqueArray allIDs)
		
		local face_id_array = #()
						
		for k in allIDs do -- builds a sorted matrix of face collections with corresponding IDs 
		(
			face_id_array = for h=1 to o.numFaces where (getfacematID o h == k) collect h
			local newMesh = meshop.detachFaces o face_id_array delete:true asMesh:true
			update o
			local emesh = Editable_mesh()
			emesh.mesh = newMesh
			emesh.scale = o.scale
			emesh.rotation = o.rotation
			emesh.pos = o.pos
			emesh.material = mat[k]
		)
	)
	
	delete selectedObj
)


fn MatFindReplace = 
(
	local f = getMeditMaterial 23
	local t = getMeditMaterial 24

	for o in objects do
	(	
		if o.material == f then o.material = t
			
		if classof o.material == Multimaterial then
		(
			local mIDs = o.material.materialIDList
			for i=1 to mIDs.count do
			(
				if (o.material[mIDs[i]] == f) then
				(
					o.material[mIDs[i]] = t
				)
			)
			
		)
	)
)

fn MatFindReplaceName = 
(
	local f = getMeditMaterial 23
	local t = getMeditMaterial 24

	for o in objects where o.material != undefined do
	(	
		if o.material.name == f.name then o.material = t
		
		if classof o.material == Multimaterial then
		(
			local mIDs = o.material.materialIDList
			for i=1 to mIDs.count do
			(
				if (o.material[mIDs[i]].name == f.name) then
				(
					o.material[mIDs[i]] = t
				)
			)
		)
	)
)

fn MatSwitch = 
(	
	for o in allObj do
	(
		if classof o == Editable_mesh then
		(
			local allIDs= for i = 1 to o.numfaces collect getFaceMatID o i
			local allIDs = sort(makeUniqueArray allIDs)
			local face_id_array = #()
			for i in allIDs do
			(
				face_id_array[i]= for j=1 to o.numFaces where (getfacematID o j == i) collect j
			)

			for i=1 to spns.count by 2 where spns[i].value != 0 do
			(
				print "in the loop"
				--Replacers
				local original_ID = spns[i].value
				local target_ID = spns[i+1].value
				for i=1 to face_id_array[original_ID].count do ( setFaceMatID o face_id_array[original_ID][i] target_ID)
			)
			update o
		)
		if classof o == Editable_Poly then
		(	
			local allIDs= for i = 1 to o.numfaces collect polyop.getFaceMatID o i
			local allIDs = sort(makeUniqueArray allIDs)
			local face_id_array = #()
			for i in allIDs do
			(
				face_id_array[i]= for j=1 to o.numFaces where (polyop.getFaceMatID o j == i) collect j
			)

			for i=1 to spns.count by 2 where spns[i].value != 0 do
			(
				print "in the loop"
				--Replacers
				local original_ID = spns[i].value
				local target_ID = spns[i+1].value
				for i=1 to face_id_array[original_ID].count do ( polyop.setFaceMatID o face_id_array[original_ID][i] target_ID)
			)
			--update o
		)
		
	)
	
)
	rollout MatSwitcher "Material ID Tools" width:280 height:600
	(
		
		group "Puts MultiMaterial with Same Submaterial into Editor"
		(
			button multi_btn "Find Similar MultiMats" height:16 across:2
			button multi_btn2 "Fix Similar MultiMats" height:16
		)
		
		group "Find Material in Slot23 and Replace with one in Slot24"
		(
			button mfr_btn "Find/Replace" height:16 across:2
			button mfrn_btn "Find/Replace by Name" height:16
		)
		
		group "Fix MultiMaterial with Duplicate Submaterials"
		(
			button fix_DupsA_btn "Sub w/ Same Mats" height:16 across:2
			button fix_DupsB_btn "Sub w/ duplicate Mats" height:16
		)
		
		group  "Switch Material IDs on Selected Objects"
		(
			spinner o1 "Original" range:[0,1000000,0]   type:#integer across: 3
			spinner t1 "Target" range:[0,1000000,0]    type:#integer 
			button c1 "Clear"  width:80 height:16 
			
			spinner o2 "Original" range:[0,1000000,0]    type:#integer across: 3
			spinner t2 "Target" range:[0,1000000,0]    type:#integer
			button c2 "Clear"  width:80 height:16 
			
			spinner o3 "Original" range:[0,1000000,0]    type:#integer across: 3
			spinner t3 "Target" range:[0,1000000,0]    type:#integer
			button c3 "Clear"  width:80 height:16 		
			
			spinner o4 "Original" range:[0,1000000,0]    type:#integer across: 3
			spinner t4 "Target" range:[0,1000000,0]    type:#integer
			button c4 "Clear"  width:80 height:16 
			
			spinner o5 "Original" range:[0,1000000,0]    type:#integer across: 3
			spinner t5 "Target" range:[0,1000000,0]    type:#integer
			button c5 "Clear"  width:80 height:16 
			
			spinner o6 "Original" range:[0,1000000,0]    type:#integer across: 3
			spinner t6 "Target" range:[0,1000000,0]    type:#integer
			button c6 "Clear"  width:80 height:16 
			
			spinner o7 "Original" range:[0,1000000,0]    type:#integer across: 3
			spinner t7 "Target" range:[0,1000000,0]    type:#integer
			button c7 "Clear"  width:80 height:16 
			
			spinner o8 "Original" range:[0,1000000,0]    type:#integer across: 3
			spinner t8 "Target" range:[0,1000000,0]    type:#integer
			button c8 "Clear"  width:80 height:16 
			
			spinner o9 "Original" range:[0,1000000,0]    type:#integer across: 3
			spinner t9 "Target" range:[0,1000000,0]    type:#integer
			button c9 "Clear"  width:80 height:16 
			
			spinner o10 "Original" range:[0,1000000,0]    type:#integer across: 3
			spinner t10 "Target" range:[0,1000000,0]    type:#integer
			button c10 "Clear"  width:80 height:16 
			
			button switch_btn "Switch"  width:80 height:16
		)
		group "Explode"
		(
			button explByMat_btn "Explode By Material"  height:16
		)
		
		on multi_btn pressed do ( MaterialCompare() )
		on multi_btn2 pressed do (MatSwitchB() )
		on mfr_btn pressed do (MatFindReplace())
		on mfrn_btn pressed do (MatFindReplaceName())
		on fix_DupsA_btn pressed do (FixDupsA())
		on fix_DupsB_btn pressed do (FixDupsB())
			
		on c1 pressed do (o1.value = 0; t1.value = 0)
		on c2 pressed do (o2.value = 0; t2.value = 0)
		on c3 pressed do (o3.value = 0; t3.value = 0)
		on c4 pressed do (o4.value = 0; t4.value = 0)
		on c5 pressed do (o5.value = 0; t5.value = 0)
		on c6 pressed do (o6.value = 0; t6.value = 0)
		on c7 pressed do (o7.value = 0; t7.value = 0)
		on c8 pressed do (o8.value = 0; t8.value = 0)
		on c9 pressed do (o9.value = 0; t9.value = 0)
		on c10 pressed do (o10.value = 0; t10.value = 0)
				
		on switch_btn pressed do 
		(
			SelectUnique()
			MatSwitch()
		)

		on explByMat_btn pressed do 
		(
			ExplodeByMaterial()
		)		
		
	)--end rollout

	on execute do 
	(
		try( DestroyDialog MatSwitcher) catch ()
		createDialog MatSwitcher
		spns = for x in MatSwitcher.controls where classOf x == spinnercontrol collect x
	)--end on execute

)-- end scirpt
