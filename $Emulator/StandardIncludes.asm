; BOOT CRITICAL

	;  Stage2 Required Includes	;
	;	%include "../boot/betterRealMode.asm"
	;	%include "../boot/IDTmain.asm"
		%include "../Drivers/PS2/PS_2.asm"	; init should be dealt with in kernel, not s2!
		
	;  BootCritical Signature	;
		stage2_minloadSig : dd 0xDEADF154


; KERNEL CRITICAL

	;  Memory Check Includes	;
;		%include "../boot/detection.asm"
		
	;  PS/2 Driver Includes	;
		%include "../Drivers/PS2/Generic_Mouse.asm"
		%include "../Drivers/PS2/Generic_Keyboard.asm"


; NEW MODULE SYSTEM
	
	%include "../newModules/WinMan.asm"


; GRAPHICS

	;  Graphics Driver Includes	;
		%include "../Drivers/GFX/Generic_Display.asm"
		
	;  3GXlib Includes  ;
		%include "../Graphics/3GXlib/L3gxImage.asm"
		%include "../Graphics/3GXlib/DrawRect.asm"
		%include "../Graphics/3GXlib/ClearImage.asm"
		%include "../Graphics/3GXlib/DrawImage.asm"
	
	;  Text and Font Includes	;
		%include "../Graphics/TextHandler.asm"
		%include "../Graphics/Font/SysDefault.asm"	
	
	;  Dolphin Includes	;
		%include "../modules/dolphin/Dolphin.asm"	; depricated
		%include "../Meta/Graphics/Window.asm"	; depricated
		%include "../modules/dolphin2/Dolphin2.asm"
		%include "../modules/dolphin2/DolphinConfig.asm"
		%include "../modules/dolphin2/PromptBox.asm"
		%include "../modules/dolphin2/FileChooser.asm"
		%include "../modules/dolphin/WindowTools.asm"	; depricated
		%include "../modules/dolphin/Update_Text.asm"
	
	;  Catfish Includes	;
		%include "../modules/catfish/Catfish.asm"
		
	;  Component Includes	;
		%include "../Graphics/RenderTextThing.asm"
		%include "../Graphics/TextArea.asm"
		%include "../Graphics/Image.asm"
		%include "../Graphics/Grouping.asm"
		%include "../Graphics/Button.asm"
		%include "../Graphics/WindowGrouping.asm"
		%include "../Graphics/GroupingScrollable.asm"
		%include "../Graphics/SelectionPanel.asm"


; USER SIDE
		
	;  iConsole Includes	;
		%include "../OrcaHLL/iConsole.asm"	; depricated
		%include "../modules/console/iConsole.asm"	; depricated
		%include "../modules/console/iConsole2.asm"
	
	;  Module Includes	;
		%include "../modules/textEditor/TextEditor.asm"
		%include "../modules/imageEditor/ImageEditor.asm"
		%include "../modules/video/Video.asm"	; here on needs method traces added
		%include "../modules/simpleRender/SimpleRender.asm"
		%include "../modules/systemMemoryMap/SystemMemoryMap.asm"
		%include "../modules/bfParse/bfParse.asm"
		%include "../modules/hexEditor/HexEditor.asm"
	
	;  Program Loader Includes	;
		%include "../kernel/ProgramLoader.asm"	; depricated in part
	
	;  Syscall Includes	;
		%include "../modules/xlib/int30.asm"


; DRIVER CRITICAL
		
	;  PCI Driver Includes	;
		%include "../Drivers/PCI/Generic_ComponentInterface.asm"
		; %include "..\Drivers\PCI\PCI_LookupTables.asm"


; HARD-DRIVE AND FILESYSTEM
		
	;  HDD Driver Includes	;
		%include "../Drivers/HDD/rmATA.asm"
		%include "../Drivers/HDD/ATA_DETECT.asm"
		%include "../Drivers/HDD/AHCI_COMMANDS.asm"
		%include "../Drivers/HDD/AHCI_DMAWRITE.asm"
	
	;  MinnowFS Includes	;
		;%include "../Tools/System/Minnow2.asm"	; depricated
		%include "../Tools/System/Minnow3.asm"	; depricated
		%include "../Tools/System/Minnow4.asm"
		%include "../Tools/System/Minnow5.asm"


; SYSTEM MISC
	
	;  System Tool Includes	;
		%include "../Tools/System/Time.asm"
		%include "../Tools/System/Guppy.asm"
		%include "../Guppy2.asm"	;; TESTING ONLY
		%include "../Tools/System/GetValue.asm"
		; %include "..\Tools\System\TaskSwapHandler.asm"
	
	;  System Utility Includes	;
		%include "../Tools/Utility/Clock.asm"	; depricated in part
	
	;  System Security Includes	;
		%include "../Tools/Security/Manager.asm"
		%include "../Tools/Security/HaltScreen.asm"
		
	;  System Debug Includes	;
		%include "../debug/TextMode.asm"
		%include "../debug/MemoryCheck.asm"
		%include "../debug/print.asm"	; depricated


; UTILITY
	
	;  Graphics Utility Includes	;
		%include "../Graphics/Image/Tools.asm"
		%include "../Graphics/Image/TransparencyUtils.asm"
	
	;  String Utility Includes	;
		%include "../Tools/String/General.asm"
		%include "../Tools/String/EqualityTests.asm"
	
	;  Number Utility Includes	;
		%include "../Tools/Number/BCDconversions.asm"
		%include "../Tools/Number/parsing.asm"
		
	;  Buffer Utility Includes	;
		%include "../Meta/Buffer.asm"


; MISC

	;  Paging Includes	;
		%include "../kernel/Paging.asm"	; unimplemented
		%include "../kernel/betterPaging.asm"
	
	;  EHCI Driver Includes	;
		%include "../Drivers/USB/EHCI.asm"	; unimplemented
		
		%include "../$Emulator/map.asm"
		
; DEFINITIONS
	
	; Truthy / Falsey
		TRUE equ 0xFF
		true equ 0xFF
		FALSE equ 0x00
		false equ 0x00
	
	; Null
		null equ 0x0
		nullptr : dq 0
	
	; String
		endstr equ 0x0
	
	; 255-Color Palette
		WHITE equ 0xFF
