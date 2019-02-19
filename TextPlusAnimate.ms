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
	)

	fn zoomCurveVertical ctrl =
	(
		zoom ctrl #all
		ctrl.zoomValues.x = 130
		ctrl.scrollValues.x = 2
	)

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
			spinner startFrame_spn "Start Frame:" type:#integer range:[-1000000,59,0]
			spinner endFrame_spn   "  End Frame:" type:#integer range:[1,1000000,60]
			spinner duration_spn   "   Duration:" type:#integer range:[1,1000000,60]
			spinner mult_spn       "Ani. Offset:" type:#float range:[0.1,1000000,1.0]
		)

		group "Start/End Scale"
		(
			spinner startScale_spn "Start Scale:" type:#float range:[0,1000000,0.0]
			spinner endScale_spn   "  End Scale:" type:#float range:[0,1000000,1.0]

			curveControl ccScale numCurves:1 width:135 height:100 \
			x_range:[0, 1] y_range:[-1e3, 1e3] scrollValues:[2, 5] zoomValues:[135, 40] \
			rcmFlags:#(#move_xy, #move_x, #move_y, #corner, #bezier, #delete) \
			uiFlags:#(#constrainY, #noFilterButtons)
			button btnZoomScaleCurve "Zoom Ext." width:67 across:2 offset:[-5, 0]
		    button btnEditScaleCurve "Edit Curve..." width:68 offset:[5, 0]
			

			
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
			button animate_btn "Animate" width:buttonWidth	
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
			endFrame_spn.range = [(n+1),1000000,endFrame_spn.value]
			duration_spn.value = endFrame_spn.value - startFrame_spn.value
		)
		
		on endFrame_spn changed n do
		(
			--if (n < startFrame_spn.value) then (endFrame_spn.value = startFrame_spn.value + 1)
			startFrame_spn.range = [-1000000,(endFrame_spn.value-1),startFrame_spn.value]
			duration_spn.value = endFrame_spn.value - startFrame_spn.value
		)
		
		on duration_spn changed n do
		(
			endFrame_spn.value = startFrame_spn.value + n
		)


		on animate_btn pressed do
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
						--$.SetCharBaseline c (durationPerChar*(c-1)) -40
						--$.SetCharBaseline c (durationPerChar*c) 0
						$.SetCharXScale c ((startFrame_spn.value)) 0
						$.SetCharYScale c ((startFrame_spn.value)) 0
						$.SetCharXScale c (durationPerChar*c+(startFrame_spn.value)) 1
						$.SetCharYScale c (durationPerChar*c+(startFrame_spn.value)) 1
					) 
					else 
					(
						--$.SetCharBaseline c ((c-1)*(durationPerChar - durationPerCharOffset)) -40
						--$.SetCharBaseline c ((c-1)*(durationPerChar - durationPerCharOffset)+durationPerChar) 0
						$.SetCharXScale c ((c-1)*(durationPerChar - durationPerCharOffset)+(startFrame_spn.value)) 0
						$.SetCharYScale c ((c-1)*(durationPerChar - durationPerCharOffset)+(startFrame_spn.value)) 0
						$.SetCharXScale c ((c-1)*(durationPerChar - durationPerCharOffset)+durationPerChar+(startFrame_spn.value)) 1
						$.SetCharYScale c ((c-1)*(durationPerChar - durationPerCharOffset)+durationPerChar+(startFrame_spn.value)) 1
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
			if (classof this == TextPlus) then
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
