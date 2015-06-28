[bits 32]
;	BEGIN EXECUTING THE KERNEL	;
Kernel.init :
		;	SETUP GRAPHICS MODE		;
	call Graphics.init
		
	call Guppy.init
		
		;	INITIALIZING MODULES	;
	call kernel.initModules
	
		call USB_InitController
		
		call USB_EnablePlugAndPlay

		;	LOCK THE COMPUTER	;
	call Manager.lock
		;	CHECK TO SEE IF THE COMPUTER IS LOCKED	;
	call Manager.handleLock
	;call kernel.halt
	
	;	MAIN LOOP	;
	kernel.loop:
			;	RUN INSTALLED MODULES	;
		call kernel.runModules
			;	CHECK TO SEE IF THE COMPUTER IS LOCKED	;
		call Manager.handleLock
			;	REPEAT	;
		jmp kernel.loop
		
	
kernel.runModules :
	mov bl, Manager.CONTROL_MODULES
	mov [os.mlloc], bl
	call console.loop
	;	call card.loop
	call Clock.loop
ret
	
kernel.initModules :
	call Dolphin.init
	call console.init
	;	call card.init
	
	call KeyManager.init
	
	call Clock.init
	call Clock.show	; should be bound to a command!	
ret
	
kernel.halt :
	cli
	mov ebx, kernel.HALT_MESSAGE
	call debug.println
	call goRealMode
	hlt

kernel.HALT_MESSAGE :
db "The operating system is now halted.", 0

os.mlloc :
db 0x0
	
%include "../$Emulator/StandardIncludes.asm"
%include "../_not os code/~DO NOT SYNC/DadCard.asm"

MINNOW_START :