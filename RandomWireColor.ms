macroScript RandomWireColor
category:"ilya_s Scripts"
tooltip:"RandomWireColor"
buttontext:"RandomWireColor"
(
allObj = for o in selection collect o
clearSelection()
for o in allObj do
(
	if InstanceMgr.GetInstances o &instances > 1 then
	(	
		InstanceMgr.GetInstances o &instances
		randomColour = (color (random 0 255) (random 0 255) (random 0 255) )
		for p in instances do 
		(
			p.wirecolor = randomColour
			deleteIndex = findItem allObj p
			if deleteIndex !=0 then deleteitem allObj deleteIndex
		)
	)
	else o.wirecolor = (color (random 0 255) (random 0 255) (random 0 255) )
)
)
