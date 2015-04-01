[bits 32]
[org 0x7e00]
db 0x4a

;	BEGIN EXECUTING THE KERNEL	;
Kernel.init :

	;	INITIALIZING MODULES	;
	call debug.init
	call Guppy.init
	
	;	PALETTE SETTING		;
	call Dolphin.setGrayscalePalette
	call Dolphin.setVGApalette
	
	;	SETTING BAGROUND IMAGE	;
	;mov ebx, bg_name
	;call Minnow.byName
	;call Dolphin.makeBG
	
	;	INITIALIZING PROGRAMS	;
	call console.init
	call View.init
	
	;	ALERT DEBUG OF SYSTEM START		;
	mov ebx, LOAD_FINISH
	call debug.log.system
	
	;	MAIN LOOK	;
	kernel.loop:
	
		;	POLL KEYBOARD FOR DATA	;
		call os.pollKeyboard
		;	RUN REGISTERED PROGRAMS	;
		call console.loop
		call View.loop
		;	PUSH BUFFER TO SCREEN	;
		call Dolphin.updateScreen
		;	REPEAT	;
		jmp kernel.loop
	
	jmp $
	
	
;	INITIALIZE THE PS2 CONTROLLER TO RETURN MOUSE UPDATES	;
Mouse.init :
	push ax
	;	ENABLE AUXILLARY INPUT
	mov al, 0xA8
	out 0x64, al
	;	TELL MOUSE TO LISTEN FOR A COMMAND	;
	mov al, 0xD4
	out 0x64, al
	;	COMMAND MOUSE TO SEND PACKETS	;
	mov al, 0xF4
	out 0x60, al
	
	pop ax
	ret

	
;	MODIFY WHICH SUBROUTIGE IS CALLED ON PRESS OF THE ENTER KEY	;
os.setEnterSub :
	pusha
	
	mov eax, [os.ecatch]
	mov [eax], ebx
	
	popa
	ret

	
;	POLL THE PS2 KEYBOARD FOR DATA	;
os.pollKeyboard :
	pusha
	
	in al, 0x60	; get last keycode
	mov bl, al	; storing code in bl
	and al, 0x80	; 1 if release code, 0 if not
	cmp al, 0x0	; if a key has not been released
	je os.pollKeyboard.checkKey
	mov cx, 0x1	; otherwise a key was released
	mov [os.pollKeyboard.isReady], cx	; store 1 so we know we are ready to read next time
	jmp os.pollKeyboard.return

	os.pollKeyboard.checkKey :
		; key in bl
		mov al, [os.lastKey]
		cmp al, bl
		jne os.pollKeyboard.checkKey.override
		;jmp os.pollKeyboard.return
	mov cx, [os.pollKeyboard.isReady]
	cmp cx, 0x0
	je os.pollKeyboard.return	; if not ready, a key is being held down, dont reprint it
		os.pollKeyboard.checkKey.override :
		push bx
	call os.keyboard.toChar
	cmp bl, 0x1d
		je os.pollKeyboard.drawKeyFinalize	; should not print a modifier byte
	cmp bl, 0x2a
		je os.pollKeyboard.drawKeyFinalize	; should not print a modifier byte
	;cmp al, 0xFF
	;je console.doBackspace;	SHOULD NOT BE COMMENTED OUT
	;cmp al, 0x1
	;je os.doEnter
		cmp bl, 0x50	; down key
		je os.handleSpecial
		cmp bl, 0x4d	; right key
		je os.handleSpecial
		cmp bl, 0x48	; up key
		je os.handleSpecial
		cmp bl, 0x4b	; left key
		je os.handleSpecial
		cmp bl, 0x0f	; tab key
		je os.handleSpecial
		cmp bl, 0x3a	; caps lock
		je os.handleSpecial
		cmp bl, 0x29
		jne os.handlecont
		call Dolphin.activateNext
		jmp os.pollKeyboard.drawKeyFinalize
		os.handlecont :
	mov bl, al
	call os.keyPress	; keypress will be sent to the currently registered program in al
	os.pollKeyboard.drawKeyFinalize :
	mov cx, 0x0
	mov [os.pollKeyboard.isReady], cx	; so we know that we have already printed the character, and should not do so again
	pop bx
	mov [os.lastKey], bl
	os.pollKeyboard.return :
	popa
	ret

	
os.doEnter :
	ret
	;mov bl, 0xFE
	;jmp os.handlecont
	;mov eax, [os.ecatch]
	;mov ebx, [eax]
	;mov ah, 0xB
	;call ebx
	;jmp os.pollKeyboard.drawKeyFinalize

os.keyPress :
	pusha
	mov [0x1030], bl
	mov al, 0xFF
	mov [0x1031], al
	popa
	ret

os.getKey :
	push eax
	;	 check the program is allowed to get keypresses here
	mov al, [currentWindow]
	mov ah, [Dolphin.activeWindow]
	cmp al, ah
		je os.getKey.kcont
	pop eax
	mov bl, 0x0
	ret
	os.getKey.kcont :
	;
	mov bl, 0x0
	mov al, [0x1031]
	cmp al, 0xFF
	jne os.getKey.ret
	mov bl, [0x1030]
	mov al, 0x0
	mov [0x1031], al
	os.getKey.ret :
	pop eax
	ret

os.keyboard.toChar :
	cmp bl, 0x1E
	mov al, 'A'
	je os.keyboard.toChar.ret
	cmp bl, 0x30
	mov al, 'B'
	je os.keyboard.toChar.ret
	cmp bl, 0x2E
	mov al, 'C'
	je os.keyboard.toChar.ret
	cmp bl, 0x20
	mov al, 'D'
	je os.keyboard.toChar.ret
	cmp bl, 0x12
	mov al, 'E'
	je os.keyboard.toChar.ret
	cmp bl, 0x21
	mov al, 'F'
	je os.keyboard.toChar.ret
	cmp bl, 0x22
	mov al, 'G'
	je os.keyboard.toChar.ret
	cmp bl, 0x23
	mov al, 'H'
	je os.keyboard.toChar.ret
	cmp bl, 0x17
	mov al, 'I'
	je os.keyboard.toChar.ret
	cmp bl, 0x24
	mov al, 'J'
	je os.keyboard.toChar.ret
	cmp bl, 0x25
	mov al, 'K'
	je os.keyboard.toChar.ret
	cmp bl, 0x26
	mov al, 'L'
	je os.keyboard.toChar.ret
	cmp bl, 0x32
	mov al, 'M'
	je os.keyboard.toChar.ret
	cmp bl, 0x31
	mov al, 'N'
	je os.keyboard.toChar.ret
	cmp bl, 0x18
	mov al, 'O'
	je os.keyboard.toChar.ret
	cmp bl, 0x19
	mov al, 'P'
	je os.keyboard.toChar.ret
	cmp bl, 0x10
	mov al, 'Q'
	je os.keyboard.toChar.ret
	cmp bl, 0x13
	mov al, 'R'
	je os.keyboard.toChar.ret
	cmp bl, 0x1F
	mov al, 'S'
	je os.keyboard.toChar.ret
	cmp bl, 0x14
	mov al, 'T'
	je os.keyboard.toChar.ret
	cmp bl, 0x16
	mov al, 'U'
	je os.keyboard.toChar.ret
	cmp bl, 0x2F
	mov al, 'V'
	je os.keyboard.toChar.ret
	cmp bl, 0x11
	mov al, 'W'
	je os.keyboard.toChar.ret
	cmp bl, 0x2D
	mov al, 'X'
	je os.keyboard.toChar.ret
	cmp bl, 0x15
	mov al, 'Y'
	je os.keyboard.toChar.ret
	cmp bl, 0x2C
	mov al, 'Z'
	je os.keyboard.toChar.ret
	cmp bl, 0x39
	mov al, ' '
	je os.keyboard.toChar.ret
	cmp bl, 0x34
	mov al, '.'
	je os.keyboard.toChar.ret
	cmp bl, 0x33
	mov al, ','
	je os.keyboard.toChar.ret
	cmp bl, 0x02
	mov al, '1'
	je os.keyboard.toChar.ret
	cmp bl, 0x03
	mov al, '2'
	je os.keyboard.toChar.ret
	cmp bl, 0x04
	mov al, '3'
	je os.keyboard.toChar.ret
	cmp bl, 0x05
	mov al, '4'
	je os.keyboard.toChar.ret
	cmp bl, 0x06
	mov al, '5'
	je os.keyboard.toChar.ret
	cmp bl, 0x07
	mov al, '6'
	je os.keyboard.toChar.ret
	cmp bl, 0x08
	mov al, '7'
	je os.keyboard.toChar.ret
	cmp bl, 0x09
	mov al, '8'
	je os.keyboard.toChar.ret
	cmp bl, 0x0A
	mov al, '9'
	je os.keyboard.toChar.ret
	cmp bl, 0x0B
	mov al, '0'
	je os.keyboard.toChar.ret
	cmp bl, 0x0E	; backspace
	mov al, 0xff
	je os.keyboard.toChar.ret
	cmp bl, 0x1C
	mov al, 0xfe
	je os.keyboard.toChar.ret
	mov al, 0x3f
	mov ecx, charSPACE
	pusha
	and ebx, 0xFF
	call debug.num
	popa
	os.keyboard.toChar.ret :
	ret

retfunc :
	ret

os.handleSpecial :
	pusha
	cmp bl, 0x50
	je os.handleSpecial.down
	cmp bl, 0x48
	je os.handleSpecial.up
	cmp bl, 0x4d
	je os.handleSpecial.right
	cmp bl, 0x4b
	je os.handleSpecial.left
	cmp bl, 0x3a
	je os.handleSpecial.swapMode
	;	else it is a tab, reset the window's position
	mov eax, 0
	mov ebx, 0
	call Dolphin.moveWindowAbsolutte
	jmp os.handleSpecial.ret	; not a huge problem that it calls moveWindow
	os.handleSpecial.up :
	mov eax, 0
	mov ebx, -1
	jmp os.handleSpecial.ret
	os.handleSpecial.left :
	mov eax, -1
	mov ebx, 0
	jmp os.handleSpecial.ret
	os.handleSpecial.right :
	mov eax, 1
	mov ebx, 0
	jmp os.handleSpecial.ret
	os.handleSpecial.down :
	mov eax, 0
	mov ebx, 1
	jmp os.handleSpecial.ret
		os.handleSpecial.swapMode :
		mov bl, [os.hsmode]
		xor bl, 0xFF
		mov [os.hsmode], bl
		popa
		jmp os.pollKeyboard.drawKeyFinalize
	os.handleSpecial.ret :
		push bx
		mov bl, [os.hsmode]
		cmp bl, 0x0
		pop bx
			jne os.handleSpecial.size
		call Dolphin.moveWindow
		jmp os.handleSpecial.aret
	os.handleSpecial.size :
		call Dolphin.sizeWindow
	os.handleSpecial.aret :
	popa
	jmp os.pollKeyboard.drawKeyFinalize

os.halt :
	mov ebx, OK_MSG
	call debug.println
	call Dolphin.updateScreen
	jmp $

os.getProgramNumber :	; returns pnum in bl
	mov bl, [os.pnumCounter]
	add bl, 1
	mov [os.pnumCounter], bl
	push ebx
	mov ebx, PROGRAM_REGISTERED
	call debug.print
	pop ebx
	and ebx, 0xFF
	call debug.num
	call debug.newl
	ret


%include "..\boot\init_GDT.asm"
%include "..\kernel\drawChar.asm"
%include "..\modules\Guppy.asm"
%include "..\modules\Dolphin.asm"
%include "..\modules\programLoader.asm"
%include "..\modules\minnow.asm"
%include "..\modules\iConsole.asm"
%include "..\modules\View.asm"
%include "..\boot\realMode.asm"
%include "..\debug\print.asm"

KERNEL_BOOT :
db "Kernel Successfully Loaded!", 0

OK_MSG :
db "The operating system is now halted.", 0

HARDWARE_BOOT :
db "STATE: Hardware", 0

BOCHS_BOOT :
db "STATE: Emulator", 0

bg_name :
db "TEAMBLDR", 0
txt_name :
db "HELOWRLD", 0

LOAD_FINISH :
db "Transferring control to user!", 0

FILE_DESCR :
db "File name: ", 0

PROGRAM_REGISTERED :
db "A program has been registered: PNUM=", 0

os.pollKeyboard.isReady :
dd 0x0

os.textwidth :
dw 0x0

os.ecatch :
dd 0x10F0

os.lastKey :
dw 0x0

os.pnumCounter :
db 0x0

os.hsmode :
db 0x0

MINNOW_START :