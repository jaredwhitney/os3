[bits 16]

mov eax, label1

pusha
mov al, cl
mov bx, dx
mov edx, eax
mov ch, dl

label2 :
call label1
jmp label1

mov edx, 0xFA0
popa
nop
nop
mov ah, 0xE3
mov al, 2
mov dx, 5
mov ecx, 0x281
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
mov dword
[edx], dx

ret



jmp 0x20
jmp 0x8000
jmp 0x200
jmp ebx
jmp dx

