-- Copies selected assets from the asset selector to the destination folder
macroScript CopyAssetsToProject
category:"ilya_s Scripts"
tooltip:"CopyAssetsToProject v1.0"
buttontext:"CopAss"
(
	global CopyAssetsRollout
	local copyOnly = false
	
	fn convertPathToMappedDrives infile =
	(
		local result = infile
		if matchPattern infile pattern:@"\\fs-01\projects*" then (result = replace infile 1 (@"\\fs-01\projects").count "X:")
		else if matchPattern infile pattern:@"\\fs-01\library*" then (result = replace infile 1 (@"\\fs-01\library").count "Y:")
		else if matchPattern infile pattern:@"\\fs-01\frames*" then (result = replace infile 1 (@"\\fs-01\frames").count "Z:")
		result	
	)
	
		/*
	Given a file path 
	Looks for a pattern NN-NNN where N are integers
	infile: string file path
	Returns the index of the path leaf that contains the project name
	*/
	fn getProjectIndex infile = 
	(
		local result = undefined
		local fs = filterstring infile "\\"
		
		for i=1 to fs.count do
		(
			local str = try(execute ( substring fs[i] 1 6 ))catch("undefined")
			if (classof str == integer) then (result = i; exit with result)
		)
		result
	)
	
	/*
	Given a file path 
	Removes everything before the Project Root Directory
	infile: string file path
	Returns modified path
		ie given    X:\Something\00-000_Project\Path\File.max
		ie return  00-000_Project\Path\File.max
	*/
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
		)
		else 
		(
			"undefined"
		)
	)
	
	/*
	Given a file path 
	Creates an array of everything before the Project Root Directory, Project Root Dir and everything after
	infile: string file path
	Returns a 3 part array of everything before the Project Root Directory, Project Root Dir and everything after with trailing slashes
		ie given    "X:\Something\00-000_Project\Path\File.max"
		ie return  #("X:\Something\", "00-000_Project\", "Path\File.max")
	*/	
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
			
		)else (result[2] = "undefined" )
	
		result
	)
	
	/*
	Given file path, new output root and project directory name
	compare project directory name and project directory name from infile
	if the same - leave as is
	if different - take off project name of infile and add project name
	
	infile: string file path of the archived file ie. "X:\Something\00-000_Project\Path\File.max"
	outRoot: string path of the root directory no trailing slash ie. "X:\00-000_NewRoot"
	projectName: string Project Root Dir ie. "00-000_Project\" with trailing slash
	
	Returns an array of  modified path string, 1 - prefered path, 2 - alternate path if file collision
	ie. given   "X:\Something\00-000_Project\Path\File.max"  "X:\00-000_NewRoot"   "00-000_Project\"
	ie. return #( ""X:\00-000_NewRoot\Path\File.max" , "X:\00-000_NewRoot\00-000_Project\Path\File.max")
	*/
	fn getRestoreFilePath infile outRoot =
	(

		local thisProjectPath = getPathSections infile
		
		if thisProjectPath[2] != "undefined" then
		(
			return #(outRoot + "\\" + thisProjectPath[3] , outRoot + "\\" + getFilenamePath thisProjectPath[3] + getFilenameFile  thisProjectPath[3] + (random 1 10000) as string + getFilenameType thisProjectPath[3] ) 
		)
		else (return "undefined")
	)
	
	fn checkArchive inFile archiveProjectRoot = 
	(
		local result = ""
		
		if (doesFileExist ("V:\\ProjectsArchive\\" + (getProjectPath inFile)) == true) then 
		(
			result = ("V:\\ProjectsArchive\\" + (getProjectPath inFile))
		)
		else if (doesFileExist (archiveProjectRoot + (getProjectPath inFile)) == true) then 
		(
			result = (archiveProjectRoot  + (getProjectPath inFile))		
		)
		else (result = "")
		
		return result
	)
	
	fn copyAssets restoreRootPath = 
	(
		
		local fList = #()
		ATSOps.GetSelectedFiles &fList
		ATSOps.ClearSelection() 
		
		for i = 1 to fList.count do
		(
			local mappedPath = convertPathToMappedDrives fList[i]
			local ext = getFilenameType mappedPath
			local filePath = getFilenamePath mappedPath
			
			if (not doesFileExist mappedPath) then
			(
				print "s"
				local fileSections = getPathSections mappedPath
				print "d"
				if (checkArchive mappedPath fileSections[1] != "") then 
				(
					mappedPath = checkArchive mappedPath fileSections[1]
					print archivedFilePath
				)
			)
			
			if (doesFileExist mappedPath) then
			(
				local restoreFilePath = getRestoreFilePath mappedPath restoreRootPath 

				print mappedPath
				print restoreFilePath[1]
				
				if ( doesfileexist (getFilenamePath restoreFilePath[1]) == false ) then 
				(
					makeDir (getFilenamePath restoreFilePath[1])
				)
				
				if (doesFileExist restoreFilePath[1] == false) then
				(
					local copyAsset = copyFile mappedPath restoreFilePath[1]
					if copyAsset then
					(
						ATSOps.selectfiles &fList[i]
						ATSOps.RetargetSelection restoreFilePath[1] CreateOutputFolder: false
					)
				)
				else
				(
					ATSOps.selectfiles &fList[i]
					ATSOps.RetargetSelection restoreFilePath[1] CreateOutputFolder: false
				)
			)
			else
			(

			)
		)
	)
	
	rollout CopyAssetsRollout "Copy Assets to Project v1.0" width:600 height:150
	(
		
			
		editText rootPath "Recover to Location: " text:@"X:\00-000_TestCopy" width: 540 across:2 align:#left offset:[0,5]
		button getPath_bn "..." width: 30 align:#right offset:[0,3]
		
		checkbox copyOnly_cb "Copy only, don't change paths"  checked:false
		checkbox log_cb "Verbose log (Slower Recover)"  checked:false
		
		button select_bn "Select Other Project Assets" offset:[0,5] --enabled: false
		button do_bn "Copy" offset:[0,5] --enabled: false
		
		--label l1 "The script will also check these mapped drives:\nV:\\ - \\\\herschel\ProjectsBackup\n \nMap those drives to the specified letters to use this functionality" height: 200
		
		
		on getPath_bn pressed do
		(
			rp = getSavePath caption:"Select New Project Root" initialDir:"X:\\"
			if rp != undefined then
			(
				rootPath.text = rp
				do_bn.enabled = true
			)
		)
		
		on copyOnly_cb changed state do
		(
			copyOnly = state
		)
		
		on log_cb changed state do
		(
			verboseLog = state
		)
		
		on select_bn pressed do 
		(
			if ATSOps.Visible == true then
			(
				local thisMaxFile = convertPathToMappedDrives (maxfilepath + maxFileName)
				local thisProjectIndex = getProjectIndex thisMaxFile
				
				if thisProjectIndex != undefined then
				(
					local thisProjectName = (FilterString thisMaxFile "\\")[thisProjectIndex]
				
					local fList = #()
					local fListSelect = #()
					ATSOps.Refresh()
					ATSOps.GetFiles &fList
					
					for i = 1 to fList.count do
					(
						local mappedPath = convertPathToMappedDrives fList[i]
						if mappedPath[1] == "X" or mappedPath[1] == "x" then
						(
							local mappedPathProjectIndex = getProjectIndex mappedPath
							local mappedPathProjectName = (FilterString mappedPath "\\")[mappedPathProjectIndex]
							if mappedPathProjectName != thisProjectName then
							(
								append fListSelect fList[i]
							)
						)
						
						
						
					)
					ATSOps.selectfiles fListSelect
				)
				else
				(
					messageBox "File is not saved in a project folder"
				)
			)
			else
			(
				messageBox "Open the Asset Track and select assets you want to copy"
			)
		)
		
		on do_bn pressed do 
		(
			if ATSOps.Visible == true then
			(
				local proceed = false
				if copyOnly == false then 
				(
					qb = queryBox "Proceed with COPYING and RE-PATHING?"
					if qb == true then proceed = true
				)
				else if copyOnly == true then 
				(
					qb = queryBox "Proceed with just COPYING?"
					if qb == true then proceed = true
				)
			
				if proceed == true then
				(
					--local logFilePath = rootPath.text + "\\ProjectDuplicatorLog_" + timeNow() + ".txt"
					--logFile = createFile logFilePath
					
					--local start = timeStamp()
					copyAssets rootPath.text
					--local end = timeStamp()
									
					--close logFile
					--logFile = undefined
					--gc()
				)
				messagebox ("Done.")
			)
			else
			(
				messageBox "Open the Asset Track and select assets you want to copy"
			)
		)
	)

	on execute do 
	(
		try(destroyDialog CopyAssetsRollout)catch()
		createDialog CopyAssetsRollout
		
	)
)