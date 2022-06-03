-------------------------------------------------------------------------------
-- SafeCollapse.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Dec 16 2019
-- Collapses selection to single mesh by adding objects to a mesh in batches,
-- much faster than built in Collapse and doesn't crash 3dsmax
-------------------------------------------------------------------------------
macroScript SafeCollapse
Category: "ilya_s Scripts"
Tooltip: "Safe Collapse"
buttontext:"Collapse"

(
	global SafeCollapse
	local prog_big, prog_small
	local step = 20
		
	fn safe_collapse ps pb = 
	(
		local n = for o in selection as array collect o
		local firstCount = n.count
		for i = n.count to i = 1 by -1*step do
		(
			if i>=step then
			(
				InstanceMgr.MakeObjectsUnique n[i-(step-1)] #individual
				if superclassof n[i-(step-1)] == GeometryClass then
				(
					macros.run "Modifier Stack" "Convert_to_Mesh"
					for j =step-1 to j=1 by -1 do
					(
						meshop.attach n[i-(step-1)] n[i-(step-1)+j] attachMat:#IDToMat condenseMat:true
						ps.value = 100.0*j/(step-1) 
					)
				)
				else if superclassof n[i-(step-1)] == shape then
				(
					macros.run "Modifier Stack" "Convert_to_Spline"
					for j =step-1 to j=1 by -1 do
					(
						addandweld  n[i-(step-1)] n[i-(step-1)+j] 0.001
						ps.value = 100.0*j/(step-1) 
					)
				)
			)
			else
			(
				InstanceMgr.MakeObjectsUnique n[1] #individual
				if superclassof n[1] == GeometryClass then
				(
					macros.run "Modifier Stack" "Convert_to_Mesh"
					for j =i to j=2 by -1 do
					(
						meshop.attach n[1] n[j] attachMat:#IDToMat condenseMat:true
						ps.value = 100.0*j/i 
					)
				)
				
				else if superclassof  n[1] == shape then
				(
					macros.run "Modifier Stack" "Convert_to_Spline"
					for j =i to j=2 by -1 do
					(
						addandweld  n[1] n[j] 0.001
						ps.value = 100.0*j/(step-1) 
					)
				)
			)
			pb.value = 100.0*i/firstCount
			windows.processPostedMessages()
			gc()		
		)-- end for
		
		if n.count != 1 then safe_collapse ps pb
	)-- end function


	rollout SafeCollapse "Safe Collapse" 
	(
		spinner step_spinner "Step:" range:[0,10000000,step] type:#integer scale:1 
		button do_it_bn "Collapse"
		Label time_lbl ""
		group "Progress"
		(
			progressbar prog_big color:red 
			progressbar prog_small color:blue 
		)
		
		on step_spinner changed n do
		(
			step= n
		--	print thresh_n
		)
		
		on do_it_bn pressed do 
		(
			if ($ != undefined) then
			(		
				time_lbl.text = "Working..."
				start = timeStamp()
				safe_collapse prog_small prog_big
				end = timeStamp()
				time_lbl.text =  ("Done in "+ ((end - start) / 1000.0) as string +" seconds" ) as string
			)--end if
		)-- end on

	)-- end rollout
	on execute do 
	(
		try( DestroyDialog SafeCollapse) catch ()
		createDialog SafeCollapse
	)--end on execute
)-- end script