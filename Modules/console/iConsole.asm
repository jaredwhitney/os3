[bits 32]

console.init :
pusha
	
	call ProgramManager.getProgramNumber	; register program with the OS
	mov [console.pnum], bl
	call ProgramManager.setActive	; Make removable Later
	
	mov ebx, 0x10fa	; sectors
	cmp byte [Graphics.VESA_MODE], 0x0
		je console.init.novesa
	mov ebx, 0x6000	; sectors
	console.init.novesa :
	call ProgramManager.requestMemory

	pusha
	mov bl, [console.pnum]
	mov eax, console.windowStruct
	call Dolphin.registerWindow
	mov [console.winNum], bl
	and ebx, 0xFF
	mov [Dolphin.currentWindow], ebx
	popa
	
call Dolphin.create				; allocate memory for a window
				;mov ebx, MEMORY_START + 1000	; debugging
mov eax, ebx
mov bl, [Window.BUFFER]
call Dolphin.setAttribDouble
				;mov ebx, MEMORY_START + 1000 + 70000	; debugging
mov eax, ecx
mov bl, [Window.WINDOWBUFFER]
call Dolphin.setAttribDouble

	call console.createWindow
mov ah, 0xF	; yellow
call JASM.console.init	; initiallize the console
;call JASM.test.main	; testing some JASM code that interfaces with the console
call console.clearScreen
	mov ah, 0xFF
	call Time.printToConsole
call JASM.console.post_init
call debug.toggleView	; fine to turn off debugging, the console should be under the user's control by now
call console.update

call ProgramManager.finalize	; Make removable Later

popa
ret

console.createWindow :
	pusha
		
	mov ebx, 0x1
	mov [JASM.console.draw], ebx

	call console.clearScreen
	call JASM.console.post_init		; FIX THIS!!!
	call console.update
	popa
	ret
	

console.loop :
pusha

	mov bl, [console.pnum]
	call ProgramManager.setActive	; Make removable Later
	
	xor ebx, ebx
	mov bl, [console.winNum]
	mov [Dolphin.currentWindow], ebx

mov ebx, [JASM.console.draw]
cmp ebx, 0x0
je console.update.gone
	mov eax, [console.dat]
		push eax
		mov bl, [Window.WIDTH]
		call Dolphin.getAttribWord
		mov ebx, eax
		pop eax
	cmp eax, ebx
	je console.loop.noChange
	mov [console.dat], ebx
	call console.update
console.loop.noChange :
mov bl, [console.winNum]
mov [Dolphin.currentWindow], bl
	console.loop.checkKeyBuffer :
	mov ebx, [KeyManager.bufferpos]
	cmp ebx, 0x0	; is there any data avaliable?
		je console.loop.ret
	call Keyboard.getKey
	cmp bl, 0x0		; was the program allowed to get data?
		je console.loop.ret
	cmp bl, 0xff	; was the character a backspace?
		je console.doBackspace
	cmp bl, 0xfe	; was the character an enter?
		jne console.loop.notEnter
	call JASM.console.handleEnter
	jmp console.loop.checkKeyBuffer
	console.loop.notEnter :
		mov al, bl
		mov ah, 0xFF
		call console.cprint
		jmp console.loop.checkKeyBuffer
console.loop.ret :

	call ProgramManager.finalize	; Make removable Later

popa
ret

console.setWidth :
pusha
and ebx, 0xFFFF
mov eax, [Graphics.bytesPerPixel]
imul ebx, eax
mov eax, ebx
mov bl, [Window.WIDTH]
call Dolphin.setAttribWord
popa
ret

console.setHeight :
	mov ax, bx
	mov bl, [Window.HEIGHT]	; -> ecx
	call Dolphin.setAttribWord
ret

console.setPos :
mov al, [console.winNum]
mov [Dolphin.currentWindow], al
mov eax, ebx
call Dolphin.moveWindowAbsolute
ret

JASM.console.safeFullscreen :
mov ebx, [Graphics.SCREEN_WIDTH]
	mov eax, ebx
	mov bl, [Window.WIDTH]
	call Dolphin.setAttribWord
mov ebx, [Graphics.SCREEN_HEIGHT]
call console.setHeight
ret

console.test :	; command that can be used to test anything.
pusha
	call USB_PrintControllerInfo
	call USB_PrintActivePorts
	call USB_EnablePlugAndPlay
	;mov ebx, USB_QUEUEHEADEX
	;call USB_LoadQueueHead
	;call USB_RunAsyncTasks
popa
ret

console.memstat :
	mov ah, 0xFF
	pusha
	mov ebx, [Guppy.usedRAM]
	mov edx, ebx
	mov ebx, [Guppy.totalRAM]
	mov ecx, ebx
	cmp ecx, 0x0
		je console.FUNCTION_UNSUPPORTED
	push eax
	mov eax, edx
	imul eax, 100
	xor edx, edx
	idiv ecx
	mov ebx, eax
	pop eax
	call console.numOut
	mov ebx, Guppy.div3
	call console.println
popa
ret

console.checkColor :
	cmp ah, 0x0
		jne console.checkColor_ret
	mov ah, 0xFF
	console.checkColor_ret :
	ret

console.FUNCTION_UNSUPPORTED :
mov ah, 0x3	; RED
mov ebx, console.UNSUP_MSG
call console.println
popa
ret

screen.wipe :
;pusha
;mov ebx, [console.pos]
;add ebx, [Dolphin.SCREEN_BUFFER]
;mov cx, [console.width]
;mov dx, [console.height]
;call Dolphin.clear
;popa
ret

console.update :
pusha
mov ebx, [JASM.console.draw]
cmp ebx, 0x0
je console.update.gone
	xor ebx, ebx
	mov bl, [console.winNum]
	mov [Dolphin.currentWindow], ebx
	
	call Dolphin.uUpdate
	
popa
ret

console.update.gone :
mov bl, [console.winNum]
call Dolphin.windowExists
cmp eax, 0x0
je console.update.gone.ret
call Dolphin.unregisterWindow
console.update.gone.ret :
popa
ret

;console.checkClear :
;mov ebx, [console.bufferPos]
;cmp ebx, 0x1000
;jle cseret
;call console.clearScreen
;cseret :
;ret

console.print :
pusha
	push ebx
	xor ebx, ebx
	mov bl, [console.winNum]
	mov [Dolphin.currentWindow], ebx
	pop ebx
call console.checkColor
		push eax
		push bx
		mov bl, [Window.BUFFER]	; -> edx
		call Dolphin.getAttribDouble
		mov edx, eax
		
		mov bl, [Window.BUFFERSIZE]	; -> ecx
		call Dolphin.getAttribDouble
		mov ecx, eax
		pop bx
		pop eax
add edx, ecx
printitp :
mov al, [ebx]
;mov ah, 0x0c ; or 0x0f... you get the point
cmp al, 0
je printdonep
mov [edx], ax
;call TextHandler.drawChar
add ebx, 1
add edx, 2
push ebx
		push eax
		mov bl, [Window.BUFFERSIZE]	; -> ebx
		call Dolphin.getAttribDouble
		mov ebx, eax
		pop eax
add ebx, 0x2
	push eax
	mov eax, ebx
	mov bl, [Window.BUFFERSIZE]	; <- ebx
	call Dolphin.setAttribDouble
	pop eax
pop ebx
jmp printitp
printdonep :
call console.update
popa
ret

;console.drawCursor :
;pusha
;mov edx, [console.buffer]
;mov ecx, [console.bufferPos]
;add edx, ecx
;mov cl, 0x5f
;mov ch, 0x0F
;mov [edx], cx
;popa
;ret

console.println :
call console.print
call console.newline
ret

console.numOutFakeDecimal :	; just go base 10 -> the same characters in hex (ONLY WORKS WITH 2-DIGIT DECIMAL NUMBERS)
pusha
	mov eax, ebx
	xor edx, edx
	mov ecx, 0xA
	push ebx
	idiv ecx
	pop ebx
	imul eax, 0x6
	add [cnOFDchange], eax
add ebx, [cnOFDchange]
call console.numOut
popa
ret
cnOFDchange :
dd 0x0

console.numOut :
pusha
call console.checkColor
mov [console.cstor], ah
mov cl, 28
mov ch, 0x0

; num out
console.numOut.start :
	cmp ebx, 0x0
	jne console.numOut.cont
	mov ah, [console.cstor]
	mov al, '0'
	call console.cprint
	popa
	ret
	console.numOut.cont :
mov edx, ebx
shr edx, cl
and edx, 0xF

cmp dx, 0x0
je console.numOut.checkZ
mov ch, 0x1
console.numOut.dontcare :
push ebx
mov eax, edx

cmp dx, 0x9
jg console.numOut.g10
add eax, 0x30
jmp console.numOut.goPrint
console.numOut.g10 :
add eax, 0x37
console.numOut.goPrint :
push ax
mov ah, [console.cstor]
call console.cprint
pop ax
pop ebx
console.numOut.goCont :
cmp cl, 0
jle console.numOut.end
sub cl, 4
jmp console.numOut.start
console.numOut.end :
popa
ret

console.numOut.checkZ :
cmp ch, 0x0
je console.numOut.goCont
jmp console.numOut.dontcare

; newline
console.newline :
	pusha
		push ebx
	xor ebx, ebx
	mov bl, [console.winNum]
	mov [Dolphin.currentWindow], ebx
	pop ebx
			push eax
			push bx
			mov bl, [Window.BUFFER]	; -> edx
			call Dolphin.getAttribDouble
			mov edx, eax
			mov bl, [Window.BUFFERSIZE]	; -> ecx
			call Dolphin.getAttribDouble
			mov ecx, eax
			pop bx
			pop eax
		add edx, ecx
		mov al, 0x0A
		mov ah, 0xFF
		mov [edx], ax
			push eax
			mov bl, [Window.BUFFERSIZE]	; -> ebx
			call Dolphin.getAttribDouble
			mov ebx, eax
			pop eax
		add ebx, 0x2
			mov bl, [Window.BUFFERSIZE]	; <- ebx
			mov eax, ebx
			call Dolphin.setAttribDouble
	popa
	ret

console.doBackspace :
		mov bl, [Window.BUFFERSIZE]	; -> eax
		call Dolphin.getAttribDouble
mov edx, 0x0
bsdloop :
push edx
xor edx, edx
		push eax
		push bx
		mov bl, [Window.WIDTH]	; -> dx
		call Dolphin.getAttribWord
		mov dx, ax
		pop bx
		pop eax
;add dx, dx
sub eax, edx
pop edx
add edx, 0x1
cmp eax, 0
jg bsdloop
cmp eax, 0x0
mov ecx, 2
jne bsfnoloop
		push eax
		mov bl, [Window.BUFFERSIZE]	; -> ebx
		call Dolphin.getAttribDouble
		mov ebx, eax
		pop eax
push ecx
		push eax
		push bx
		mov bl, [Window.BUFFER]	; -> ecx
		call Dolphin.getAttribDouble
		mov ecx, eax
		pop bx
		pop eax
add ebx, ecx
pop ecx
mov [ebx], edx
mov eax, edx
push bx
push edx
xor edx, edx
		push eax
		push bx
		mov bl, [Window.WIDTH]	; -> dx
		call Dolphin.getAttribWord
		mov dx, ax
		pop bx
		pop eax
;add dx, dx
mov bx, dx
pop edx
mul bx
pop bx
sub eax, 2
push ecx
		push eax
		push bx
		mov bl, [Window.BUFFER]	; -> ecx
		call Dolphin.getAttribDouble
		mov ecx, eax
		pop bx
		pop eax
add eax, ecx
pop ecx
mov bx, 0x0
bsfcloop :
add ecx, 2
sub eax, 2
cmp [eax], bx
je bsfcloop
sub ecx, 2
bsfnoloop :
		push bx
		mov bl, [Window.BUFFERSIZE]	; -> eax
		call Dolphin.getAttribDouble
		pop bx
sub eax, ecx
cmp eax, 0
jl console.doBackspace.stop
		push bx
		mov bl, [Window.BUFFERSIZE]	; <- eax
		call Dolphin.setAttribDouble
		pop bx
console.doBackspace.stop :
push ecx
		push eax
		push bx
		mov bl, [Window.BUFFER]	; -> ecx
		call Dolphin.getAttribDouble
		mov ecx, eax
		pop bx
		pop eax
add eax, ecx
pop ecx
mov bx, 0x0
mov [eax], bx
add eax, 2
mov [eax], bx
call console.update
jmp console.loop.checkKeyBuffer

console.cprint :
pusha
		push eax
		mov bl, [Window.BUFFERSIZE]	; -> ebx
		call Dolphin.getAttribDouble
		mov ebx, eax
		pop eax
push ecx
		push eax
		push bx
		mov bl, [Window.BUFFER]	; -> ecx
		call Dolphin.getAttribDouble
		mov ecx, eax
		pop bx
		pop eax
add ebx, ecx
pop ecx
mov [ebx], ax
;call TextHandler.drawChar
		push eax
		mov bl, [Window.BUFFERSIZE]	; -> ebx
		call Dolphin.getAttribDouble
		mov ebx, eax
		pop eax
add ebx, 0x2
		push eax
		mov eax, ebx
		mov bl, [Window.BUFFERSIZE]	; <- ebx
		call Dolphin.setAttribDouble
		pop eax
call console.update
popa
ret

console.clearScreen :
pusha
								popa	; FIX THIS!!!
								ret
		push bx
		mov bl, [Window.BUFFER]	; -> eax
		call Dolphin.getAttribDouble
		pop bx
mov cx, 0x0
console.clearScreen.loop :
mov [eax], cx
add eax, 2
push ebx
		push eax
		mov bl, [Window.BUFFER]	; -> ebx
		call Dolphin.getAttribDouble
		mov ebx, eax
		pop eax
add ebx, 0xfa00
cmp eax, ebx
pop ebx
jl console.clearScreen.loop
mov ecx, 0x0
		mov eax, ecx
		mov bl, [Window.BUFFER]	; <- ecx
		call Dolphin.setAttribDouble
popa
ret

console.setColor :
mov ah, bl
ret

console.getLine :	; Fixed.
pusha
		push bx
		mov bl, [Window.BUFFERSIZE]	; -> eax
		call Dolphin.getAttribDouble
		push eax
		mov bl, [Window.BUFFER]	; -> edx
		call Dolphin.getAttribDouble
		mov edx, eax
		pop eax
		pop bx
add eax, edx
mov ecx, 0x0
add eax, 0x2
gldloop :
sub eax, 0x2
mov bx, [eax]
cmp bl, 0x0a
jne gldloopnoadd
add ecx, 0x1
gldloopnoadd :
cmp eax, edx
jg gldloop
mov eax, ecx	; eax now contains the line number!

		push eax
		push bx
		mov bl, [Window.BUFFER]	; -> edx
		call Dolphin.getAttribDouble
		mov edx, eax
		pop bx
		pop eax
	mov ecx, 0x0
	gldloop2 :
	mov bx, [edx]
	cmp bl, 0x0a
	jne gldloop2noadd
	add ecx, 1
	gldloop2noadd :
	add edx, 2
	cmp ecx, eax
	jl gldloop2
	cmp eax, 0x0
	jne gldloop2nofix
	sub edx, 2
	gldloop2nofix :
mov eax, edx
; eax now contains the beginning of the line

mov ebx, eax

mov edx, console.line
glrloop :
mov al, [ebx]
cmp al, 0x0
je glrloopDone
mov [edx], al
add ebx, 2
add edx, 1
jmp glrloop
glrloopDone :
;sub edx, 1
mov al, 0x0
mov [edx], al
mov eax, console.line
mov [retval], eax
popa
ret

%include "../Modules/console/build.asm"


console.pos :	; should be removed, use the window's position instead
dd 0x0

console.cstor :
db 0x0

console.line :
dd 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0

console.winNum :
db 0x0

console.pnum :
db 0x0

console.dat :
dd 0x0

console.UNSUP_MSG :
db "The specified function is unsupported on your computer.", 0

console.bufferstor :
dd 0x0

counter1 :
dd 0x0

console.title :
db "iConsole VER_1.1", 0

console.windowStruct :
	dd console.title
	dw 0xa0	; width
	dw 0xc8	; height
	dw 0x0	; xpos
	dw 20	; ypos
	db 0	; type: 0=text, 1=image
	db 0	; depth, set by Dolphin
	dd 0x0	; buffer location for storing the updated window
	dd 0x0	; buffer location for storing data
	dd 0xa2	; length of buffer (chars)