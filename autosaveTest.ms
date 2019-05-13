-------------------------------------------------------------------------------
-- AutobackInBG.ms
-- Based on : https://www.reddit.com/r/3dsmax/comments/7o2cnj/heres_a_solution_to_that_damn_autobackup_that/
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- May 11th 2019
-- Replaces native autoback function and uses save in background with random ID
-- Installation: Place the file in max's startup script directory
-------------------------------------------------------------------------------

(
	global Thread,MainThread
	global fileIncrement = 1
	--find the number of 3dsmax.exe processes are running and return as an exit code
	local hiddenCom = HiddenDOSCommand  "for /f %a in ('tasklist ^| findstr /i 3dsmax.exe ^| find /v \"\" /c') do EXIT %a" ExitCode:&variable
	global processID = variable as string

	--Disable autosave
	if autosave.Enable == true then autosave.Enable = false

	-- from Background worker updating meshes on CGSociety
	source = ""
	source += "using System;\n"
	source += "using System.Runtime.InteropServices;\n"
	source += "class WindowsGhosting\n"
	source += "{\n"
	source += "	[DllImport(\"user32.dll\")]\n"
	source += "	public static extern void DisableProcessWindowsGhosting();\n"
	source += "}\n"

	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"

	compilerParams.GenerateInMemory = on
	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)

	assembly = compilerResults.CompiledAssembly
	windowsGhosting = assembly.CreateInstance "WindowsGhosting"
	windowsGhosting.DisableProcessWindowsGhosting()

	fn padNumber nr padLen = (local n = (nr as string)	for x = 1 to (padLen - n.count) do n = "0" + n 	return n)

	fn incrementFile i =
	(
		local result = (((mod i (autosave.NumberOfFiles)) as integer) + 1)
		result = padNumber result (autosave.NumberOfFiles as string).count
		return (result as string)
	)

	-- Actual autosave function
	fn runAutosave sender e =
	(
		try
		(
			local fIncrement = incrementFile fileIncrement
			pushPrompt "Background Auto-save is saving..."
			
			if maxFilename != "" then 
			(
				
				saveMaxFile (GetDir(#autoback) + "\\" + (getFilenameFile maxFileName) + "_" + processID + "_" + fIncrement + ".max") clearNeedSaveFlag:false useNewFile:false quiet:true
				
			) 
			else
			(
				saveMaxFile (GetDir(#autoback) + "\\" + "Untitled_" + processID + "_" + fIncrement + ".max") clearNeedSaveFlag:false useNewFile:false quiet:true
			)
			fileIncrement = fileIncrement + 1
			
			pushPrompt "Background Auto-save was successful."
		)
		catch
		(
			print "Error: "
			getCurrentException()
		
		)
	)

	-- Callback function for timer
	fn runSaveThread sender e =
	(
		try
		(
			--if getSaveRequired() do 
			--(
				/* -- not sure about this
				if maxFilename != "" then 
				(
					if (getfiles (maxFilePath + "bk" + maxFileName)).count != 0 then deleteFile (maxFilePath + "bk" + maxFileName)
				) else (
					if (getfiles (GetDir(#autoback)+"\untitled.max")).count != 0 then deleteFile (GetDir(#autoback)+"\untitled.max")
				)
				*/
				if not MainThread.IsBusy do MainThread.RunWorkerAsync()
			--)	
		) 
		catch 
		( 
			print "Error: "
			getCurrentException()
		)
	)

	-- Create a timer
	autosaveTimer = dotNetObject "System.Windows.Forms.Timer"

	-- Set the interval to be equal to Max's native autobackup
	autosaveTimer.interval = int(1000*60*1.0)--autosave.Interval)

	-- Set callback function for timer
	dotNet.addEventHandler autosaveTimer "tick" runSaveThread

	-- Specify the BackgroundWorker Class

	--	MainThread = dotnetobject "System.ComponentModel.BackGroundWorker"
	MainThread = dotnetobject "CSharpUtilities.SynchronizingBackgroundWorker"

	--MainThread.WorkerReportsProgress = true
	MainThread.WorkerSupportsCancellation = true		
	dotNet.addEventHandler MainThread "DoWork" runAutosave
	--dotNet.addEventHandler MainThread "ProgressChanged" UpdateThread

	autosaveTimer.start()

	--autosaveTimer.stop()
)
