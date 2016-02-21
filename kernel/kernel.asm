KERNEL_SIZE equ (((KERNEL_END-KERNEL_START)-1)/0x200)+1

[bits 32]

;	BEGIN EXECUTING THE KERNEL	;
Kernel.init :
	
	
	;	PREVENT WINDOWS FROM BEING DRAWN	;
		mov byte [Dolphin_WAIT_FLAG], 0xFF
	
	; Load the rest of the kernel ;
		mov ax, [0x1000]
		and eax, 0xFFFF
		mov edx, KERNEL_SIZE
		sub edx, eax ; edx contains the number of sectors that need to be loaded
		add edx, 1
		;add eax, 2	; eax contains the sector to begin loading from
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
		Kernel.init.loadLoop :
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
					;			mov eax, [esi]
					;			mov dword [kernel.sloadcount2], eax
					;			mov eax, [edi]
					;			mov dword [kernel.sloadcount], eax
					ahstoia :
					mov ebx, [esi]
					mov [edi], ebx
					add esi, 4
					add edi, 4
					sub ecx, 4
					cmp ecx, 0x0
						jg ahstoia
			pop ecx
		add eax, 1
		sub edx, 1
		add ecx, 0x200
		cmp edx, 0x0
			jg Kernel.init.loadLoop
	
		call SSE.enable
	
	;	SETUP GRAPHICS MODE		;
		call Graphics.init
	
	;	SETUP THE MAIN MEMORY MANAGEMENT	;
		call Guppy.init
	
	;	INITIALIZE ALL PRESENT MODULES	;
		call kernel.initModules
	
	;	DISPLAY TEXT MODE WELCOME MESSAGE IF NEEDED	;
		call kernel.checkRunTextModeInit
	
		mov ebx, [kernel.sloadcount]
		call console.numOut
		call console.newline
		mov ebx, [kernel.sloadcount2]
		call console.numOut
		call console.newline
	
	;	INITIALIZE THE AHCI DRIVER	;
		call ATA_DETECT
		
		call Minnow3.loadFS
		;call AHCI.searchForDataBlock	; be really surprised if this works!
		;mov eax, 0x1
		;mov bx, 0x0
		;mov edx, 0x200
		;call AHCI.DMAread
		;add ecx, 0x1BE
		;mov [C.test.val], ecx
		;mov ebx, [ecx]
		;call console.numOut
		;call console.newline
		;mov ebx, [ecx+4]
		;call console.numOut
		;call console.newline
		;mov ebx, [ecx+8]
		;call console.numOut
		;call console.newline
		;mov ebx, [ecx+12]
		;call console.numOut
		;call console.newline
		
		;call ATAPIO.init

		;call ATA0.init

	;	SET UP THE ORCAHLL CONSOLE AND MEMORY WORKAROUND	;
		call kernel.OrcaHLLsetup_memhack
	
	;	INITIALIZE THE USB DRIVER	;
		;call EHCI.findDevice
	
	;	READY TO LOCK THE COMPUTER	;
		call Manager.lock
	
	;	ACTUALLY LOCK IT	;
		call Manager.handleLock
		
	;	ALLOW WINDOWS TO BE DRAWN	;
		mov byte [Dolphin_WAIT_FLAG], 0x00
	
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

[bits 16]
kernel.loadFunc :
		mov eax, [k_lF.low]
		mov bx, [k_lF.high]
		call realMode.ATAload
	ret
k_lF.low :
	dd 0x0
k_lF.high :
	dd 0x0
[bits 32]
			
;	RUN INSTALLED MODULES	;
kernel.runModules :

	;	BLAME THE MODULES IF ANYTHING BREAKS	;
		mov bl, Manager.CONTROL_MODULES
		mov [os.mlloc], bl
	
	;	RUN THE MODULES	;
		call console.runOHLL_workaround
		;call InfoPanel.loop
	
	ret

	
;	INITIALIZE ALL PRESENT MODULES	;
kernel.initModules :

	;	INITIALIZE THE MODULES	;
		call Dolphin.init
		call console.init
		call KeyManager.init
		;call InfoPanel.init
	
	ret
	

;	FREEZE THE COMPUTER AND DISPLAY A MESSAGE	;
kernel.halt :

	;	CLEAR/DISABLE INTERRUPTS	;
		cli
	
	;	PRINT A DEBUG HALT MESSAGE (DEPRECATED)	;
		mov ebx, kernel.HALT_MESSAGE
		call debug.println
	
	;	JUMP TO REAL MODE TO FREEZE THE COMPUTER	;
		;call goRealMode
	cli
	hlt
	jmp $


;	MEMORY "HACK" TO INSURE THAT ORCAHLL PROGRAMS HAVE *SOME* MEMORY TO ALLOCATE	;
;		SHOULD BE REPLACED BY A MORE ELEGANT SOLUTION ASAP	;
kernel.OrcaHLLsetup_memhack :

	;	GET A PROGRAM NUMBER (IDENTIFIER) AND STORE IT	;
		call ProgramManager.getProgramNumber
		mov [OHLLPROTO_PNUM], bl
	
	;	MARK THE PROGRAM AS ACTIVE	;
		call ProgramManager.setActive
	
	;	REQUEST ALLOCATION OF A (RATHER ARBITRARY) AMOUNT OF MEMORY
		call Window.getSectorSize	; <- eax
		add eax, 0x1
		mov ebx, eax
		call ProgramManager.requestMemory
	
	;	INITIALIZE THE ORCAHLL CONSOLE	;
		call iConsole._init
	
	;	MARK THE PROGRAM AS INACTIVE
		call ProgramManager.finalize
	
	ret

;	DATA (SEPERATED AS THE MEMORY "HACK" SHOULD BE REMOVED)	;

	OHLLPROTO_PNUM :
		db 0x0


;	DATA	;

	kernel.HALT_MESSAGE :
		db "The operating system is now halted.", 0
	kernel.sloadcount :
		dd 0x0
	kernel.sloadcount2 :
		dd 0x0
	
	os.mlloc :
		db 0x0
	
	
;	PRINT TEXT MODE GREETING IF NEEDED	;
kernel.checkRunTextModeInit :
	
	;	CHECK THE DISPLAY MODE	;
		cmp dword [DisplayMode], MODE_TEXT
			jne kernel.checkRunTextModeInit.ret
	
	;	IF IT IS IN TEXT MODE PRINT THE GREETING	;
		call kernel.textInit
	
	kernel.checkRunTextModeInit.ret :
	ret
	

;	PRINTS A GREETING (FOR USE IN TEXT MODE)	;
kernel.textInit :

	;	CLEAR THE CONSOLE	;
		call console.clearScreen
		
	;	PRINT THE MESSAGE	;
		mov ebx, TEXTMODE_INIT
		call console.println
	
	;	PRINT A NEWLINE	;
		call console.newline
	
	ret

	
	SSE.enable :
		pusha
			mov eax, 1
			cpuid
			test edx, 1<<25
				jz kernel.halt	; no SSE support
			mov eax, cr0
			and eax, ~(0b100)
			or eax, 0b10
			mov cr0, eax
			mov eax, cr4
			or eax, 0b11000000000
			mov cr4, eax
			
			movdqu xmm0, [SSETESTDATA]
			movdqu [SSETESTDATAREP], xmm0
			cmp dword [SSETESTDATAREP], 0
				jne kernel.halt
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

;	DATA	;

	TEXTMODE_INIT :
		db "Booted into debug (text) mode.", 0

;	INCLUDES	;

	%include "../$Emulator/StandardIncludes.asm"
		
os_imageDataBaseLBA :
	dd ($-$$)/0x200+2	; 1 additional because the bootloader is LBA 0

times ((($-$$)/0x200+1)*0x200)-($-$$) db 0	; pad the code to the nearest sector

KERNEL_END :

; External files to include
;incbin "C:\Users\Jared\Documents\Java\FrameGrabber\output\VIDEO.simplevideo"
;times ((($-$$)/0x200+1)*0x200)-($-$$) db 0	; pad the file to the nearest sector
