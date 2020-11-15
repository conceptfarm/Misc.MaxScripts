-------------------------------------------------------------------------------
-- FixRealWorldTexture.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- June 6th 2020
-- Fix real world proportions on a Bitmap map
-------------------------------------------------------------------------------
macroScript FixRWTex
Category: "ilya_s Scripts"
Tooltip: "Fix realworld texture"
buttontext:"FixRWTex"
(
	tex = medit.GetCurMtl()
	if (classof tex == Bitmaptexture) then
	(
		if (tex.coords.realWorldScale == true and tex.bitmap != undefined) then
		(
			rcmenu ComboRC 
			(
				menuitem fixH "Leave Width Fix Height"
				menuitem fixW "Leave Height Fix Width"
				
				on fixH picked do 
				(
					tex.coords.realWorldHeight = (tex.bitmap.height * tex.coords.realWorldWidth)/tex.bitmap.width
				)
				
				on fixW picked do 
				(
					tex.coords.realWorldWidth = (tex.bitmap.width * tex.coords.realWorldHeight)/tex.bitmap.height
				)
			)
			popupmenu ComboRC
		)
		else
		(
			MessageBox "Bitmap map has no file or is not a Real-World Scale."
		)
	)
	else
	(
		MessageBox "Texture map is not a bitmap."
	)
)