[bits 32]
[org 0x7e00]
db 0x4a
kernel :

mov ebx, retfunc
call os.setEcatch

mov ebx, Dolphin.create
mov [0x10C6], ebx

;call Mouse.init

call Guppy.init

;mov ecx, console.asm.start
;mov ebx, [ecx]
;call console.numOut
;jmp $

mov ebx, console.asm.start
call program.register
call program.init

;call console.asm.init
;mov al, 'K'
;mov ah, 0xF
;mov ebx, 0xa0000
;mov [charpos], ebx
;call graphics.drawChar



kernel.loop:
call os.pollKeyboard
;call console.asm.post_init
jmp kernel.loop

jmp $

Mouse.init :
push ax
mov al, 0xA8
out 0x64, al	; aux input enable
mov al, 0xD4
out 0x64, al	; we are going to be sending a command to the mouse:
mov al, 0xF4
out 0x60, al	; 	start sending us packets!
pop ax
ret

os.setEcatch :
pusha
mov eax, [os.ecatch]
mov [eax], ebx
popa

os.pollKeyboard :
pusha
in al, 0x64
and al, 0x20
cmp al, 0x0
je os.pollKeyboard.kcol
mov eax, 0x0	; start mouse handle code
in al, 0x60
mov ebx, eax
call console.numOut
call console.newline
in al, 0x60
mov ebx, eax
call console.numOut
call console.newline
in al, 0x60
mov ebx, eax
call console.numOut
call console.newline
call console.newline
jmp os.pollKeyboard.return	; end mouse handle code
os.pollKeyboard.kcol :
in al, 0x60	; get last keycode
mov bl, al	; storing code in bl
and al, 0x80	; 1 if release code, 0 if not
cmp al, 0x0	; if a key has not been released
je os.pollKeyboard.checkKey
mov cx, 0x1	; otherwise a key was released
mov [os.pollKeyboard.isReady], cx	; store 1 so we know we are ready to read next time
jmp os.pollKeyboard.return

os.pollKeyboard.checkKey :
mov cx, [os.pollKeyboard.isReady]
cmp cx, 0x0
je os.pollKeyboard.return	; if not ready, a key is being held down, dont reprint it
call os.keyboard.toChar
cmp al, 0x0
je console.doBackspace
cmp al, 0x1
je os.doEnter
mov bl, al
call os.keyPress	; keypress will be sent to the currently registered program in al
os.pollKeyboard.drawKeyFinalize :
mov cx, 0x0
mov [os.pollKeyboard.isReady], cx	; so we know that we have already printed the character, and should not do so again

os.pollKeyboard.return :
popa
ret

os.doEnter :
mov eax, [os.ecatch]
mov ebx, [eax]
mov ah, 0xB
call ebx
jmp os.pollKeyboard.drawKeyFinalize

os.keyPress :
mov [0xA0000], bl
;call console.cprint
ret


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
;add eax, [console.buffer]
;mov bx, 0x0
;mov [eax], bx
;add eax, 2
;mov [eax], bx
;call kernel.update
jmp os.pollKeyboard.drawKeyFinalize

os.keyboard.toChar :
cmp bl, 0x1E
mov al, 'A'
je os.keyboard.toChar.ret
cmp bl, 0x30
mov al, 'B'
je os.keyboard.toChar.ret
cmp bl, 0x2E
mov al, 'C'
je os.keyboard.toChar.ret
cmp bl, 0x20
mov al, 'D'
je os.keyboard.toChar.ret
cmp bl, 0x12
mov al, 'E'
je os.keyboard.toChar.ret
cmp bl, 0x21
mov al, 'F'
je os.keyboard.toChar.ret
cmp bl, 0x22
mov al, 'G'
je os.keyboard.toChar.ret
cmp bl, 0x23
mov al, 'H'
je os.keyboard.toChar.ret
cmp bl, 0x17
mov al, 'I'
je os.keyboard.toChar.ret
cmp bl, 0x24
mov al, 'J'
je os.keyboard.toChar.ret
cmp bl, 0x25
mov al, 'K'
je os.keyboard.toChar.ret
cmp bl, 0x26
mov al, 'L'
je os.keyboard.toChar.ret
cmp bl, 0x32
mov al, 'M'
je os.keyboard.toChar.ret
cmp bl, 0x31
mov al, 'N'
je os.keyboard.toChar.ret
cmp bl, 0x18
mov al, 'O'
je os.keyboard.toChar.ret
cmp bl, 0x19
mov al, 'P'
je os.keyboard.toChar.ret
cmp bl, 0x10
mov al, 'Q'
je os.keyboard.toChar.ret
cmp bl, 0x13
mov al, 'R'
je os.keyboard.toChar.ret
cmp bl, 0x1F
mov al, 'S'
je os.keyboard.toChar.ret
cmp bl, 0x14
mov al, 'T'
je os.keyboard.toChar.ret
cmp bl, 0x16
mov al, 'U'
je os.keyboard.toChar.ret
cmp bl, 0x2F
mov al, 'V'
je os.keyboard.toChar.ret
cmp bl, 0x11
mov al, 'W'
je os.keyboard.toChar.ret
cmp bl, 0x2D
mov al, 'X'
je os.keyboard.toChar.ret
cmp bl, 0x15
mov al, 'Y'
je os.keyboard.toChar.ret
cmp bl, 0x2C
mov al, 'Z'
je os.keyboard.toChar.ret
cmp bl, 0x39
mov al, ' '
je os.keyboard.toChar.ret
cmp bl, 0x34
mov al, '.'
je os.keyboard.toChar.ret
cmp bl, 0x33
mov al, ','
je os.keyboard.toChar.ret
cmp bl, 0x02
mov al, '1'
je os.keyboard.toChar.ret
cmp bl, 0x03
mov al, '2'
je os.keyboard.toChar.ret
cmp bl, 0x04
mov al, '3'
je os.keyboard.toChar.ret
cmp bl, 0x05
mov al, '4'
je os.keyboard.toChar.ret
cmp bl, 0x06
mov al, '5'
je os.keyboard.toChar.ret
cmp bl, 0x07
mov al, '6'
je os.keyboard.toChar.ret
cmp bl, 0x08
mov al, '7'
je os.keyboard.toChar.ret
cmp bl, 0x09
mov al, '8'
je os.keyboard.toChar.ret
cmp bl, 0x0A
mov al, '9'
je os.keyboard.toChar.ret
cmp bl, 0x0B
mov al, '0'
je os.keyboard.toChar.ret
cmp bl, 0x0E
mov al, 0x0
je os.keyboard.toChar.ret
cmp bl, 0x1C
mov al, 0x1
je os.keyboard.toChar.ret
mov al, 0x3f
mov ecx, charSPACE
os.keyboard.toChar.ret :
ret

retfunc :
ret

%include "..\boot\init_GDT.asm"
%include "..\kernel\drawChar.asm"
%include "..\modules\Guppy.asm"
%include "..\modules\Dolphin.asm"
%include "..\modules\programLoader.asm"
%include "..\programs\Console\console.asm"

KERNEL_BOOT :
db "Kernel Successfully Loaded!", 0

OK_MSG :
db "The operating system is now halted.", 0

HARDWARE_BOOT :
db "STATE: Hardware", 0

BOCHS_BOOT :
db "STATE: Emulator", 0

console.width :
dd 0x0

console.height :
dd 0x0

console.pos :
dd 0x0

console.buffer :
dd 0x0

os.pollKeyboard.isReady :
dd 0x0

console.charPos :
dd 0xA2

os.ecatch :
dd 0x10F0

console.line :
dd 0x0, 0x0, 0x0, 0x0

times 0x1000-($-$$) db 0