%include "..\modules\dolphin\Dolphin.asm"
%include "..\modules\dolphin\WindowTools.asm"
%include "..\modules\dolphin\Update_Text.asm"

%include "..\modules\console\iConsole.asm"
%include "..\modules\xlib\int30.asm"

%include "..\Graphics\Image\Tools.asm"
%include "..\Graphics\TextHandler.asm"
%include "..\Graphics\Font\SysDefault.asm"

%include "..\Drivers\PS2\Generic_Mouse.asm"
%include "..\Drivers\PS2\Generic_Keyboard.asm"
%include "..\Drivers\GFX\Generic_Display.asm"

%include "..\Drivers\PCI\Generic_ComponentInterface.asm"
%include "..\Drivers\USB\Generic_EHCI.asm"

%include "..\Tools\System\Time.asm"
%include "..\Tools\System\Guppy.asm"
%include "..\Tools\System\Minnow.asm"

%include "..\Tools\Utility\Clock.asm"
%include "..\Tools\Security\Manager.asm"

%include "..\Tools\String\General.asm"
%include "..\Tools\String\EqualityTests.asm"
%include "..\Tools\Number\BCDconversions.asm"

%include "..\kernel\ProgramLoader.asm"
%include "..\debug\print.asm"
%include "..\boot\IDTmain.asm"
%include "..\boot\realMode.asm"

%include "..\Meta\Graphics\Window.asm"
%include "..\Meta\Buffer.asm"

%include "..\Debug\InfoPanel.asm"
Catfish.notify:
ret
View.file:
ret
WHITE equ 0xFF