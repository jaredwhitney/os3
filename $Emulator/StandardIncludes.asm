%include "..\boot\betterRealMode.asm"
%include "..\boot\IDTmain.asm"
%include "..\boot\detection.asm"
%include "..\Drivers\GFX\Generic_Display.asm"
%include "..\Drivers\PS2\PS_2.asm"
%include "..\Drivers\PS2\Generic_Mouse.asm"
%include "..\Drivers\PS2\Generic_Keyboard.asm"

%include "..\modules\dolphin\Dolphin.asm"
%include "..\modules\dolphin2\Dolphin2.asm"
%include "..\modules\dolphin\WindowTools.asm"
%include "..\modules\dolphin\Update_Text.asm"

%include "..\modules\console\iConsole.asm"
%include "..\modules\console\iConsole2.asm"
%include "..\modules\video\Video.asm"
%include "..\modules\xlib\int30.asm"

%include "..\Graphics\Image\Tools.asm"
%include "..\Graphics\Image\TransparencyUtils.asm"
%include "..\Graphics\TextHandler.asm"
%include "..\Graphics\RenderTextThing.asm"
%include "..\Graphics\TextArea.asm"
%include "..\Graphics\Image.asm"
%include "..\Graphics\Grouping.asm"
%include "..\Graphics\Button.asm"
%include "..\Graphics\WindowGrouping.asm"
%include "..\Graphics\GroupingScrollable.asm"
%include "..\Graphics\SelectionPanel.asm"
%include "..\Graphics\Font\SysDefault.asm"

;  3GXlib Includes  ;
	%include "..\Graphics\3GXlib\L3gxImage.asm"
	%include "..\Graphics\3GXlib\DrawRect.asm"
	%include "..\Graphics\3GXlib\ClearImage.asm"
	%include "..\Graphics\3GXlib\DrawImage.asm"

%include "..\Drivers\HDD\rmATA.asm"
%include "..\Drivers\HDD\ATA_DETECT.asm"
%include "..\Drivers\HDD\AHCI_COMMANDS.asm"
%include "..\Drivers\HDD\AHCI_DMAWRITE.asm"

%include "..\Drivers\PCI\Generic_ComponentInterface.asm"

%include "..\Tools\System\Time.asm"
%include "..\Tools\System\Guppy.asm"
;%include "..\Tools\System\Minnow.asm"
%include "..\Tools\System\Minnow4.asm"
%include "..\Tools\System\Minnow3.asm"
%include "..\Tools\System\Minnow2.asm"
%include "..\Tools\System\GetValue.asm"
;%include "..\Tools\System\TaskSwapHandler.asm"

%include "..\Tools\Utility\Clock.asm"

%include "..\Tools\Security\Manager.asm"
%include "..\Tools\Security\HaltScreen.asm"

%include "..\Tools\String\General.asm"
%include "..\Tools\String\EqualityTests.asm"
%include "..\Tools\Number\BCDconversions.asm"

%include "..\OrcaHLL\iConsole.asm"

%include "..\kernel\ProgramLoader.asm"
%include "..\kernel\Paging.asm"

%include "..\debug\TextMode.asm"
%include "..\debug\print.asm"	; depricated

%include "..\Meta\Graphics\Window.asm"
%include "..\Meta\Buffer.asm"

;%include "..\Drivers\PCI\PCI_LookupTables.asm"

%include "..\Drivers\USB\EHCI.asm"

Catfish.notify:
ret
View.file:
ret
TRUE equ 0xFF
true equ 0xFF
FALSE equ 0x00
false equ 0x00
null equ 0x0
nullptr :
	dq 0
endstr equ 0x0
WHITE equ 0xFF