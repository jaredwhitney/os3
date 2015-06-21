Clock.init :
pusha
	call ProgramManager.getProgramNumber
	mov [Clock.pnum], bl
	
	call ProgramManager.setActive
	
	mov ebx, 0x1000
	call ProgramManager.requestMemory
	
	call ProgramManager.finalize
popa
ret

Clock.show :
pusha
	mov bl, [Clock.pnum]
	call ProgramManager.setActive
	
	mov eax, Clock.windowStruct
	call Window.create
	mov [Clock.wnum], bl
	
	mov bl, [Window.BUFFER]
	call Dolphin.getAttribDouble
	
	mov ebx, eax
	call Clock.createTimeString
	call Clock.win_update
	
	call ProgramManager.finalize
popa
ret

Clock.loop :
pusha
	mov bl, [Clock.pnum]
	call ProgramManager.setActive
	
	xor ebx, ebx
	mov bl, [Clock.wnum]
	mov [Dolphin.currentWindow], ebx

			mov bl, [Window.BUFFER]
			call Dolphin.getAttribDouble
			mov ebx, eax
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

	call ProgramManager.finalize
popa
ret

Clock.createTimeString :	; ebx = buffer location
pusha
	call Clock.ensure_cleared
	mov eax, ebx
	xor ebx, ebx
	
	call RTC.getHour	; hours
	push bx
		mov bl, [Window.BUFFER]
		call Dolphin.getAttribDouble
	pop bx;mov eax, [Clock.buffer]	; this can be commented out?
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
			mov bl, [Window.BUFFER]
			call Dolphin.getAttribDouble
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
			mov bl, [Window.BUFFER]
			call Dolphin.getAttribDouble
			mov ebx, eax
		call String.getLength
		;	mov ebx, edx
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
			push ebx
			mov bl, [Window.WIDTH]
			call Dolphin.setAttribWord
			pop ebx
		
		mov ecx, 0x12/2
		imul ecx, [TextHandler.textSizeMultiplier]
			push ebx
			push ax
			mov bl, [Window.HEIGHT]
			mov ax, cx
			call Dolphin.setAttribWord
			pop ax
			pop ebx
			
	xor ebx, ebx
	mov bl, [Clock.wnum]
	mov [Dolphin.currentWindow], ebx
	
		mov bl, [Window.BUFFER]
		call Dolphin.getAttribDouble
		mov ebx, eax
		call String.getLength	; length of Time string -> edx
		mov bl, [Window.BUFFERSIZE]
		mov eax, edx
		call Dolphin.setAttribDouble
	
	call Dolphin.uUpdate
	
	mov ebx, 1
	mov [TextHandler.textSizeMultiplier], ebx
popa
ret


Clock.pnum :
	db 0x0
Clock.wnum :
	db 0x0
Clock.size :
	dd 0x2
Clock.title :
	db "Clock VER_1.0", 0
Clock.windowStruct :
	dd Clock.title	; title
	dw 0x00	; width
	dw 0x13	; height
	dw 0x0	; xpos
	dw 0	; ypos
	db 0	; type: 0=text, 1=image
	db 0	; depth, set by Dolphin
	dd 0x0	; buffer location for storing the updated window
	dd 0x0	; buffer location for storing data
	dd 0x0