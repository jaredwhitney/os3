[bits 32]

;	BEGIN EXECUTING THE KERNEL	;
Kernel.init :

	;	PREVENT WINDOWS FROM BEING DRAWN	;
		mov byte [Dolphin_WAIT_FLAG], 0xFF
	
	;	SETUP GRAPHICS MODE		;
		call Graphics.init
	
	;	SETUP THE MAIN MEMORY MANAGEMENT	;
		call Guppy.init
	
	;	INITIALIZE ALL PRESENT MODULES	;
		call kernel.initModules
	
	;	DISPLAY TEXT MODE WELCOME MESSAGE IF NEEDED	;
		call kernel.checkRunTextModeInit
	
	;	INITIALIZE THE AHCI DRIVER	;
		call ATA_DETECT
		
		;call AHCI.searchForDataBlock	; be really surprised if this works!
		mov eax, 0x1
		mov bx, 0x0
		mov edx, 0x200
		call AHCI.DMAread
		;add ecx, 0x1BE
		mov [C.test.val], ecx
		mov ebx, [ecx]
		call console.numOut
		call console.newline
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
		call USB.init
	
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
		call goRealMode
	
	hlt


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
	
	os.mlloc :
		db 0x0
	
	
;	INCLUDES	;

	%include "../$Emulator/StandardIncludes.asm"
	
	
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


;	DATA	;

	TEXTMODE_INIT :
		db "Booted into debug (text) mode.", 0
	
	
;	THE "FILESYSTEM" STARTS HERE IN RAM	;

	MINNOW_START :

	
;	INCLUDES TO BE LISTED AS FILES	;

	%include "..\OrcaHLL\iConsole.asm"
	%include "..\OrcaHLL\Library.asm"
	%include "..\OrcaHLL\VideoInfo.asm"
	%include "..\OrcaHLL\TestProgram.asm"
