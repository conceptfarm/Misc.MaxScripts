-------------------------------------------------------------------------------
-- modifierMeasure.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- June 6th 2020
-- Measures the distance between two points and inserts that measurement into 
-- a modifer
-- Supported modifiers: Extrude, Shell, Clone
-------------------------------------------------------------------------------
macroScript ModMeasure
category:"ilya_s Scripts"
internalcategory:"ilya_s Scripts"
tooltip:"Modifier Measure"
buttontext:"ModMeasure"
(
	fn checkPosNeg n =
	(
		result = 1
		if n < 0 then result = -1
		result	
	)
	
	fn pick2points = 
	(
		local result = undefined
		try
		(
			pp1= pickPoint prompt:"pick point 1" snap:#3D
			pp2= pickPoint prompt:"\npick point 2" snap:#3D  rubberBand:pp1
			result = #()
			result[1] = pp1
			result[2] = pp2
		)
		catch()
		result
	)

	currentMod = modPanel.getCurrentObject() 
	
	case (classof currentMod) of
	(
		Extrude:
		(
			rcmenu ComboRC 
			(
				menuitem extAmount "Extrude Amount (Pick 2 Points)"
				
				on extAmount picked do 
				(
					pp = pick2points()
					if pp != undefined then currentMod.amount = (checkPosNeg currentMod.amount)*(distance pp[1] pp[2])
				)
			)
			popupmenu ComboRC
		)
		
		Shell:
		(
			rcmenu ComboRC 
			(
				menuitem inner "Inner Amount (Pick 2 Points)"
				menuitem outer "Outer Amount (Pick 2 Points)" 
				
				on inner picked do 
				(
					pp = pick2points()
					if pp != undefined then currentMod.innerAmount = (distance pp[1] pp[2])
				)
				
				on outer picked do 
				(
					pp = pick2points()
					if pp != undefined then currentMod.outerAmount = (distance pp[1] pp[2])
				)
			)
			popupmenu ComboRC
		)
		
		clone:
		(	
			rcmenu ComboRC 
			(
				menuitem xDisp "X Displacment (Pick 2 Points)"
				menuitem yDisp "Y Displacment (Pick 2 Points)" 
				menuitem zDisp "Z Displacment (Pick 2 Points)" 
				menuitem xEvenDisp "X Even Distribution (Pick 2 Points)"
				menuitem yEvenDisp "Y Even Distribution (Pick 2 Points)" 
				menuitem zEvenDisp "Z Even Distribution (Pick 2 Points)" 
				
				on xDisp picked do 
				(
					pp = pick2points()
					if pp != undefined then currentMod.movex = (checkPosNeg currentMod.movex)*(distance pp[1] pp[2])
				)
				
				on yDisp picked do 
				(
					pp = pick2points()
					if pp != undefined then currentMod.movey = (checkPosNeg currentMod.movey)*(distance pp[1] pp[2])
				)
				
				on zDisp picked do 
				(
					pp = pick2points()
					if pp != undefined then currentMod.movez = (checkPosNeg currentMod.movez)*(distance pp[1] pp[2])
				)
				
				on xEvenDisp picked do 
				(
					pp = pick2points()
					if pp != undefined then
					(
						d = (distance pp[1] pp[2])/currentMod.clones
						currentMod.movex = (checkPosNeg currentMod.movex) * d
					)
				)
				
				on yEvenDisp picked do 
				(
					pp = pick2points()
					if pp != undefined then
					(
						d = (distance pp[1] pp[2])/currentMod.clones
						currentMod.movey = (checkPosNeg currentMod.movey) * d
					)
				)
				
				on zEvenDisp picked do 
				(
					pp = pick2points()
					if pp != undefined then
					(
						d = (distance pp[1] pp[2])/currentMod.clones
						currentMod.movez = (checkPosNeg currentMod.movez) * d
					)
				)
			)
			popupmenu ComboRC	
		)--end clone
	)--end case
)
