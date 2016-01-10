[bits 32]

console.init :
pusha
	
	call ProgramManager.getProgramNumber	; register program with the OS
	mov [console.pnum], bl
	call ProgramManager.setActive	; Make removable Later
	
	;mov ebx, 0x10fa	; sectors
	;cmp byte [Graphics.VESA_MODE], 0x0
	;	je console.init.novesa
	call Window.getSectorSize	; <- eax
	add eax, 0x1
	mov ebx, eax
	console.init.novesa :
	call ProgramManager.requestMemory
			;mov eax, [ProgramManager.memoryStart]
			;call DebugLogEAX
	push dword console.title
	push word Window.TYPE_TEXT
	call Window.create	; essentially: Window windowStructLoc = new Window(title, Window.TYPE_TEXT)
	mov [console.windowStructLoc], ecx
	mov [console.winNum], bl	; PHASE OUT winNum/wnum !!! Dolphin.currentWindow should contain the window struct pointer! NOTE: in this case, 'winNum' should become 'window' and contain the same data 'windowStructLoc' does right now, and 'windowStructLoc' should be removed	
	
	mov ebx, [console.windowStructLoc]
	add bl, [Window.WIDTH]
	mov word [ebx], 0x3C0	; need to fix window width so it is NOT dependent on bpp!
	mov ebx, [console.windowStructLoc]
	add bl, [Window.HEIGHT]
	mov word [ebx], 0xC8
	
	call console.createWindow
	
	;mov ah, 0xF	; yellow
	;call JASM.console.init	; initiallize the console
	
	;call console.clearScreen
	
	;mov ah, 0xFF
	;call Time.printToConsole
	
	;call JASM.console.post_init
	
	;call debug.toggleView	; fine to turn off debugging, the console should be under the user's control by now
	
	;call console.update
	
	call ProgramManager.finalize	; Make removable Later

popa
ret

console.createWindow :
	pusha
		
	mov ebx, 0x1
	mov [console.draw], ebx

	call console.clearScreen
	;call JASM.console.post_init		; FIX THIS!!!
	;call console.update
	popa
	ret

console.rereg :
pusha
	;mov eax, [console.windowStructLoc]
	;call Dolphin.registerWindow
	;mov [console.winNum], bl
popa
ret

;console.loop :	; UNUSED
;pusha
;
;	mov bl, [console.pnum]
;	call ProgramManager.setActive	; Make removable Later
;	
;	xor ebx, ebx
;	mov bl, [console.winNum]
;	mov [Dolphin.currentWindow], ebx
;
;mov ebx, [console.draw]
;cmp ebx, 0x0
;je console.update.gone
;	mov [console.dat], ebx
;	;call console.update
;;mov bl, [console.winNum]
;;mov [Dolphin.currentWindow], bl
;	console.loop.checkKeyBuffer :
;		mov ebx, [KeyManager.bufferpos]
;		cmp ebx, 0x0	; is there any data avaliable?
;			je console.loop.ret
;		call Keyboard.getKey
;		cmp bl, 0x0		; was the program allowed to get data?
;			je console.loop.ret
;		cmp bl, 0xff	; was the character a backspace?
;			je console.doBackspace
;		cmp bl, 0xfe	; was the character an enter?
;			jne console.loop.notEnter
;		call JASM.console.handleEnter
;		jmp console.loop.checkKeyBuffer
;		console.loop.notEnter :
;			cmp bl, 0xfb
;				jne console.loop.notUp
;			mov ah, 0xFF
;			mov ebx, console.lastLine
;			call console.print
;			jmp console.loop.checkKeyBuffer
;		console.loop.notUp :
;			mov al, bl
;			mov ah, 0xFF
;			call console.cprint
;		jmp console.loop.checkKeyBuffer
;console.loop.ret :
;
;	call ProgramManager.finalize	; Make removable Later
;
;popa
;ret

console.runOHLL_workaround :
		mov bl, [OHLLPROTO_PNUM]
		call ProgramManager.setActive
			call iConsole._loop
		call ProgramManager.finalize
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
pusha
	mov ax, bx
	mov bl, [Window.HEIGHT]	; -> ecx
	call Dolphin.setAttribWord
popa
ret

console.setPos :
pusha
mov al, [console.winNum]
mov [Dolphin.currentWindow], al
mov eax, ebx
call Dolphin.moveWindowAbsolute
popa
ret

JASM.console.safeFullscreen :
pusha
	mov eax, 0
	mov bl, [Window.X_POS]
	call Dolphin.setAttribWord
	mov eax, 8
	mov bl, [Window.Y_POS]
	call Dolphin.setAttribWord
	mov eax, [Graphics.SCREEN_WIDTH]
	mov bl, [Window.WIDTH]
	call Dolphin.setAttribWord
	mov eax, [Graphics.SCREEN_HEIGHT]
	mov bl, [Window.HEIGHT]
	call Dolphin.setAttribWord
popa
ret

console.test :	; command that can be used to test anything.
pusha

	mov eax, 0x0
	call Minnow.getBuffer
	mov ebx, [ecx]
	call console.numOut
	call console.newline
	
	mov dword [ecx], 0x053EEEA4
	mov eax, 0x0
	call Minnow.writeBuffer

popa
ret
C.test.val :
	dd 0x0

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

; console.update :
; pusha
; mov ebx, [console.draw]
; cmp ebx, 0x0
; je console.update.gone
	; xor ebx, ebx
	; mov bl, [console.winNum]
	; mov [Dolphin.currentWindow], ebx
	
	; call Dolphin.uUpdate
	
; popa
; ret

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
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.print
pusha
push ebx
	xor ebx, ebx
	mov bl, [console.winNum]
	mov [Dolphin.currentWindow], ebx
pop ebx
		mov ah, [console.vgacolor]
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
mov word [edx], 0x0
;call console.update
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
	cmp dword [DisplayMode], MODE_TEXT
		je TextMode.newline
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
			mov eax, ebx
			mov bl, [Window.BUFFERSIZE]	; <- ebx
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
;call console.update
;jmp console.loop.checkKeyBuffer
jmp kernel.halt

console.cprint :
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.cprint
pusha

	mov ah, [console.vgacolor]

	push ebx
	xor ebx, ebx
	mov bl, [console.winNum]
	mov [Dolphin.currentWindow], ebx
	pop ebx

		push eax
		mov bl, [Window.BUFFERSIZE]	; -> ebx
		call Dolphin.getAttribDouble
		mov edx, eax

		push bx
		mov bl, [Window.BUFFER]	; -> ecx
		call Dolphin.getAttribDouble
		pop bx

add edx, eax

pop eax

mov [edx], ax
add edx, 2
mov word [edx], 0x0
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
;call console.update
popa
ret

console.clearScreen :
cmp dword [DisplayMode], MODE_TEXT
	je TextMode.clearScreen
pusha
	xor ebx, ebx
	mov bl, [console.winNum]
	mov [Dolphin.currentWindow], ebx

	call Window.forceFlush
	
	mov bl, [Window.BUFFER]	; -> eax
	call Dolphin.getAttribDouble
	;mov ebx, eax
	;call String.getLength
	mov ebx, [Graphics.SCREEN_SIZE];edx
	call Buffer.clear

		mov eax, 0
		mov bl, [Window.BUFFERSIZE]	; <- ecx
		call Dolphin.setAttribDouble
popa
ret
console.clearScreen.end :
	dd 0x0

console.setColor :
mov [console.vgacolor], bl
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
	add eax, 9
	mov ebx, console.lastLine
	call String.copy
popa
ret

%include "../Modules/console/build.asm"

console.vgacolor :
	db 0xC
console.color :
	dd 0xFF0000

console.pos :	; should be removed, use the window's position instead
dd 0x0

console.draw :
dd 0x0

console.cstor :
db 0x0

console.line :
times 14 dd 0x0

console.lastLine :
times 14 dd 0x0

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

console.windowStructLoc :
	dd 0