-------------------------------------------------------------------------------
-- OpenWithoutXrefs.mcr
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- June 24 2022
-- Open max files faster by disabling all xrefs
-------------------------------------------------------------------------------
macroScript OpenWithoutXrefs
category:"ilya_s Scripts"
tooltip:"OpenWithoutXrefs"
buttontext:"OpenWithoutXrefs"
(

	local maxFile = getOpenFileName caption:"Open max file" types:"3ds max Scene(*.max)|*.max" 
	
	if (maxFile != undefined) then
	(
		local f = (maxFile + "_OpenNoXrefs.max")
		local makeCopy = copyFile maxFile f
				
		if makeCopy == true then
		(
			local fileAssets = getMAXFileAssetMetadata f
			
			print ("---- Accessing file " + f)
			for i=1 to fileAssets.count do 
			(			
				if (doesfileexist fileAssets[i].filename == true) then
				(
					if (getFilenameType fileAssets[i].filename == ".max") then
					(
						print ("Removing Xref Path: " + fileAssets[i].filename)
						fileAssets[i].filename = fileAssets[i].filename + "-missing"
					)
				)
			)
			setMAXFileAssetMetadata f fileAssets
			loadMaxFile  f
		)
		else
		(
			messageBox ("Failed to make a copy of the file\n" + f as string +"\n\nEither the file is already existing or is open somewhere.")
		)
	)
)