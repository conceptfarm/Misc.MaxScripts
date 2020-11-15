macroScript FixRWTex
Category: "ilya_s Scripts"
Tooltip: "Fix realworld texture"
buttontext:"FixRWTex"
(
	tex = medit.GetCurMtl()
	if (classof tex == Bitmaptexture and tex.coords.realWorldScale == true) then
	(
		tex.coords.realWorldHeight = (tex.bitmap.height * tex.coords.realWorldWidth)/tex.bitmap.width
	)
)