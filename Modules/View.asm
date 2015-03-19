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

View.file.animation :
jmp View.file.unknownFile

View.file.text :
call View.winSetup
mov eax, edx
mov ebx, [View.buffer]
mov ecx, 0xa0
mov edx, 0xc0
call View.winSize

call Dolphin.drawText
call View.updateWindow

call View.file.modEcatch
jmp View.file.return

View.file.modEcatch :
	pusha
	mov ebx, [os.ecatch]
	mov ebx, [ebx]
	mov [View.file.ecatchStor], ebx
	mov ebx, View.file.enter
	call os.setEcatch
	popa
	ret
View.file.enter :
pusha
mov ebx, [View.file.ecatchStor]
call os.setEcatch
mov bl, [View.wnum]
call Dolphin.unregisterWindow
popa
ret

View.updateWindow :
pusha
mov eax, [View.buffer]
mov ebx, [View.windowBuffer]
call Dolphin.copyImageLinear
popa
ret

View.FILE_TYPE_UNSUPPORTED :
db "[View] Unrecognized filetype.", 0x0
View.OK :
db "[View] Succesfully loaded file.", 0x0
View.file.ecatchStor :
dd 0x0
View.wnum :
db 0x0
View.pnum :
db 0x0

View.windowStruct :
	dd "VIEW ver_1.2.0__"	; title
	dw SCREEN_WIDTH	; width
	dw SCREEN_HEIGHT	; height
	dw 0	; xpos
	dw 0	; ypos
	db 1	; type: 0=text, 1=image
	db 0	; depth, set by Dolphin
	View.windowBuffer :
	dd 0x0	; buffer location for storing the updated window
	View.buffer :
	dd 0x0	; buffer location for storing data