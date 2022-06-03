-------------------------------------------------------------------------------
-- Aligner.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Dec 30 2018
-- Aligns and distributes selected objects based on viewport coordinates
-------------------------------------------------------------------------------
macroScript Aligner
category:"ilya_s Scripts"
tooltip:"Aligner"
buttontext:"Aligner"
(
	global aligner_floater
	global AlignerIconImg = openBitMap ("X:\\00-000_ScriptTest\\scripts\\LaymanIcons\\AlignerIcons.bmp")


	---------------------------------------------
	-- SPLINE FUNCTIONS -------------------------
	---------------------------------------------

	fn compareFNKnots v1 v2 coord: =
	(
		local d = 0
		local c = coord
		
		case c of 
		(
			"xCnt":  d = ( v1[3].x - v2[3].x )
			"yCnt":  d = ( v1[3].y - v2[3].y )
			"zCnt":  d = ( v1[3].z - v2[3].z ) 
		)
		
		case of
		(
			(d < 0.): -1
			(d > 0.): 1
			default: 0
		)
	)

	fn checkSpline =
	(
		if (subObjectLevel == 1 and IsSubSelEnabled() == true and selection.count == 1 and (modPanel.getCurrentObject() as string == "Edit_Spline:Edit Spline" or modPanel.getCurrentObject() as string  ==  "Editable Spline" or modPanel.getCurrentObject() as string ==  "Line")) then
		(
			if (modPanel.getCurrentObject() as string == "Edit_Spline:Edit Spline") then
			(
				local qb = QueryBox "Can't perform this action on Edit Spline Modifier.\nYES - Collapse to Editable Spline.\nNO - Leave as is, don't do anything. "
				if qb == true then
				(
					convertToSplineShape  $
					true
				)else (false)
			)else (true)
		)
		else (false)
	)

	fn collectKnots = 
	(
		local knotArray = #()

		for i=1 to (numSplines $) do
		(
			for k in getKNotSelection $ i do
			(
				local knotPos = (in coordsys (Inverse(getViewTM())) (getKnotPoint $ i k))
				append knotArray  (#(i, k, knotPos))
			)
		)
		return knotArray
	)

	fn alignKnots axis =
	(
		if checkSpline() == true then
		(
			local knotArray = collectKnots()
			
			if knotArray.count >= 2 then
			(
				if (axis == "xCnt" or axis == "yCnt" or axis == "zCnt") then
				(
					local centers = [0,0,0]
					
					for i=1 to knotArray.count do
					(
						centers = centers + knotArray[i][3]
					)
					
					local aveCenter = centers/knotArray.count
					print aveCenter
					
					for i = 1 to (knotArray.count) do 
					(		
						in coordsys (Inverse(getViewTM()))
						local knt = getKnotPoint $ knotArray[i][1] knotArray[i][2]
						
						in coordsys (Inverse(getViewTM()))
						local inVec = getInVec $ knotArray[i][1] knotArray[i][2]
						
						in coordsys (Inverse(getViewTM()))
						local outVec = getOutVec$ knotArray[i][1] knotArray[i][2]
							
						case axis of
						(
							"xCnt":
							(
								in coordsys (Inverse(getViewTM()))
								setInVec $ knotArray[i][1] knotArray[i][2] [aveCenter.x+(inVec.x-knt.x) ,inVec.y,inVec.z]
								in coordsys (Inverse(getViewTM()))
								setOutVec $ knotArray[i][1] knotArray[i][2] [aveCenter.x+(outVec.x-knt.x),outVec.y,outVec.z]	
								in coordsys (Inverse(getViewTM()))
								setKnotPoint $ knotArray[i][1] knotArray[i][2] [aveCenter.x,knt.y,knt.z]
							)
							"yCnt": 
							(
								in coordsys (Inverse(getViewTM()))
								setInVec $ knotArray[i][1] knotArray[i][2] [inVec.x ,aveCenter.y+(inVec.y-knt.y),inVec.z]
								in coordsys (Inverse(getViewTM()))
								setOutVec $ knotArray[i][1] knotArray[i][2] [outVec.x ,aveCenter.y+(outVec.y-knt.y),outVec.z]
								in coordsys (Inverse(getViewTM()))
								setKnotPoint $ knotArray[i][1] knotArray[i][2] [knt.x,aveCenter.y,knt.z]
							)
							"zCnt": 
							(
								in coordsys (Inverse(getViewTM()))
								setInVec $ knotArray[i][1] knotArray[i][2] [inVec.x,inVec.y,aveCenter.z+(inVec.z-knt.z)]
								in coordsys (Inverse(getViewTM()))
								setOutVec $ knotArray[i][1] knotArray[i][2] [outVec.x,outVec.y,aveCenter.z+(outVec.z-knt.z)]	
								in coordsys (Inverse(getViewTM()))
								setKnotPoint $ knotArray[i][1] knotArray[i][2] [knt.x,knt.y,aveCenter.z]
							)
						)
					)
					updateshape $
				)
				else
				(
					case axis of
					(
						"xMax": qsort knotArray compareFNKnots coord:"xCnt"
						"yMax": qsort knotArray compareFNKnots coord:"yCnt"
						"zMax": qsort knotArray compareFNKnots coord:"zCnt"

						"xMin": qsort knotArray compareFNKnots coord:"xCnt"
						"yMin": qsort knotArray compareFNKnots coord:"yCnt"
						"zMin": qsort knotArray compareFNKnots coord:"zCnt"
					)

					local alignMin = knotArray[1][3]
					local alignMax = knotArray[knotArray.count][3]
					
					if (axis == "xMin" or axis == "yMin" or axis == "zMin") then
					(
						for i = 2 to i = (knotArray.count) do 
						(		
							in coordsys (Inverse(getViewTM()))
							local knt = getKnotPoint $ knotArray[i][1] knotArray[i][2]
							
							in coordsys (Inverse(getViewTM()))
							local inVec = getInVec $ knotArray[i][1] knotArray[i][2]
							
							in coordsys (Inverse(getViewTM()))
							local outVec = getOutVec $ knotArray[i][1] knotArray[i][2]

							case axis of
							(
								"xMin":
								(
									in coordsys (Inverse(getViewTM()))
									setInVec $ knotArray[i][1] knotArray[i][2] [alignMin.x+(inVec.x-knt.x) ,inVec.y,inVec.z]
									in coordsys (Inverse(getViewTM()))
									setOutVec $ knotArray[i][1] knotArray[i][2] [alignMin.x+(outVec.x-knt.x),outVec.y,outVec.z]	
									in coordsys (Inverse(getViewTM()))
									setKnotPoint $ knotArray[i][1] knotArray[i][2] [alignMin.x,knt.y,knt.z]
								)
								"yMin": 
								(
									in coordsys (Inverse(getViewTM()))
									setInVec $ knotArray[i][1] knotArray[i][2] [inVec.x ,alignMin.y+(inVec.y-knt.y),inVec.z]
									in coordsys (Inverse(getViewTM()))
									setOutVec $ knotArray[i][1] knotArray[i][2] [outVec.x ,alignMin.y+(outVec.y-knt.y),outVec.z]
									in coordsys (Inverse(getViewTM()))
									setKnotPoint $ knotArray[i][1] knotArray[i][2] [knt.x,alignMin.y,knt.z]
								)
								"zMin": 
								(
									in coordsys (Inverse(getViewTM()))
									setInVec $ knotArray[i][1] knotArray[i][2] [inVec.x,inVec.y,alignMin.z+(inVec.z-knt.z)]
									in coordsys (Inverse(getViewTM()))
									setOutVec $ knotArray[i][1] knotArray[i][2] [outVec.x,outVec.y,alignMin.z+(outVec.z-knt.z)]	
									in coordsys (Inverse(getViewTM()))
									setKnotPoint $ knotArray[i][1] knotArray[i][2] [knt.x,knt.y,alignMin.z]
								)
							)
						)
						updateshape $
					)

					if (axis == "xMax" or axis == "yMax" or axis == "zMax") then
					(
						for i = 1 to i = (knotArray.count - 1) do 
						(		
							in coordsys (Inverse(getViewTM()))
							local knt = getKnotPoint $ knotArray[i][1] knotArray[i][2]
							
							in coordsys (Inverse(getViewTM()))
							local inVec = getInVec $ knotArray[i][1] knotArray[i][2]
							
							in coordsys (Inverse(getViewTM()))
							local outVec = getOutVec$ knotArray[i][1] knotArray[i][2]

							case axis of
							(
								"xMax":
								(
									in coordsys (Inverse(getViewTM()))
									setInVec $ knotArray[i][1] knotArray[i][2] [alignMax.x+(inVec.x-knt.x) ,inVec.y,inVec.z]
									in coordsys (Inverse(getViewTM()))
									setOutVec $ knotArray[i][1] knotArray[i][2] [alignMax.x+(outVec.x-knt.x),outVec.y,outVec.z]	
									in coordsys (Inverse(getViewTM()))
									setKnotPoint $ knotArray[i][1] knotArray[i][2] [alignMax.x,knt.y,knt.z]
								)
								"yMax": 
								(
									in coordsys (Inverse(getViewTM()))
									setInVec $ knotArray[i][1] knotArray[i][2] [inVec.x ,alignMax.y+(inVec.y-knt.y),inVec.z]
									in coordsys (Inverse(getViewTM()))
									setOutVec $ knotArray[i][1] knotArray[i][2] [outVec.x ,alignMax.y+(outVec.y-knt.y),outVec.z]
									in coordsys (Inverse(getViewTM()))
									setKnotPoint $ knotArray[i][1] knotArray[i][2] [knt.x,alignMax.y,knt.z]
								)
								"zMax": 
								(
									in coordsys (Inverse(getViewTM()))
									setInVec $ knotArray[i][1] knotArray[i][2] [inVec.x,inVec.y,alignMax.z+(inVec.z-knt.z)]
									in coordsys (Inverse(getViewTM()))
									setOutVec $ knotArray[i][1] knotArray[i][2] [outVec.x,outVec.y,alignMax.z+(outVec.z-knt.z)]	
									in coordsys (Inverse(getViewTM()))
									setKnotPoint $ knotArray[i][1] knotArray[i][2] [knt.x,knt.y,alignMax.z]
								)
							)
						)
						updateshape $
					)
				)
			)
			else
			(
				MessageBox ("Select 2 or more verteces.")
			)
		)
	)


	fn distributeKnots axis = 
	(
		if checkSpline() == true then
		(
			local knotArray = collectKnots()
			
			if knotArray.count >= 3 then
			(

				case axis of
				(
					"xCnt": qsort knotArray compareFNKnots coord:"xCnt"
					"yCnt": qsort knotArray compareFNKnots coord:"yCnt"
					"zCnt": qsort knotArray compareFNKnots coord:"zCnt"
				)

				local startPos = knotArray[1][3]
				local endPos = knotArray[knotArray.count][3]
				
				for i = 2 to (knotArray.count - 1) do 
				(		
					local evenPos = startPos + (((endPos - startPos)/(knotArray.count - 1)) * ((i-1) as float))
					
					in coordsys (Inverse(getViewTM()))
					local knt = getKnotPoint $ knotArray[i][1] knotArray[i][2]
					
					in coordsys (Inverse(getViewTM()))
					local inVec = getInVec $ knotArray[i][1] knotArray[i][2]
					
					in coordsys (Inverse(getViewTM()))
					local outVec = getOutVec$ knotArray[i][1] knotArray[i][2]
						
					case axis of
					(
						"xCnt":
						(
							in coordsys (Inverse(getViewTM()))
							setInVec $ knotArray[i][1] knotArray[i][2] [evenPos.x+(inVec.x-knt.x) ,inVec.y,inVec.z]
							in coordsys (Inverse(getViewTM()))
							setOutVec $ knotArray[i][1] knotArray[i][2] [evenPos.x+(outVec.x-knt.x),outVec.y,outVec.z]	
							in coordsys (Inverse(getViewTM()))
							setKnotPoint $ knotArray[i][1] knotArray[i][2] [evenPos.x,knt.y,knt.z]
						)
						"yCnt": 
						(
							in coordsys (Inverse(getViewTM()))
							setInVec $ knotArray[i][1] knotArray[i][2] [inVec.x ,evenPos.y+(inVec.y-knt.y),inVec.z]
							in coordsys (Inverse(getViewTM()))
							setOutVec $ knotArray[i][1] knotArray[i][2] [outVec.x ,evenPos.y+(outVec.y-knt.y),outVec.z]
							in coordsys (Inverse(getViewTM()))
							setKnotPoint $ knotArray[i][1] knotArray[i][2] [knt.x,evenPos.y,knt.z]
						)
						"zCnt": 
						(
							in coordsys (Inverse(getViewTM()))
							setInVec $ knotArray[i][1] knotArray[i][2] [inVec.x,inVec.y,evenPos.z+(inVec.z-knt.z)]
							in coordsys (Inverse(getViewTM()))
							setOutVec $ knotArray[i][1] knotArray[i][2] [outVec.x,outVec.y,evenPos.z+(outVec.z-knt.z)]	
							in coordsys (Inverse(getViewTM()))
							setKnotPoint $ knotArray[i][1] knotArray[i][2] [knt.x,knt.y,evenPos.z]
						)
					)
				)
				updateshape $
			) 
			else
			(
				MessageBox ("Select 3 or more verteces.")
			)
		)
	)



	---------------------------------------------
	-- OBJECT FUNCTIONS -------------------------
	---------------------------------------------



	fn compareFNKnotsObj v1 v2 coord: =
	(
		local d = [0,0,0]
		local c = coord
		
		case c of 
		(
			"xCnt":  d = (in coordsys (Inverse(getViewTM())) ((v1.max - v1.min)/2.0 + v1.min).x ) - (in coordsys (Inverse(getViewTM())) ((v2.max - v2.min)/2.0 + v2.min).x )
			"yCnt":  d = (in coordsys (Inverse(getViewTM())) ((v1.max - v1.min)/2.0 + v1.min).y ) - (in coordsys (Inverse(getViewTM())) ((v2.max - v2.min)/2.0 + v2.min).y )
			"zCnt":  d = (in coordsys (Inverse(getViewTM())) ((v1.max - v1.min)/2.0 + v1.min).z ) - (in coordsys (Inverse(getViewTM())) ((v2.max - v2.min)/2.0 + v2.min).z )

			"xMin":  d = (in coordsys (Inverse(getViewTM())) v1.min.x) - (in coordsys (Inverse(getViewTM())) v2.min.x)
			"yMin":  d = (in coordsys (Inverse(getViewTM())) v1.min.y) - (in coordsys (Inverse(getViewTM())) v2.min.y)
			"zMin":  d = (in coordsys (Inverse(getViewTM())) v1.min.z) - (in coordsys (Inverse(getViewTM())) v2.min.z)

			"xMax":  d = (in coordsys (Inverse(getViewTM())) v1.max.x) - (in coordsys (Inverse(getViewTM())) v2.max.x)
			"yMax":  d = (in coordsys (Inverse(getViewTM())) v1.max.y) - (in coordsys (Inverse(getViewTM())) v2.max.y)
			"zMax":  d = (in coordsys (Inverse(getViewTM())) v1.max.z) - (in coordsys (Inverse(getViewTM())) v2.max.z)
		)
		
		case of
		(
			(d < 0.): -1
			(d > 0.): 1
			default: 0
		)
	)


	fn distribute axis obj = 
	(
		if obj.count >= 3 then
		(
			case axis of
			(
				"xCnt": qsort obj compareFNKnotsObj coord:"xCnt"
				"yCnt": qsort obj compareFNKnotsObj coord:"yCnt"
				"zCnt": qsort obj compareFNKnotsObj coord:"zCnt"
			)
			
			local startPos = in coordsys (Inverse(getViewTM())) (obj[1].max - obj[1].min)/2.0 + obj[1].min --obj[1].pos
			local endPos = in coordsys (Inverse(getViewTM())) (obj[obj.count].max - obj[obj.count].min)/2.0 + obj[obj.count].min   --obj[obj.count].pos
			
			for i = 1 to i = (obj.count - 2) do 
			(		
				local evenPos = startPos + (((endPos - startPos)/(obj.count - 1)) * (i as float))
				
				if axis == "xCnt" then 
				(
					in coordsys (Inverse(getViewTM()))
					obj[i+1].pos.x = evenPos.x + (obj[i+1].pos.x - ((obj[i+1].max - obj[i+1].min)/2.0 + obj[i+1].min).x) 
				)
				else if axis == "yCnt" then 
				(
					in coordsys (Inverse(getViewTM()))
					obj[i+1].pos.y = evenPos.y + (obj[i+1].pos.y - ((obj[i+1].max - obj[i+1].min)/2.0 + obj[i+1].min).y)
				)
				else if axis == "zCnt" then 
				(
					in coordsys (Inverse(getViewTM()))
					obj[i+1].pos.z = evenPos.z + (obj[i+1].pos.z - ((obj[i+1].max - obj[i+1].min)/2.0 + obj[i+1].min).z)
				)
				else()
			)
		)
		else (MessageBox "Select 3 or more objects.")
	)
	
	fn cAlign axis obj =
	(
		if obj.count >= 2 then
		(
			local centers = 0.0
			
			for o in obj do
			(
				case axis of
				(
					"xCnt": (centers = centers + (in coordsys (Inverse(getViewTM())) ((o.max - o.min)/2.0 + o.min).x ))
					"yCnt": (centers = centers + (in coordsys (Inverse(getViewTM())) ((o.max - o.min)/2.0 + o.min).y ))
					"zCnt": (centers = centers + (in coordsys (Inverse(getViewTM())) ((o.max - o.min)/2.0 + o.min).z ))
				)
			)
			
			local aveCenter = centers/obj.count
			
			for o in obj do 
			(
				case axis of
				(
					"xCnt": (in coordsys (Inverse(getViewTM())); o.pos.x = aveCenter + (o.pos.x - ((o.max - o.min)/2.0 + o.min).x) )
					"yCnt": (in coordsys (Inverse(getViewTM())); o.pos.y = aveCenter + (o.pos.y - ((o.max - o.min)/2.0 + o.min).y) )
					"zCnt": (in coordsys (Inverse(getViewTM())); o.pos.z = aveCenter + (o.pos.z - ((o.max - o.min)/2.0 + o.min).z) )
				)
			)
			
		)
		else (MessageBox "Select 2 or more objects.")
	)

	fn objAlign axis obj = 
	(
		if obj.count >= 2 then
		(
			case axis of
			(
				"xMin": qsort obj compareFNKnotsObj coord:"xMin"
				"yMin": qsort obj compareFNKnotsObj coord:"yMin"
				"zMin": qsort obj compareFNKnotsObj coord:"zMin"

				"xMax": qsort obj compareFNKnotsObj coord:"xMax"
				"yMax": qsort obj compareFNKnotsObj coord:"yMax"
				"zMax": qsort obj compareFNKnotsObj coord:"zMax"
			)
			
			local minPos = in coordsys (Inverse(getViewTM())) obj[1].min
			local maxPos = in coordsys (Inverse(getViewTM())) obj[obj.count].max

			if (axis == "xMin" or axis == "yMin" or axis == "zMin") then
			(
				for i = 2 to i = (obj.count) do 
				(		
					case axis of
					(
						"xMin": (in coordsys (Inverse(getViewTM())); obj[i].pos.x = minPos.x + (obj[i].pos.x - obj[i].min.x) )
						"yMin": (in coordsys (Inverse(getViewTM())); obj[i].pos.y = minPos.y + (obj[i].pos.y - obj[i].min.y) )
						"zMin": (in coordsys (Inverse(getViewTM())); obj[i].pos.z = minPos.z + (obj[i].pos.z - obj[i].min.z) )
					)
				)
			)

			if (axis == "xMax" or axis == "yMax" or axis == "zMax") then
			(
				for i = 1 to i = (obj.count - 1) do 
				(		
					case axis of
					(
						"xMax": (in coordsys (Inverse(getViewTM())); obj[i].pos.x = maxPos.x - (obj[i].max.x - obj[i].pos.x) )
						"yMax": (in coordsys (Inverse(getViewTM())); obj[i].pos.y = maxPos.y - (obj[i].max.y - obj[i].pos.y) )
						"zMax": (in coordsys (Inverse(getViewTM())); obj[i].pos.z = maxPos.z - (obj[i].max.z - obj[i].pos.z) )
					)
				)
			)
		)
		else (MessageBox "Select 2 or more objects.")
	)
	
	rollout aligner_floater "Aligner v0.1" width:150 height:360
	(
		radiobuttons mode_btn "Mode:" labels:#("Object Selection","Vertex Selection")

		groupBox DisEvenlyGrp "Distribute Evenly Along:" pos:[5,65] width:140 height:60
		button dist_X_btn images:#(AlignerIconImg , undefined, 17,1,1,1,1) toolTip:"Distribute Along X" width:27 height:27 pos:[DisEvenlyGrp.pos.x + 15,DisEvenlyGrp.pos.y + 25] 
		button dist_Y_btn images:#(AlignerIconImg , undefined, 17,2,2,2,2) toolTip:"Distribute Along Y" width:27 height:27 pos:[DisEvenlyGrp.pos.x + 55,DisEvenlyGrp.pos.y + 25] 
		button dist_Z_btn images:#(AlignerIconImg , undefined, 17,3,3,3,3) toolTip:"Distribute Along Z" width:27 height:27 pos:[DisEvenlyGrp.pos.x + 95,DisEvenlyGrp.pos.y + 25] 
		
		groupBox xAlignGroup "X Align To:" pos:[DisEvenlyGrp.pos.x,DisEvenlyGrp.pos.y + DisEvenlyGrp.height + 10] width:140 height:60
		button lAlign_X_btn images:#(AlignerIconImg , undefined, 17,4,4,4,4) toolTip:"Align to Min X" width:27 height:27 pos:[xAlignGroup.pos.x + 15,xAlignGroup.pos.y + 25] 
		button cAlign_X_btn images:#(AlignerIconImg , undefined, 17,5,5,5,5) toolTip:"Align to Center X" width:27 height:27 pos:[xAlignGroup.pos.x + 55,xAlignGroup.pos.y + 25] 
		button rAlign_X_btn images:#(AlignerIconImg , undefined, 17,6,6,6,6) toolTip:"Align to Max X" width:27 height:27 pos:[xAlignGroup.pos.x + 95,xAlignGroup.pos.y + 25] 

		groupBox yAlignGroup "Y Align To:" pos:[xAlignGroup.pos.x,xAlignGroup.pos.y + xAlignGroup.height + 10] width:140 height:60
		button lAlign_y_btn images:#(AlignerIconImg , undefined, 17,7,7,7,7) toolTip:"Align to Min Y" width:27 height:27 pos:[yAlignGroup.pos.x + 15,yAlignGroup.pos.y + 25] 
		button cAlign_Y_btn images:#(AlignerIconImg , undefined, 17,8,8,8,8) toolTip:"Align to Center Y" width:27 height:27 pos:[yAlignGroup.pos.x + 55,yAlignGroup.pos.y + 25] 
		button rAlign_y_btn images:#(AlignerIconImg , undefined, 17,9,9,9,9) toolTip:"Align to Max Y" width:27 height:27 pos:[yAlignGroup.pos.x + 95,yAlignGroup.pos.y + 25] 

		groupBox zAlignGroup "Z Align To:" pos:[yAlignGroup.pos.x,yAlignGroup.pos.y + yAlignGroup.height + 10] width:140 height:60
		button lAlign_Z_btn images:#(AlignerIconImg , undefined, 17,10,10,10,10) toolTip:"Align to Min Z" width:27 height:27 pos:[zAlignGroup.pos.x + 15,zAlignGroup.pos.y + 25] 
		button cAlign_Z_btn images:#(AlignerIconImg , undefined, 17,11,11,11,11) toolTip:"Align to Center Z" width:27 height:27 pos:[zAlignGroup.pos.x + 55,zAlignGroup.pos.y + 25] 
		button rAlign_Z_btn images:#(AlignerIconImg , undefined, 17,12,12,12,12) toolTip:"Align to Max Z" width:27 height:27 pos:[zAlignGroup.pos.x + 95,zAlignGroup.pos.y + 25] 
		
		on dist_X_btn pressed do with undo label:("Distribute Along X") on
		(
			case mode_btn.state of
			(
				1:
				(
					local allObjs = for o in selection collect o
					distribute "xCnt" allObjs
				)
				2:
				(
					distributeKnots "xCnt"	
				)
			)
		)
		
		on dist_Y_btn pressed do with undo label:("Distribute Along Y") on
		(
			case mode_btn.state of
			(
				1:
				(
					local allObjs = for o in selection collect o
					distribute "yCnt" allObjs
				)
				2:
				(
					distributeKnots "yCnt"
				)
			)
		)
		
		on dist_Z_btn pressed do with undo label:("Distribute Along Z") on
		(
			case mode_btn.state of
			(
				1:
				(
					local allObjs = for o in selection collect o
					distribute "zCnt" allObjs
				)
				2:
				(
					distributeKnots "zCnt"
				)
			)
		)
		
		on cAlign_X_btn pressed do with undo label:("Align to Center X") on
		(
			case mode_btn.state of
			(
				1:
				(
					local allObjs = for o in selection collect o
					cAlign "xCnt" allObjs
				)
				2:
				(
					alignKnots "xCnt"
				)
			)
		)
		
		on cAlign_Y_btn pressed do with undo label:("Align to Center Y") on
		(
			case mode_btn.state of
			(
				1:
				(
					local allObjs = for o in selection collect o
					cAlign "yCnt" allObjs
				)
				2:
				(
					alignKnots "yCnt" 
				)
			)
		)
		
		on cAlign_Z_btn pressed do with undo label:("Align to Center Z") on
		(
			case mode_btn.state of
			(
				1:
				(
					local allObjs = for o in selection collect o
					cAlign "zCnt" allObjs
				)
				2:
				(
					alignKnots "zCnt"
				)
			)
		)

		on lAlign_X_btn pressed do with undo label:("Align to Min X") on
		(
			case mode_btn.state of
			(
				1:
				(
					local allObjs = for o in selection collect o
					objAlign "xMin" allObjs
				)
				2:
				(
					alignKnots "xMin"
				)
			)
		)
		
		on lAlign_Y_btn pressed do with undo label:("Align to Min Y") on
		(
			case mode_btn.state of
			(
				1:
				(
					local allObjs = for o in selection collect o
					objAlign "yMax" allObjs
				)
				2:
				(
					alignKnots "yMax"
				)
			)
		)
		
		on lAlign_Z_btn pressed do with undo label:("Align to Min Z") on
		(
			case mode_btn.state of
			(
				1:
				(
					local allObjs = for o in selection collect o
					objAlign "zMin" allObjs
				)
				2:
				(
					alignKnots "zMin"
				)
			)
		)

		on rAlign_X_btn pressed do with undo label:("Align to Max X") on
		(
			case mode_btn.state of
			(
				1:
				(
					local allObjs = for o in selection collect o
					objAlign "xMax" allObjs
				)
				2:
				(
					alignKnots "xMax"
				)
			)
		)
		
		on rAlign_Y_btn pressed do with undo label:("Align to Max Y") on
		(
			case mode_btn.state of
			(
				1:
				(
					local allObjs = for o in selection collect o
					objAlign "yMin" allObjs
				)
				2:
				(
					alignKnots "yMin"
				)
			)
		)
		
		on rAlign_Z_btn pressed do with undo label:("Align to Max Z") on
		(
			case mode_btn.state of
			(
				1:
				(
					local allObjs = for o in selection collect o
					objAlign "zMax" allObjs
				)
				2:
				(
					alignKnots "zMax"
				)
			)
		)
	)
	
	
	on execute do 
	(
		try(destroydialog aligner_floater)catch()
		createDialog aligner_floater
	) --end execute
	
)