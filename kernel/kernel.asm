[bits 32]
;	BEGIN EXECUTING THE KERNEL	;
Kernel.init :
	cmp dword [DisplayMode], MODE_TEXT
		je Kernel.textInit
	kernel.cont :
	
	mov byte [Dolphin_WAIT_FLAG], 0xFF
		;	SETUP GRAPHICS MODE		;
	call Graphics.init
	call Guppy.init
	
	;call Paging.init
	;Paging.ret :
	;call Stubfunc
	;jmp $
	
	call kernel.initModules
	
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
			
			
	;jmp $
		;	LOCK THE COMPUTER	;
	call Manager.lock
		;	CHECK TO SEE IF THE COMPUTER IS LOCKED	;
	call Manager.handleLock
	
	call mouse.init
	
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
	
	call Mouse.loop
	
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
	call TextMode.clearScreen
	mov ebx, TEXTMODE_INIT
	call TextMode.println
	
	call TextMode.newline
	;mov ax, [VESACNTERRCODE]
	;and eax, 0xFF
	;call DebugLogEAX
	;call TextMode.newline
	
	mov eax, [0x2000]
	mov [VESA_TAG], eax
	mov ebx, VESA_TAGMSG
	call TextMode.print
	mov ebx, VESA_TAG
	call TextMode.println
	
	mov ax, [0x2004]
	and eax, 0xFFFF
	mov ebx, VESA_VER
	call TextMode.print
	call DebugLogEAX
	call TextMode.newline
	
	;mov eax, [0x2006]
	;call DebugLogEAX
	;call TextMode.newline
	;mov eax, [0x200E]
	;call DebugLogEAX
	;call TextMode.newline
	
	mov ebx, VESA_OEMMSG
	call TextMode.print
	mov ax, [0x2006]
	mov bx, [0x2008]
	and ebx, 0xFFFF
	and eax, 0xFFFF
	imul ebx, 0x10
	add eax, ebx
	mov ebx, eax
	mov [Graphics.CARDNAME], ebx
	call TextMode.println
	
	mov ax, [0x200E]
	mov bx, [0x2010]
	and ebx, 0xFFFF
	and eax, 0xFFFF
	imul ebx, 0x1000
	add eax, ebx
	Txmlp_0.qo :
	mov bx, [eax]
	add eax, 2
	add ecx, 1
	cmp bx, 0xFFFF
		jne Txmlp_0.qo
	
	mov eax, ecx
	mov ebx, VESA_VMODENUMMSG
	call TextMode.print
	call DebugLogEAX
	call TextMode.newline
	
	mov ebx, VESA_CLOSEST_MATCHMSG
	call TextMode.print
	xor eax, eax
	mov ax, [VESA_CLOSEST_MATCH]
	call DebugLogEAX
	call TextMode.newline
	
	mov ebx, VESA_CLOSEST_RESMSG
	call TextMode.print
	
	xor eax, eax
	mov ax, [VESA_CLOSEST_XRES]
	call DebugLogEAX
	
	mov ebx, VESA_CLOSEST_RESDIV
	call TextMode.print
	
	xor eax, eax
	mov ax, [VESA_CLOSEST_YRES]
	call DebugLogEAX
	
	mov ebx, VESA_CLOSEST_BPPMSG
	call TextMode.print
	
	xor eax, eax
	mov ax, [VESA_CLOSEST_BPP]
	call DebugLogEAX
	call TextMode.newline
	
	mov ebx, VESA_CLOSEST_BUFFERLOCMSG
	call TextMode.print
	mov eax, [VESA_CLOSEST_BUFFERLOC]
	call DebugLogEAX
	call TextMode.newline
	
	jmp kernel.cont
jmp $

TextMode.println :	; ebx is String
pusha
call TextMode.print
call TextMode.newline
popa
ret
TextMode.print :	; ebx is String
pusha
	mov ah, 0x0F
	mov ecx, [TextMode.charpos]
	TextMode.println.loop :
	mov al, [ebx]
	cmp al, 0x0
		je TextMode.println.ret
	mov [ecx], ax
	add ecx, 2
	add ebx, 1
	jmp TextMode.println.loop
	TextMode.println.ret :
	mov [TextMode.charpos], ecx
	call TextMode.scroll
popa
ret

TextMode.newline :
pusha
	mov eax, [TextMode.charpos]
	sub eax, 0xb8000
	xor ebx, ebx
	xor edx, edx
	mov ecx, 160
	idiv ecx
	add eax, 1
	imul eax, 160
	add eax, 0xb8000
	mov [TextMode.charpos], eax
popa
ret

TextMode.clearScreen :
pusha
	mov eax, 0xb8000
	mov [TextMode.charpos], eax
	TextMode.clearScreen.loop :
	cmp eax, 0xb9000
		je TextMode.clearScreen.ret
	mov dword [eax], 0x0
	add eax, 4
	jmp TextMode.clearScreen.loop
TextMode.clearScreen.ret :
popa
ret

DebugLogEAX :
pusha
	mov ecx, DebugStringStor
	mov dword [ecx], 0x0
	add ecx, 4
	mov dword [ecx], 0x0
	mov ebx, eax
	mov eax, DebugStringStor
	call String.fromHex
	mov ebx, eax
	call String.copyColorToRaw
	;call TextMode.clearScreen
	call TextMode.print
popa
ret

TextMode.scroll :
pusha
	mov ecx, [TextMode.charpos]
	cmp ecx, 0xb9000
		jle TextMode.scroll.ret
	call TextMode.clearScreen
	;mov esi, 0xb9000
	;mov edx, 0xb8000
	;mov ecx, 0x1000
	;rep movsb
TextMode.scroll.ret :
popa
ret

TEXTMODE_INIT :
	db "Booted into debug (text) mode.", 0
TextMode.charpos :
	dd 0xb8000
DebugStringStor :
	dd 0x0, 0x0, 0x0, 0x0, 0x0

MINNOW_START :

%include "..\OrcaHLL\iConsole.asm"	; so it will also show up as a file
%include "..\OrcaHLL\Library.asm"
%include "..\OrcaHLL\VideoInfo.asm"
%include "..\OrcaHLL\TestProgram.asm"
