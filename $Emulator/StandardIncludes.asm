%include "..\modules\dolphin\Dolphin.asm"
%include "..\modules\dolphin\Catfish.asm"
%include "..\modules\console\iConsole.asm"
%include "..\modules\xlib\int30.asm"

%include "..\Graphics\Image\Tools.asm"
%include "..\Graphics\TextHandler.asm"
%include "..\Graphics\Font\SysDefault.asm"

%include "..\Drivers\PS2\Generic_Mouse.asm"
%include "..\Drivers\PS2\Generic_Keyboard.asm"
%include "..\Drivers\GFX\Generic_Display.asm"

%include "..\Tools\System\Time.asm"
%include "..\Tools\System\View.asm"
%include "..\Tools\System\Guppy.asm"
%include "..\Tools\System\Minnow.asm"

%include "..\Tools\Security\Manager.asm"
%include "..\Tools\String\EqualityTests.asm"

%include "..\kernel\ProgramLoader.asm"
%include "..\debug\print.asm"
%include "..\boot\IDTmain.asm"