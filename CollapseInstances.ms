-------------------------------------------------------------------------------
-- CollapseInstances.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- June 1 2022
-- Collapses all instance groups to a individual single objects
-------------------------------------------------------------------------------
macroScript CollapseInstances
Category: "ilya_s Scripts"
Tooltip: "Collapse Instances"
buttontext:"Collapse Instances"
(
	global CollapseInstances
	local prog_big, prog_small, prog_med

	local step = 20

	fn getUnique instanceOnly:false =
	(
		local result = #()
		local resultInstaceOnly = #()
		local instanceOnlyHandle = #()
		local handles = #()
		local allObj = for o in objects as array where superclassof o == GeometryClass and classof o != Targetobject and classof o != LinkComposite collect o

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


	fn safe_collapse n ps pm = 
	(
		local firstCount = n.count
		for i = n.count to i = 1 by -1*step do
		(
			if i >= step then
			(
				InstanceMgr.MakeObjectsUnique n[i-(step-1)] #individual
				if superclassof n[i-(step-1)] == GeometryClass then
				(
					addModifier n[i-(step-1)] (Turn_To_Mesh())
					collapseStack n[i-(step-1)]
					
					for j = step-1 to j=1 by -1 do
					(
						meshop.attach n[i-(step-1)] n[i-(step-1)+j] attachMat:#IDToMat condenseMat:true
						ps.value = 100.0*j/(step-1) 
					)
				)
			)
			else
			(
				InstanceMgr.MakeObjectsUnique n[1] #individual
				if superclassof n[1] == GeometryClass then
				(
					addModifier n[1] (Turn_To_Mesh())
					collapseStack n[1]
					for j =i to j=2 by -1 do
					(
						meshop.attach n[1] n[j] attachMat:#IDToMat condenseMat:true
						ps.value = 100.0*j/i 
					)
				)
			)
			pm.value = 100.0*i/firstCount
			windows.processPostedMessages()
			gc()
		)-- end for
		
		if n.count != 1 then
		(
			n = for o in n where isValidNode o collect o
			safe_collapse n ps pm
		)
	)-- end function

	rollout CollapseInstances "Collapse Instances" 
	(
		spinner step_spinner "Step:" range:[0,10000000,step] type:#integer scale:1 
		button do_it_bn "Collapse"
		Label time_lbl ""
		group "Progress"
		(
			progressbar prog_big color:red 
			progressbar prog_med color:green 
			progressbar prog_small color:blue 
		)
		
		on step_spinner changed n do
		(
			step= n
		)
		
		on do_it_bn pressed do 
		(
			time_lbl.text = "Working..."
			local instanceObj = getUnique instanceOnly:true
			local start = timeStamp()
			local objIndex = 1
			for o in instanceObj do
			(	
				InstanceMgr.getinstances o &n
				safe_collapse n prog_small prog_med
				prog_big.value = 100.0*objIndex/instanceObj.count
				objIndex = objIndex + 1
			)
			local end = timeStamp()
			time_lbl.text =  ("Done in "+ ((end - start) / 1000.0) as string +" seconds" )
		)-- end on

	)-- end rollout

	on execute do 
	(
		try( DestroyDialog CollapseInstances) catch ()
		createDialog CollapseInstances
	)--end on execute
)

