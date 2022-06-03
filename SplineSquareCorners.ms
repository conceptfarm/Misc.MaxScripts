macroScript SplineSquareCorners
category:"ilya_s Scripts"
tooltip:"SplineSquareCorners"
buttontext:"SplineSquareCorners"
(
	fn GetVectorsAngle v1 v2 =
	(
		theAngle = acos(dot (normalize v1) (normalize v2))
	)

	on execute do 
	(	

		AllSplines = for o in selection where superclassof o == shape collect o


		for o in AllSplines do
		(
			s = copy o
			s.name = s.name + "_squared"
			s.wirecolor = (color 255 0 0)
			n = numknots s

			angleArray = #()

			for i =1 to n do
			(
				l = getSegLengths s 1
				j = ((mod i n)+1) as integer
				k = abs((mod (i-1) n) ) as integer
				if k ==0 then k = n
			
				p0 = getKnotPoint s 1 i -- position p0 the angle in question
				p1 = getKnotPoint s 1 k -- position before p0
				p2 = getKnotPoint s 1 j -- position after p0
				
				c = p1 - p0 -- before vector
				b = p2 - p0 -- after vector
			
				theta = GetVectorsAngle c b
				
				append angleArray theta
			)

			smallest = 360
			smallest_i = 0

			for i=1 to AngleArray.count do
			(
				angle_comp = abs(AngleArray[i] - 90)
				if angle_comp < smallest then 
				(
					smallest = angle_comp
					smallest_i = i
				)
			)

			setFirstKnot  s 1 smallest_i

			angleArray = #()

			for i = 1 to n do
			(
				l = getSegLengths s 1
				j = ((mod i n)+1) as integer
				k = abs((mod (i-1) n) ) as integer
				if k ==0 then k = n
				
				p0 = getKnotPoint s 1 i -- position p0 the angle in question
				p1 = getKnotPoint s 1 k -- position before p0
				p2 = getKnotPoint s 1 j -- position after p0
					
				c = p1 - p0 -- before vector
				b = p2 - p0 -- after vector
				
				theta = GetVectorsAngle c b
				
				append angleArray theta
				
			)
			
			angleArray = #()

			for i = 1 to n do
			(
				l = getSegLengths s 1
				j = ((mod i n)+1) as integer
				k = abs((mod (i-1) n) ) as integer
				if k ==0 then k = n
				
				p0 = getKnotPoint s 1 i -- position p0 the angle in question
				p1 = getKnotPoint s 1 k -- position before p0
				p2 = getKnotPoint s 1 j -- position after p0
					
				c = p1 - p0 -- before vector
				b = p2 - p0 -- after vector
				
				theta = GetVectorsAngle c b
				
				normal_dir = cross c b -- normal
				if normal_dir.z < 0 then -- if angle is concave
				(
					theta = 360 - theta -- angle is inverted - clockwise is 360 minus counter clockwise
				)
				append angleArray theta
			)

			angleArray

			for i = 1 to n-1 do
			(
				l = getSegLengths s 1
				j = ((mod i n)+1) as integer
				k = abs((mod (i-1) n) ) as integer
				if k ==0 then k = n
				
				a = l[i+n] -- length of after vector
				
				p0 = getKnotPoint s 1 i -- position p0 the angle in question
				p1 = getKnotPoint s 1 k -- position before p0
				p2 = getKnotPoint s 1 j -- position after p0
					
				c = p1 - p0 -- before vector
				b = p2 - p0 -- after vector
				
				
				m = 1
				if b.x < 0 then m = -1
				
				theta = GetVectorsAngle c b -- the original angle1
				delta = GetVectorsAngle [0, m*1 ,0] b --angle between original angle and the y axis	
				
				normal_dir = cross c b -- normal
				
				if normal_dir.z < 0 then -- if angle is concave
				(
					theta = 360 - theta -- angle is inverted - cw is 360 - ccw
				)
				
				
				if angleArray[i] > 120.0 and angleArray[i] < 150.0 then
				(
					gamma = theta - 135
				)
				
				else if angleArray[i] > 150.0 and angleArray[i] < 210 then
				(
					gamma = theta - 180
				)
				
				else if angleArray[i] > 210 and angleArray[i] < 240 then
				(
					gamma = theta - 225
				)
				
				-- need rules for 180 - 225 and 225 - 270
				
				else (gamma = theta - 90)
				

					
				projL = (cos gamma) * a
				
				final_dir = 90 - (delta + gamma)
				
				p = [0,0,0]
				p.x = ((cos final_dir) * projL) * m
				p.y = ((sin final_dir) * projL) * m
				
				final_location = p0 + p
				
				setKnotPoint s 1 j final_location
				updateShape s
			-- 	print ("a is " + a as string)
			-- 	print ("b is " + b as string)
			-- 	print ("c is " + c as string)
			-- 	print ("normal_dir is " + normal_dir as string)
			-- 	print ("i is " + i as string)
			-- 	print ( "j is " + j as string)
			-- 	print ("k is " + k as string)
			-- 	print ("cw is " + cw as string)
			-- 	print ("theta is " + theta as string)
			-- 	print ("gamma is " + gamma as string)
			-- 	print ("delta is " + delta as string)
			-- 	print ("projL is " + projL as string)
			-- 	print ("final_dir is " + final_dir as string)
			-- 	print ("final_location is " + final_location as string)
				
			)

		)
	)
)