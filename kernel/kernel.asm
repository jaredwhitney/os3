KERNEL_SIZE equ (((KERNEL_END-KERNEL_START)-1)/0x200)+1	; keep track of the kernel's size

[bits 32]	; the kernel will be run in 32-bit protected mode

; Begin executing the kernel
Kernel.init :	
	
	; Prevent windows from being drawn (deprecated?)
		mov byte [Dolphin_WAIT_FLAG], 0xFF
	
	; Load the rest of the kernel
		call kernel.finishLoading
	
	; Enable SSE Extentions (allows use of instructions using the XMM registers)
		call SSE.enable
	
	; Set up graphics mode
		call Graphics.init
	
	; Set up the main memory management
	;;	call Guppy.init
		call Guppy2.init
	
	; Initialize kernel modules
	;;	call kernel.initModules
	
	; Display the text mode welcome message if needed
		call kernel.checkRunTextModeInit
		
		call Guppy2.runTest
		jmp $
	
	; Initialize the AHCI Driver
		call ATA_DETECT

	; Set up the OrcaHLL console and memory workaround (deprecated)
		call kernel.OrcaHLLsetup_memhack
	
	; Initialize the USB Driver
		; call EHCI.findDevice
	
	cli
	call betterPaging.init
	sti
	; Enable the FPU
		call FPU.enable
	
	; Allow windows to be drawn	(deprecated?)
		mov byte [Dolphin_WAIT_FLAG], 0x00
	
	; Workaround to make KeyManager report keypresses (...)
		mov al, [Dolphin.currentWindow]
		mov [Dolphin.activeWindow], al
	
	; Pause for 1000 clock tics (needed workaround or will not boot)
		mov eax, 1000
		call System.sleep
	
	; Set up and run the windowing system (does not return).
		call console.test
	
	; If this is ever executed (it shouldn't be), halt the CPU.
		cli	; disable interrupts
		hlt	; halt the CPU
	
	kernel.sloadcount :
		dd 0x0

	kernel.sloadcount2 :
		dd 0x0

		
; Load the rest of the kernel
kernel.finishLoading :
		mov ax, [0x1000]
		and eax, 0xFFFF	; eax contains the sector to begin loading from
		mov edx, KERNEL_SIZE
		sub edx, eax ; edx contains the number of sectors that need to be loaded
		add edx, 1
		push eax
		mov ecx, S2_CODE_LOC
		imul eax, 0x200
		add ecx, eax
		pop eax	; ecx contains the place to begin writing the data to
		sub ecx, 0x200	; should work
		;;
		mov dword [kernel.sloadcount2], eax
		mov dword [kernel.sloadcount], ecx
		;;
		mov dword [os_RealMode_functionPointer], kernel.loadFunc
		.loadLoop :
		mov [k_lF.low], eax
		pusha
		call os.hopToRealMode
		popa
			mov esi, 0x7c00
			mov edi, ecx
			push ax
			xor ax, ax
			mov es, ax
			pop ax
			push ecx
			mov ecx, 0x200
				.copyDataLoop :
				mov ebx, [esi]
				mov [edi], ebx
				add esi, 4
				add edi, 4
				sub ecx, 4
				cmp ecx, 0x0
					jg .copyDataLoop
			pop ecx
		add eax, 1
		sub edx, 1
		add ecx, 0x200
		cmp edx, 0x0
			jg .loadLoop
	ret
		
		
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
		call Dolphin.init
		call console.init
		call KeyManager.init
	ret
	

; Halt the CPU and display a message
kernel.halt :

	; Clear/disable interrupts
		cli
	
	; Print a debug halt message (deprecated)	;
		mov ebx, kernel.HALT_MESSAGE
		call debug.println
		
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
	cmp dword [DisplayMode], MODE_TEXT
		jne kernel.checkRunTextModeInit.ret
		call kernel.textInit
	kernel.checkRunTextModeInit.ret :
	ret
	

; Prints a greeting message (for use in text mode)
kernel.textInit :

	; Clear the console
		call console.clearScreen
		
	; Print the message
		mov ebx, TEXTMODE_INIT
		call console.println
	
	; Print a newline
		call console.newline
	
	ret
	
	TEXTMODE_INIT :
		db "Booted into debug (text) mode.", 0
	
; Enable the use of SSE instructions
SSE.enable :
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
	ret

	SSETESTDATA :
		dd 0, 1, 2, 3
	SSETESTDATAREP :
		dd 9, 9, 9, 9


; Enables use of the FPU
FPU.enable :
		mov eax, cr0
		and eax, (~0b1110)
		or eax, 0b100000
		mov cr0, eax
		fninit
	ret


; Includes

	%include "../$Emulator/StandardIncludes.asm"


; File Padding	

	times ((($-$$)/0x200+1)*0x200)-($-$$) db 0	; pad the code to the nearest sector


KERNEL_END :


; External files to include
	
	; LBA of the file's data
	
		os_imageDataBaseLBA :
			dd ($-$$)/0x200+1	; 1 additional because the bootloader is LBA 0

	; The file's data
	
		incbin "..\_not os code\Convenience\VGA\bgex2.vesa.dsp"

	
; File Padding

	times ((($-$$)/0x200+1)*0x200)-($-$$) db 0	; pad the file to the nearest sector

