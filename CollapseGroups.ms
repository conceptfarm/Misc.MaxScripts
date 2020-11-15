-------------------------------------------------------------------------------
-- CollapseGroups
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Aug 30th 2020
-- Collapse selected groups to single mesh
-- keeping original transforms 
-------------------------------------------------------------------------------
macroScript CollapseGroups
Category: "ilya_s Scripts"
Tooltip: "Collapse Groups"
buttontext:"Collapse Groups"

(
	allobj = for o in selection where (isGroupHead o ==true) collect o
	clearSelection()

	for i=allobj.count to 1 by -1 do
	(
		local m = mesh vertices:#([0,0,0],[0,0,0],[0,0,0]) faces:#([1,2,3])
		deleteFace m 1
		update m
		m.transform = allobj[i].transform
		
		local _children = for o in allobj[i].children collect o
		explodeGroup allobj[i]
		
		for child in _children do
		(
			meshop.attach m child attachMat:#IDToMat condenseMat:true
		)
		update m
	)
)