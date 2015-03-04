[bits 32]

clearScreenG :
pusha
mov dx, 0x0
mov ebx, SCREEN_BUFFER
mov edx, ebx
add edx, 0xf800
csgloop :
mov [ebx], dx
add ebx, 0x2
cmp ebx, edx
jl csgloop
mov ecx, [charpos]
mov ecx, SCREEN_BUFFER
mov [charpos], ecx
popa
ret

drawChar :	; ebx contains char to draw
pusha
mov [colorS], ah
mov dx, 0x0
drawCharloop :
; ah contains the current row of the char
mov ah, [ebx]
call drawRow
add ebx, 0x1
add dx, 0x1
cmp dx, 0x7
jl drawCharloop
call drawFill
mov ecx, [charpos]
sub ecx, 0xB40
add ecx, 6	; if newlines are broken, etc turn this back to 8
mov [charpos], ecx
popa
ret

drawFill :
pusha
mov dl, [char.solid]
cmp dl, 0x0
je drawFill.ret
mov ah, 0x0
call drawRow
call drawRow
drawFill.ret :
popa
ret

drawRow :	; ah contains row
pusha
mov ebx, [charpos]
mov cl, 6	; if newlines are broken, etc turn this back to 8
drawRowloop :
mov ch, ah
sub cl, 0x1
shr ch, cl
and ch, 0b1
cmp ch, 0b0
je drawRownd
mov dl, [colorS]
mov [ebx], dl
jmp drawRownddone
drawRownd :
push dx
mov dl, [char.solid]
cmp dl, 0x0
je drawRownd.nodr
mov dl, 0x0
mov [ebx], dl
drawRownd.nodr :
pop dx
drawRownddone :
add ebx, 0x1
cmp cl, 0x0
jg drawRowloop

mov ecx, [charpos]
add ecx, 0x140
mov [charpos], ecx
popa
ret

graphics.newline :
;mov eax, [charpos]
;mov bx, 0x0
;mov [eax], bx
mov eax, [charpos]
mov ecx, 0x0
add eax, 0x2
gnldloop :
sub eax, 0xA00
add ecx, 0x1
cmp eax, SCREEN_BUFFER
jg gnldloop
mov eax, ecx
mov ebx, 0xA00
mul ebx
add eax, SCREEN_BUFFER
mov [charpos], eax

ret

graphics.drawChar :		; char in ax
pusha
call graphics.getPos
call drawChar
popa
ret

graphics.getPos :
mov ebx, charA
mov edx, fontOrder
graphicsgetposloop :
mov cl, [edx]
cmp al, cl
je graphicsgetposret
add edx, 1
mov cl, [edx]
cmp al, cl
je graphicsgetposret
add ebx, 7
add edx, 1
mov cl, [edx]
cmp cl, '*'
je graphicsgetposret
jmp graphicsgetposloop

graphicsgetposret :
ret

os.seq :
	push ebx
	push ecx
	push edx
	seq.loop_0.start :
		mov cl, [eax]
		mov dl, [ebx]
		cmp cl, 0
			je seq.loop_0.go
		cmp cl, dl
			jne seq.loop_0.end
		add eax, 1
		add ebx, 1
		jmp seq.loop_0.start
	seq.loop_0.go :
		pop edx
		pop ecx
		pop ebx
		mov al, 0x1
		ret
	seq.loop_0.end :
		pop edx
		pop ecx
		pop ebx
		mov al, 0x0
		ret

charpos :
dd SCREEN_BUFFER

colorS :
db 0xF

char.solid :
db 0x0

fontOrder :
db 'A', 'a', 'B', 'b', 'C', 'c', 'D', 'd', 'E', 'e', 'F', 'f', 'G', 'g'
db 'H', 'h', 'I', 'i', 'J', 'j', 'K', 'k', 'L', 'l', 'M', 'm', 'N', 'n', 'O', 'o'
db 'P', 'p', 'Q', 'q', 'R', 'r', 'S', 's', 'T', 't', 'U', 'u', 'V', 'v', 'W', 'w'
db 'X', 'x', 'Y', 'y', 'Z', 'z', ' ', '_', '.', '!', ',', ',', '1', '1'
db '2', '2', '3', '3', '4', '4', '5', '5', '6', '6', '7', '7', '8', '8', '9', '9', '0', '0', '"', 0x27, ':', ':'
db '(', '[', ')', ']', '-', '~', '*'

charA :
db 0x04, 0x0A, 0x11, 0x1F, 0x11, 0x11, 0x11
db 0x1E, 0x11, 0x11, 0x1E, 0x11, 0x11, 0x1E	; B
db 0x06, 0x09, 0x10, 0x10, 0x10, 0x09, 0x06	; C

db 0b11100	; D
db 0b10010
db 0b10001
db 0b10001
db 0b10001
db 0b10010
db 0b11100

db 0b11111	; E
db 0b10000
db 0b10000
db 0b11100
db 0b10000
db 0b10000
db 0b11111

db 0b11111	; F
db 0b10000
db 0b10000
db 0b11111
db 0b10000
db 0b10000
db 0b10000

db 0b01110	; G
db 0b10001
db 0b10000
db 0b10111
db 0b10001
db 0b10001
db 0b01111

db 0b10001	; H
db 0b10001
db 0b10001
db 0b11111
db 0b10001
db 0b10001
db 0b10001

db 0b11111	; I
db 0b00100
db 0b00100
db 0b00100
db 0b00100
db 0b00100
db 0b11111

db 0b00001	; J
db 0b00001
db 0b00001
db 0b00001
db 0b00001
db 0b01001
db 0b00110

db 0b10001	; K
db 0b10001
db 0b10010
db 0b11100
db 0b10010
db 0b10001
db 0b10001

db 0b10000	; L
db 0b10000
db 0b10000
db 0b10000
db 0b10000
db 0b10000
db 0b11111

db 0b10001	; M
db 0b10001
db 0b11011
db 0b10101
db 0b10001
db 0b10001
db 0b10001

db 0b10001	; N
db 0b11001
db 0b11001
db 0b10101
db 0b10101
db 0b10011
db 0b10001

db 0b00100	; O
db 0b01010
db 0b10001
db 0b10001
db 0b10001
db 0b01010
db 0b00100

db 0b11110	; P
db 0b10001
db 0b10001
db 0b11110
db 0b10000
db 0b10000
db 0b10000

db 0b01110	; Q
db 0b10001
db 0b10001
db 0b10001
db 0b10101
db 0b10010
db 0b01101

db 0b11110	; R
db 0b10001
db 0b10001
db 0b11110
db 0b10001
db 0b10001
db 0b10001

db 0b00111	; S
db 0b01000
db 0b01000
db 0b00100
db 0b00010
db 0b00010
db 0b11100

db 0b11111	; T
db 0b00100
db 0b00100
db 0b00100
db 0b00100
db 0b00100
db 0b00100

db 0b10001	; U
db 0b10001
db 0b10001
db 0b10001
db 0b10001
db 0b10001
db 0b01110

db 0b10001	; V
db 0b10001
db 0b10001
db 0b01010
db 0b01010
db 0b01010
db 0b00100

db 0b10001	; W
db 0b10001
db 0b10001
db 0b10101
db 0b10101
db 0b10101
db 0b01010

db 0b10001	; X
db 0b10001
db 0b01010
db 0b00100
db 0b01010
db 0b10001
db 0b10001

db 0b10001	; Y
db 0b10001
db 0b01010
db 0b01110
db 0b00100
db 0b00100
db 0b00100

db 0b11111	; Z
db 0b00001
db 0b00010
db 0b00100
db 0b01000
db 0b10000
db 0b11111

charSPACE :
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

db 0b00000	; .
db 0b00000
db 0b00000
db 0b00000
db 0b00000
db 0b00000
db 0b00100


db 0b00000	; ,
db 0b00000
db 0b00000
db 0b00000
db 0b00100
db 0b00100
db 0b01000

db 0b00100	; 1
db 0b01100
db 0b10100
db 0b00100
db 0b00100
db 0b00100
db 0b11111

db 0b01110	; 2
db 0b10001
db 0b00001
db 0b00010
db 0b00100
db 0b01000
db 0b11111

db 0b01110	; 3
db 0b10001
db 0b00001
db 0b01110
db 0b00001
db 0b10001
db 0b01110

db 0b10001	; 4
db 0b10001
db 0b10001
db 0b11111
db 0b00001
db 0b00001
db 0b00001

db 0b11111	; 5
db 0b10000
db 0b10000
db 0b11110
db 0b00001
db 0b00001
db 0b11110

db 0b01110	; 6
db 0b10001
db 0b10000
db 0b11110
db 0b10001
db 0b10001
db 0b01110

db 0b11111	; 7
db 0b00001
db 0b00001
db 0b00001
db 0b00001
db 0b00001
db 0b00001

db 0b01110	; 8
db 0b10001
db 0b10001
db 0b01110
db 0b10001
db 0b10001
db 0b01110

db 0b01110	; 9
db 0b10001
db 0b10001
db 0b01111
db 0b00001
db 0b10001
db 0b01110

db 0b01110	; 0
db 0b10001
db 0b10001
db 0b10101
db 0b10001
db 0b10001
db 0b01110

db 0b01010	; "
db 0b01010
db 0b00000
db 0b00000
db 0b00000
db 0b00000
db 0b00000

db 0b00000	; :
db 0b00100
db 0b00000
db 0b00000
db 0b00000
db 0b00100
db 0b00000

db 0b00111	; [
db 0b00100
db 0b00100
db 0b00100
db 0b00100
db 0b00100
db 0b00111

db 0b11100	; ]
db 0b00100
db 0b00100
db 0b00100
db 0b00100
db 0b00100
db 0b11100

db 0b00000	; -
db 0b00000
db 0b00000
db 0b11111
db 0b00000
db 0b00000
db 0b00000

db 0b11111
db 0b11111
db 0b11111
db 0b11111
db 0b11111
db 0b11111
db 0b11111
