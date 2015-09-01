WINDOW_CLASS_SIZE equ 47

Window.create.createBuffers :
pusha

	;mov dl, [Graphics.VESA_MODE]
	;cmp dl, 0x0
	;	je Window.create.NONVESA
	
	mov ebx, [Graphics.SCREEN_SIZE]
	call ProgramManager.reserveMemory
		mov eax, ebx
		mov ebx, [Graphics.SCREEN_SIZE]
		call Buffer.clear
		mov bl, [Window.BUFFER]
		call Dolphin.setAttribDouble
	
	mov ebx, [Graphics.SCREEN_SIZE]
	call ProgramManager.reserveMemory
		mov eax, ebx
		mov ebx, [Graphics.SCREEN_SIZE]
		call Buffer.clear
		mov bl, [Window.OLDBUFFER]
		call Dolphin.setAttribDouble
	
	mov ebx, [Graphics.SCREEN_SIZE]
	call ProgramManager.reserveMemory
		mov eax, ebx
		mov ebx, [Graphics.SCREEN_SIZE]
		call Buffer.clear
		mov bl, [Window.WINDOWBUFFER]
		call Dolphin.setAttribDouble

popa
ret	; returns buffer locations in ebx, ecx

Window.create :	; String title, byte type : returns ebx (bl) = winNum, ecx = object pointer
pop dword [retstor]
pop dx
pop ecx
	
	call Window.create.allocNewWindow
	
	mov eax, ebx
	push ebx
	call Dolphin.registerWindow
	and ebx, 0xFF
	mov [Dolphin.currentWindow], ebx
	call Window.create.createBuffers
	pop ecx
push dword [retstor]
ret

;Window.create.NONVESA :
mov ebx, 0x7D*0x200
call ProgramManager.reserveMemory
		mov eax, ebx
		mov ebx, 0x7D*0x200
;		call Buffer.clear
		mov bl, [Window.BUFFER]
		call Dolphin.setAttribDouble
mov ebx, 0x7D*0x200
call ProgramManager.reserveMemory
		mov eax, ebx
		mov ebx, 0x7D*0x200
;		call Buffer.clear
		mov bl, [Window.OLDBUFFER]
		call Dolphin.setAttribDouble
mov ebx, 0x7D*0x200
call ProgramManager.reserveMemory
		mov eax, ebx
		mov ebx, 0x7D*0x200
;		call Buffer.clear
		mov bl, [Window.WINDOWBUFFER]
		call Dolphin.setAttribDouble
		
popa
ret

retstor :
	dd 0x0
Window.create.allocNewWindow :

	mov ebx, WINDOW_CLASS_SIZE	; window size
	call ProgramManager.reserveMemory
	push ebx
	mov [ebx], ecx			; title
	add ebx, 4
	mov word [ebx], 0x90		; width
	add ebx, 4
	mov word [ebx], 0x40		; height
	add ebx, 4
	mov word [ebx], 0		; xpos
	add ebx, 4
	mov word [ebx], 8		; ypos
	add ebx, 4
	mov [ebx], dl			; type
	add ebx, 1
	mov byte [ebx], 0		; depth
	add ebx, 1
	mov dword [ebx], 0		; buffer
	add ebx, 4
	mov dword [ebx], 0		; windowbuffer
	add ebx, 4
	mov dword [ebx], 0		; buffersize
	add ebx, 8
	mov byte [ebx], 0	; needsRectUpdate
	pop ebx
ret

Window.makeGlass :
pusha
	mov bl, [Window.X_POS]
	call Dolphin.getAttribWord
	push eax
	mov bl, [Window.Y_POS]
	call Dolphin.getAttribWord
	sub eax, 8
	mov ebx, eax
	push bx
	mov bl, [Window.WIDTH]
	call Dolphin.getAttribWord
	mov ecx, eax
	mov bl, [Window.HEIGHT]
	call Dolphin.getAttribWord
	add eax, 8
	mov edx, eax
	pop bx
	pop eax
	
	push edx
	mov edx, [Graphics.SCREEN_WIDTH]
	sub edx, ecx
	mov [Window.makeGlass.lineVal], edx
	pop edx
	
	add eax, [Graphics.SCREEN_MEMPOS]
	imul ebx, [Graphics.SCREEN_WIDTH]
	add eax, ebx	; window position on screen
	
	call Dolphin.getSolidBGColor
	
	Window.mG_l0 :
		push ecx
		Window.mG_l1 :
			mov [eax], ebx
			add eax, 4
			sub ecx, 4
			cmp ecx, 0
				jg Window.mG_l1
		pop ecx
		add eax, [Window.makeGlass.lineVal]
		sub edx, 1
		cmp edx, 0
			jg Window.mG_l0
	
popa
ret
Window.makeGlass.lineVal :
	dd 0x0

Window.getSectorSize :
push edx
push ecx
	mov eax, [Graphics.SCREEN_SIZE]
	add eax, WINDOW_CLASS_SIZE
	xor edx, edx
	mov ecx, 0x200
	idiv ecx
	imul eax, 3
pop ecx
pop edx
ret

Window.forceFlush :	; winnum in currentWindow
pusha
;mov byte [Dolphin_WAIT_FLAG], 0xFF
	mov bl, [Window.OLDBUFFER]
	call Dolphin.getAttribDouble
	;mov ebx, eax
	;call String.getLength
	mov ebx, [Graphics.SCREEN_SIZE];edx
	call Buffer.clear
		mov bl, [Window.WIDTH]
		call Dolphin.getAttribWord
		mov ecx, eax
		and ecx, 0xFFFF
		mov bl, [Window.HEIGHT]
		call Dolphin.getAttribWord
		and eax, 0xFFFF
		imul ecx, eax
		mov bl, [Window.WINDOWBUFFER]
		call Dolphin.getAttribDouble
		mov ebx, ecx
		call Buffer.clear
;mov byte [Dolphin_WAIT_FLAG], 0x0
popa
ret


Window.TYPE_TEXT equ 0x0
Window.TYPE_IMAGE equ 0x1

Window.TITLE :
db 0
Window.WIDTH :
db 4
Window.LASTWIDTH :
db 6
Window.HEIGHT :
db 8
Window.LASTHEIGHT :
db 10
Window.X_POS :
db 12
Window.LASTX_POS :
db 14
Window.Y_POS :
db 16
Window.LASTY_POS :
db 18
Window.TYPE :
db 20
Window.DEPTH :
db 21
Window.WINDOWBUFFER :
db 22
Window.BUFFER :
db 26
Window.BUFFERSIZE :
db 30
Window.OLDBUFFER :
db 34
Window.NEEDS_RECT_UPDATE :
db 38
Window.RECTL_BASE :
db 39
Window.RECTL_TOP :
db 43