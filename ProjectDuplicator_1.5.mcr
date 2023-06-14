macroScript ProjectDup
category:"ilya_s Scripts"
tooltip:"ProjDup v1.5"
buttontext:"ProjDup v1.5"
(
	global ProjectDupRollout
	--global pathArray = #()
	global pathArray = #(@"V:\ProjectsArchive\21-1880_CavtatMarinaDevelopment\01_Models\05_Stills\360s\VR_Day.max")
	global processedArray = #()
	local copyOnly = false
	local copiedAssetFilesList = #() --keeps track of original source and copied source file paths
	local nCopiedFiles = 0
	local nExistingFiles = 0
	local nSkippedFiles = 0
	local nMissingFiles = 0
	local nCreatedDirs = 0
	local nErrorFileCopies = 0
	local nBytesCopied = 0
	local nMaxNesting = 0
	local logFile = undefined
	local verboseLog = false
	
	
	--fileAssets = getMAXFileAssetMetadata (maxfilepath + maxfilename)
	--for o in fileassets do print o.filename
	
	fn padNumber nr padLen = (local n = (nr as string)	for x = 1 to (padLen - n.count) do n = "0" + n 	return n)	
	
	fn timeNow =
	(	
		local result = ""
		local timenow = getlocaltime()
		result = timenow[1] as string + "-" + (padnumber timenow[2] 2) as string + "-" + (padnumber timenow[4] 2) as string + "_" + (padnumber timenow[5] 2) as string + "_" + (padnumber timenow[6] 2) as string + "_" + (padnumber timenow[7] 2) as string
		result
	)
	
	fn multString str n = 
	(
		local result = ""
		for i = 1 to (abs n) do ( result = result + str)
		result
	)
	
	/*
	Generates a hash given hash method and file path
	sourcefile: string file path
	hashmethod: string "MD5" or "SHA1"
	returns hash string
	*/
	fn getFileHash HashMethod SourceFile =
	(
		case tolower(HashMethod) of
		(
			"sha1" : hMethod = dotNetObject "System.Security.Cryptography.SHA1CryptoServiceProvider"
			default : hMethod = dotNetObject "System.Security.Cryptography.MD5CryptoServiceProvider"
		)
		f = dotNetObject "System.IO.FileStream" SourceFile (dotNetClass "System.IO.FileMode").Open (dotNetClass "System.IO.FileAccess").Read (dotNetClass "System.IO.FileShare").Read 8192
		hMethod.ComputeHash f
		hash = hMethod.Hash
		f.Close()
		buff = dotnetObject "System.Text.StringBuilder"
		byte = dotNetClass "System.Byte"
		SysString = dotNetClass "System.String"
		for hashByte in hash do
		(
			buff.Append (SysString.Format "{0:X2}" hashByte)
		)
		buff.ToString()
	)
	
	/*
	Compares two files using a MD5 hash
	fileA fileB: string file path
	returns true | false | undefined if one of the files is not found
	*/
	fn compareFileHash fileA fileB = 
	(
		local result = undefined
		if (doesFileExist (fileA as string) and doesFileExist (fileB as string)) then
		(
			local hashMethod = "MD5"  --"MD5" or "SHA1"
			local md5FileA=getFileHash hashMethod fileA
			local md5FileB=getFileHash hashMethod fileB
			
			if md5FileA == md5FileB then result = true
			else result = false
		)
		result
	)
	
	
	fn getOriginalFilePath copiedFilePath copiedAssetFilesList =
	(
		-- #(archivedFilePath, restoreFilePath)
		local result = undefined
		for o in copiedAssetFilesList do
		(
			if o[2] == copiedFilePath then 
			(
				result = o[1]
				--print("Found asset " + copiedFilePath + " in copiedAssetFilesList")
				exit with result
			)
		)
		if result == undefined then 
		(	
			print("Can't find asset " + copiedFilePath + " in copiedAssetFilesList")
			for o in copiedAssetFilesList do print(o)
		)
		result
	)
	
	fn checkAssetProcessed archivedAssetPath copiedAssetFilesList =
	(
		-- #(archivedFilePath, restoreFilePath)
		local result = undefined
		for o in copiedAssetFilesList do
		(
			if o[1] == archivedAssetPath then 
			(
				result = o[2]
				if verboseLog then
				(
					local str = "Asset " + archivedAssetPath + " is already processed\n"
					--print("Asset " + archivedAssetPath + " is already processed")
					format "%"  (str) to: logFile
				)
				exit with result
			)
		)
		result
	)
	
	/*
	Opens dialog for selection of max files
	Returns an array of max file paths
	*/
	fn collectMaxFiles =
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
	
	/*
	Collects all max files given a root directory
	root: string root path
	pattern: string file name pattern with extension to look for
	recursive: boolean do recursive or not
	ignore: boolean ignore backup folder
	Returns an array of max file paths
	*/
	fn getFilesRecursive root pattern recursive ignore =
	(
		if root[root.count] == "\\" then root = substring root 1 (root.count-1)
		
		local dir_array = #()
		
		if recursive then
		(
			dir_array = GetDirectories (root+"/*")
			for d in dir_array do
			(
				join dir_array (GetDirectories (d+"/*"))
			)
		)
		else 
		(
			dir_array = #(root+"/")
		)
		
		local my_files = #()
		for f in dir_array do
		(
			if (matchpattern f pattern:"*backup*" == false or ignore == false ) then
			(
				join my_files (getFiles (f + pattern))
			)
		)
		my_files
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
			
		)else (result = "undefined")
	
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
		--print thisProjectPath
		
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
	
	fn convertPathToMappedDrives infile =
	(
		local result = infile
		if matchPattern infile pattern:@"\\fs-01\projects*" then (result = replace infile 1 (@"\\fs-01\projects").count "X:")
		else if matchPattern infile pattern:@"\\fs-01\library*" then (result = replace infile 1 (@"\\fs-01\library").count "Y:")
		else if matchPattern infile pattern:@"\\fs-01\frames*" then (result = replace infile 1 (@"\\fs-01\frames").count "Z:")
		result	
	)
	
	fn processAssetFile archivedFilePath restoreRootPath archivedProjectRoot nestIndex initialRun:false = 
	(
		local doCopySource = false
		local doCopyDestination = false
		local result = undefined
		local indent = multString "\t" nestIndex
		
		if nestIndex > nMaxNesting then nMaxNesting = nestIndex
		
		local mappedPath = convertPathToMappedDrives archivedFilePath
		if mappedPath != archivedFilePath then 
		(
			if verboseLog then
			(
				local str = indent + "Converting to mappaed drive path: " +archivedFilePath + " -> " + mappedPath + "\n"
				--print (indent + "Converting to mappaed drive path: " + archivedFilePath + " -> " + mappedPath)
				format "%"  (str) to: logFile
			)
			result = mappedPath
			archivedFilePath = mappedPath
		)
		
		-- check here if the archivedFilePath is already there
		-- initial run are the selected files in the script dialog, so we know they already exist
		if ((not doesFileExist archivedFilePath) or (initialRun == true)) then
		(
			local restoreFilePath = getRestoreFilePath archivedFilePath restoreRootPath 
			if verboseLog then
			(			
				local str = indent + "Original path: " + archivedFilePath + "\n"
				--print (indent + "Original path: " + archivedFilePath)
				format "%"  (str) to: logFile
				str = indent + "Restore path: " + restoreFilePath[1] + "\n"
				--print (indent + "Restore path: " + restoreFilePath[1])
				format "%"  (str) to: logFile
			)
			
			-- Source Path
			if (doesfileexist archivedFilePath == false) then
			(
				if (checkArchive archivedFilePath archivedProjectRoot != "") then 
				(
					archivedFilePath = checkArchive archivedFilePath archivedProjectRoot
					if verboseLog then
					(
						local str = indent + "Archived path: " + archivedFilePath + "\n"
						--print (indent + "Archived path: " + archivedFilePath)
						format "%"  (str) to: logFile
					)
				)
			)
			
			if (doesfileexist archivedFilePath == true) then
			(
				doCopySource = true
			)
			else
			(
				if verboseLog then
				(
					local str = indent + "ERROR: Archived path don't exist: " + archivedFilePath + "\n"
					--print (indent + "ERROR: Archived path don't exist: " + archivedFilePath)
					format "%"  (str) to: logFile
				)
				nMissingFiles = nMissingFiles + 1
				doCopySource = false
			)
			
			local checkProcessed = checkAssetProcessed archivedFilePath copiedAssetFilesList
			
			if (checkProcessed != undefined) then
			(
				doCopySource = false
				doCopyDestination = false
				result = checkProcessed
				
				if verboseLog then
				(
					local str = indent + "Already restored, skipping: " + archivedFilePath + "\n"
					--print (indent + "Already restored, skipping: " + archivedFilePath)
					format "%"  (str) to: logFile
				)
			)
			
			if doCopySource then 
			(
				-- Destination Path
				if ( doesfileexist (getFilenamePath restoreFilePath[1]) == false ) then 
				(
					makeDir (getFilenamePath restoreFilePath[1])
					nCreatedDirs = nCreatedDirs + 1
				)
				
				if doesFileExist restoreFilePath[1] then
				(
					local originalFile = getOriginalFilePath restoreFilePath[1] copiedAssetFilesList
					-- file is already there but was not copied during this session
					-- could manually copied or copied by a previous run for prject dup
					if originalFile == undefined then
					(
						originalFile = restoreFilePath[1]
					)
					
					local hashCompare = compareFileHash archivedFilePath originalFile
					
					if not hashCompare then 
					(
						restoreFilePath = restoreFilePath[2]
						doCopyDestination = true
						if verboseLog then
						(
							local str = indent + "Restore path (same name): " + restoreFilePath + "\n"
							--print (indent + "Restore path (same name): " + restoreFilePath)
							format "%"  (str) to: logFile
						)
					)
					else 
					(
						restoreFilePath = restoreFilePath[1]
						nSkippedFiles = nSkippedFiles + 1
						doCopyDestination = false
						if verboseLog then
						(
							local str = indent + "Already restored, skipping: " + restoreFilePath + "\n"
							--print (indent + "Already restored, skipping: " + restoreFilePath)
							format "%"  (str) to: logFile
						)
					)
				)
				else 
				(
					restoreFilePath = restoreFilePath[1];
					doCopyDestination = true
				)
			)
									
			if doCopySource and doCopyDestination then
			(
				local copyAsset = copyFile archivedFilePath restoreFilePath
				
				if (copyAsset == true) then
				(
					nCopiedFiles = nCopiedFiles + 1
					nBytesCopied = nBytesCopied + (getFileSize restoreFilePath)
					append copiedAssetFilesList #(archivedFilePath, restoreFilePath)
					
					-- the copied asset is max file
					if (getFilenameType restoreFilePath == ".max") then
					(
						local fileAssets = getMAXFileAssetMetadata restoreFilePath
						
						if verboseLog then
						(
							local str = "\n" + indent + "---- Accessing file " + restoreFilePath + "\n"
							--print ("\n" + indent + "---- Accessing file " + restoreFilePath)
							format "%"  (str) to: logFile
						)
						
						for i=1 to fileAssets.count do 
						(
							local archivedAssetPath = fileAssets[i].filename
							
							local newAssetPath = processAssetFile archivedAssetPath restoreRootPath archivedProjectRoot (nestIndex + 1)
							
							if verboseLog then
							(													
								local str = indent + "Pre metadata assignment: -newAssetPath: " + (newAssetPath) as string + " -restoreFilePath: " + restoreFilePath + "\n"
								format "%"  (str) to: logFile
							)
							
							if copyOnly == false and newAssetPath != undefined then
							(
								fileAssets[i].Filename = newAssetPath
								if verboseLog then
								(
									local str = indent + "New Asset Path : " + newAssetPath+"\n"
									--print (indent + "New Asset Path : " + newAssetPath)
									format "%"  (str) to: logFile
								)
							)
						)
						setMAXFileAssetMetadata restoreFilePath fileAssets
						result = restoreFilePath
					)
					else
					(
						-- the copied asset is non-max file
						--print ("Old Asset : " + archivedFilePath)
						--format ("Old Asset Path : " + archivedFilePath +"\n") to: logFile
						result = restoreFilePath
					)
				)
				else 
				(
					if verboseLog then
					(
						local str =indent + "ERROR: Asset " + archivedFilePath + " failed to copy to " + restoreFilePath + "\n"
						--print(indent + "ERROR: Asset " + archivedFilePath + " failed to copy.")
						format "%"  (str) to: logFile
					)
					nErrorFileCopies = nErrorFileCopies + 1
				)
			)
			else
			(
				if verboseLog then
				(
					local str = indent + "ERROR: Asset " + archivedFilePath + " is missing or already processed, skipping copy.\n"
					--print(str)
					format "%"  (str) to: logFile
				)
			)
		)
		else
		(
			if verboseLog then
			(
				local str = indent + "Asset " + archivedFilePath + "  already exists, skipping copy.\n"
				--print(str)
				format "%"  (str) to:logFile
			)
			nExistingFiles = nExistingFiles + 1
		)
		windows.processPostedMessages()
		result
	)
	
	fn changePaths fileList restoreRootPath = 
	(
		if ((fileList != undefined) and (restoreRootPath != undefined)) then
		(
			for file in fileList do
			(
				--local archivedProjectRoot = getParentPath file
				local fileSections = getPathSections file
				local nestIndex = 0
				processAssetFile file restoreRootPath fileSections[1] nestIndex initialRun:true
			)
		)
		else (MessageBox "Error!")
	)
	
	
	rollout ProjectDupRollout "Project Duplicator v1.5" width:600 height:400
	(
		button findPath_bn "Select Max Files To Recover" across: 2
		button getFileFromRoot_bn "Get All .max Files from Folder"
		checkbox getRec_cb "Get Recursive"  checked:true offset:[getFileFromRoot_bn.pos.x,0]
		checkbox ignoreBackup_cb "Ignore _backup folders"  checked:true offset:[getFileFromRoot_bn.pos.x,0]
		listbox scale_cb "Max Files to Recover:" items:pathArray
		checkbox copyOnly_cb "Copy only, don't change paths"  checked:false
		
		editText rootArchivePath "Project Archive Location: " text:"V:\\ProjectsArchive\\" width: 540 across:2 align:#left enabled: false offset:[0,5]
		button getArchivePath_bn "..." width: 30 align:#right offset:[0,3] enabled: false
		
		editText rootPath "Recover to Location: " text:@"X:\00-000_TestCopy" width: 540 across:2 align:#left offset:[0,5]
		button getPath_bn "..." width: 30 align:#right offset:[0,3]
		
		checkbox log_cb "Verbose log (Slower Recover)"  checked:false
		
		button do_bn "Recover" offset:[0,5] --enabled: false
		
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
		
		on findPath_bn pressed do
		(
			pathArray = collectMaxFiles()
			scale_cb.items = pathArray
		)
		
		on getFileFromRoot_bn pressed do
		(
			local rootPath = getSavePath caption:"Select New Project Root" initialDir:"X:\\"
			if rp != undefined then
			(
				pathArray = getFilesRecursive rootPath "*.max" getRec_cb.checked ignoreBackup_cb.checked
				scale_cb.items = pathArray
			)
		)
				
		on do_bn pressed do 
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
					
			if not doesDirectoryExist rootPath.text  then
			(
				local md = makeDir rootPath.text 
				if not md then 
				(
					proceed = false
					messageBox ("Failed to create directory.\n" + rootPath.text)
				)
			)
			
			if proceed == true then
			(
				local logFilePath = rootPath.text + "\\ProjectDuplicatorLog_" + timeNow() + ".txt"
				logFile = createFile logFilePath
				
				local iniFile =  rootPath.text + "\\CopiedAssetFilesList.ini"
				if doesFileExist iniFile then
				(
					local data = getINISetting iniFile "Files" 

					for d in data do
					(
						append copiedAssetFilesList #(d, (getINISetting iniFile "Files" d))
					)
				)
				
				
				local start = timeStamp()
				changePaths pathArray rootPath.text
				local end = timeStamp()
				
				format ("\n------------------------------------------------------------------------------------\n\n") to: logFile 
				format ("Files Copied: " + (nCopiedFiles as string) + "\n") to: logFile 
				format ("Files Skipped (Duplicate): " + (nSkippedFiles as string) + "\n") to: logFile 
				format ("Files Skipped (Existing): " + (nExistingFiles as string) + "\n") to: logFile 
				format ("Files Skipped (Missing): " + (nMissingFiles as string) + "\n") to: logFile 
				format ("File Copy Errors: " + (nErrorFileCopies as string) + "\n") to: logFile 
				format ("Dirs Created: " + (nCreatedDirs as string) + "\n") to: logFile
				format ("Maximum File Nesting: " + (nMaxNesting as string) + "\n") to: logFile 
				format ("Copied Size: " + ((nBytesCopied/1000000.0) as string) + " MB\n") to: logFile 
				format ("Process took: "+ ((end - start) / 1000.0) as string +" seconds" ) to: logFile 
				
				close logFile
				logFile = undefined
				
				if doesFileExist iniFile then
				(					
					deleteFile iniFile
				)
				
				for o in copiedAssetFilesList do
				(
					setINISetting iniFile "Files" o[1] o[2]
				)
				
				gc()
				
				--print copiedAssetFilesList
			)
			messagebox ("Done.")
		)
	)

	on execute do 
	(
		try(destroyDialog ProjectDupRollout)catch()
		createDialog ProjectDupRollout
		
	)
	
)