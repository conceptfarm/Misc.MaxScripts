if ($ != undefined and superclassof $== camera ) then
(
	if (classof $ == Targetcamera) then
	(
		existingCam = $
		newCam = vrayphysicalcamera name: existingCam.name pos: existingCam.pos target: (targetObject name: existingCam.target.name pos: existingCam.target.pos)
		camAngle = cameraFOV.FOVtoMM existingCam.fov
		newCam.focal_length = camAngle
		delete existingCam
	)
	
	if (classof $ == Freecamera) then
	(
		existingCam = $
		newCam = vrayphysicalcamera name: existingCam.name pos: existingCam.pos 
		newCam.rotation = existingCam.rotation
		camAngle = cameraFOV.FOVtoMM existingCam.fov
		newCam.focal_length = camAngle
		delete existingCam
	)
)

else (messagebox "Select a standard camera")