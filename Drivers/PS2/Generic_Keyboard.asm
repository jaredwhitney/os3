KeyManager.init :
pusha
	mov al, 0x1
	mov ebx, 0x10
	call Guppy.malloc
	mov [Keyboard_buffer], ebx
popa
ret

;	POLL THE PS2 KEYBOARD FOR DATA	;
Keyboard.poll :
	pusha
	
	in al, 0x60	; get last keycode
	mov bl, al	; storing code in bl
	and al, 0x80	; 1 if release code, 0 if not
	cmp al, 0x0	; if a key has not been released
		je Keyboard.poll.checkKey
		
	xor bl, 0x80
	mov cx, 0x1	; otherwise a key was released
	mov [KeyManager.isReady], cx	; store 1 so we know we are ready to read next time
	cmp bl, 0x2a
		jne Keyboard.poll.return
	; shift key has been released !
	mov byte [KeyManager.caps], 0x0
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
	
	call KeyManager.handleShift
	
	cmp bl, 0x1d
		je Keyboard.poll.drawKeyFinalize	; should not print a modifier byte
	cmp bl, 0x2a
		je Keyboard.poll.drawKeyFinalize	; should not print a modifier byte UMMM NEED TO LOOK INTO THIS!
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
		cmp bl, 0x1		; escape
		je KeyManager.handleSpecialKey
		cmp bl, 0x29
		jne os.handlecont
		call Dolphin.activateNext
		jmp Keyboard.poll.drawKeyFinalize
		os.handlecont :
		;cmp bl, 0x3a
		;je Keyboard.poll.drawKeyFinalize
		
		;jmp KeyManager.handleShift
		
	;KeyManager.handleShift.reentry :
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
	push ebx
	cmp bl, 0x2a
		je KeyManager.handleShift.on	; DONT JUMP, handle it
	push ax
	mov al, [KeyManager.caps]
	cmp al, 0x0
	pop ax
	je KeyManager.handleShift.ret
	
	mov ecx, KeyManager.shiftSpecialCases
	.specialCaseLoop :
	cmp al, [ecx]
		je .handleSpecialCase
	add ecx, 2
	cmp byte [ecx], 0x0
		jne .specialCaseLoop
	jmp .notSpecialCase
	.handleSpecialCase :
		mov al, [ecx+1]
		jmp .ret
	.notSpecialCase :
	
	cmp al, 0x61
	jl KeyManager.handleShift.ret
	cmp al, 0x7a
	jg KeyManager.handleShift.ret
	sub al, 0x20
	
	KeyManager.handleShift.ret :
	pop ebx
	ret
	KeyManager.handleShift.on :
		push ax
		mov al, 0xFF
		mov [KeyManager.caps], al
		pop ax
		pop ebx
		ret
KeyManager.shiftSpecialCases :
	db '`', '~', '1', '!', '2', '@', '3', '#', '4', '$', '5', '%', '6', '^', '7', '&', '8', '*', '9', '(', '0', ')', '-', '_', '=', '+', '[', '{', ']', '}', ';', ':', "'", '"', ',', '<', '.', '>', '/', '?', '\', '|', 0x0, 0x0

KeyManager.keyPress :	; key in bl
pusha
	; old code kept for compatability
	;mov [0x1030], bl
	;mov al, 0xFF
	;mov [0x1031], al
	
	; new code
	cmp bl, 0x0
		je KeyManager.keyPress.ret
		pusha	; shift all elements up in the array
			mov eax, [KeyManager.bufferpos]
			mov ebx, [Keyboard_buffer]
			mov cl, [ebx]
			KeyManager.keyPress.arrLoop :
			add ebx, 1
			mov dl, [ebx]
			mov [ebx], cl
			mov cl, dl
			sub eax, 1
			cmp eax, 0x0
				jg KeyManager.keyPress.arrLoop
		popa
	mov eax, [Keyboard_buffer]
	mov [eax], bl
	mov eax, [KeyManager.bufferpos]
	add eax, 1
	mov [KeyManager.bufferpos], eax
	KeyManager.keyPress.ret :
popa
			push ebx
			mov [Component.keyChar], al	; NEED TO NOT DO THIS
		;	call WinMan.HandleKeyEvent
			mov ebx, [Dolphin2.started]
			cmp ebx, 0x0
				je qwerfasdf
			mov ebx, [Dolphin2.focusedComponent]
			call Component.HandleKeyboardEvent
			qwerfasdf :
			pop ebx
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
	
	; old code
	;mov bl, 0x0
	;mov al, [0x1031]
	;cmp al, 0xFF
	;jne Keyboard.getKey.ret
	;mov bl, [0x1030]
	;mov al, 0x0
	;mov [0x1031], al
	;Keyboard.getKey.ret :
	
	;jmp Keyboard.getKey.new_retk
	
	; new code
	mov bl, 0x0
	push ecx
	mov ecx, [KeyManager.bufferpos]
	cmp ecx, 0x0
		je Keyboard.getKey.new_ret
	mov eax, [Keyboard_buffer]
	add eax, ecx
	sub eax, 1
	mov bl, [eax]
	sub ecx, 1
	mov [KeyManager.bufferpos], ecx
	Keyboard.getKey.new_ret :
	pop ecx
	Keyboard.getKey.new_retk :
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
	cmp bl, 0x1A
	mov al, '['
	je KeyManager.toChar.ret
	cmp bl, 0x1B
	mov al, ']'
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
	cmp bl, 0x0C
	mov al, '-'
	je KeyManager.toChar.ret
	cmp bl, 0x0D
	mov al, '='
	je KeyManager.toChar.ret
	cmp bl, 0x28
	mov al, "'"
	je KeyManager.toChar.ret
	cmp bl, 0x0E	; backspace
	mov al, 0xff
	je KeyManager.toChar.ret
	cmp bl, 0x1C
	mov al, 0xfe	; enter
	je KeyManager.toChar.ret
	cmp bl, 0x51	; pgdown
	mov al, 0xfd
	je KeyManager.toChar.ret
	cmp bl, 0x49	; pgup
	mov al, 0xfc
	je KeyManager.toChar.ret
	cmp bl, 0x48	; UP ARROW
	mov al, 0xfb
	je KeyManager.toChar.ret
	cmp bl, 0x4D	; RIGHT ARROW
	mov al, 0xfa
	je KeyManager.toChar.ret
	cmp bl, 0x4B
	mov al, 0xf9	; LEFT ARROW
	je KeyManager.toChar.ret
	mov al, bl
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
	push word [Dolphin.currentWindow]
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
	cmp bl, 0x1
	je KeyManager.handleSpecialKey.closeWindow
	;	else it is a tab, reset the window's position
	mov bh, [Dolphin.activeWindow]
	mov [Dolphin.currentWindow], bh
	mov eax, 0
	mov ebx, 8
	call Dolphin.moveWindowAbsolute
	jmp KeyManager.handleSpecialKey.aret	; not a huge problem that it calls moveWindow
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
		pop word [Dolphin.currentWindow]
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
	pop word [Dolphin.currentWindow]
	popa
	jmp Keyboard.poll.drawKeyFinalize

	KeyManager.handleSpecialKey.closeWindow :
	mov bl, [Dolphin.activeWindow]
	call Dolphin.unregisterWindow
	jmp KeyManager.handleSpecialKey.aret
	
KeyManager.hasEvent :
push bx
	mov bl, [Dolphin.currentWindow]
	mov bh, [Dolphin.activeWindow]
	cmp bl, bh
		jne KeyManager.hasEvent.false
	mov ecx, [KeyManager.bufferpos]
	cmp ecx, 0x0
		je KeyManager.hasEvent.false
	mov cl, 0xFF
	jmp KeyManager.hasEvent.ret
	KeyManager.hasEvent.false :
	mov cl, 0x00
	KeyManager.hasEvent.ret :
pop bx
ret

	
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

Keyboard_buffer :
dd 0x0

KeyManager.bufferpos :
dd 0x0
