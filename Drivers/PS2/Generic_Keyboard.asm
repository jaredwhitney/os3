;	POLL THE PS2 KEYBOARD FOR DATA	;
Keyboard.poll :
	pusha
	
	in al, 0x60	; get last keycode
	mov bl, al	; storing code in bl
	and al, 0x80	; 1 if release code, 0 if not
	cmp al, 0x0	; if a key has not been released
	je Keyboard.poll.checkKey
	xor bl, 0x80
	cmp bl, 0x2a
	je KeyManager.handleShift.off
	KeyManager.handleShift.off.reentry :
	mov cx, 0x1	; otherwise a key was released
	mov [KeyManager.isReady], cx	; store 1 so we know we are ready to read next time
	jmp Keyboard.poll.return

	Keyboard.poll.checkKey :
		; key in bl
		mov al, [KeyManager.lastKey]
		cmp al, bl
		jne Keyboard.poll.checkKey.override
		;jmp Keyboard.poll.return
	mov cx, [KeyManager.isReady]
	cmp cx, 0x0
	je Keyboard.poll.return	; if not ready, a key is being held down, dont reprint it
		Keyboard.poll.checkKey.override :
		push bx
	call KeyManager.toChar
	cmp bl, 0x1d
		je Keyboard.poll.drawKeyFinalize	; should not print a modifier byte
	;cmp bl, 0x2a
	;	je Keyboard.poll.drawKeyFinalize	; should not print a modifier byte UMMM NEED TO LOOK INTO THIS!
	;cmp al, 0xFF
	;je console.doBackspace;	SHOULD NOT BE COMMENTED OUT
	;cmp al, 0x1
	;je os.doEnter
	push ax
	mov al, [KeyManager.caps]
	cmp al, 0x0
	pop ax
	je os.handlecont
		
		cmp bl, 0x50	; down key
		je KeyManager.handleSpecialKey
		cmp bl, 0x4d	; right key
		je KeyManager.handleSpecialKey
		cmp bl, 0x48	; up key
		je KeyManager.handleSpecialKey
		cmp bl, 0x4b	; left key
		je KeyManager.handleSpecialKey
		cmp bl, 0x0f	; tab key
		je KeyManager.handleSpecialKey
		cmp bl, 0x3a	; caps lock
		je KeyManager.handleSpecialKey
		cmp bl, 0x29
		jne os.handlecont
		call Dolphin.activateNext
		jmp Keyboard.poll.drawKeyFinalize
		os.handlecont :
		cmp bl, 0x3a
		je Keyboard.poll.drawKeyFinalize
	jmp KeyManager.handleShift
	KeyManager.handleShift.reentry :
	mov bl, al
	call KeyManager.keyPress	; keypress will be sent to the currently registered program in al
	Keyboard.poll.drawKeyFinalize :
	mov cx, 0x0
	mov [KeyManager.isReady], cx	; so we know that we have already printed the character, and should not do so again
	pop bx
	mov [KeyManager.lastKey], bl
	Keyboard.poll.return :
	popa
	ret

KeyManager.handleShift :	; charcode in bl
	cmp bl, 0x2a
	je KeyManager.handleShift.on	; DONT JUMP, handle it
	push ax
	mov al, [KeyManager.caps]
	cmp al, 0x0
	pop ax
	je KeyManager.handleShift.ret
	cmp al, 0x61
	jl KeyManager.handleShift.ret
	cmp al, 0x7a
	jg KeyManager.handleShift.ret
	sub al, 0x20
	KeyManager.handleShift.ret :
	jmp KeyManager.handleShift.reentry
	KeyManager.handleShift.on :
		push ax
		mov al, 0xFF
		mov [KeyManager.caps], al
		pop ax
		jmp Keyboard.poll.drawKeyFinalize
	KeyManager.handleShift.off :
		push ax
		mov al, 0x0
		mov [KeyManager.caps], al
		pop ax
		jmp KeyManager.handleShift.off.reentry

KeyManager.keyPress :
	pusha
	mov [0x1030], bl
	mov al, 0xFF
	mov [0x1031], al
	popa
	ret

Keyboard.getKey :
	push eax
	;	 check the program is allowed to get keypresses here
	mov al, [Dolphin.currentWindow]
	mov ah, [Dolphin.activeWindow]
	cmp al, ah
		je Keyboard.getKey.kcont
	pop eax
	mov bl, 0x0
	ret
	Keyboard.getKey.kcont :
	;
	mov bl, 0x0
	mov al, [0x1031]
	cmp al, 0xFF
	jne Keyboard.getKey.ret
	mov bl, [0x1030]
	mov al, 0x0
	mov [0x1031], al
	Keyboard.getKey.ret :
	pop eax
	ret

KeyManager.toChar :
	cmp bl, 0x1E
	mov al, 'a'
	je KeyManager.toChar.ret
	cmp bl, 0x30
	mov al, 'b'
	je KeyManager.toChar.ret
	cmp bl, 0x2E
	mov al, 'c'
	je KeyManager.toChar.ret
	cmp bl, 0x20
	mov al, 'd'
	je KeyManager.toChar.ret
	cmp bl, 0x12
	mov al, 'e'
	je KeyManager.toChar.ret
	cmp bl, 0x21
	mov al, 'f'
	je KeyManager.toChar.ret
	cmp bl, 0x22
	mov al, 'g'
	je KeyManager.toChar.ret
	cmp bl, 0x23
	mov al, 'h'
	je KeyManager.toChar.ret
	cmp bl, 0x17
	mov al, 'i'
	je KeyManager.toChar.ret
	cmp bl, 0x24
	mov al, 'j'
	je KeyManager.toChar.ret
	cmp bl, 0x25
	mov al, 'k'
	je KeyManager.toChar.ret
	cmp bl, 0x26
	mov al, 'l'
	je KeyManager.toChar.ret
	cmp bl, 0x32
	mov al, 'm'
	je KeyManager.toChar.ret
	cmp bl, 0x31
	mov al, 'n'
	je KeyManager.toChar.ret
	cmp bl, 0x18
	mov al, 'o'
	je KeyManager.toChar.ret
	cmp bl, 0x19
	mov al, 'p'
	je KeyManager.toChar.ret
	cmp bl, 0x10
	mov al, 'q'
	je KeyManager.toChar.ret
	cmp bl, 0x13
	mov al, 'r'
	je KeyManager.toChar.ret
	cmp bl, 0x1F
	mov al, 's'
	je KeyManager.toChar.ret
	cmp bl, 0x14
	mov al, 't'
	je KeyManager.toChar.ret
	cmp bl, 0x16
	mov al, 'u'
	je KeyManager.toChar.ret
	cmp bl, 0x2F
	mov al, 'v'
	je KeyManager.toChar.ret
	cmp bl, 0x11
	mov al, 'w'
	je KeyManager.toChar.ret
	cmp bl, 0x2D
	mov al, 'x'
	je KeyManager.toChar.ret
	cmp bl, 0x15
	mov al, 'y'
	je KeyManager.toChar.ret
	cmp bl, 0x2C
	mov al, 'z'
	je KeyManager.toChar.ret
	cmp bl, 0x39
	mov al, ' '
	je KeyManager.toChar.ret
	cmp bl, 0x34
	mov al, '.'
	je KeyManager.toChar.ret
	cmp bl, 0x33
	mov al, ','
	je KeyManager.toChar.ret
	cmp bl, 0x02
	mov al, '1'
	je KeyManager.toChar.ret
	cmp bl, 0x03
	mov al, '2'
	je KeyManager.toChar.ret
	cmp bl, 0x04
	mov al, '3'
	je KeyManager.toChar.ret
	cmp bl, 0x05
	mov al, '4'
	je KeyManager.toChar.ret
	cmp bl, 0x06
	mov al, '5'
	je KeyManager.toChar.ret
	cmp bl, 0x07
	mov al, '6'
	je KeyManager.toChar.ret
	cmp bl, 0x08
	mov al, '7'
	je KeyManager.toChar.ret
	cmp bl, 0x09
	mov al, '8'
	je KeyManager.toChar.ret
	cmp bl, 0x0A
	mov al, '9'
	je KeyManager.toChar.ret
	cmp bl, 0x0B
	mov al, '0'
	je KeyManager.toChar.ret
	cmp bl, 0x0E	; backspace
	mov al, 0xff
	je KeyManager.toChar.ret
	cmp bl, 0x1C
	mov al, 0xfe
	je KeyManager.toChar.ret
	cmp bl, 0x51	; pgdown
	mov al, 0xfd
	je KeyManager.toChar.ret
	cmp bl, 0x49	; pgup
	mov al, 0xfc
	je KeyManager.toChar.ret
	mov al, 0x3f
	pusha
	and ebx, 0xFF
		push ebx
		mov ebx, KeyManager.INVALID_CHAR
		call debug.print
		pop ebx
		call debug.num
		call debug.newl
	popa
	KeyManager.toChar.ret :
	ret

KeyManager.handleSpecialKey :
	pusha
	cmp bl, 0x50
	je KeyManager.handleSpecialKey.down
	cmp bl, 0x48
	je KeyManager.handleSpecialKey.up
	cmp bl, 0x4d
	je KeyManager.handleSpecialKey.right
	cmp bl, 0x4b
	je KeyManager.handleSpecialKey.left
	cmp bl, 0x3a
	je KeyManager.handleSpecialKey.swapMode
	;	else it is a tab, reset the window's position
	mov bh, [Dolphin.activeWindow]
	mov [Dolphin.currentWindow], bh
	mov eax, 0
	mov ebx, 0
	call Dolphin.moveWindowAbsolute
	jmp KeyManager.handleSpecialKey.ret	; not a huge problem that it calls moveWindow
	KeyManager.handleSpecialKey.up :
	mov eax, 0
	mov ebx, -4
	jmp KeyManager.handleSpecialKey.ret
	KeyManager.handleSpecialKey.left :
	mov eax, -4
	imul eax, [Graphics.bytesPerPixel]
	mov ebx, 0
	jmp KeyManager.handleSpecialKey.ret
	KeyManager.handleSpecialKey.right :
	mov eax, 4
	imul eax, [Graphics.bytesPerPixel]
	mov ebx, 0
	jmp KeyManager.handleSpecialKey.ret
	KeyManager.handleSpecialKey.down :
	mov eax, 0
	mov ebx, 4
	jmp KeyManager.handleSpecialKey.ret
		KeyManager.handleSpecialKey.swapMode :
		mov bl, [KeyManager.hsmode]
		xor bl, 0xFF
		mov [KeyManager.hsmode], bl
		popa
		jmp Keyboard.poll.drawKeyFinalize
	KeyManager.handleSpecialKey.ret :
		push bx
			mov bh, [Dolphin.activeWindow]
			mov [Dolphin.currentWindow], bh
		pop bx
		push bx
		mov bl, [KeyManager.hsmode]
		cmp bl, 0x0
		pop bx
			jne KeyManager.handleSpecialKey.size
		call Dolphin.moveWindow
		jmp KeyManager.handleSpecialKey.aret
	KeyManager.handleSpecialKey.size :
		call Dolphin.sizeWindow
	KeyManager.handleSpecialKey.aret :
	popa
	jmp Keyboard.poll.drawKeyFinalize

	
KeyManager.hsmode :
db 0x0

KeyManager.caps :
db 0x0

KeyManager.INVALID_CHAR :
db "Unrecognized keycode: ", 0

KeyManager.isReady :
dd 0x0

KeyManager.lastKey :
dw 0x0
