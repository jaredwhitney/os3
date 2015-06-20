[bits 32]

WHITE equ 0xFF
GREEN equ 0xC
PINK equ 0x17
BLUE equ 0x30
ORANGE equ 0xF

View.init :
pusha
	call ProgramManager.getProgramNumber
	mov [View.pnum], bl
	call Dolphin.create
	mov [View.buffer], ecx
	mov [View.windowBuffer], ebx
popa
ret

View.file :	; ebx contains file name
pusha
call Minnow.byName
	cmp ebx, 0x0
	je View.file.bad_file
			pusha
			sub ebx, 16	; THIS IS WRONG!
			mov ebx, [ebx]
			mov [fszstor], ebx
			;call debug.num
			popa
mov edx, ebx
call Minnow.getType
call debug.println
	push ebx
	mov ebx, View.OK
	call debug.println
	pop ebx
mov eax, Minnow.IMAGE
call os.seq
cmp al, 0x1
je View.file.image
mov eax, Minnow.ANIMATION
call os.seq
cmp al, 0x1
je View.file.animation
mov eax, Minnow.TEXT
call os.seq
cmp al, 0x1
je View.file.text
jmp View.file.unknownFile
View.file.return :
popa
ret

View.file.bad_file :
mov bl, 0x3
call console.setColor
mov ebx, Minnow.FILE_NOT_FOUND
call console.println
jmp View.file.return

View.file.unknownFile :
mov ebx, View.FILE_TYPE_UNSUPPORTED
call debug.log.info
jmp View.file.return

View.winSetup :
		pusha
			xor ebx, ebx
			mov bl, [View.wnum]
			call Dolphin.windowExists
			cmp eax, 0x0
				je View.nocleanup
			call Dolphin.unregisterWindow
			View.nocleanup :
		mov eax, View.windowStruct
		call Dolphin.registerWindow
			mov [View.wnum], bl
		popa
		ret
View.winSize :
	pusha
		mov bl, [View.wnum]
		mov [Dolphin.currentWindow], bl
		mov eax, ecx
		mov bl, [Window.WIDTH]
		call Dolphin.setAttribWord
		mov eax, edx
		mov bl, [Window.HEIGHT]
		call Dolphin.setAttribWord
	popa
	ret
View.file.image :
	push cx
	mov cl, 'I'
	mov [typestor], cl
	pop cx
call View.winSetup

mov eax, edx	; file location
mov ebx, eax
add eax, 4
	mov ecx, [Minnow.image.DIM]
	call Minnow.getAttribute
	and ecx, 0xFFFF	; image width
	and edx, 0xFFFF	; image height
	call View.winSize
mov ebx, [View.buffer]
call Image.copyLinear
call View.updateWindow
call View.file.modEcatch
;jmp $
jmp View.file.return

View.winUpdate :
pusha
mov cl, [typestor]
cmp cl, 'I'
jne View.winUpdate.notImage
xor ecx, ecx
xor edx, edx
mov cx, [View.windowStruct.width]
mov dx, [View.windowStruct.height]
call View.updateWindow	; finish the proccess
jmp View.winUpdate.ret
View.winUpdate.notImage :
cmp cl, 'T'
jne View.winUpdate.notText
; if the window is a text window
	xor ecx, ecx
	mov cx, [View.windowStruct.width]
	mov eax, [View.fpos]
	mov ebx, [View.buffer]
	mov edx, [fszstor]
				; THE NEXT THREE LINES SHOULT *NOT* BE COMMENTED OUT
			;cmp edx, (Graphics.SCREEN_HEIGHT/9)*(Graphics.SCREEN_HEIGHT/6)	; dont worry about drawing characters where they would simply be drawn off-screen
			;jle View.winUpdate.np
			;mov edx, (Graphics.SCREEN_HEIGHT/9)*(Graphics.SCREEN_HEIGHT/6)
			View.winUpdate.np :
		push bx
		mov bl, 0xE0
		mov [Dolphin.colorOverride], bl
		mov bl, 0xFF
		mov [highlight], bl
		pop bx
	call Dolphin.drawText
		push bx
		mov bx, 0x0
		mov [Dolphin.colorOverride], bl
		mov bl, 0x0
		mov [highlight], bl
		pop bx
	call View.updateWindow
	jmp View.winUpdate.ret
View.winUpdate.notText :
View.winUpdate.ret :
popa
ret

View.file.animation :
jmp View.file.unknownFile

jmp View.file.return

View.file.text :
	push cx
	mov cl, 'T'
	mov [typestor], cl
	pop cx
call View.winSetup
mov eax, edx
mov [View.fpos], eax
mov [View.fllim], eax
	mov ebx, [fszstor]
	add edx, ebx
	mov [View.fhlim], edx
mov ebx, [View.buffer]
mov ecx, 0x140
mov edx, 0xc0
call View.winSize
	push bx
	mov bx, 0xE0
	mov [Dolphin.colorOverride], bl
	pop bx
mov edx, [fszstor]
push ebx
mov ebx, edx
call console.numOut
sub edx, 1
pop ebx
call Dolphin.drawText
	push bx
	mov bx, 0x0
	mov [Dolphin.colorOverride], bl
	pop bx
call View.updateWindow

call View.file.modEcatch
jmp View.file.return

View.file.modEcatch :
;	pusha
	;mov ebx, [os.ecatch]
	;mov ebx, [ebx]
	;mov [View.file.ecatchStor], ebx
	;mov ebx, View.file.enter
	;call os.setEnterSub
	;popa
	ret
	
View.loop :
pusha
	xor ebx, ebx
	mov bl, [View.wnum]
	mov [Dolphin.currentWindow], bl
	call Dolphin.windowExists
	cmp eax, 0x0
		je View.loop.ret	; if no window to deal with, return
		;	if we are here, the window is visible!
					; should not be updating every single frame!
			call View.winUpdate
	call Keyboard.getKey
	cmp bl, 0xfe	; enter
	jne View.loop.cont
		mov bl, [View.wnum]
		call Dolphin.unregisterWindow
	View.loop.cont :
		cmp bl, 0xfd
			jne View.loop.notScrollDown
				;pusha
				;mov eax, View.OK
				;call Catfish.notify
				;popa
		mov ebx, [View.fpos]
		View.loop.nextLine :
			mov cl, [ebx]
			add ebx, 1
			cmp cl, 0x0a
			jne View.loop.nextLine
			cmp ebx, [View.fhlim]
			jle View.loop.ScrollDown.cont
			mov ebx, [View.fhlim]
			View.loop.ScrollDown.cont :
		mov [View.fpos], ebx
	View.loop.notScrollDown :
		cmp bl, 0xfc
			jne View.loop.ret
			mov ebx, [View.fpos]
			sub ebx, 2
			View.loop.lastLine :
			mov cl, [ebx]
			sub ebx, 1
			cmp cl, 0x0a
			jne View.loop.lastLine
			add ebx, 2
			cmp ebx, [View.fllim]
			jge View.loop.ScrollUp.cont
			mov ebx, [View.fllim]
			View.loop.ScrollUp.cont :
		mov [View.fpos], ebx
View.loop.ret :
popa
ret

View.file.enter :
;pusha
;mov ebx, [View.file.ecatchStor]
;call os.setEnterSub
;mov bl, [View.wnum]
;call Dolphin.unregisterWindow
;popa
ret

View.updateWindow :
mov eax, [View.buffer]
mov ebx, [View.windowBuffer]
call Image.copyLinear
ret

Syntax.reset :
		push dx
		xor dl, dl
		mov [Syntax.highlight.over], dl
		mov [Syntax.highlight.set], dl
		mov dl, 0xFF
		mov [scStor], dl
		pop dx
		ret

Syntax.highlight :	; position in buffer in ebx, return color in ah
push ebx
push ecx
push edx
		push ebx
		mov bl, [highlight]
		cmp bl, 0x0
		pop ebx
			je Syntax.highlight.ret
	mov ecx, ebx	; keep a copy in ecx
	mov bh, [ecx]
	cmp bh, 0x0A
	jne Syntax.highlight_1
		call Syntax.reset
		jmp Syntax.highlight.done
	Syntax.highlight_1 :
	cmp bh, ';'
	jne Syntax.highlight_2
	mov bl, GREEN
	mov dl, 0xFF
	mov [Syntax.highlight.over], dl
		jmp Syntax.highlight.done
	Syntax.highlight_2 :
	mov dl, [Syntax.highlight.over]
	cmp dl, 0xFF
	mov bl, [scStor]
	je Syntax.highlight.done
	; END OF TESTED CODE
	cmp bh, ' '
	je Syntax.highlight_3
	cmp bh, '['
	je Syntax.highlight_3
	cmp bh, ']'
	je Syntax.highlight_3.partial
	cmp bh, 0x9	; TAB
	jne Syntax.highlight_4
	Syntax.highlight_3 :
		call Syntax.reset
		Syntax.highlight_3.partial :
		mov bl, 0xFF
		jmp Syntax.highlight.done
	Syntax.highlight_4 :
	mov dl, [Syntax.highlight.set]
	cmp dl, 0xFF
	je Syntax.highlight.done
	cmp bh, 0x30
	jl Syntax.highlight_5
	cmp bh, 0x39
	jg Syntax.highlight_5
	mov bl, BLUE
	mov dl, 0xFF
	mov [Syntax.highlight.set], dl
	jmp Syntax.highlight.done
	Syntax.highlight_5 :
				;mov bl, 0xFF	; END FOR NOW!!!
				;jmp Syntax.highlight.done
		push eax
		mov eax, Syntax_ORANGE	; make use orange color too@@@!
		mov bl, ORANGE
		call Syntax.highlight.internal_1
		mov eax, Syntax_PINK
		mov bl, PINK
		call Syntax.highlight.internal_1
		mov eax, Syntax_BLUE
		mov bl, 0x13
		call Syntax.highlight.internal_1
		pop eax
		mov bl, dl
	mov dl, [Syntax.highlight.set]
	cmp dl, 0xFF
	je Syntax.highlight.done
		mov dh, 0xFF
		mov [Syntax.highlight.set], dh
	mov bl, WHITE
	Syntax.highlight.done :
	mov ah, bl
	mov [scStor], bl
Syntax.highlight.ret :
pop edx
pop ecx
pop ebx
ret
	Syntax.highlight.internal_1 :
		push eax
		push ebx
		push ecx
		mov [Shclstor], bl
		mov ebx, ecx
		Syntax.highlight_6 :
		call os.lenientStringMatch	; returns 0x0 or 0xFF in dh, auto-increments eax
		cmp dh, 0xFF
		jne Syntax.highlight_7
		mov dl, [Shclstor]	;color
		mov dh, 0xFF
		mov [Syntax.highlight.set], dh
		jmp Syntax.highlight_8
		Syntax.highlight_7 :
		mov cl, [eax]
		cmp cl, 0xFF
		jne Syntax.highlight_6
		Syntax.highlight_8 :
		pop ecx
		pop ebx
		pop eax
		ret
	Syntax.highlight.over :
		db 0x0
	Syntax.highlight.set :
		db 0x0
	Shclstor :
		db 0x0
	Syntax_ORANGE :
		db "add", 0, "sub", 0, "mov", 0, "call", 0, "jmp", 0, "jl", 0, "je", 0, "jne", 0, "jg", 0, "jle", 0, "jge", 0, "ret", 0, "push", 0, "pop", 0, "pusha", 0, "popa", "mul", 0, "div", 0, "imul", 0, "idiv", 0, "cmp", 0, "test", 0, "and", 0, "or", 0, "xor", 0, 0xFF
	Syntax_BLUE :
		db "ah", 0, "al", 0, "ax", 0, "eax", 0, "bh", 0, "bl", 0, "bx", 0, "ebx", 0, "ch", 0, "cl", 0, "cx", 0, "ecx", 0, "dh", 0, "dl", 0, "dx", 0, "edx", 0, "cr0", 0, "si", 0, "esi", 0, "di", 0, "edi", 0, "es", 0, "gs", 0, "ss", 0, "ds", 0, "fs", 0, 0xFF
	Syntax_PINK :
		db "db", 0, "dw", 0, "dd", 0, "bits", 0, "equ", 0, "lgdt", 0, 0xFF

View.FILE_TYPE_UNSUPPORTED :
db "[View] Unrecognized filetype.", 0x0
View.OK :
db "[View] Succesfully loaded file.", 0x0
View.file.ecatchStor :
dd 0x0
View.wnum :
db 0xff
View.pnum :
db 0x0
View.fpos :
dd 0x0
View.fllim :
dd 0x0
View.fhlim :
dd 0x0
fszstor :
dd 0x0
typestor :
db 0x0
highlight :
db 0x0
scStor :
db 0x0

View.windowStruct :
	dd "VIEW ver_1.2.0__"	; title
	View.windowStruct.width :
	dw Graphics.SCREEN_WIDTH	; width
	View.windowStruct.height :
	dw Graphics.SCREEN_HEIGHT	; height
	dw 0	; xpos
	dw 0	; ypos
	db 1	; type: 0=text, 1=image
	db 0	; depth, set by Dolphin
	View.windowBuffer :
	dd 0x0	; buffer location for storing the updated window
	View.buffer :
	dd 0x0	; buffer location for storing data