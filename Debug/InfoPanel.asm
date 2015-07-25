InfoPanel.init :
pusha
	call InfoPanel.initProgram
	call InfoPanel.initWindow
call ProgramManager.finalize
popa
ret

InfoPanel.initProgram :
	call ProgramManager.getProgramNumber
	mov [InfoPanel.pnum], bl
	call ProgramManager.setActive
	mov ebx, 0x6000
	call ProgramManager.requestMemory
ret

InfoPanel.initWindow :
	push dword InfoPanel.title
	push word Window.TYPE_TEXT
	call Window.create
	mov [InfoPanel.window], ecx
	mov [InfoPanel.wnum], bl
	
	mov bl, [Window.BUFFER]
	call Dolphin.getAttribDouble
	
	mov ebx, eax
		mov eax, InfoPanel.EMPTY_MESSAGE
	call String.copyRawToWhite	; move String into [ebx]
	call Window.fitTextBufferSize
	mov ax, 0x100
	mov bx, 0x10
	call Dolphin.sizeWindow
	call InfoPanel.win_update
ret

InfoPanel.loop :
pusha
mov bl, [InfoPanel.pnum]
call ProgramManager.setActive	
	xor ebx, ebx
	mov bl, [InfoPanel.wnum]
	call Dolphin.windowExists
	cmp al, 0x0
		je InfoPanel.loop.ret
	call InfoPanel.win_update
InfoPanel.loop.ret :
call ProgramManager.finalize
popa
ret

InfoPanel.win_update :
pusha
	xor ebx, ebx
	mov bl, [InfoPanel.wnum]
	mov [Dolphin.currentWindow], ebx
		mov bl, [Window.BUFFER]
		call Dolphin.getAttribDouble
		mov ebx, [cval]
		call String.fromHex
		call Window.fitTextBufferSize
	call Dolphin.uUpdate
popa
ret

InfoPanel.pnum :
	db 0x0
InfoPanel.wnum :
	db 0x0
InfoPanel.window :
	dd 0x0
InfoPanel.EMPTY_MESSAGE :
	db "            ", 0
InfoPanel.title :
	db "Diagnostics", 0