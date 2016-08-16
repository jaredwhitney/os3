[bits 32]
Catfish.notify :	; eax = text
	pusha
	mov [Catfish.buffer], eax
	call Catfish.createWindow
	popa
	ret
Catfish.createWindow :
	pusha
	mov ecx, [Dolphin.activeWindow]
	xor ebx, ebx
	mov bl, [Catfish.wnum]
	mov eax, [Catfish.active]
	cmp eax, 0x0
		je Catfish.nocleanup
	call Dolphin.unregisterWindow
	Catfish.nocleanup :
		mov eax, Catfish.windowStruct
		call Dolphin.registerWindow
		mov [Catfish.wnum], bl
			mov [Dolphin.currentWindow], bl
			mov eax, 0;Graphics.SCREEN_WIDTH/2-5	; xpos	THIS NEEDS TO BE FIXED!!!
			mov ebx, [Graphics.SCREEN_HEIGHT]	; ypos
			call Dolphin.moveWindowAbsolute
	mov [Dolphin.activeWindow], ecx
	mov eax, 0xFF
	xor edx, edx
	mov [Catfish.count], edx
	mov [Catfish.active], eax
	popa
	ret
Catfish.loop :
	pusha
	mov eax, [Catfish.active]
	cmp eax, 0
		je Catfish.loop.ret
	xor ebx, ebx
	mov bl, [Catfish.wnum]
	mov [Dolphin.currentWindow], bl
	;call Dolphin.windowExists
	;cmp eax, 0x0
	;	je Catfish.loop.ret	; if no window to deal with, return
	;	if we are here, the window is visible!
	call Catfish.updateWindow
	mov eax, [Catfish.count]
	xor ebx, ebx
	mov bx, [Catfish.height]
	add ebx, 5
	cmp eax, ebx
	mov edx, -1
		jl Catfish.movWin	; if not fully on screen yet keep moving there
	add ebx, 0x500
	cmp eax, ebx
		jl Catfish.loop.cont	; if not done displaying return
	xor edx, edx
	mov dx, [Catfish.height]
	add ebx, edx
	add ebx, 5
	cmp eax, ebx
	mov edx, 1
	jl Catfish.movWin
	mov bl, [Catfish.wnum]		; else unregister
	call Dolphin.unregisterWindow
		mov eax, 0x0
		mov [Catfish.active], eax
	Catfish.loop.cont :
		mov eax, [Catfish.count]
		add eax, 1
		mov [Catfish.count], eax
	Catfish.loop.ret :
	popa
	ret
	Catfish.movWin :
		mov bh, [Catfish.wnum]
		mov [Dolphin.currentWindow], bh
		xor eax, eax
		mov ebx, edx
		call Dolphin.moveWindow
		jmp Catfish.loop.cont
	Catfish.updateWindow :
				mov bx, 0xE0
				mov [Dolphin.colorOverride], bl
			mov eax, [Catfish.buffer]
			mov ebx, [Catfish.windowBuffer]
			mov cx, [Catfish.width]
			call Catfish.getLength
		call Dolphin.drawText
				mov bx, 0x0
				mov [Dolphin.colorOverride], bl
			;mov eax, [Catfish.buffer]
			;mov ebx, [Catfish.windowBuffer]
			;xor ecx, ecx
			;xor edx, edx
			;mov cx, [Catfish.width]
			;mov dx, [Catfish.height]
		;call Image.copyLinear
		ret
Catfish.getLength :	; String in eax, return length in edx
	push eax
	push bx
		xor edx, edx
		Catfish.getLength.loop :
		mov bl, [eax]
		cmp edx, 0x100
			jg Catfish.getLength.done
		add eax, 1
		add edx, 1
		cmp bl, 0x0
			jne Catfish.getLength.loop
		sub edx, 1
	Catfish.getLength.done :
	pop bx
	pop eax
	ret
Catfish.init :
	call ProgramManager.getProgramNumber
	mov [Catfish.pnum], bl
	call Window.create	; will not work
	mov [Catfish.buffer], ecx
	mov [Catfish.windowBuffer], ebx
	ret

Catfish.testMsg :
	db "Ima catfish.", 0xA0, "Meow!", 0x0
Catfish.pnum :
	db 0x0
Catfish.wnum :
	db 0xff
Catfish.count :
	dd 0x0
Catfish.active :
	dd 0x0
Catfish.windowStruct :
	dd "CATFISH VER_1.00"	; title
	Catfish.width :
	dw 0x140/2	; width		SHOULD NOT BE HARDCODED???
	Catfish.height :
	dw 40	; height
	dw 0	; xpos		GENERALLY NOT 0
	dw Graphics.SCREEN_HEIGHT	; ypos
	db 0	; type: 0=text, 1=image
	db 0	; depth, set by Dolphin
	Catfish.windowBuffer :
	dd 0x0	; buffer location for storing the updated window
	Catfish.buffer :
	dd 0x0	; buffer location for storing data