[bits 16]

pusha
mov al, cl
mov bx, dx
mov edx, eax
mov ch, dl

call label1

mov edx, 0xFA0
popa
nop
nop
mov ah, 0xE3
nop


add ax, bx
add bl, cl
add edx, ecx


mov al, [bx]
mov dl, [bx]
mov cl, [bx]

mov al, [eax]


mov dx, [ecx]

mov edx, [ecx]
label1 :
mov [eax], al
mov [ebx], cl

mov [ecx], ebx
mov [edx], dx

ret



jmp 0x20
jmp 0x8000
jmp 0x200
jmp ebx
jmp dx

