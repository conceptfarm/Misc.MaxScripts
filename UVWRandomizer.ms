macroScript UVWRandomizer
Category: "ilya_s Scripts"
Tooltip: "UVWRandomizer"
buttontext:"UVWRandomizer"

(
	global UVWRandomizer_RO
	
	fn lastBit arr = 
	(
		local b
		for n in arr while (b = n; on) do ()
		b
	)
	 
	fn getElementFaceList obj red_prog =
	(
		local result = #()
		local faceCount = obj.numFaces
		
		local i = 1
		if classof obj == Editable_mesh then 
		(
			while i < faceCount do
			(
				local faces = meshop.getelementsusingface obj #{i}
				append result faces
				local lastFace = lastBit faces
				i = lastFace + 1
				red_prog.value = 100.0*lastFace/faceCount
				windows.processPostedMessages()

			)
		)
		else if classOf obj == Editable_Poly then
		(
			while i < faceCount do
			(
				local faces = polyop.getelementsusingface obj #{i}
				append result faces
				local lastFace = lastBit faces
				i = lastFace + 1
				red_prog.value = 100.0*lastFace/faceCount
				windows.processPostedMessages()

			)
		)
		result
	)
	
	fn transformUVW red_prog blue_prog moveMin moveMax =
	(
		gc #light
		max modify mode
		
		local uvwMod = undefined
		
		local mods = for m in $.modifiers where classof m == UVWUnwrap collect m
		
		if mods.count > 0 then
		(
			uvwMod = mods[1]
		)
		else
		(
			uvwMod = Unwrap_UVW()
			addModifier $ uvwMod
		)
		
		local elementFaceList = getElementFaceList $ red_prog
		
		subobjectLevel = 3
		
		local counter = 1
		for element in elementFaceList do
		(
			uvwMod.selectFaces #{}
			uvwMod.selectFaces element
			uvwMod.breakSelected()
			uvwMod.moveSelected [(random moveMin moveMax),(random moveMin moveMax),0]
			blue_prog.value = 100.0 * counter/elementFaceList.count
			counter = counter + 1
			windows.processPostedMessages()

		)
		
		subobjectLevel = 0

		--messageBox "Done"
	)
	
	rollout UVWRandomizer_RO "Safe Collapse" 
	(
		spinner moveMin_spnr  "Step:" range:[-10000000,10000000,-500] type:#integer scale:1
		spinner moveMax_spnr "Step:" range:[-10000000,10000000,500] type:#integer scale:1 
		button do_it_bn "Randomize"
		
		Label time_lbl "Precess took 0 seconds"
		
		group "Progress"
		(
			progressbar red_prog  color:red 
			progressbar blue_prog color:blue 
		)
			
		on do_it_bn pressed do 
		(
			if ($ != undefined) then
			(		
				start = timeStamp()
				transformUVW red_prog blue_prog moveMin_spnr.value moveMax_spnr.value
				end = timeStamp()
				time_lbl.text =  ("Process took "+ ((end - start) / 1000.0) as string +" seconds" ) as string
			)
		)
	)-- end rollout
	
	on execute do 
	(
		try( DestroyDialog UVWRandomizer_RO) catch ()
		createDialog UVWRandomizer_RO
	)--end on execute
)