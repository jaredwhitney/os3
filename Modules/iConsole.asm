[bits 32]

console.init :
pusha
	call os.getProgramNumber	; register program with the OS
	mov [console.pnum], bl
call Dolphin.create				; allocate memory for a window
mov [console.buffer], ebx 
mov [console.windowBuffer], ecx
	mov bl, [console.pnum]
	mov eax, console.windowStruct
	call Dolphin.registerWindow
	mov [console.winNum], bl
mov ah, 0xF	; yellow
call JASM.console.init	; initiallize the console
;call JASM.test.main	; testing some JASM code that interfaces with the console
call console.clearScreen
call JASM.console.post_init
call debug.toggleView	; fine to turn off debugging, the console should be under the user's control by now
call console.update

popa
ret

console.loop :
pusha
mov ebx, [JASM.console.draw]
cmp ebx, 0x0
je console.loop.ret
	mov eax, [console.dat]
	mov ebx, [console.width]
	cmp eax, ebx
	je console.loop.noChange
	mov [console.dat], ebx
	call console.update
console.loop.noChange :
mov bl, [console.winNum]
mov [currentWindow], bl
call os.getKey
cmp bl, 0x0
je console.loop.ret
cmp bl, 0xff
je console.doBackspace
cmp bl, 0xfe
jne console.loop.notEnter
call JASM.console.handleEnter
jmp console.loop.ret
console.loop.notEnter :
mov al, bl
mov ah, 0xFF
call console.cprint
console.loop.ret :
popa
ret

console.setWidth :
mov [console.width], bx
;call console.clearScreen
ret

console.setHeight :
mov [console.height], bx
;call console.clearScreen
ret

console.setPos :
mov [console.pos], bx
ret

console.test :	; command that can be used to test anything.
mov eax, Catfish.testMsg
call Catfish.notify
pusha
	
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
;add ebx, SCREEN_BUFFER
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
	mov [currentWindow], ebx
	call Dolphin.getWindowBuffer
	mov ebx, eax
	mov eax, [console.buffer]
	mov cx, [console.width]
	mov edx, [console.charPos]
		;cmp edx, 0xA00
		;jl console.size.noworry
		;pusha
			;call console.clearScreen
		;popa
		;console.size.noworry :
	call Dolphin.drawText
popa
ret

console.update.gone :
mov bl, [console.winNum]
call Dolphin.unregisterWindow
popa
ret

;console.checkClear :
;mov ebx, [console.charPos]
;cmp ebx, 0x1000
;jle cseret
;call console.clearScreen
;cseret :
;ret

console.print :
pusha
call console.checkColor
mov edx, [console.buffer]
mov ecx, [console.charPos]
add edx, ecx
printitp :
mov al, [ebx]
;mov ah, 0x0c ; or 0x0f... you get the point
cmp al, 0
je printdonep
mov [edx], ax
;call graphics.drawChar
add ebx, 1
add edx, 2
push ebx
mov ebx, [console.charPos]
add ebx, 0x2
mov [console.charPos], ebx
pop ebx
jmp printitp
printdonep :
call console.update
popa
ret

console.printMem :
pusha
call console.checkColor
mov edx, [console.buffer]
mov ecx, [console.charPos]
add edx, ecx
printitpMem :
mov al, [ebx]
;mov ah, 0x0c ; or 0x0f... you get the point
cmp al, 0
je printdonepMem
mov [edx], ax
add ebx, 2
add edx, 2
push ebx
mov ebx, [console.charPos]
add ebx, 0x2
mov [console.charPos], ebx
pop ebx
jmp printitpMem
printdonepMem :
popa
ret

console.drawCursor :
pusha
mov edx, [console.buffer]
mov ecx, [console.charPos]
add edx, ecx
mov cl, 0x5f
mov ch, 0x0F
mov [edx], cx
popa
ret

console.println :
call console.print
call console.newline
ret

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
		mov edx, [console.buffer]
		mov ecx, [console.charPos]
		add edx, ecx
		mov al, 0x0A
		mov ah, 0xFF
		mov [edx], ax
		mov ebx, [console.charPos]
		add ebx, 0x2
		mov [console.charPos], ebx
	popa
	ret

console.doBackspace :

mov eax, [console.charPos]
mov edx, 0x0
bsdloop :
push edx
xor edx, edx
mov dx, [console.width]
;add dx, dx
sub eax, edx
pop edx
add edx, 0x1
cmp eax, 0
jg bsdloop
cmp eax, 0x0
mov ecx, 2
jne bsfnoloop
mov ebx, [console.charPos]
add ebx, [console.buffer]
mov [ebx], edx
mov eax, edx
push bx
push edx
xor edx, edx
mov dx, [console.width]
;add dx, dx
mov bx, dx
pop edx
mul bx
pop bx
sub eax, 2
add eax, [console.buffer]
mov bx, 0x0
bsfcloop :
add ecx, 2
sub eax, 2
cmp [eax], bx
je bsfcloop
sub ecx, 2
bsfnoloop :
mov eax, [console.charPos]
sub eax, ecx
cmp eax, 0
jl console.doBackspace.stop
mov [console.charPos], eax
console.doBackspace.stop :
add eax, [console.buffer]
mov bx, 0x0
mov [eax], bx
add eax, 2
mov [eax], bx
call console.update
jmp console.loop.ret

console.cprint :
pusha
mov ebx, [console.charPos]
add ebx, [console.buffer]
mov [ebx], ax
;call graphics.drawChar
mov ebx, [console.charPos]
add ebx, 0x2
mov [console.charPos], ebx
call console.update
popa
ret

console.clearScreen :
pusha
mov eax, [console.buffer]
mov cx, 0x0
console.clearScreen.loop :
mov [eax], cx
add eax, 2
push ebx
mov ebx, [console.buffer]
add ebx, 0xfa00
cmp eax, ebx
pop ebx
jl console.clearScreen.loop
mov ecx, 0x0
mov [console.charPos], ecx
popa
ret

console.setColor :
mov ah, bl
ret

console.getLine :	; Fixed.
pusha
mov eax, [console.charPos]
mov edx, [console.buffer]
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

	mov edx, [console.buffer]
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

%include "../programs/new console/build.asm"


console.pos :	; should be removed, use the window's position instead
dd 0x0

console.charPos :
dd 0xA2

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

console.windowStruct :
	dd "iConsole VER_1.0"	; title
	console.width :
	dw 0xa0	; width
	console.height :
	dw 0xc8	; height
	dw 0x0	; xpos
	dw 0	; ypos
	db 0	; type: 0=text, 1=image
	db 0	; depth, set by Dolphin
	console.windowBuffer :
	dd 0x0	; buffer location for storing the updated window
	console.buffer :
	dd 0x0	; buffer location for storing data
