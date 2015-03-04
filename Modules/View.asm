[bits 32]

View.file :	; ebx contains file name
pusha
call Minnow.byName
	cmp ebx, 0x0
	je View.file.bad_file
mov edx, ebx
call Minnow.getType
call debug.println
	call Dolphin.updateScreen
	;popa
	;ret
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

View.file.image :
	mov cl, 0x0
	mov [JASM.console.draw], cl
mov eax, edx
mov ebx, eax
add eax, 4
mov ecx, [Minnow.image.DIM]
call Minnow.getAttribute
and ecx, 0xFFFF
and edx, 0xFFFF
mov ebx, 0x0
call Dolphin.windowUpdate
call View.file.modEcatch
jmp View.file.return

View.file.animation :
jmp View.file.unknownFile

View.file.text :
call Dolphin.toggleColored
	mov cl, 0x0
	mov [JASM.console.draw], cl
mov eax, edx
mov ebx, 0x140
mov cx, 40
mov dx, 25
call Dolphin.textUpdate
call Dolphin.toggleColored
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
mov cl, 0x1
mov [JASM.console.draw], cl
mov ebx, [View.file.ecatchStor]
call os.setEcatch
call console.update
popa
ret

View.FILE_TYPE_UNSUPPORTED :
db "[View] Unrecognized filetype.", 0x0
View.OK :
db "[View] Succesfully loaded file.", 0x0
View.file.ecatchStor :
dd 0x0