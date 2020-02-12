-------------------------------------------------------------------------------
-- ProjectDuplicator.mcr
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Feb 11 2020
-- Copies the file and its dependencies to a specified location, repaths the
-- resulting file
-------------------------------------------------------------------------------
macroScript ProjectDuplicator
category:"ilya_s Scripts"
tooltip:"ProjDup"
buttontext:"ProjDup"
(
	global ProjectDupRollout
	global pathArray = #()
	global processedArray = #()
	
	--fileAssets = getMAXFileAssetMetadata (maxfilepath + maxfilename)
	--for o in fileassets do print o.filename
	
	
	fn collectImgFiles =
	(
		theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
		theDialog.title = "Select One Or More Files" --set the title
		theDialog.Multiselect = true --allow multiple files to be selected
		theDialog.Filter = "All Files (*.*)|*.*|MAX Files(*.max)|*.max"
		theDialog.FilterIndex = 2 --set the filter drop-down list to All Files
		result = theDialog.showDialog() --display the dialog, get result into variable
		result.ToString() --when closed, convert the result to string
		result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
		result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
		f = theDialog.fileNames --the selected filenames will be returned as an array
		return f
	)
	
	fn getProjectIndex infile = 
	(
		local result = undefined
		local fs = filterstring infile "\\"
		
		for i=1 to fs.count do
		(
			print fs[i]
			local str = try(execute ( substring fs[i] 1 6 ))catch("undefined")
			if (classof str == integer) then (result = i; exit with result)
		)
		result
	)
	
	fn getProjectPath infile = 
	(
		local index = getProjectIndex infile
		
		if index != undefined then
		(
			for i = 1 to (index - 1) do
			(
				infile = pathConfig.removePathTopParent inFile	
			)
			return infile
		)else ("undefined")
	)
		
	fn getPathSections infile = 
	(
		local result = #()
		local index = getProjectIndex infile
		local projectPath = infile
		
		if index != undefined then
		(
			local fs = filterstring infile "\\"
			local parentPath = ""
			
			for i = 1 to (index - 1) do
			(
				parentPath = parentPath + fs[i] + "\\"
				projectPath = pathConfig.removePathTopParent projectPath	
			)
			
			local projectName = fs[index] + "\\"
			local filePath = pathConfig.removePathTopParent projectPath
			
			result = #(parentPath, projectName, filePath)
			
		)else (result = "undefined")
	
		return result
	)

	fn replaceRoot infile outRoot projectName=
	(
		-- compare project names if the same leave as is
		-- if different take off project name of archived and add project name
		local thisProjectPath = getPathSections infile
		
		if thisProjectPath[2] == projectName then
		(
			return outRoot + "\\" + thisProjectPath[2] + thisProjectPath[3]
		)
		else if thisProjectPath[2] != projectName and thisProjectPath[2] != "undefined" then
		(
			return outRoot + "\\" + projectName + thisProjectPath[2] + thisProjectPath[3]		
		)
		else
		(return "undefined")
		
	)
	
	fn checkArchive inFile archivePath = 
	(
		local result = ""
		
		if (doesFileExist ("V:\\ProjectsArchive\\" + (getProjectPath inFile)) == true) then 
		(
			result = ("V:\\ProjectsArchive\\" + (getProjectPath inFile))
		)
		else if (doesFileExist (archivePath + (getProjectPath inFile)) == true) then 
		(
			result = (archivePath  + (getProjectPath inFile))		
		)
		else (result = "")
		
		return result
	)
	
	
	fn processMaxFile file newRootPath archivePath projectName= 
	(
		newPath = replaceRoot file newRootPath projectName
		print ("original root: " + file)
		print ("replaced root: " + newPath)

		if ( doesfileexist (getFilenamePath newPath) == false ) then (makeDir (getFilenamePath newPath))
		local c = copyFile file newPath
		if (c == true) then
		(
			fileAssets = getMAXFileAssetMetadata newPath
			
			print ("---- Accessing file " + newPath)
			for i=1 to fileAssets.count do 
			(
				--print fileAssets[i]
				local assetPath = fileAssets[i].filename
				if (assetPath[1] == "X") then
				(
					if (doesfileexist assetPath == false) then
					(
						if (checkArchive assetPath archivePath != "") then (assetPath = checkArchive assetPath archivePath)
					)
					
					if (doesfileexist assetPath == true) then
					(
						if (getFilenameType  assetPath == ".max") then
						(
							print ("Old Path : " + assetPath)
							processMaxFile assetPath newRootPath archivePath projectName
							newAssetPath = replaceRoot assetPath newRootPath projectName
							assetPath = newAssetPath
							fileAssets[i].Filename = newAssetPath
							
							print ("New Path : " + newAssetPath)
							setMAXFileAssetMetadata newPath fileAssets
						)
						else 
						(
							print ("Else Old Path : " + assetPath)
							newAssetPath = replaceRoot assetPath newRootPath projectName
							if ( doesfileexist (getFilenamePath newAssetPath) == false ) then (makeDir (getFilenamePath newAssetPath))
							copyFile assetPath newAssetPath
							assetPath = newAssetPath
							fileAssets[i].Filename = newAssetPath
							
							print ("Else New Path : " + newAssetPath)
							setMAXFileAssetMetadata newPath fileAssets
						)
					)
				)
			)
		)
		else print ("----Already processed----- " + file)
	)
	
	fn changePaths fileList newRootPath = 
	(
		if ((fileList != undefined) and (newRootPath != undefined)) then
		(
			for file in fileList do
			(
				--local archivePath = getParentPath file
				local fileSections = getPathSections file
				processMaxFile file newRootPath fileSections[1] fileSections[2]
			)
		)
		else (MessageBox "Error!")
	)
	
	
	rollout ProjectDupRollout "Project Duplicator v1.0" width:600 height:400
	(
		button findPath_bn "Select Max Files To Duplicate: "
		listbox scale_cb "Selected Files" items:pathArray
		editText rootPath "New Project Root: " width: 350 across:2 align:#left
		button getPath_bn "..." width: 30 align:#right
		button do_bn "Do" enabled: false
		label l1 "The script will also check these mapped drives:\nV:\\ - \\\\herschel\ProjectsBackup\n \nMap those drives to the specified letters to use this functionality" height: 200
		
		
		on getPath_bn pressed do
		(
			rp = getSavePath caption:"Select New Project Root" initialDir:"X:\\"
			if rp != undefined then
			(
				rootPath.text = rp
				do_bn.enabled = true
			)
		)
		
		
		on findPath_bn pressed do
		(
			pathArray = collectImgFiles()
			scale_cb.items = pathArray
		)
				
		on do_bn pressed do (changePaths pathArray rootPath.text)
	)

	on execute do 
	(
		try(destroyDialog ProjectDupRollout)catch()
		createDialog ProjectDupRollout
		
	)
	
)