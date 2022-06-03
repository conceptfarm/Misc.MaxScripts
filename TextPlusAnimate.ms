---------------------------------------------------------------------------------
-- TextPlusAnimate.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Feb 17th 2019
-- A modifier that animates each characters' scale sequentially in a text+ object
---------------------------------------------------------------------------------
plugin modifier TextPlusAnimate
name:"Text+ Animate"
category:"ilya_s Scripts"
classID:#(0x52abffc8, 0x677691ab)
extends:EmptyModifier
replaceUI:true
version:0.1
(
	local buttonWidth = 135

	parameters main rollout:params
	(
		startFrame_spn type:#integer animatable:false ui:startFrame_spn default:0
		endFrame_spn type:#integer animatable:false ui:endFrame_spn default:60
		duration_spn type:#integer animatable:false ui:duration_spn default:60
		mult_spn type:#float animatable:false ui:mult_spn default:1.0
		startScale_spn type:#float animatable:false ui:startScale_spn default:0
		endScale_spn type:#float animatable:false ui:endScale_spn default:1
		bgPadding_V_val type:#integer animatable:false ui:bgPadding_V_spn default:0
		bgPadding_H_val type:#integer animatable:false ui:bgPadding_H_spn default:0
	)

	fn zoomCurveVertical ctrl =
	(
		zoom ctrl #all
		ctrl.zoomValues.x = 130
		ctrl.scrollValues.x = 2
	)
	
	fn deleteKeysInRange start end =
	(
		$.GetPlaintextString &str
		local nChar = str.count
		
		for c = 1 to nChar do
		(
			--delete the key that is automatically set at 0, this is assuming that there are max 2 keys per animation (start and end scale)
			if $.charXScale[c].controller.keys.count > 0 then
			(
				for i = $.charXScale[c].controller.keys.count to 1 by -1 do
				(
					if $.charXScale[c].controller.keys[i].time <= end and  $.charXScale[c].controller.keys[i].time >= start then
					(
						deleteItem $.charXScale[c].controller.keys i
					)
				)
			)
			
			if $.charYScale[c].controller.keys.count > 0 then
			(
				for i = $.charYScale[c].controller.keys.count to 1 by -1 do
				(
					if $.charYScale[c].controller.keys[i].time <= end and  $.charYScale[c].controller.keys[i].time >= start then
					(
						deleteItem $.charYScale[c].controller.keys i
					)
				)
			)
		)
	)
	
	fn charAnimate appendType:#none =
	(
		$.GetPlaintextString &str
		local nChar = str.count
		
		if nChar != 0 then
		(
			if appendType == #none then
			(
				try(
					for i=1 to $.charXScale.count do 
					(
						deleteKeys $.charXScale[i].controller #allkeys
						deleteKeys $.charYScale[i].controller #allkeys
					)
				)catch()
			)
			else
			(
				deleteKeysInRange this.startFrame_spn this.endFrame_spn
			)

			local duration = this.duration_spn
			local mult = this.mult_spn
			local durationPerCharOrig = duration/nChar
			local durationPerCharOffset = ((nChar * mult * durationPerCharOrig) - duration)/(nChar - 1)
			local durationPerChar = duration/nChar*mult

			print ("DPLOffset: " + durationPerCharOffset as string)
			print ("DPL: " + durationPerChar as string)
			print ("start f: " + this.startFrame_spn as string)

				
			for c=1 to nChar do
			(
				if $.charXScale[c].controller == undefined then  $.charXScale[c].controller = bezier_Float()
				if $.charYScale[c].controller == undefined then  $.charYScale[c].controller = bezier_Float()
				
				if c==1 then 
				(
					local keyTime = this.startFrame_spn
					addNewKey $.charXScale[c].controller.keys keyTime
					local index = getKeyIndex $.charXScale[c].controller keyTime
					$.charXScale[c].controller.keys[index].value = this.startScale_spn
					addNewKey $.charYScale[c].controller.keys keyTime
					$.charYScale[c].controller.keys[index].value = this.startScale_spn
					
					keyTime = (durationPerChar*c+(this.startFrame_spn))
					addNewKey $.charXScale[c].controller.keys keyTime
					index = getKeyIndex $.charXScale[c].controller keyTime
					$.charXScale[c].controller.keys[index].value = this.endScale_spn
					addNewKey $.charYScale[c].controller.keys keyTime
					$.charYScale[c].controller.keys[index].value = this.endScale_spn
				) 
				else 
				(
					local keyTime = ((c-1)*(durationPerChar - durationPerCharOffset)+(this.startFrame_spn))
					addNewKey $.charXScale[c].controller.keys keyTime
					local index = getKeyIndex $.charXScale[c].controller keyTime
					$.charXScale[c].controller.keys[index].value = this.startScale_spn
					addNewKey $.charYScale[c].controller.keys keyTime
					$.charYScale[c].controller.keys[index].value = this.startScale_spn
					
					keyTime = ((c-1)*(durationPerChar - durationPerCharOffset)+durationPerChar+(this.startFrame_spn))
					addNewKey $.charXScale[c].controller.keys keyTime
					index =  getKeyIndex $.charXScale[c].controller keyTime
					$.charXScale[c].controller.keys[index].value = this.endScale_spn
					addNewKey $.charYScale[c].controller.keys keyTime
					$.charYScale[c].controller.keys[index].value = this.endScale_spn
				)
				
				sortKeys #($.charXScale[c].controller.keys)
				sortKeys #($.charYScale[c].controller.keys)
			)			
		)
		else
		(
			MessageBox "The text object must have at least 1 character to animate."
		)
	)--on ani end
	
	
	
	fn getCurveItem type = case type of
	(
		#rotation: curves.GetItem 1
		--#scale: curves.GetItem 2
		#shapeAnim: curves.GetItem 3
	)
	
	local curveEdit = rollout curveEdit "Edit Curve" width:500 height:300
	(
		local ccHwnd, cpHwnd
		--local forceUpdate = forceUpdate
		local curve = curve
		local type = type

		fn show type = if NOT curveEdit.inDialog do 
		(
			--curveEdit.curve = this.getCurveItem type
			--curveEdit.forceUpdate = this.forceUpdate
			curveEdit.type = type
			removeRollout (this.getRollout type)
			createDialog curveEdit style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing)
		)

		curveControl cc numCurves:1 width:482 height:280 align:#left offset:[-4, 2] \
			x_range:[0, 1] y_range:[-1e3, 1e3] commandMode:#move_xy rcmFlags:#(#delete, #corner, #bezier)

		on curveEdit open do
		(
			deleteAllChangeHandlers id:#sweepGeneric

			advancedSweepFns.setControlCurve cc curve
			ccHwnd = cc.hwnd[1]
			cpHwnd = for ctrl in windows.getChildrenHWND ccHwnd where ctrl[4] == "DefPopUp" do exit with ctrl[1]

			advancedSweepFns.sendClick ccHwnd
			zoom cc #all

			--when topology (refs.dependents cc.curves[1])[1] changes id:#sweepGeneric do this.forceUpdate()
		)

		on curveEdit resized size do
		(
			windows.setWindowPos ccHwnd 9 7 (size.x - 18) (size.y - 13) true
			windows.setWindowPos cpHwnd 0 0 (size.x - 18) (size.y - 13) true
		)
		
		--on cc ptChanged curveIndex val do if not loading do this.forceUpdate()
		--on cc tangentChanged curveIndex val type do if not loading do this.forceUpdate()
		--on cc deleted curveIndex val do this.forceUpdate()
		--on cc reset curveIndex do this.forceUpdate()
		
		on curveEdit close do
		(
			deleteAllChangeHandlers id:#sweepGeneric
			cc.numCurves = 0
			if (modPanel.getCurrentObject()) == this do addRollout (this.getRollout type)
		)
	)


	rollout params "Text+ Animated Properties"
	(
		group "Animation Duration"
		(
			spinner startFrame_spn "Start Frame:" type:#integer range:[-1000000,1000000,0]
			spinner endFrame_spn   "  End Frame:" type:#integer range:[-1000000,1000000,60]
			spinner duration_spn   "   Duration:" type:#integer range:[1,1000000,60]
			spinner mult_spn       "Ani. Overlap:" type:#float range:[0.1,1000000,1.0] tooltip:"Amount of frames that overlap the end of one letter animation with the beginning of the next letter animation. Higher value - smoother animation."
		)

		group "Start/End Scale"
		(
			spinner startScale_spn "Start Scale:" type:#float range:[-1000000,1000000,0.0]
			spinner endScale_spn   "  End Scale:" type:#float range:[-1000000,1000000,1.0]

			curveControl ccScale numCurves:1 width:135 height:100 \
			x_range:[0, 1] y_range:[-1e3, 1e3] scrollValues:[2, 5] zoomValues:[135, 40] \
			rcmFlags:#(#move_xy, #move_x, #move_y, #corner, #bezier, #delete) \
			uiFlags:#(#constrainY, #noFilterButtons) visible:false 
			button btnZoomScaleCurve "Zoom Ext." width:67 across:2 offset:[-5, 0] visible:false
		    button btnEditScaleCurve "Edit Curve..." width:68 offset:[5, 0] visible:false
			

			
			on params open do
			(
				deleteAllChangeHandlers id:#sweepScale
				advancedSweepFns.setControlCurve ccScale (this.getCurveItem #scale)
				this.zoomCurveVertical ccScale
				
				--when topology (refs.dependents ccScale.curves[1])[1] changes id:#sweepScale do this.forceUpdate()
			)
			
			--on ccScale ptChanged curveIndex val do if not loading do this.forceUpdate()
			--on ccScale tangentChanged curveIndex val type do if not loading do this.forceUpdate()
			--on ccScale deleted curveIndex val do this.forceUpdate()
			--on ccScale reset curveIndex do this.forceUpdate()

			on btnZoomScaleCurve pressed do
				this.zoomCurveVertical ccScale

			on btnEditScaleCurve pressed do
				curveEdit.show #scale

			on scaleParams close do
			(
				deleteAllChangeHandlers id:#sweepScale
				ccScale.numCurves = 0
			)

		)

		group "Generate Frames"
		(
			button clearAnimate_btn "Clear + Animate" width:buttonWidth	
			button appendAnimate_btn "Append + Animate" width:buttonWidth	
		)
		
		group "Create Background"
		(
			spinner bgPadding_V_spn "V. BG Pad %:" type:#integer range:[0,100000000000,0]
			spinner bgPadding_H_spn "H. BG Pad %:" type:#integer range:[0,100000000000,0]
			button createBG_btn "Create BG" width:buttonWidth	
			
			
			on createBG_btn pressed do
			(

				local bbox = nodeGetBoundingBox $ $.transform
				local size = [(bbox[2][1]-bbox[1][1]),(bbox[2][2]-bbox[1][2]),(bbox[2][3]-bbox[1][3])]

				local bg = Box realWorldMapSize:on width:size[1] length:size[2] height:size[3]
				bg.name = $.name + "_BG"
				bg.pivot.z = bg.max.z
				bg.rotation = $.rotation
				bg.position = [$.center[1], $.center[2], $.center[3]]
				in coordsys $ bg.position.z = $.max.z
				bg.parent = $
				
				--width
				bg.width.controller = float_script()
				bg.width.controller.AddNode  "txt" $
				scriptstring =  "bbox = nodeGetBoundingBox txt txt.transform\n" + \
								"w = bbox[2][1]-bbox[1][1]\n" + \
								"w + w * txt.modifiers[\"Text+ Animate\"].bgPadding_H_val/100.0"
				bg.width.controller.script = scriptstring
				
				--length
				bg.length.controller = float_script()
				bg.length.controller.AddNode  "txt" $
								scriptstring =  "bbox = nodeGetBoundingBox txt txt.transform\n" + \
								"size = [(bbox[2][1]-bbox[1][1]),(bbox[2][2]-bbox[1][2]),(bbox[2][3]-bbox[1][3])]\n" + \
								"if (size[1]*size[2]*size[3]) == 0.0 then 0\n" + \
								"else size[2] + size[2] * txt.modifiers[\"Text+ Animate\"].bgPadding_V_val/100.0"
				bg.length.controller.script = scriptstring
			)
		)


		on params open do
		(
			$.GetPlaintextString &str
			local nChar = str.count - 0.1
			mult_spn.range = [0.1,nChar,mult_spn.value]
		)

		on startFrame_spn changed n do
		(
			--if (n > endFrame_spn.value) then (startFrame_spn.value = endFrame_spn.value - 1)
			endFrame_spn.value = n+duration_spn.value
			--duration_spn.value = endFrame_spn.value - startFrame_spn.value
		)
		
		on endFrame_spn changed n do
		(
			--if (n < startFrame_spn.value) then (endFrame_spn.value = startFrame_spn.value + 1)
			startFrame_spn.value = n-duration_spn.value 
			--duration_spn.value = endFrame_spn.value - startFrame_spn.value
		)
		
		on duration_spn changed n do
		(
			endFrame_spn.value = startFrame_spn.value + n
		)
		
		on clearAnimate_btn pressed do
		(
			charAnimate appendType:#none
		)
		
		on appendAnimate_btn pressed do
		(
			charAnimate appendType:#append
		)
		
		
		on clearAnimate_btn_old pressed do
		(		
			$.GetPlaintextString &str
			nChar = str.count
			
			if nChar != 0 then
			(
				try(
					for i=1 to $.charXScale.count do 
					(
						deleteKeys $.charXScale[i].controller #allkeys
						deleteKeys $.charYScale[i].controller #allkeys
					)
				)catch()



				duration = duration_spn.value
				mult = mult_spn.value
				durationPerCharOrig = duration/nChar
				durationPerCharOffset = ((nChar * mult * durationPerCharOrig) - duration)/(nChar - 1)
				durationPerChar = duration/nChar*mult

				print ("DPLOffset: " + durationPerCharOffset as string)
				print ("DPL: " + durationPerChar as string)
				print ("start f: " + startFrame_spn.value as string)


				for c=1 to nChar do
				(
					--$.SetCharBaseline c 0 -40
					$.SetCharXScale c startFrame_spn.value 0
					$.SetCharYScale c startFrame_spn.value 0
				)


				set animate on
				
				for c=1 to nChar do
				(
					if c==1 then 
					(
						--<boolean>SetCharXScale <index>index <time>time <float>value
						$.SetCharXScale c ((startFrame_spn.value)) this.startScale_spn
						$.SetCharYScale c ((startFrame_spn.value)) this.startScale_spn
						$.SetCharXScale c (durationPerChar*c+(startFrame_spn.value)) this.endScale_spn
						$.SetCharYScale c (durationPerChar*c+(startFrame_spn.value)) this.endScale_spn
					) 
					else 
					(
						$.SetCharXScale c ((c-1)*(durationPerChar - durationPerCharOffset)+(startFrame_spn.value)) this.startScale_spn
						$.SetCharYScale c ((c-1)*(durationPerChar - durationPerCharOffset)+(startFrame_spn.value)) this.startScale_spn
						$.SetCharXScale c ((c-1)*(durationPerChar - durationPerCharOffset)+durationPerChar+(startFrame_spn.value)) this.endScale_spn
						$.SetCharYScale c ((c-1)*(durationPerChar - durationPerCharOffset)+durationPerChar+(startFrame_spn.value)) this.endScale_spn
					)
					
					--delete the key that is automatically set at 0, this is assuming that there are max 2 keys per animation (start and end scale)
					if $.charXScale[c].controller.keys.count > 2 then
					(
						for i = $.charXScale[c].controller.keys.count to 1 by -1 do
						(
							if $.charXScale[c].controller.keys[i].time == 0f then
							(
								deleteItem $.charXScale[c].controller.keys i
								deleteItem $.charYScale[c].controller.keys i
							)
						)
					)
					
				)
				
				set animate off
			)
			else
			(
				MessageBox "The text object must have at least 1 character to animate."
			)
		)--on ani end




	)


	on attachedToNode this do
 	(
 		if this != undefined then
 		(
			if (classof this.baseobject == TextPlus) then
			(
				result = for i=1 to this.modifiers.count where (classof this.modifiers[i] == TextPlusAnimate) collect i
				
				if (result.count > 1) then 
				(
					local qb = QueryBox "There are more than one TextPlus Animator added to this object.\nOverwrite?\nYES - Delete old replace with new\nNO - Do not add the new modifier, leave as is."
					if qb == true then
					(
						for i = result.count to 2 by -1 do
						(
							print ("false - deleting " + i as string)
							deleteModifier this (result[i])
						)
					)
					else 
					(
						for i = result.count - 1 to 1 by -1 do
						(
							print ("true - deleting " + i as string)
							deleteModifier this (result[i])
						)
					)
				)

			)
			else
			(
				messageBox "This modifier only works on TextPlus object."
			)
		)
 	)


)