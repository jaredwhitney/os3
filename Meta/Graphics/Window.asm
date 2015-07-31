Window.create.createBuffers :
pusha

	mov dl, [Graphics.VESA_MODE]
	cmp dl, 0x0
		je Window.create.NONVESA
	
	mov ebx, 0x2800*0x200
	call ProgramManager.reserveMemory
		mov eax, ebx
		mov bl, [Window.BUFFER]
		call Dolphin.setAttribDouble
	
	mov ebx, 0x2800*0x200
	call ProgramManager.reserveMemory
		mov eax, ebx
		mov bl, [Window.OLDBUFFER]
		call Dolphin.setAttribDouble
	
	mov ebx, 0x2800*0x200
	call ProgramManager.reserveMemory
		mov eax, ebx
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
	call Dolphin.registerWindow
	and ebx, 0xFF
	mov [Dolphin.currentWindow], ebx
	call Window.create.createBuffers
	
push dword [retstor]
ret

Window.create.NONVESA :
mov ebx, 0x7D*0x200
call ProgramManager.reserveMemory
		mov eax, ebx
		mov bl, [Window.BUFFER]
		call Dolphin.setAttribDouble
mov ebx, 0x7D*0x200
call ProgramManager.reserveMemory
		mov eax, ebx
		mov bl, [Window.OLDBUFFER]
		call Dolphin.setAttribDouble
mov ebx, 0x7D*0x200
call ProgramManager.reserveMemory
		mov eax, ebx
		mov bl, [Window.WINDOWBUFFER]
		call Dolphin.setAttribDouble
popa
ret

retstor :
	dd 0x0
Window.create.allocNewWindow :

	mov ebx, 30	; window size
	call ProgramManager.reserveMemory
	push ebx
	mov [ebx], ecx			; title
	add ebx, 4
	mov word [ebx], 4		; width
	add ebx, 2
	mov word [ebx], 4		; height
	add ebx, 2
	mov word [ebx], 0		; xpos
	add ebx, 2
	mov word [ebx], 8		; ypos
	add ebx, 2
	mov [ebx], dl			; type
	add ebx, 1
	mov byte [ebx], 0		; depth
	add ebx, 1
	mov dword [ebx], 0		; buffer
	add ebx, 4
	mov dword [ebx], 0		; windowbuffer
	add ebx, 4
	mov dword [ebx], 0		; buffersize
	pop ebx
ret

Window.fitTextBufferSize :
pusha
	mov bl, [Window.BUFFER]
	call Dolphin.getAttribDouble
	mov ebx, eax
	call String.getLength
	
	mov eax, edx
	mov bl, [Window.BUFFERSIZE]
	call Dolphin.setAttribDouble
popa
ret


Window.TYPE_TEXT equ 0x0
Window.TYPE_IMAGE equ 0x1

Window.TITLE :
db 0
Window.WIDTH :
db 4
Window.HEIGHT :
db 6
Window.X_POS :
db 8
Window.Y_POS :
db 10
Window.TYPE :
db 12
Window.DEPTH :
db 13
Window.WINDOWBUFFER :
db 14
Window.BUFFER :
db 18
Window.BUFFERSIZE :
db 22
Window.OLDBUFFER :
db 26