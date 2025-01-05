macroScript ConvertBitmapToVrayBitmap
category:"ilya_s Scripts"
internalcategory:"ilya_s Scripts"
tooltip:"ConvertBitmapToVrayBitmap"
buttontext:"ConvertBitmapToVrayBitmap"	
(
	with undo on
	(
		texMap = medit.GetCurMtl()

		if (classof texmap == Bitmaptexture) then 
		(
			tex = VRayBitmap()
			tex.HDRIMapName = texmap.bitmap.filename
			tex.mapType=4
			tex.UVGen.blur=texmap.coords.blur
			tex.UVGen.mapping=texmap.coords.mapping
			tex.UVGen.mapChannel=texmap.coords.mapChannel
			tex.UVGen.mappingType=texmap.coords.mappingType
			tex.UVGen.UVW_Type=texmap.coords.UVW_Type
			tex.UVGen.U_Mirror=texmap.coords.U_Mirror
			tex.UVGen.V_Mirror=texmap.coords.V_Mirror
			tex.UVGen.U_Tile=texmap.coords.U_Tile
			tex.UVGen.V_Tile=texmap.coords.V_Tile
			tex.UVGen.showMapOnBack=texmap.coords.showMapOnBack
			tex.UVGen.Noise_On=texmap.coords.Noise_On
			tex.UVGen.Noise_Animate=texmap.coords.Noise_Animate
			tex.UVGen.realWorldScale=texmap.coords.realWorldScale
			tex.UVGen.realWorldHeight=texmap.coords.realWorldHeight
			tex.UVGen.realWorldWidth=texmap.coords.realWorldWidth
			tex.UVGen.phase=texmap.coords.phase
			tex.UVGen.U_Angle=texmap.coords.U_Angle
			tex.UVGen.V_Angle=texmap.coords.V_Angle
			tex.UVGen.W_Angle=texmap.coords.W_Angle
			tex.UVGen.Noise_Amount=texmap.coords.Noise_Amount
			tex.UVGen.Noise_Size=texmap.coords.Noise_Size
			tex.UVGen.Noise_Levels=texmap.coords.Noise_Levels
			tex.UVGen.Blur_Offset=texmap.coords.Blur_Offset
			tex.UVGen.u_tiling=texmap.coords.u_tiling
			tex.UVGen.v_tiling=texmap.coords.v_tiling
			tex.UVGen.u_offset=texmap.coords.u_offset
			tex.UVGen.v_offset=texmap.coords.v_offset
			
			--Convert channel output
			tex.rgbOutput = texmap.rgbOutput
			tex.monoOutput = texmap.monoOutput
			tex.alphaSource = texmap.alphaSource
			
			--Convert crop/placement
			tex.cropplace_on = texmap.apply
			tex.cropplace_mode = texmap.cropPlace
			tex.cropplace_u = texmap.clipu
			tex.cropplace_v = texmap.clipv
			tex.cropplace_width = texmap.clipw
			tex.cropplace_height = texmap.cliph

			--Convert output parameters including curve control
			replaceInstances tex.output (copy texmap.output)
			
			replaceInstances texMap tex
			
			--Frees up all the memory used by the image file bitmap caches.
			--This is useful if memory is fragmented with a lot of different bitmaps and you want to have just the ones currently active reloaded.
			freescenebitmaps()

		)
		else
		(
			messageBox "Selected map is not a Bitmap texture"
		)
		
	)
)