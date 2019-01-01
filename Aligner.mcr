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
	
	fn compareC v1 v2 coord: =
	(
		local d= [0,0,0]
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
				"xCnt": qsort obj compareC coord:"xCnt"
				"yCnt": qsort obj compareC coord:"yCnt"
				"zCnt": qsort obj compareC coord:"zCnt"
			)
			
			startPos = in coordsys (Inverse(getViewTM())) (obj[1].max - obj[1].min)/2.0 + obj[1].min --obj[1].pos
			endPos = in coordsys (Inverse(getViewTM())) (obj[obj.count].max - obj[obj.count].min)/2.0 + obj[obj.count].min   --obj[obj.count].pos
			
			for i = 1 to i = (obj.count - 2) do 
			(		
				evenPos = startPos + (((endPos - startPos)/(obj.count - 1)) * (i as float))
				
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
				"xMin": qsort obj compareC coord:"xMin"
				"yMin": qsort obj compareC coord:"yMin"
				"zMin": qsort obj compareC coord:"zMin"

				"xMax": qsort obj compareC coord:"xMax"
				"yMax": qsort obj compareC coord:"yMax"
				"zMax": qsort obj compareC coord:"zMax"
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
	
	rollout aligner_floater "Aligner v0.1" width:150 height:300
	(
		groupBox DisEvenlyGrp "Distribute Evenly Along:" pos:[5,5] width:140 height:60
		button dist_X_btn "X" pos:[20,30] 
		button dist_Y_btn "Y" pos:[60,30] 
		button dist_Z_btn "Z" pos:[100,30] 
		
		groupBox xAlignGroup "X Align To:" pos:[DisEvenlyGrp.pos.x,DisEvenlyGrp.pos.y + DisEvenlyGrp.height + 10] width:140 height:60
		button lAlign_X_btn "L" pos:[xAlignGroup.pos.x + 15,xAlignGroup.pos.y + 25] 
		button cAlign_X_btn "C" pos:[xAlignGroup.pos.x + 55,xAlignGroup.pos.y + 25] 
		button rAlign_X_btn "R" pos:[xAlignGroup.pos.x + 95,xAlignGroup.pos.y + 25] 

		groupBox yAlignGroup "Y Align To:" pos:[xAlignGroup.pos.x,xAlignGroup.pos.y + xAlignGroup.height + 10] width:140 height:60
		button lAlign_y_btn "L" pos:[yAlignGroup.pos.x + 15,yAlignGroup.pos.y + 25] 
		button cAlign_Y_btn "C" pos:[yAlignGroup.pos.x + 55,yAlignGroup.pos.y + 25] 
		button rAlign_y_btn "R" pos:[yAlignGroup.pos.x + 95,yAlignGroup.pos.y + 25] 

		groupBox zAlignGroup "Z Align To:" pos:[yAlignGroup.pos.x,yAlignGroup.pos.y + yAlignGroup.height + 10] width:140 height:60
		button lAlign_Z_btn "L" pos:[zAlignGroup.pos.x + 15,zAlignGroup.pos.y + 25] 
		button cAlign_Z_btn "C" pos:[zAlignGroup.pos.x + 55,zAlignGroup.pos.y + 25] 
		button rAlign_Z_btn "R" pos:[zAlignGroup.pos.x + 95,zAlignGroup.pos.y + 25] 
		
		on dist_X_btn pressed do with undo label:("Aligner Y") on
		(
			local allObjs = for o in selection collect o
			distribute "xCnt" allObjs
		)
		
		on dist_Y_btn pressed do with undo label:("Aligner Y") on
		(
			local allObjs = for o in selection collect o
			distribute "yCnt" allObjs
		)
		
		on dist_Z_btn pressed do with undo label:("Aligner Y") on
		(
			local allObjs = for o in selection collect o
			distribute "zCnt" allObjs
		)
		
		on cAlign_X_btn pressed do with undo label:("Aligner Y") on
		(
			local allObjs = for o in selection collect o
			cAlign "xCnt" allObjs
		)
		
		on cAlign_Y_btn pressed do with undo label:("Aligner Y") on
		(
			local allObjs = for o in selection collect o
			cAlign "yCnt" allObjs
		)
		
		on cAlign_Z_btn pressed do with undo label:("Aligner Y") on
		(
			local allObjs = for o in selection collect o
			cAlign "zCnt" allObjs
		)

		on lAlign_X_btn pressed do with undo label:("Aligner Y") on
		(
			local allObjs = for o in selection collect o
			objAlign "xMin" allObjs
		)
		
		on lAlign_Y_btn pressed do with undo label:("Aligner Y") on
		(
			local allObjs = for o in selection collect o
			objAlign "yMin" allObjs
		)
		
		on lAlign_Z_btn pressed do with undo label:("Aligner Y") on
		(
			local allObjs = for o in selection collect o
			objAlign "zMin" allObjs
		)


		on rAlign_X_btn pressed do with undo label:("Aligner Y") on
		(
			local allObjs = for o in selection collect o
			objAlign "xMax" allObjs
		)
		
		on rAlign_Y_btn pressed do with undo label:("Aligner Y") on
		(
			local allObjs = for o in selection collect o
			objAlign "yMax" allObjs
		)
		
		on rAlign_Z_btn pressed do with undo label:("Aligner Y") on
		(
			local allObjs = for o in selection collect o
			objAlign "zMax" allObjs
		)
	)
	
	
	on execute do 
	(
		try(destroydialog aligner_floater)catch()
		createDialog aligner_floater
	) --end execute
	
)