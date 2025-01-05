fn clampViewPoint input upperBounds =
(
    [amax 0 (amin input.x upperBounds.x), amax 0 (amin input.y upperBounds.y), 0]

)

fn getAllBBoxPoints obj =
(
	local bb = obj.boundingbox
	local p1 = bb.max
	local p2 = bb.min
	
	#([p1.x, p1.y, p1.z],\
	[p1.x, p1.y, p2.z],\
	[p1.x, p2.y, p1.z],\
	[p1.x, p2.y, p2.z],\
	[p2.x, p2.y, p2.z],\
	[p2.x, p1.y, p2.z],\
	[p2.x, p2.y, p1.z],\
	[p2.x, p1.y, p1.z])
)

fn getScreenBBox obj =
(
	local bbPoints = getAllBBoxPoints obj
	

    if bbPoints.count > 0 do
    (
        gw.setTransform (Matrix3 1)
        local screenBBox = Box3()
        local viewSize = getViewSize()

        for p in bbPoints do
            expandToInclude screenBBox (gw.wTransPoint p)

        
        Box3 (clampViewPoint screenBBox.min viewSize) (clampViewPoint screenBBox.max viewSize)
    )
)

if selection.count == 1  do
(
    --min max points of a cropped image on the grabbed vp image
	local screenBBoxPos = getScreenBBox $

    --w and h of the cropped image
	local cropImgDims = screenBBoxPos.max - screenBBoxPos.min

	--vp grabbed image
    local viewGrab = gw.getViewportDib captureAlpha:on
   
	--empty bitmap with correct dimensions to be pasted into
	local croppedGrab = bitmap cropImgDims.x cropImgDims.y
    
	--pasteBitmap <src_bitmap> <dest_bitmap> <src_box2> <dest_point2>
    pasteBitmap viewGrab croppedGrab (Box2 screenBBoxPos.min screenBBoxPos.max) [0, 0] type:#paste
    display croppedGrab
)