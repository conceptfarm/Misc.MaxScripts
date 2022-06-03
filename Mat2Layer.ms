macroScript Material2Layer
category:"ilya_s Scripts"
tooltip:"Material2Layer"
buttontext:"Material2Layer"
(
	layers = #()
	obj = #()
	global layer
	for o in geometry where o.material != undefined do (append obj o)
	m = scenematerials
	c = m.count

	for i = 1 to c do 
	(
		layername = m[i].name
		print layername
		layer = layermanager.newLayerFromName layername
		print layer
		for o in obj where (o.material.name == m[i].name) do (layer.addnode o)
	)
)