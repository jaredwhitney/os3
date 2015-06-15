Clock.init :
pusha
	call ProgramManager.getProgramNumber
	mov [Clock.pnum], bl
	call Dolphin.create
	mov [Clock.buffer], ebx
	mov [Clock.windowBuffer], ecx
popa
ret

Clock.show :
pusha
	mov eax, Clock.windowStruct
	call Dolphin.registerWindow
	mov ebx, [Clock.buffer]
	call Clock.createTimeString
	call Clock.win_update
popa
ret

Clock.loop :
pusha
	mov ebx, [Clock.buffer]
	call Clock.createTimeString
	call Clock.win_update
	call Keyboard.getKey
	cmp bl, 0x0
		je Clock.loop.ret
	cmp bl, '-'
		jne Clock.loop.nossub
	mov eax, [Clock.size]
	sub eax, 1
	mov [Clock.size], eax
	jmp Clock.loop.ret
	Clock.loop.nossub :
	cmp bl, '='
		jne Clock.loop.ret
		mov eax, [Clock.size]
		add eax, 1
		mov [Clock.size], eax
Clock.loop.ret :
popa
ret

Clock.createTimeString :	; ebx = buffer location
pusha
	call Clock.ensure_cleared
	mov eax, ebx
	xor ebx, ebx
	
	call RTC.getHour	; hours
	mov eax, [Clock.buffer]
	call String.fromHex
	
	call Clock.nav_to_end	; ':'
	mov bh, 0xFF
	mov bl, ':'
	mov [eax], bx
	add eax, 0x2
	
	xor ebx, ebx	; minutes
	call RTC.getMinute
	call Clock.nav_to_end
	call String.fromHex
	
	call Clock.nav_to_end	; ':'
	mov bh, 0xFF
	mov bl, ':'
	mov [eax], bx
	add eax, 0x2
	
	xor ebx, ebx	; seconds
	call RTC.getSecond
	call Clock.nav_to_end
	call String.fromHex
popa
ret

Clock.ensure_cleared :
pusha
	call String.getLength
	mov al, 0x0
	Clock.ensure_cleared.loop :
	mov [ebx], al
	add ebx, 1
	sub edx, 1
	cmp edx, 0x0
		jg Clock.ensure_cleared.loop
popa
ret

Clock.nav_to_end :
	push ebx
	push edx
	mov eax, [Clock.buffer]
	mov ebx, eax
	call String.getLength
	add eax, edx
	sub eax, 1
	pop edx
	pop ebx
ret

Clock.win_update :
pusha
	mov ebx, [Clock.size]
	mov [TextHandler.textSizeMultiplier], ebx
		mov ebx, [Clock.buffer]
		call String.getLength
			mov ebx, edx
		sub edx, 1
		imul edx, [Graphics.bytesPerPixel]
		mov ecx, 3
		imul ecx, [TextHandler.textSizeMultiplier]
		imul edx, ecx		; char width / 2
		add edx, 2
		mov eax, edx
		xor edx, edx
		mov ecx, 4
		idiv ecx
		add eax, 1
		imul eax, 4
		mov [Clock.width], ax
		
		mov ecx, 0x12/2
		imul ecx, [TextHandler.textSizeMultiplier]
		mov [Clock.height], cx
		
	xor ebx, ebx
	mov bl, [Clock.pnum]
	mov [Dolphin.currentWindow], ebx
	mov eax, [Clock.buffer]
	mov ebx, [Clock.windowBuffer]
	mov cx, [Clock.width]
		push ebx
		mov ebx, [Clock.buffer]
		call String.getLength	; length of Time string -> edx
		pop ebx
		mov [Clock.bsize], edx
	call Dolphin.drawText
	mov ebx, 1
	mov [TextHandler.textSizeMultiplier], ebx
popa
ret


Clock.pnum :
	db 0x0
Clock.size :
	dd 0x2
Clock.windowStruct :
	dd "Clock VER_1.0", 0	; title
	Clock.width :
	dw 0x00	; width
	Clock.height :
	dw 0x13	; height
	dw 0x0	; xpos
	dw 0	; ypos
	db 0	; type: 0=text, 1=image
	db 0	; depth, set by Dolphin
	Clock.windowBuffer :
	dd 0x0	; buffer location for storing the updated window
	Clock.buffer :
	dd 0x0	; buffer location for storing data
	Clock.bsize :
	dd 0x0