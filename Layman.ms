
global vp
global vp_prev
global LayManDia
global preHideArray
global explorerPos_prev
global explorerSize_prev
--have to preload image instead of loading in the button itself, gets a wierd display error that way
global iconImg = openBitMap ("X:\\00-000_ScriptTest\\scripts\\LaymanIcons\\layIcons.bmp")

fn redrawviews_p = 
(
	explorerVisible = SceneExplorerManager.ExplorerIsOpen "Layer Explorer"
	explorerFloating = SceneExplorerManager.IsExplorerInViewport "Layer Explorer"
	explorerPos = SceneExplorerManager.GetExplorerPosition "Layer Explorer"
	explorerSize = SceneExplorerManager.GetExplorerSize "Layer Explorer"
	vp = explorerVisible
	if vp_prev != vp and vp == true then 
	(
		--print "opened"
		createdialog LayManDia style:#(#style_sysmenn) pos:[(explorerPos.x - 48) ,(explorerPos.y)] -- 7 for border
	)
	else if vp_prev != vp and vp == false then (print "closed"; DestroyDialog LayManDia)
	
	if (explorerVisible == true and (GetDialogSize LayManDia) != [0,0] and (explorerPos_prev != explorerPos or explorerSize_prev != explorerSize)) then
	(
		SetDialogPos LayManDia [(explorerPos.x - 48) ,(explorerPos.y)]
	)
	
	vp_prev = vp
	explorerPos_prev = explorerPos
	explorerSize_prev = explorerSize
	redrawViews() 
)


	
	--sceneExploreres = SceneExplorerManager.GetExplorerCount()
	--createdialog camChecklistRO style:#(#style_sysmenn) pos:[((GetDialogPos multiCam_floater).x) + 580,(GetDialogPos multiCam_floater).y + 0]F
	--SceneExplorerManager.ExplorerIsOpen
	
	
	fn purgeLay =
	(
		n = LayerManager.count

		for i = n-1 to 1 by -1 do
		(
			thisLayer = layermanager.getlayer i
			layername = thisLayer.name as string
			thisLayer.nodes &theNodes
		
			if (theNodes.count == 0) then 
			(
				layermanager.deleteLayerByName  layername
			)
		)
	)
	
	fn isoCurrentLay = 
	(
		currentLay = LayerManager.current
		n = LayerManager.count
		for i = 0 to n-1  do
		(
			thisLayer = (layermanager.getlayer i)
			if ((layerManager.getLayer i) != currentLay) then
			(
				layer = layerManager.getLayer i
				layer.on = false
			)
		)
	)
	
	fn isoSelected = 
	(
		selectedItems = (SceneExplorerManager.GetExplorer "Layer Explorer").SelectedItems()
		selectedLayers = #()
		n = LayerManager.count
		
		sceneStateMgr.Capture "tempPreIsolate" #{sceneStateMgr.MapPartToIndex "Layer Properties"}
		
		for o in selectedItems do
		(
			if classof o != Base_LayerBase_Layer then
			(		
				appendifunique selectedLayers o.layer.name
			)				
			else appendifunique selectedLayers o.name
		)
		
		for i = 0 to n-1  do
		(
			thisLayerName = (layermanager.getlayer i).name
			if ((findItem selectedLayers thisLayerName) != 0) then
			(
				layer = layerManager.getLayer i
				layer.on = true
			)
			else 
			(
				layer = layerManager.getLayer i
				layer.on = false
			)
		)
	)
	
	fn unIso =
	(
		if (sceneStateMgr.FindSceneState "tempPreIsolate" != 0) then 
		(
			sceneStateMgr.Restore "tempPreIsolate" #{sceneStateMgr.MapPartToIndex "Layer Properties"}
			sceneStateMgr.Delete "tempPreIsolate"
		)
	)
	
	fn hideLay = 
	(
		n = LayerManager.count
		for i = 0 to n-1  do
		(
			(layermanager.getlayer i).on = false
		)
	)
	
	fn freezeLay = 
	(
		n = LayerManager.count
		for i = 0 to n-1  do
		(
			(layermanager.getlayer i).lock = true
		)
	)
	
	fn unfreezeLay = 
	(
		n = LayerManager.count
		for i = 0 to n-1  do
		(
			(layermanager.getlayer i).lock = false
		)
	)
	
	fn renderAllLay = 
	(
		n = LayerManager.count
		for i = 0 to n-1  do
		(
			(layermanager.getlayer i).renderable = true
		)
	)
	
	fn renderNoneLay = 
	(
		n = LayerManager.count
		for i = 0 to n-1  do
		(
			(layermanager.getlayer i).renderable = false
		)
	)
	
	fn unhideLay = 
	(
		n = LayerManager.count
		for i = 0 to n-1  do
		(
			(layermanager.getlayer i).on = true
		)
	)
	
	fn prefixLayerWithFilename =
	(
		local qb = queryBox "Prefix this max file name to all/selected layer names?" 
		if qb then
		(
			local layerExplorer = SceneExplorerManager.GetActiveExplorer()
			local selectedItems = layerExplorer.SelectedItems()
			local prefix = (filterstring maxfilename ".")[1] + " - "
			if selectedItems.count != 0 then
			(
				for i in selectedItems where isKindOf i Base_Layer do
				if (i.name != "0" and i.name != "forest_templates") then
				(
					i.setname (prefix + i.name)
				)
			)
			else
			(
				local n = LayerManager.count
				
				for i = 0 to n-1  do
				(
					local thisLayer = (layermanager.getlayer i)
					if (thisLayer.name != "0" and thisLayer.name != "forest_templates") then
					(
						thisLayer.setname (prefix + thisLayer.name)
					)
				)
			)
		)
	)
	
	rollout LayManDia "LayMan v1.0" width:48 height:360
	(
		
		
		button HideLay_bn images:#(iconImg , undefined, 13,6,6,6,6) toolTip:"Hide All Layers" width:24 height:22
		button UnhideLay_bn images:#(iconImg , undefined, 13,1,1,1,1) toolTip:"Unhide All Layers"  width:24 height:22
		
		button FreezeLay_bn images:#(iconImg , undefined, 13,8,8,8,8) toolTip:"Freeze All Layers" width:24 height:22
		button UnfreezeLay_bn images:#(iconImg , undefined, 13,3,3,3,3) toolTip:"Unfreeze All Layers"  width:24 height:22
		
		button IsoSel_bn images:#(iconImg , undefined, 13,7,7,7,7) toolTip:"Isolate Selected Layers" width:24 height:22
		button UnIso_bn images:#(iconImg , undefined, 13,2,2,2,2) toolTip:"Unisolate Layers" width:24 height:22
		
		button renderAll_bn images:#(iconImg , undefined, 13,11,11,11,11) toolTip:"Renderable All Layers" width:24 height:22
		button renderNone_bn images:#(iconImg , undefined, 13,12,12,12,12) toolTip:"Unrenderable All Layers" width:24 height:22
		
		button addToLayer_bn images:#(iconImg , undefined, 13,13,13,13,13) toolTip:"Add Selected Objects to Selected Layer" width:24 height:22
		button PurgeLay_bn images:#(iconImg , undefined, 13,5,5,5,5) toolTip:"Clean Up Layers" width:24 height:22
		
		button prefixLay_bn "Rn" toolTip:"Prefix Layer with File Name" width:24 height:22
		
		
		on HideLay_bn pressed do
		(
			hideLay()
		)
		
		on UnhideLay_bn pressed do
		(
			unhideLay()
		)
		
		on FreezeLay_bn pressed do
		(
			freezeLay()
		)
		
		on UnfreezeLay_bn pressed do
		(
			unfreezeLay()
		)
		
		on IsoLay_bn pressed do
		(
			isoCurrentLay()
		)
		
		on IsoSel_bn pressed do
		(
			isoSelected()
		)
		
		on UnIso_bn pressed do
		(
			unIso()
		)
		
		on renderAll_bn pressed do
		(
			renderAllLay()
		)
		
		on renderNone_bn pressed do
		(
			renderNoneLay()
		)
		
		on addToLayer_bn pressed do 
		(
			local newLayer = LayerManager.current
			for n in (selection as array) do newLayer.addnode n
		)

		on PurgeLay_bn pressed do
		(
			purgeLay()
		)
		
		on prefixLay_bn pressed do
		(
			prefixLayerWithFilename()
		)
		
	)--end rollout
	
	
-- 	on execute do 
-- 	(
-- 		try( DestroyDialog LayManDia) catch ()
-- 		createDialog LayManDia
-- 	)--end on execute

registerRedrawViewsCallback redrawviews_p

--unregisterRedrawViewsCallback redrawviews_p