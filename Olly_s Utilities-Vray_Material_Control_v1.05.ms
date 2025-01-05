macroScript Vray_Material_Control_v1
category:"Olly's Utilities"
tooltip:"Vray Material Control"
buttontext:"VMC"
(	
	-- Verison History:
	-- v1.00 (2007/12/18) Initial Build
	-- v1.01 (2007/12/20) Added control for standard & vraymtlwrapper materials. Fixed bug: VRayMtlWrapper base materials weren't accounted for in a property change.
	-- v1.02 (2007/12/21) Added undo & re-wrote functions to change properties of nested materials more effeciently.
	-- v1.03 (2007/12/22) Removed display of unsupported properties, specifically sub-materials & maps. Added a help. Tested script thoroughly & hopefully removed any script errors.
	-- v1.04 (2008/02/11) Added support for VrayMtl's contained within VRayOverrideMtl.
	-- v1.05 (2023/06/28) Properties are now searchable and drop down converted to a list box
	
	VMCversion = "VMC v1.05"	
	
	-- Variables & Defaults
	Global VMC_main_floater
	Global VMC_main_rollout
	Global VMC_About_Rollout
	Global DefaultMatType
	
	if DefaultMatType == undefined do (DefaultMatType = 1)	
	
	Vraymaterials = #(vraymtl, vrayfastsss2, vraylightmtl, vraymtlwrapper, VRayCarPaintMtl, VRayCarPaintMtl2, standard)
	CurrentMaterialType = Vraymaterials[DefaultMatType]
	OperateOn
	ChosenMatPropertyArray = getpropnames (CurrentMaterialType()) 
	ChosenPropertyList = #()
	PropertyToChange = ChosenMatPropertyArray[1] as string
	PropertyClass = classof (getproperty (CurrentMaterialType()) PropertyToChange)
	SelectionMaterials = #()	
	NewValueToSet
	NumberOfCoatMats = 9 -- 9 being the number of coat materials in a VRayBlendMtl 
	
	-- Functions
	RecordValue
	SeperateMatsByClass
	EnableRelevantControl

	fn RemoveUnsupportedProps propArray =
	(			
		for i in propArray.count to 1 by -1 do
		(
			a = classof (getproperty (CurrentMaterialType()) propArray[i])
			if a == UndefinedClass do deleteitem propArray i
		)
		-- VMC_main_rollout.PropertiesList.items = propArray
		-- EnableRelevantControl()
		propArray
	)

	fn CreateVmcMaterials Choice = 
	(
		VmcMaterials = #()
		if Choice == 1 then (for m in selection do (if m.material != undefined then append VmcMaterials m.material))
		else if Choice == 2 then VmcMaterials = scenematerials
		else if Choice == 3 then VmcMaterials = meditMaterials
		return VmcMaterials
	)

	fn CollectMats =
	(
		RecordValue()
		VmcMaterials = CreateVmcMaterials OperateOn 
		undo on (for i in VmcMaterials do SeperateMatsByClass i)
	)

	fn SeperateMatsByClass mat = 
	(
		if classof mat == Multimaterial then
		(
			for i = 1 to mat.count do
			(
				SeperateMatsByClass mat[i]
			)
		)
		else if classof mat == VRay2sidedMtl then
		(
			SeperateMatsByClass mat.frontmtl
			SeperateMatsByClass mat.backmtl
		)
		else if classof mat == VRayMtlWrapper then
		(
			SeperateMatsByClass mat.basemtl
			if CurrentMaterialType == VRayMtlWrapper then (setproperty mat PropertyToChange NewValueToSet)
		)
		else if classof mat == VRayBlendMtl then
		(
			SeperateMatsByClass mat.basemtl
		)
		else if classof mat == CurrentMaterialType then
		(
			setproperty mat PropertyToChange NewValueToSet
		)
		else if classof mat == VRayOverrideMtl then
		(
			SeperateMatsByClass mat.basemtl
			SeperateMatsByClass mat.giMtl
			SeperateMatsByClass mat.reflectMtl
			SeperateMatsByClass mat.refractMtl
			SeperateMatsByClass mat.shadowMtl
		)
	)
		
	fn EnableRelevantControl DefaultType:1 =
	(
		PropertyToChange = ChosenPropertyList[DefaultType] as string
		PropertyClass = classof (getproperty (CurrentMaterialType()) PropertyToChange)
		if PropertyClass == BooleanClass then
		(
			VMC_main_rollout.BooleanClassLabel.enabled = true
			VMC_main_rollout.BooleanClassType.enabled = true
			VMC_main_rollout.ColorType.enabled = false
			VMC_main_rollout.FloatType.enabled = false
			VMC_main_rollout.IntegerType.enabled = false
		)
		if PropertyClass == Color then
		(
			VMC_main_rollout.BooleanClassLabel.enabled = false
			VMC_main_rollout.BooleanClassType.enabled = false
			VMC_main_rollout.ColorType.enabled = true
			VMC_main_rollout.FloatType.enabled = false
			VMC_main_rollout.IntegerType.enabled = false
		)
		if PropertyClass == Float then
		(
			VMC_main_rollout.BooleanClassLabel.enabled = false
			VMC_main_rollout.BooleanClassType.enabled = false
			VMC_main_rollout.ColorType.enabled = false
			VMC_main_rollout.FloatType.enabled = true
			VMC_main_rollout.IntegerType.enabled = false
		)
		if PropertyClass == Integer then
		(
			VMC_main_rollout.BooleanClassLabel.enabled = false
			VMC_main_rollout.BooleanClassType.enabled = false
			VMC_main_rollout.ColorType.enabled = false
			VMC_main_rollout.FloatType.enabled = false
			VMC_main_rollout.IntegerType.enabled = true
		)
	)

	fn RecordValue =
	(
		if PropertyClass == BooleanClass then
		(
			NewValueToSet = VMC_main_rollout.BooleanClassType.State
		)
		if PropertyClass == Color then
		(
			NewValueToSet = VMC_main_rollout.ColorType.Color
		)
		if PropertyClass == Float then
		(
			NewValueToSet = VMC_main_rollout.FloatType.Value
		)
		if PropertyClass == Integer then
		(
			NewValueToSet = VMC_main_rollout.IntegerType.Value
		)
	)
	
	--  Search max file paths for string and don't match based on dont string
	fn searchProp_fn propList matchStr =
	(
		local matchIndexArray = #()
		
		for p in propList do
		(
			if (matchPattern p pattern:("*"+matchStr+"*"))  then (append matchIndexArray p)
		)
		
		matchIndexArray
	)

	(
		rollout VMC_main_rollout "Vray Material Control"
		(
			group "Choose Material Type:"
			(
				dropdownlist ListMaterialTypes items:(for o in Vraymaterials collect o as string) selection:DefaultMatType width:140 across:2
				button helpbutton "?" align:#right width:25
			)			
			group "Property To Change:"
			(
				edittext SearchProp_et
				listbox PropertiesList items:ChosenPropertyList
				label BooleanClassLabel "On/Off:" align:#left across:3 offset:[25,3] enabled:false
				checkbox BooleanClassType align:#left offset:[7,3] enabled:false
				colorpicker ColorType "Colour:" color:[128,128,128] offset:[-1,0] enabled:false
				spinner FloatType "Float:" range:[-1000,1000,100.0] fieldwidth:40 align:#left across:2 enabled:false
				spinner IntegerType "Integer:" range:[-8,200,8] type:#integer fieldwidth:40 align:#right enabled:false
			)		
			Group "Apply Change to:"
			(
				Button ChangeSelectedMaterials "Materials On Selected Objects" width:172 align:#center 
				Button ChangeSceneMaterials "Scene Materials" width:172 align:#center 
				Button ChangeMeditMaterials "Material Editor Slots" width:172 align:#center 
			)
			
			on helpbutton pressed do
			(
				messagebox "How to use this tool:\n\n1. Choose material type.\n2. Choose property to change.\n3. Enter the new value.\n4. Apply the change using buttons.\n\nNotes:\n\nTake care when changing properties\ndisplayed as drop-down lists and radio\nbutton choices: The first item is set\nwith 0, second with 1 and so on, using\nthe integer field. But using this script\nyou could set a vaule that exceeds the\noptions in the list, which can lead to\nunexpected behaviour.\n\nA material type's hidden properties are\nlisted in the \"Property To Change:\" list\nand changing these can have\nunpredictable results." Title:"Help:" beep:false
			)
			
			on ListMaterialTypes selected i do
			(
				VMC_main_rollout.PropertiesList.selection = 1
				CurrentMaterialType = Vraymaterials[i]
				ChosenMatPropertyArray = getpropnames (CurrentMaterialType()) 
				ChosenPropertyList = RemoveUnsupportedProps ChosenMatPropertyArray
				PropertiesList.items = ChosenPropertyList
				DefaultMatType = i
			)
			
			on SearchProp_et entered str do
			(
				ChosenPropertyList = searchProp_fn ChosenMatPropertyArray SearchProp_et.text
				PropertiesList.items = ChosenPropertyList
			)
			
			on PropertiesList selected i do
			(
				
				EnableRelevantControl DefaultType:i
				print(PropertyToChange)
			)	
			
			on ChangeSelectedMaterials pressed do
			(
				if  $ != undefined then
				(
					OperateOn = 1
					CollectMats()					
				)
				else if $ == undefined then	(messagebox "You Have Nothing Selected." title:"" beep:false)					
			)
			
			on ChangeSceneMaterials pressed do
			(					
				OperateOn = 2
				CollectMats()
			)
			
			on ChangeMeditMaterials pressed do
			(					
				OperateOn = 3
				CollectMats()
			)			
		)
		
		rollout VMC_About_Rollout "About..." rolledup:true
		(
			label aboutlabel1 "Written By Olly Radford \xa9 2007"
			label aboutlabel2 "If you find this script useful:"
			label aboutlabel3 "Please donate via PayPal!"
			hyperlink PayPalLink "vmc@turn2dinto3d.co.uk" align:#center color:[0,0,255] hovercolor:[0,0,255] address:"http://www.paypal.com/" 
		)
	)
	
	on execute do 
	(
			try(closeRolloutFloater  VMC_main_floater )catch()
			VMC_main_floater = newrolloutfloater VMCversion 230 420 --800 130
			addRollout VMC_main_rollout VMC_main_floater
			addRollout VMC_About_Rollout VMC_main_floater
			ChosenPropertyList = RemoveUnsupportedProps ChosenMatPropertyArray
			VMC_main_rollout.PropertiesList.items = ChosenPropertyList
			EnableRelevantControl()
	)--end on execute
)