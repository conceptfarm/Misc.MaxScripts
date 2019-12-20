-------------------------------------------------------------------------------
-- CrapRemover.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Dec 16 2019
-- Removes crap from max file, optimize display of railclone and forest pro
-------------------------------------------------------------------------------
fn removeCrapCAs = 
(
	x = rootscene

	for i = (custAttributes.count x) to 1 by -1  do
	(
		print i
		z = custattributes.getdef x i
		print z.name
		if (z.name == #day1RefCA or z.name == #d1_filenotes) then (custAttributes.delete x z; print "deleted")	
	)
)

--Raytrace popup
fn removeRaytracePopup =
(
	local r_trace = RaytraceGlobalSettings()
	r_trace.enable_raytracing = False
	r_trace.showmessages = False
	r_trace.showProgressDlg = False
)

fn removeRefAlpha m =
(
	if (classof m == VRayMtl) then 
	(
		m.reflection_useInterpolation = false
		m.refraction_useInterpolation = false
		m.reflection_affectAlpha = 0
	)

	else if ( classof m == VRay2SidedMtl) then
	(
		removeRefAlpha (m.frontMtl)
		removeRefAlpha (m.backMtl)
	)

	else if (classof m == VRayBlendMtl) then
	(
		removeRefAlpha (m.baseMtl)
		Blendmtls = m.coatMtl
		for o in BlendMtls where o != undefined do (removeRefAlpha o)
	)

	else if (classof m == VRayMtlWrapper) then ( removeRefAlpha m.baseMtl )

	else if (classof m == VRayOverrideMtl) then
	(
		removeRefAlpha m.baseMtl
		removeRefAlpha m.giMtl
		removeRefAlpha m.reflectMtl
		removeRefAlpha m.refractMtl
		removeRefAlpha m.shadowMtl
	)

	else if (classof m == Multimaterial) then
	(
		for o in m.materialList do (removeRefAlpha o)		
	)
	
	else if (classof m == VRayBumpMtl) then (removeRefAlpha m.baseMtl)
)

fn purgeLayers =
(
	lay0 = layermanager.getlayer 0 --(Note: layer indecies begin at "0")
	lay0.current = true

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

fn setObjectDisplay = 
(
	for o in objects where (classof o == RailClone_Pro) do (o.vmesh = 1)
	for o in objects where (classof o == Forest_Pro) do (o.vmesh = 1; o.vtype = 0)
	for o in objects where (classof o == VRayProxy) do (o.display = 0)
)

fn main = 
(
	matLib = sceneMaterials
	
	--Remove affect alpha in reflection
	for j in matLib do removeRefAlpha j
	
	try
	(
		t=trackviewnodes
		n=t[#Max_MotionClip_Manager]
		deleteTrackViewController t n.controller
		gc()
	)catch( print "No Max Motion Clip Manager Found")
	
	try
	(
		t=trackviewnodes
		n=t[#Anim_Layer_Control_Manager]
		deleteTrackViewController t n.controller
		gc()
	)catch( print "No Anim Layer Control Manager Found")
		
	-- Net render button checked in old version of max
	renderSceneDialog.close()
	rendUseNet = false
	
	removeCrapCAs()
	purgeLayers()
	removeRaytracePopup()
	setObjectDisplay()
	
	--Exit Isolation Mode
	IsolateSelection.ExitIsolateSelectionMode()
	
	-- Delete Slate Material Editor Hidden Materials
	for i = sme.GetNumViews() to i =1 by -1 do
	(
		sme.DeleteView i false
	)
)
	
main()
