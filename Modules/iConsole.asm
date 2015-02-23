[bits 32]

console.init :
mov ecx, 20
mov [console.width], ecx
mov ecx, 20
mov [console.height], ecx
mov bl, 0x2
call Dolphin.create
mov [console.buffer], ebx
mov ah, 0xB
call JASM.console.init	; initiallize the console
call JASM.test.main	; testing some JASM code that interfaces with the console
call JASM.console.post_init

console.setWidth :
call screen.wipe
mov [console.width], ebx
call console.clearScreen
ret

console.setHeight :
call screen.wipe
mov [console.height], ebx
call console.clearScreen
ret

console.setPos :
call screen.wipe
mov [console.pos], ebx
call console.clearScreen
ret

screen.wipe :
pusha
mov ebx, [console.pos]
add ebx, 0xa0000
mov ecx, [console.width]
mov edx, [console.height]
call Dolphin.clear
popa
ret

kernel.update :
pusha
mov eax, [console.buffer]
mov ebx, [console.pos]
mov ecx, [console.width]
mov edx, [console.height]
call Dolphin.textUpdate
popa
ret

console.checkClear :
mov ebx, [console.charPos]
cmp ebx, 0x1000
jle cseret
call console.clearScreen
cseret :
ret

console.print :
pusha
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
call kernel.update
popa
ret

console.printMem :
pusha
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
mov cl, 28
mov ch, 0x0

; num out
console.numOut.start :
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
call console.cprint
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
mov edx, [console.width]
add edx, edx
mov eax, [console.charPos]
add eax, [console.buffer]
mov bx, 0x0
mov [eax], bx
mov eax, [console.charPos]
mov ecx, 0x0
add eax, 0x2
dloop :
sub eax, edx	; usually 0xA0
add ecx, 0x1
cmp eax, 0
jg dloop
mov eax, ecx
mov ebx, edx	; usually 0xA0
mul ebx
mov [console.charPos], eax
;call graphics.newline
popa
ret

console.doEnter :
mov eax, [os.ecatch]
mov ebx, [eax]
mov ah, 0xB
call ebx
jmp os.pollKeyboard.drawKeyFinalize

console.doBackspace :

mov eax, [console.charPos]
mov edx, 0x0
bsdloop :
push edx
mov edx, [console.width]
add edx, edx
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
mov edx, [console.width]
add edx, edx
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
call kernel.update
jmp os.pollKeyboard.drawKeyFinalize

console.cprint :
mov ah, 0x0f
mov ebx, [console.charPos]
add ebx, [console.buffer]
mov [ebx], ax
;call graphics.drawChar
mov ebx, [console.charPos]
add ebx, 0x2
mov [console.charPos], ebx
call kernel.update
ret

console.clearScreen :
pusha
call clearScreenG
mov eax, [console.buffer]
mov cx, 0x0
console.clearScreen.loop :
mov [eax], cx
add eax, 2
push ebx
mov ebx, [console.buffer]
add ebx, 0x1000
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

console.getLine :
pusha
mov eax, [console.charPos]
;mov ebx, eax
;call console.numOut
mov ecx, 0x0
add eax, 0x2
gldloop :
push edx
mov edx, [console.width]
add edx, edx
sub eax, edx
pop edx
add ecx, 0x1
cmp eax, 0
jg gldloop
mov eax, ecx

push edx
mov edx, [console.width]
add edx, edx
mov ebx, edx
pop edx
mul ebx
add eax, [console.buffer]
push edx
mov edx, [console.width]
add edx, edx
sub eax, edx
pop edx
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

console.width :
dd 0x0

console.height :
dd 0x0

console.pos :
dd 0x0

console.buffer :
dd 0x0

console.charPos :
dd 0xA2

console.line :
dd 0x0, 0x0, 0x0, 0x0