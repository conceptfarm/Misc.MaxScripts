macroScript ImagePlane
category:"ilya_s Scripts"
tooltip:"Image Plane Creator"
buttontext:"ImgPlane"
(

	global ImagePlane_RO
	local h_value, w_value
	
	fn convertMaxUtoDisplayU val =
	(
		(val/units.decodeValue "1")
	)
	
	fn convertDisplayUToMaxU val =
	(
		(val * (units.decodeValue "1"))
	)
	
	fn collectImgFiles =
	(
		theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
		theDialog.title = "Select One Or More Files" --set the title
		theDialog.Multiselect = true --allow multiple files to be selected
		--theDialog.Filter = "HTML Files (*.html)|*.html|All Files (*.*)|*.*" --specify the filter
		theDialog.Filter = "All Files (*.*)|*.*|Jpg(*.jpg,*.jpeg)|*.jpg;*.jpeg|PNG(*.png)|*.png|Tiff(*.tiff)|*.tiff|Tif(*.tif)|*.tif |Tga(*.tga)|*.tga"
		theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
		result = theDialog.showDialog() --display the dialog, get result into variable
		result.ToString() --when closed, convert the result to string
		result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
		result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
		return theDialog.fileNames --the selected filenames will be returned as an array
	)	
		

	fn createImagePlane =
	(
		-- = getOpenFileName types:"All|*.*|Jpg(*.jpg)|*.jpg|Jpeg(*.jpeg)|*.jpeg|PNG(*.png)|*.png|Tiff(*.tiff)|*.tiff|Tif(*.tif)|*.tif |Tga(*.tga)|*.tga|"
		local f = collectImgFiles()
		if f != undefined then --if the user did not cancel
		(
				for o in f do
				(
					local map = openbitmap o
					local planeSize= convertDisplayUToMaxU 1.6
					local ratio = (map.width * planeSize)/map.height
					local genplane = Plane realWorldMapSize:off length:planeSize width:ratio transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,planeSize/2]) isSelected:off
					genplane.lengthsegs = h_value
					genplane.widthsegs = w_value
					genplane.name = "ImagePlane__" + filenameFromPath o
					genplane.pivot = [genplane.pivot.x,genplane.pivot.y,0]

					
					local newmat = VrayMtl()
					newmat.name = "Image__" + filenameFromPath o
					
					local diff = bitmaptexture()
					diff.filename = o
					diff.alphasource = 2
					diff.coords.realWorldScale = false
				
					newmat.texmap_diffuse = diff
					
					genplane.material = newmat
					showTextureMap newmat newmat.texmap_diffuse on
				)
		) --end if
	) --end function


	fn createPictureFrame =
	(
		-- = getOpenFileName types:"All|*.*|Jpg(*.jpg)|*.jpg|Jpeg(*.jpeg)|*.jpeg|PNG(*.png)|*.png|Tiff(*.tiff)|*.tiff|Tif(*.tif)|*.tif |Tga(*.tga)|*.tga|"
		local f = collectImgFiles()
		if f != undefined then --if the user did not cancel
		(
				sm = sceneMaterials 
				smNames = for i=1 to sm.count collect sm[i].name
					
				for o in f do
				(
					local map = openbitmap o
					local planeSize= convertDisplayUToMaxU 1.6
					local ratio = (map.width * (convertDisplayUToMaxU 0.5))/map.height
					local genplane = Plane realWorldMapSize:off length:(convertDisplayUToMaxU 0.5) width:ratio transform:(matrix3 [1,0,0] [0,0,1] [0,1,0] [0,0,planeSize/2]) isSelected:off
					genplane.lengthsegs = h_value
					genplane.widthsegs = w_value
					genplane.name = "PictureFrame__" + filenameFromPath o + "_picture"
					--genplane.pivot = [genplane.pivot.x,genplane.pivot.y,0]


					local newmat = VrayMtl()
					newmat.name = "Image__" + filenameFromPath o
					
					local diff = bitmaptexture()
					diff.filename = o
					diff.alphasource = 2
					diff.coords.realWorldScale = false
				
					newmat.texmap_diffuse = diff
					
					genplane.material = newmat
					showTextureMap newmat newmat.texmap_diffuse on
					
					local glassMat = undefined
					local frameMat = undefined
					local paperMat = undefined
					
					if (finditem smNames "pF_Glass" == 0) then
					(
						glassMat = VrayMtl()
						glassMat.name = "pF_Glass"
						glassMat.Reflection = color 235 235 235
						glassMat.Refraction = color 225 225 225					
					)
					else
					(
						glassMat = sm[(finditem smNames "pF_Glass")]
					)
					
					if (finditem smNames "pF_Frame" == 0) then
					(
						frameMat = VrayMtl()
						frameMat.Diffuse = color 22 22 22
						frameMat.name = "pF_Frame"
						frameMat.Reflection = color 205 205 205
						frameMat.reflection_glossiness = 0.75
						frameMat.reflection_subdivs = 25
						frameMat.reflection_maxDepth = 2
					)
					else
					(
						frameMat = sm[(finditem smNames "pF_Frame")]
					)
					
					if (finditem smNames "pF_Paper" == 0) then
					(
						paperMat = VrayMtl()
						paperMat.Diffuse = color 242 242 242
						paperMat.name = "pF_Paper"
					)
					else
					(
						paperMat = sm[(finditem smNames "pF_Paper")]
					)
					
					
					
					local inSet = Rectangle length:genplane.length width:genplane.width cornerRadius:0 transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] (genplane.pos)) isSelected:on
					inSet.name = "PictureFrame__" + filenameFromPath o + "_inset"
					modPanel.addModToSelection (sweep ()) ui:on
					inSet.modifiers[#Sweep].CurrentBuiltInShape = 2
					inSet.modifiers[#Sweep][#Bar_Section].length = (convertDisplayUToMaxU 0.005)
					inSet.modifiers[#Sweep][#Bar_Section].width = genplane.width/4.0
					inSet.modifiers[#Sweep].PivotAlignment = 0
					inSet.modifiers[#Sweep].SmoothSection = off
					inSet.modifiers[#Sweep].SmoothPath = off
					inSet.modifiers[#Sweep].yOffset =  (convertDisplayUToMaxU -0.005)
					inSet.modifiers[#Sweep].angle = -2
					inSet.material = paperMat

					local frame = Rectangle length:(genplane.length+2*(inSet.modifiers[#Sweep][#Bar_Section].width)) width:(genplane.width+2*(inSet.modifiers[#Sweep][#Bar_Section].width)) cornerRadius:0 transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] inSet.pos) isSelected:on
					frame.name = "PictureFrame__" + filenameFromPath o + "_frame"
					modPanel.addModToSelection (sweep ()) ui:on
					frame.modifiers[#Sweep].CurrentBuiltInShape = 2
					frame.modifiers[#Sweep][#Bar_Section].width = (convertDisplayUToMaxU 0.01)
					frame.modifiers[#Sweep][#Bar_Section].length = (convertDisplayUToMaxU 0.04)
					frame.modifiers[#Sweep].yOffset = (convertDisplayUToMaxU 0.01168)
					frame.modifiers[#Sweep].angle = 0
					frame.material = frameMat
						
					
					local fGlass = Rectangle length:(genplane.length+2*(inSet.modifiers[#Sweep][#Bar_Section].width)) width:(genplane.width+2*(inSet.modifiers[#Sweep][#Bar_Section].width)) cornerRadius:0 transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] inSet.pos) isSelected:on
					fGlass.name = "PictureFrame__" + filenameFromPath o + "_glass"
					modPanel.addModToSelection (Extrude ()) ui:on
					fGlass.modifiers[#Extrude].amount = (convertDisplayUToMaxU 0.005)
					local back = copy fGlass
					back.name = "PictureFrame__" + filenameFromPath o + "_backing"
					fGlass.pos = fGlass.pos + [0, 0.7*(frame.modifiers[#Sweep][#Bar_Section].length) ,0]
					back.pos = genplane.pos - [0, 0.1*(frame.modifiers[#Sweep][#Bar_Section].length) ,0]
					fGlass.material = glassMat
					back.material = paperMat
						
					group #(fGlass, frame, inSet, genplane, back)	name:("PictureFrame_" + (filenameFromPath o))
				)
			
		) --end if
	) --end function

	
	fn createGalleryFrame =
	(
		-- = getOpenFileName types:"All|*.*|Jpg(*.jpg)|*.jpg|Jpeg(*.jpeg)|*.jpeg|PNG(*.png)|*.png|Tiff(*.tiff)|*.tiff|Tif(*.tif)|*.tif |Tga(*.tga)|*.tga|"
		local f = collectImgFiles()
		if f != undefined then --if the user did not cancel
		(
				sm = sceneMaterials 
				smNames = for i=1 to sm.count collect sm[i].name
					
				for o in f do
				(
					local map = openbitmap o
					local planeSize= convertDisplayUToMaxU 1.6
					local ratio = (map.width * (convertDisplayUToMaxU 0.5))/map.height
					local genplane = Plane realWorldMapSize:off length:(convertDisplayUToMaxU 0.5) width:ratio transform:(matrix3 [1,0,0] [0,0,1] [0,1,0] [0,0,planeSize/2]) isSelected:on
					genplane.lengthsegs = h_value
					genplane.widthsegs = w_value
					genplane.name = "GalleryFrame__" + filenameFromPath o + "_picture"
					modPanel.addModToSelection (shell ()) ui:on
					genplane.modifiers[#Shell].outerAmount = (convertDisplayUToMaxU 0.015)
					genplane.modifiers[#Shell].straightenCorners = on
					--genplane.pivot = [genplane.pivot.x,genplane.pivot.y,0]


					local newmat = VrayMtl()
					newmat.name = "Image__" + filenameFromPath o
					
					local diff = bitmaptexture()
					diff.filename = o
					diff.alphasource = 2
					diff.coords.realWorldScale = false
				
					newmat.texmap_diffuse = diff
					
					genplane.material = newmat
					showTextureMap newmat newmat.texmap_diffuse on
					
					local frameMat = undefined
					
					if (finditem smNames "pF_Frame" == 0) then
					(
						frameMat = VrayMtl()
						frameMat.Diffuse = color 22 22 22
						frameMat.name = "pF_Frame"
						frameMat.Reflection = color 205 205 205
						frameMat.reflection_glossiness = 0.75
						frameMat.reflection_subdivs = 25
						frameMat.reflection_maxDepth = 2
					)
					else
					(
						frameMat = sm[(finditem smNames "pF_Frame")]
					)
										
					local frame = Rectangle length:genplane.length width:genplane.width cornerRadius:0 transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] (genplane.pos)) isSelected:on
					frame.name = "PictureFrame__" + filenameFromPath o + "_inset"
					modPanel.addModToSelection (sweep ()) ui:on
					frame.modifiers[#Sweep].CurrentBuiltInShape = 1
					frame.modifiers[#Sweep][#Angle_Section].angle_length = (convertDisplayUToMaxU 0.01)
					frame.modifiers[#Sweep][#Angle_Section].angle_width = (convertDisplayUToMaxU 0.02)
					frame.modifiers[#Sweep][#Angle_Section].angle_thickness = (convertDisplayUToMaxU 0.004)
					frame.modifiers[#Sweep][#Angle_Section].angle_radius = 0
					frame.modifiers[#Sweep][#Angle_Section].angle_radius2 = 0
					frame.modifiers[#Sweep][#Angle_Section].angle_EdgeFillet = 0
					frame.modifiers[#Sweep].PivotAlignment = 0
					frame.modifiers[#Sweep].SmoothSection = off
					frame.modifiers[#Sweep].SmoothPath = off
					frame.modifiers[#Sweep].yOffset =  0
					frame.modifiers[#Sweep].angle = 90
					frame.material = frameMat
						
					group #(frame, genplane)	name:("GalleryFrame" + (filenameFromPath o))
				)
			
		) --end if
	) --end function
		

	fn createSIImagePlane =
	(
		local f = collectImgFiles()
		if f != undefined then --if the user did not cancel
		(
				for o in f do
				(	
					local map = openbitmap o
					local planeSize= convertDisplayUToMaxU 1.6
					local ratio = (map.width * planeSize)/map.height
					local genplane = Plane realWorldMapSize:off length:planeSize width:ratio transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,planeSize/2]) isSelected:off
					genplane.lengthsegs = h_value
					genplane.widthsegs = w_value
					genplane.name = "ImagePlane__" + filenameFromPath o
					genplane.pivot = [genplane.pivot.x,genplane.pivot.y,0]

					
					local newmat = VrayLightMtl()
					local shellMat = Shell_Material()
					local displayMat = Standardmaterial()
					newmat.name = "Image__" + filenameFromPath o
					shellMat.name = newmat.name + "_viewport"
					displayMat.name = newmat.name + "_display"
					
					local diff = bitmaptexture()
					diff.filename = o
					diff.alphasource = 2
					diff.coords.realWorldScale = false
					
					newmat.texmap = diff
					newmat.texmap_on = true
					newmat.compensate_exposure = true
					
					displayMat.diffuseMap = diff
					
					shellMat.originalMaterial = newmat
					shellMat.bakedMaterial = displayMat
					shellMat.viewportMtlIndex = 1
					shellMat.renderMtlIndex = 0
					
					genplane.material = shellMat
					showTextureMap displayMat on
				)
			
		) --end if
	) --end function

	fn createAlphaImagePlane rendType =
	(
		print rendType
		local f = collectImgFiles()
		if f != undefined then --if the user did not cancel
		(
				for o in f do
				(
					local map = openbitmap o
					local planeSize= convertDisplayUToMaxU 1.6
					local ratio = (map.width * planeSize)/map.height
					local genplane = Plane realWorldMapSize:off length:planeSize width:ratio transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,planeSize/2]) isSelected:off
					genplane.lengthsegs = h_value
					genplane.widthsegs = w_value
					genplane.name = "ImagePlane__" + filenameFromPath o
					genplane.pivot = [genplane.pivot.x,genplane.pivot.y,0]

					local diff = bitmaptexture()
					diff.filename = o
					diff.alphasource = 2
					diff.coords.realWorldScale = false
				
					local op = bitmaptexture()
					op.filename = o
					op.coords.realWorldScale = false
					op.coords.U_Tile = false
					op.coords.V_Tile = false
					op.rgbOutput = 1
					op.monoOutput = 1
					
					local newmat = VrayMtl()
					if rendType == "Vray" then
					(
						print "vray"
						newmat = VrayMtl()
						newmat.name = "Image__" + filenameFromPath o
						
						newmat.texmap_opacity = op
						newmat.texmap_diffuse = diff
						
						genplane.material = newmat
						showTextureMap newmat newmat.texmap_diffuse on
					)
					else
					(
						print "std"
						newmat = Standardmaterial()
						print (classof newmat)
						newmat.name = "Image__" + filenameFromPath o
						
						newmat.opacityMap = op
						newmat.diffuseMap = diff
						
						try(newMat.babylontransparencyMode = 2)catch("No Babylon Plugin Found")
						
						genplane.material = newmat
						showTextureMap newmat newmat.diffuseMap on
					)
					

				)--end for
		) --end if
	)--end function

	
	
	
	fn createMultiIDAnimation = 
	(
		local f = collectImgFiles()
		
		if f != undefined then --if the user did not cancel
		(
			local map = openbitmap f[1]
			local planeSize= convertDisplayUToMaxU 1.6
			local ratio = (map.width * planeSize)/map.height
			local genplane = Plane realWorldMapSize:off length:planeSize width:ratio transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,planeSize/2]) isSelected:off
			genplane.lengthsegs = h_value
			genplane.widthsegs = w_value
			genplane.name = "ImagePlane__" + filenameFromPath f[1]
			genplane.pivot = [genplane.pivot.x,genplane.pivot.y,0]
			
			local newmat = VrayMtl()
			newmat.name = "Image__" + filenameFromPath f[1]
			
			local texDiff = VRayMultiSubTex()
			local texOp = VRayMultiSubTex()
			
			texDiff.texmap_id  = #()
			texOp.texmap_id  = #()
			
			newmat.texmap_diffuse = texDiff
			newmat.texmap_opacity = texOp
					
			local idCount = #()
			
			for i = 1 to f.count do
			(
				texDiff.texmap_id = (append idCount i)
				texOp.texmap_id = idCount
				
				local diff = bitmaptexture()
				diff.filename = f[i]
				diff.alphasource = 2
				diff.coords.realWorldScale = false
				diff.coords.U_Tile = false
				diff.coords.V_Tile = false
				
				local op = bitmaptexture()
				op.filename = f[i]
				op.coords.realWorldScale = false
				op.coords.U_Tile = false
				op.coords.V_Tile = false
				op.rgbOutput = 1
				op.monoOutput = 1
				
				texDiff.texmap[i] = diff
				texDiff.texmap_on[i] = true
				texDiff.texmap_mapOn[i] = true
				texDiff.texmap_mult[i] = 100
				texDiff.texmap_color[i] =  color 0 0 0
				texOp.texmap[i] = op
				texOp.texmap_on[i] = true
				texOp.texmap_mapOn[i] = true
				texOp.texmap_mult[i] = 100
				texOp.texmap_color[i] =  color 0 0 0
				
			)
			
			genplane.material = newmat
			addModifier genplane (Materialmodifier ())
			animate on 
			(
				sliderTime = 0
				genplane.modifiers[1].materialID = 1
				sliderTime = (f.count  - 1 )
				genplane.modifiers[1].materialID = f.count
			)
			genplane.modifiers[1].materialID.controller = linear_float ()
			setBeforeORT genplane.modifiers[1].materialID.controller #cycle
			setAfterORT genplane.modifiers[1].materialID.controller #cycle
			
		)
		
		
	)


	fn createSilhImagePlane =
	(
		local f = collectImgFiles()
		if f != undefined then --if the user did not cancel
		(
			for o in f do
			(	
				local map = openbitmap o
				local planeSize= convertDisplayUToMaxU 1.6
				local ratio = (map.width * planeSize)/map.height
				local genplane = Plane realWorldMapSize:off length:planeSize width:ratio transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [0,0,planeSize/2]) isSelected:off
				genplane.lengthsegs = h_value
				genplane.widthsegs = w_value
				genplane.name = "ImagePlane__" + filenameFromPath o
				genplane.pivot = [genplane.pivot.x,genplane.pivot.y,0]

				
				local newmat = VrayMtl()
				newmat.name = "Image__" + filenameFromPath o
					
				local op = bitmaptexture()
				op.filename = o
				op.coords.realWorldScale = false
				op.coords.U_Tile = false
				op.coords.V_Tile = false
				--op.rgbOutput = 1
				--op.monoOutput = 1

				newmat.texmap_opacity = op
				
				genplane.material = newmat
				showTextureMap newmat newmat.texmap_opacity on
			)--end for
		) --end if
	)--end function


	rollout ImagePlane_RO "Create Image Plane" width:250 height:220
	(
		spinner w_spinner 		"W Segs"   range:[1,100,w_value] type:#integer across:2	
		spinner h_spinner 		"H Segs"   range:[1,100,h_value] type:#integer  	
		button create_btn 		"Simple Image Plane"  width:200 height:16 
		button create_a_btn 	"Image Plane w/ Alpha"  width:200 height:16 
		button create_a_std_btn "Image Plane w/ Alpha (Standard)"  width:200 height:16 
		button create_si_btn 	"Self Illum Image Plane"  width:200 height:16 
		button create_silh_btn 	"Silhouette Image Plane"  width:200 height:16 
		button create_AM_btn 	"Animated MultiTex Plane"  width:200 height:16 
		button create_PF_btn 	"Picture Frame"  width:200 height:16 
		button create_GF_btn 	"Gallery Frame"  width:200 height:16 


		on create_btn pressed do
		(
			createImagePlane()
		)
		
		on create_PF_btn pressed do
		(
			createPictureFrame()
		)
		
		on create_GF_btn pressed do
		(
			createGalleryFrame()
		)
		
		on create_a_btn pressed do
		(
			createAlphaImagePlane "Vray"
		)
		
		on create_a_std_btn pressed do
		(
			createAlphaImagePlane "Standard"
		)
		
		on create_si_btn pressed do
		(
			createSIImagePlane()
		)
		
		on create_silh_btn pressed do
		(
			createSilhImagePlane()
		)
		
		on create_AM_btn pressed do
		(
			createMultiIDAnimation()
		)
		
		on w_spinner changed n do
		(
			w_value = n
		)
		
		on h_spinner changed n do
		(
			h_value = n
		)
		
	) --end rollout
	
	on execute do 
	(
		if h_value == undefined then h_value = 1
		if w_value == undefined then w_value = 1
			
		try( DestroyDialog ImagePlane_RO) catch ()
		createDialog ImagePlane_RO

	)--end on execute
) --end script