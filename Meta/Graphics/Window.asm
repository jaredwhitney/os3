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
	; store winNum
	push ecx
	add cl, [Window.WIN_NUM]
	mov [ecx], bl
	pop ecx
; return
push dword [retstor]
ret

;Window.create.NONVESA :
;mov ebx, 0x7D*0x200
;call ProgramManager.reserveMemory
		;mov eax, ebx
		;mov ebx, 0x7D*0x200
;;		call Buffer.clear
		;mov bl, [Window.BUFFER]
		;call Dolphin.setAttribDouble
;mov ebx, 0x7D*0x200
;call ProgramManager.reserveMemory
;		mov eax, ebx
		;mov ebx, 0x7D*0x200
;;		call Buffer.clear
		;mov bl, [Window.OLDBUFFER]
		;call Dolphin.setAttribDouble
;mov ebx, 0x7D*0x200
;call ProgramManager.reserveMemory
		;mov eax, ebx
		;mov ebx, 0x7D*0x200
;;		call Buffer.clear
		;mov bl, [Window.WINDOWBUFFER]
		;call Dolphin.setAttribDouble
		
;popa
;ret

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

Window.makeGlassSmart :
pusha
	mov bl, [Window.X_POS]
	call Dolphin.getAttribWord
	and eax, 0xFFFF
	mov [Window.makeGlassSmart.x], eax
	mov bl, [Window.LASTX_POS]
	call Dolphin.getAttribWord
	and eax, 0xFFFF
	mov [Window.makeGlassSmart.xl], eax
	mov bl, [Window.Y_POS]
	call Dolphin.getAttribWord
	and eax, 0xFFFF
	mov [Window.makeGlassSmart.y], eax
	mov bl, [Window.LASTY_POS]
	call Dolphin.getAttribWord
	and eax, 0xFFFF
	sub eax, 8
	mov [Window.makeGlassSmart.yl], eax
	mov bl, [Window.WIDTH]
	call Dolphin.getAttribWord
	and eax, 0xFFFF
	sub eax, 8
	mov [Window.makeGlassSmart.w], eax
	mov bl, [Window.HEIGHT]
	call Dolphin.getAttribWord
	and eax, 0xFFFF
	add eax, 8
	mov [Window.makeGlassSmart.h], eax
	mov eax, [Graphics.SCREEN_WIDTH]
	mov [Image.clearRegion.imagewidth], eax
	;
	mov eax, [Window.makeGlassSmart.x]
	mov ebx, [Window.makeGlassSmart.xl]
	mov ecx, [Window.makeGlassSmart.y]
	mov edx, [Window.makeGlassSmart.yl]
	;
	add edx, 8	; whoops
	cmp ebx, eax
		jge Window.makeGlassSmart.nif0
	cmp edx, ecx
		jge Window.makeGlassSmart.nif0
				call Window.makeGlassSmart.sub1
				call Window.makeGlassSmart.sub3
				jmp Window.makeGlass.ret
	Window.makeGlassSmart.nif0 :
	cmp ebx, eax
		jle Window.makeGlassSmart.nif1
	cmp edx, ecx
		jle Window.makeGlassSmart.nif1
				call Window.makeGlassSmart.sub4star
				call Window.makeGlassSmart.sub2
				jmp Window.makeGlass.ret
	Window.makeGlassSmart.nif1 :
	cmp ebx, eax
		jle Window.makeGlassSmart.nif2
	cmp edx, ecx
		jge Window.makeGlassSmart.nif2
				call Window.makeGlassSmart.sub3star
				call Window.makeGlassSmart.sub2
				jmp Window.makeGlass.ret
	Window.makeGlassSmart.nif2 :
	cmp ebx, eax
		jge Window.makeGlassSmart.nif3
	cmp edx, ecx
		jle Window.makeGlassSmart.nif3
				call Window.makeGlassSmart.sub1
				call Window.makeGlassSmart.sub4
				jmp Window.makeGlass.ret
	Window.makeGlassSmart.nif3 :
	call Window.makeGlass
Window.makeGlass.ret :
popa
ret

Window.makeGlassSmart.x :
	dd 0x0
Window.makeGlassSmart.xl :
	dd 0x0
Window.makeGlassSmart.y :
	dd 0x0
Window.makeGlassSmart.yl :
	dd 0x0
Window.makeGlassSmart.w :
	dd 0x0
Window.makeGlassSmart.h :
	dd 0x0
Window.makeGlassSmart.dx :
	dd 0x0
Window.makeGlassSmart.dy :
	dd 0x0
Window.makeGlassSmart.dw :
	dd 0x0
Window.makeGlassSmart.dh :
	dd 0x0

Window.makeGlassSmart.sub1 :
pusha
	mov eax, [Window.makeGlassSmart.x]
	sub eax, [Window.makeGlassSmart.xl]
	mov [Window.makeGlassSmart.dw], eax
	;
	mov eax, [Window.makeGlassSmart.yl]
	imul eax, [Graphics.SCREEN_WIDTH]
	add eax, [Graphics.SCREEN_MEMPOS]
	add eax, [Window.makeGlassSmart.xl]
	;
	mov ebx, [Window.makeGlassSmart.dw]
	;
	mov ecx, [Window.makeGlassSmart.h]
	;
	push ebx
	call Dolphin.getSolidBGColor
	mov edx, ebx
	pop ebx
	call Image.clearRegion
popa
ret

Window.makeGlassSmart.sub2 :
pusha
	mov eax, [Window.makeGlassSmart.x]
	add eax, [Window.makeGlassSmart.w]
	mov [Window.makeGlassSmart.dx], eax
	;
	mov eax, [Window.makeGlassSmart.xl]
	sub eax, [Window.makeGlassSmart.x]
		add eax, 8
	mov [Window.makeGlassSmart.dw], eax
	;
	mov eax, [Window.makeGlassSmart.yl]
	imul eax, [Graphics.SCREEN_WIDTH]
	add eax, [Graphics.SCREEN_MEMPOS]
	add eax, [Window.makeGlassSmart.dx]
	;
	mov ebx, [Window.makeGlassSmart.dw]
	;
	mov ecx, [Window.makeGlassSmart.h]
	;
	push ebx
	call Dolphin.getSolidBGColor
	mov edx, ebx
	pop ebx
	call Image.clearRegion
popa
ret

Window.makeGlassSmart.sub3 :
pusha
	mov eax, [Window.makeGlassSmart.xl]
	add eax, [Window.makeGlassSmart.w]
	sub eax, [Window.makeGlassSmart.x]
	mov [Window.makeGlassSmart.dw], eax
	;
	mov eax, [Window.makeGlassSmart.y]
	sub eax, [Window.makeGlassSmart.yl]
	mov [Window.makeGlassSmart.dh], eax
	;
	mov eax, [Window.makeGlassSmart.yl]
	imul eax, [Graphics.SCREEN_WIDTH]
	add eax, [Graphics.SCREEN_MEMPOS]
	add eax, [Window.makeGlassSmart.x]
	;
	mov ebx, [Window.makeGlassSmart.dw]
	;
	mov ecx, [Window.makeGlassSmart.dh]
	;
	push ebx
	call Dolphin.getSolidBGColor
	mov edx, ebx
	pop ebx
	call Image.clearRegion
popa
ret

Window.makeGlassSmart.sub3star :
pusha
	mov eax, [Window.makeGlassSmart.x]
	mov ebx, [Window.makeGlassSmart.xl]
	mov [Window.makeGlassSmart.xl], eax
	mov [Window.makeGlassSmart.x], ebx
			call Window.makeGlassSmart.sub3
	mov eax, [Window.makeGlassSmart.x]
	mov ebx, [Window.makeGlassSmart.xl]
	mov [Window.makeGlassSmart.xl], eax
	mov [Window.makeGlassSmart.x], ebx
popa
ret

Window.makeGlassSmart.sub4 :	; this is broken for some reason :(
pusha
	mov eax, [Window.makeGlassSmart.y]
	add eax, [Window.makeGlassSmart.h]
	mov [Window.makeGlassSmart.dy], eax
	;
	mov eax, [Window.makeGlassSmart.x]
	add eax, [Window.makeGlassSmart.w]
	sub eax, [Window.makeGlassSmart.xl]
	mov [Window.makeGlassSmart.dw], eax
	;
	mov eax, [Window.makeGlassSmart.yl]
	sub eax, [Window.makeGlassSmart.y]
		add eax, 8	; 8 offs + 8 offs + 1 padding?
	mov [Window.makeGlassSmart.dh], eax
	;
	mov eax, [Window.makeGlassSmart.dy]
	imul eax, [Graphics.SCREEN_WIDTH]
	add eax, [Graphics.SCREEN_MEMPOS]
	add eax, [Window.makeGlassSmart.xl]
	;
	mov ebx, [Window.makeGlassSmart.dw]
	;
	mov ecx, [Window.makeGlassSmart.dh]
	;
	push ebx
	call Dolphin.getSolidBGColor
	mov edx, ebx
	pop ebx
	;	mov edx, 0xFF00FF
	call Image.clearRegion
popa
ret

Window.makeGlassSmart.sub4star :
pusha
	mov eax, [Window.makeGlassSmart.x]
	mov ebx, [Window.makeGlassSmart.xl]
	mov [Window.makeGlassSmart.xl], eax
	mov [Window.makeGlassSmart.x], ebx
			call Window.makeGlassSmart.sub4
	mov eax, [Window.makeGlassSmart.x]
	mov ebx, [Window.makeGlassSmart.xl]
	mov [Window.makeGlassSmart.xl], eax
	mov [Window.makeGlassSmart.x], ebx
popa
ret

Window.makeGlass :
pusha
	mov bl, [Window.LASTX_POS]
	call Dolphin.getAttribWord
	push eax
	mov bl, [Window.LASTY_POS]
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
	mov ecx, 0x1000
	idiv ecx
	imul eax, 3
pop ecx
pop edx
ret

Window.forceFlush :	; winnum in currentWindow
pusha
Window.forceFlush.wait :
;cmp byte [Dolphin_WAIT_FLAG], 0xFF
;	je Window.forceFlush.wait
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
Window.WIN_NUM :
db 38