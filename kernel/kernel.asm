[bits 32]
;	BEGIN EXECUTING THE KERNEL	;
Kernel.init :
	cmp dword [DisplayMode], MODE_TEXT
		je Kernel.textInit
	
	mov byte [Dolphin_WAIT_FLAG], 0xFF
		;	SETUP GRAPHICS MODE		;
	call Graphics.init
	
	kernel.cont :
	call Guppy.init
	
	
	call kernel.initModules
	
	call ATA_DETECT
	
	call ProgramManager.getProgramNumber	; ~!! OHLL SETUP !!~
	mov [OHLLPROTO_PNUM], bl
	call ProgramManager.setActive
	call Window.getSectorSize	; <- eax
	add eax, 0x1
	mov ebx, eax
	call ProgramManager.requestMemory
			call iConsole._init
	call ProgramManager.finalize			; ~!! END SETUP !!~
	
	
;		call USB_InitController
		
;		call USB_EnablePlugAndPlay
	
			mov ebx, MEMORY_BUFFMAXMSG
			call TextMode.print
			mov ebx, [Guppy.usedRAM]
			imul ebx, 0x200
			add ebx, MEMORY_START
			mov eax, ebx
			call DebugLogEAX
			call TextMode.newline
			
			mov eax, [Guppy.usedRAM]
			mov ecx, [Guppy.totalRAM]
			imul eax, 100
			xor edx, edx
			idiv ecx
			call DebugLogEAX
			mov ebx, Guppy.div3
			call TextMode.println
			
		;	LOCK THE COMPUTER	;
		;xor edx, edx
		mov edx, [AHCI_PORTALLOCEDMEM]
		add edx, 0x1000+0x20
		mov edx, [edx]
	call Manager.lock
		;	CHECK TO SEE IF THE COMPUTER IS LOCKED	;
	call Manager.handleLock
	
	;call mouse.init
	
	mov byte [Dolphin_WAIT_FLAG], 0x0
	;	MAIN LOOP	;
	kernel.loop:
			;	RUN INSTALLED MODULES	;
		call kernel.runModules
			;	UPDATE WINDOWS	;
		call Dolphin.updateWindows
			;	CHECK TO SEE IF THE COMPUTER IS LOCKED	;
		call Manager.handleLock
			;	REPEAT	;
		jmp kernel.loop
		
	OHLLPROTO_PNUM :
		db 0x0
		
kernel.runModules :
	mov bl, Manager.CONTROL_MODULES
	mov [os.mlloc], bl
	
		;call InfoPanel.loop
		;call console.loop
		;call Clock.loop
	mov bl, [OHLLPROTO_PNUM]
	call ProgramManager.setActive
		call iConsole._loop
	call ProgramManager.finalize
	
	;call Mouse.loop
	
ret
	
	Stubfunc :
		ret
	
kernel.initModules :
	call Dolphin.init
	call console.init
	
	call KeyManager.init
	
	;call HelloWorld.init
	;call Clock.init
	;call Clock.show	; should be bound to a command!	
	;call InfoPanel.init
ret
	
kernel.halt :
	cli
	mov ebx, kernel.HALT_MESSAGE
	call debug.println
	call goRealMode
	hlt

kernel.HALT_MESSAGE :
db "The operating system is now halted.", 0

kernel.BOOT_PROGRAM_NAME :
db "MathTest", 0

os.mlloc :
db 0x0
	
%include "../$Emulator/StandardIncludes.asm"

Kernel.textInit :
		call console.clearScreen
		mov ebx, TEXTMODE_INIT
		call console.println	
		call console.newline
	jmp kernel.cont

TEXTMODE_INIT :
	db "Booted into debug (text) mode.", 0

MINNOW_START :

%include "..\OrcaHLL\iConsole.asm"	; so it will also show up as a file
%include "..\OrcaHLL\Library.asm"
%include "..\OrcaHLL\VideoInfo.asm"
%include "..\OrcaHLL\TestProgram.asm"
