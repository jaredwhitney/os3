[bits 32]

View.init :
pusha
	call os.getProgramNumber
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
			sub ebx, 16
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
		mov [currentWindow], bl
		mov eax, ecx
		mov bl, [Dolphin.WIDTH]
		call Dolphin.setAttribute
		mov eax, edx
		mov bl, [Dolphin.HEIGHT]
		call Dolphin.setAttribute
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
call Dolphin.copyImageLinear
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
		push bx
		mov bx, 0xE0
		mov [Dolphin.colorOverride], bl
		pop bx
	call Dolphin.drawText
		push bx
		mov bx, 0x0
		mov [Dolphin.colorOverride], bl
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
mov ebx, [View.buffer]
mov ecx, 0xa0
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
	mov [currentWindow], bl
	call Dolphin.windowExists
	cmp eax, 0x0
		je View.loop.cont	; if no window to deal with, return
		;	if we are here, the window is visible!
			call View.winUpdate
	call os.getKey
	cmp bl, 0xfe	; enter
	jne View.loop.cont
		mov bl, [View.wnum]
		call Dolphin.unregisterWindow
	View.loop.cont :
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
call Dolphin.copyImageLinear
ret

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
fszstor :
dd 0x0
typestor :
db 0x0

View.windowStruct :
	dd "VIEW ver_1.2.0__"	; title
	View.windowStruct.width :
	dw SCREEN_WIDTH	; width
	View.windowStruct.height :
	dw SCREEN_HEIGHT	; height
	dw 0	; xpos
	dw 0	; ypos
	db 1	; type: 0=text, 1=image
	db 0	; depth, set by Dolphin
	View.windowBuffer :
	dd 0x0	; buffer location for storing the updated window
	View.buffer :
	dd 0x0	; buffer location for storing data