[bits 32]	; the kernel will be run in 32-bit protected mode

; Begin executing the kernel
Kernel.init :
methodTraceEnter

	mov eax, [Debug.methodTraceStackBase2]
	mov [Debug.methodTraceStack2], eax
	
	; Prevent windows from being drawn (deprecated?)
		mov byte [Dolphin_WAIT_FLAG], 0xFF
	
	; Enable SSE Extentions (allows use of instructions using the XMM registers)
		call SSE.enable
	
	; Set up graphics mode
		call Graphics.init
	
	; Set up the main memory management
		call Guppy.init
		call Guppy2.init
	
	; Initialize kernel modules
		call kernel.initModules
		
	; Display the text mode welcome message if needed
		call kernel.checkRunTextModeInit
	
	; Initialize the AHCI Driver
		call ATA_DETECT	; NEEDS TRANSITION TO GUPPY2
;
	; Set up the OrcaHLL console and memory workaround (deprecated)
;;		call kernel.OrcaHLLsetup_memhack
	
	; Initialize the USB Driver
		; call EHCI.findDevice
;	cli
;	call betterPaging.init
;	sti
	
	; Enable the FPU
		call FPU.enable
	
	; Allow windows to be drawn	(deprecated?)
		mov byte [Dolphin_WAIT_FLAG], 0x00
	
	; Workaround to make KeyManager report keypresses (...)
		mov al, [Dolphin.currentWindow]
		mov [Dolphin.activeWindow], al
	
	; Set up and run the windowing system (does not return).
		call console.test
	
	; If this is ever executed (it shouldn't be), halt the CPU.
		cli	; disable interrupts
		hlt	; halt the CPU
	
	kernel.sloadcount :
		dd 0x0

	kernel.sloadcount2 :
		dd 0x0

		
[bits 16]	; to be used in real mode

; Load a sector of the kernel from the boot drive
kernel.loadFunc :
		mov eax, [k_lF.low]
		mov bx, [k_lF.high]
		call realMode.ATAload
	ret
	k_lF.low :
		dd 0x0
	k_lF.high :
		dd 0x0


[bits 32]	; to be used in 32-bit protected mode

; Save all of a function's local variables on the stack (broken)
kernel.SaveFunctionState :	; vardata in ebx... trashes eax
		mov eax, [ebx]
		.loop :
		push dword [ebx+4]
		add ebx, 4
		sub eax, 4
		cmp eax, 0
			jg .loop
	ret

; Load all of a function's local variables from the stack (broken)
kernel.LoadFunctionState :	; vardata in ebx... trashes eax
		mov eax, [ebx]
		.loop :
		pop dword [ebx+4]
		add ebx, 4
		sub eax, 4
		cmp eax, 0
			jg .loop
	ret

; Initialize kernel modules
kernel.initModules :
	methodTraceEnter
		call Dolphin.init
		call console.init
		call KeyManager.init
	methodTraceLeave
	ret
	

; Halt the CPU and display a message
kernel.halt :
methodTraceEnter
	mov ebp, esp
	; Clear/disable interrupts
		cli
	
	; Print a debug halt message (deprecated)	;
		mov eax, SysHaltScreen.KILL
		mov ebx, kernel.HALT_MESSAGE
		call SysHaltScreen.show
		
		mov eax, 0x80808080
		mov ebx, 0x01234567
		mov ecx, 0x89ABCDEF
		mov edx, 0x80808080
		
	; Halt the CPU
		hlt
		
	kernel.HALT_MESSAGE :
		db "The operating system is now halted.", 0


					;   *** Function Deprecated ***   ;
;	MEMORY "HACK" TO INSURE THAT ORCAHLL PROGRAMS HAVE *SOME* MEMORY TO ALLOCATE	;
kernel.OrcaHLLsetup_memhack :

	;	Get a program number (identifier) and store it
		call ProgramManager.getProgramNumber
		mov [OHLLPROTO_PNUM], bl
	
	;	Mark the program as active
		call ProgramManager.setActive
	
	;	Request allocation of a (rather arbitrary) amount of memory
		call Window.getSectorSize	; <- eax
		add eax, 0x1
		mov ebx, eax
		call ProgramManager.requestMemory
	
	;	Initialize the OrcaHLL console
		call iConsole._init
	
	;	Mark the program as inactive
		call ProgramManager.finalize
	
	ret

	OHLLPROTO_PNUM :
		db 0x0
	
	os.mlloc :
		db 0x0
	
	
; Print text mode greeting if needed
kernel.checkRunTextModeInit :
	methodTraceEnter
	cmp dword [DisplayMode], MODE_TEXT
		jne kernel.checkRunTextModeInit.ret
		call kernel.textInit
	kernel.checkRunTextModeInit.ret :
	methodTraceLeave
	ret
	

; Prints a greeting message (for use in text mode)
kernel.textInit :
	methodTraceEnter

	; Clear the console
		call console.clearScreen
		
	; Print the message
		mov ebx, TEXTMODE_INIT
		call console.println
	
	; Print a newline
		call console.newline
	
	methodTraceLeave
	ret
	
	TEXTMODE_INIT :
		db "Booted into debug (text) mode.", 0
	
; Enable the use of SSE instructions
SSE.enable :
	methodTraceEnter
	pusha
	
		; Check for SSE support
		mov eax, 1
		cpuid
		test edx, 1<<25
			jz kernel.halt	; no SSE support, halt the CPU
		
		; Enable SSE instructions
		mov eax, cr0
		and eax, ~(0b100)
		or eax, 0b10
		mov cr0, eax
		mov eax, cr4
		or eax, 0b11000000000
		mov cr4, eax
		
		; Test the SSE instructions
		movdqu xmm0, [SSETESTDATA]
		movdqu [SSETESTDATAREP], xmm0
		cmp dword [SSETESTDATAREP], 0
			jne kernel.halt	; if any of the tests fail, halt the CPU
		cmp dword [SSETESTDATAREP+4], 1
			jne kernel.halt
		cmp dword [SSETESTDATAREP+8], 2
			jne kernel.halt
		cmp dword [SSETESTDATAREP+12], 3
			jne kernel.halt
		
	popa
	methodTraceLeave
	ret

	SSETESTDATA :
		dd 0, 1, 2, 3
	SSETESTDATAREP :
		dd 9, 9, 9, 9


; Enables use of the FPU
FPU.enable :
	methodTraceEnter
		mov eax, cr0
		and eax, (~0b1110)
		or eax, 0b100000
		mov cr0, eax
		fninit
	methodTraceLeave
	ret


; Includes

	%include "../$Emulator/StandardIncludes.asm"
