macroScript FixRWTex
Category: "ilya_s Scripts"
Tooltip: "Fix realworld texture"
buttontext:"FixRWTex"
(
	local tex = undefined 
	if sme.IsOpen() then tex = sme.GetMtlInParamEditor() 
	else tex = medit.GetCurMtl()
	
	if (classof tex == Bitmaptexture or classof tex == VRayBitmap ) then
	(
		if (tex.coords.realWorldScale == true) then
		(
			rcmenu ComboRC 
			(
				menuitem fixH "Leave Width Fix Height"
				menuitem fixW "Leave Height Fix Width"
				
				on fixH picked do 
				(
					if (classof tex == Bitmaptexture) then
					(
						if tex.bitmap != undefined then
						(
							tex.coords.realWorldHeight = (tex.bitmap.height * tex.coords.realWorldWidth)/tex.bitmap.width
						)
						else
						(
							MessageBox "Bitmap map has no file"
						)
					)
					else if (classof tex == VRayBitmap) then
					(
						if doesFileExist tex.HDRIMapName then
						(
							local bm = openBitMap tex.HDRIMapName
							tex.coords.realWorldHeight = (bm.height * tex.coords.realWorldWidth)/bm.width
							close bm
							free bm
						)
						else
						(
							MessageBox "Bitmap map has no file"
						)
					)
					else if (classof tex == VRayUVWRandomizer) then
					(
						local bitmapRefs = for ref in refs.dependents tex where classof ref == vraybitmap collect ref
						if bitmapRefs.count > 1 then
						(
							if doesFileExist bitmapRefs[1].HDRIMapName then
							(
								local bm = openBitMap bitmapRefs[1].HDRIMapName
								tex.coords.coords.realWorldHeight = (bm.height * tex.coords.coords.realWorldWidth)/bm.width
								close bm
								free bm
							)
							else
							(
								MessageBox "Parent bitmap map has no file"
							)
						)
					)
					else
					(
						MessageBox "Texture map is not a bitmap."
					)
				)
				
				-- Leave Height Fix Width
				on fixW picked do 
				(
					
					if (classof tex == Bitmaptexture) then
					(
						if tex.bitmap != undefined then
						(
							tex.coords.realWorldWidth = (tex.bitmap.width * tex.coords.realWorldHeight)/tex.bitmap.height
						)
						else
						(
							MessageBox "Bitmap map has no file or is not a Real-World Scale."
						)
					)
					else if (classof tex == VRayBitmap) then
					(
						if doesFileExist tex.HDRIMapName then
						(
							local bm = openBitMap tex.HDRIMapName
							tex.coords.realWorldWidth = (bm.width * tex.coords.realWorldHeight)/bm.height
							close bm
							free bm
						)
						else
						(
							MessageBox "Bitmap map has no file"
						)
					)
					else if (classof tex == VRayUVWRandomizer) then
					(
						local bitmapRefs = for ref in refs.dependents tex where classof ref == vraybitmap collect ref
						if bitmapRefs.count > 1 then
						(
							if doesFileExist bitmapRefs[1].HDRIMapName then
							(
								local bm = openBitMap bitmapRefs[1].HDRIMapName
								tex.coords.coords.realWorldWidth = (bm.width * tex.coords.coords.realWorldHeight)/bm.height
								close bm
								free bm
							)
							else
							(
								MessageBox "Parent bitmap map has no file"
							)
						)
					)
					else
					(
						MessageBox "Texture map is not a bitmap."
					)
				)
			)
			popupmenu ComboRC
		)
		else if (tex.coords.realWorldScale == false) then
		(
			rcmenu ComboRC 
			(
				menuitem fixH "Leave Width Fix Height"
				menuitem fixW "Leave Height Fix Width"
				
				on fixH picked do 
				(
					if (classof tex == Bitmaptexture) then
					(
						if tex.bitmap != undefined then
						(
							tex.coords.v_tiling = (tex.coords.u_tiling/((tex.bitmap.height * tex.coords.u_tiling)/tex.bitmap.width)) * tex.coords.u_tiling
						)
						else
						(
							MessageBox "Bitmap map has no file"
						)
					)
					else if (classof tex == VRayBitmap) then
					(
						if doesFileExist tex.HDRIMapName then
						(
							local bm = openBitMap tex.HDRIMapName
							tex.coords.v_tiling = (tex.coords.u_tiling/((bm.height * tex.coords.u_tiling)/bm.width)) * tex.coords.u_tiling
							close bm
							free bm
						)
						else
						(
							MessageBox "Bitmap map has no file"
						)
					)
					else
					(
						MessageBox "Texture map is not a bitmap."
					)
				)
				
				on fixW picked do 
				(
					
					if (classof tex == Bitmaptexture) then
					(
						if tex.bitmap != undefined then
						(
							tex.coords.u_tiling = (tex.coords.v_tiling/((tex.bitmap.width * tex.coords.v_tiling)/tex.bitmap.height)) * tex.coords.v_tiling
						)
						else
						(
							MessageBox "Bitmap map has no file or is not a Real-World Scale."
						)
					)
					else if (classof tex == VRayBitmap) then
					(
						if doesFileExist tex.HDRIMapName then
						(
							local bm = openBitMap tex.HDRIMapName
							tex.coords.u_tiling = (tex.coords.v_tiling/((bm.width * tex.coords.v_tiling)/bm.height)) * tex.coords.v_tiling
							close bm
							free bm
						)
						else
						(
							MessageBox "Bitmap map has no file"
						)
					)
					else
					(
						MessageBox "Texture map is not a bitmap."
					)
				)
			)
			popupmenu ComboRC
		)

	)
	else if (classof tex == VRayUVWRandomizer) then
	(
		print tex
		if (tex.coords.coords.realWorldScale == true) then
		(
			rcmenu ComboRC 
			(
				menuitem fixH "Leave Width Fix Height"
				menuitem fixW "Leave Height Fix Width"
				
				on fixH picked do 
				(
					local bitmapRefs = for ref in refs.dependents tex where classof ref == vraybitmap collect ref
					if bitmapRefs.count > 0 then
					(
						if doesFileExist bitmapRefs[1].HDRIMapName then
						(
							local bm = openBitMap bitmapRefs[1].HDRIMapName
							tex.coords.coords.realWorldHeight = (bm.height * tex.coords.coords.realWorldWidth)/bm.width
							close bm
							free bm
						)
						else
						(
							MessageBox "Parent bitmap map has no file"
						)
					)
				)
				
				on fixW picked do 
				(
					local bitmapRefs = for ref in refs.dependents tex where classof ref == vraybitmap collect ref
					if bitmapRefs.count > 0 then
					(
						if doesFileExist bitmapRefs[1].HDRIMapName then
						(
							local bm = openBitMap bitmapRefs[1].HDRIMapName
							tex.coords.coords.realWorldWidth = (bm.width * tex.coords.coords.realWorldHeight)/bm.height
							close bm
							free bm
						)
						else
						(
							MessageBox "Parent bitmap map has no file"
						)
					)
				)
			)
			popupmenu ComboRC
		)
		else if (tex.coords.coords.realWorldScale == false) then
		(
			rcmenu ComboRC 
			(
				menuitem fixH "Leave Width Fix Height"
				menuitem fixW "Leave Height Fix Width"
				
				on fixH picked do 
				(
					local bitmapRefs = for ref in refs.dependents tex where classof ref == vraybitmap collect ref
					if bitmapRefs.count > 0 then
					(
						if doesFileExist bitmapRefs[1].HDRIMapName then
						(
							local bm = openBitMap bitmapRefs[1].HDRIMapName
							tex.coords.coords.v_tiling = (tex.coords.coords.u_tiling/((bm.height * tex.coords.coords.u_tiling)/bm.width)) * tex.coords.coords.u_tiling
							close bm
							free bm
						)
						else
						(
							MessageBox "Parent bitmap map has no file"
						)
					)
				)
				
				on fixW picked do 
				(
					local bitmapRefs = for ref in refs.dependents tex where classof ref == vraybitmap collect ref
					if bitmapRefs.count > 0 then
					(
						if doesFileExist bitmapRefs[1].HDRIMapName then
						(
							local bm = openBitMap bitmapRefs[1].HDRIMapName
							tex.coords.coords.u_tiling = (bm.width * tex.coords.coords.v_tiling)/bm.height
							close bm
							free bm
						)
						else
						(
							MessageBox "Parent bitmap map has no file"
						)
					)
				)
			)
			popupmenu ComboRC
		)
	)
)