b = getClassInstances Blend 
for i = 1 to b.count do 
(
	setMeditMaterial i b[i]
	newBlend = VRayBlendMtl()
	newBlend.baseMtl = b[i].map1
	newBlend.coatmtl[1] = b[i].map2
	newBlend.texmap_blend[1] = b[i].mask
	newBlend.name = b[i].name
	setMeditMaterial (12+i) newBlend
	replaceInstances b[i] newBlend
)