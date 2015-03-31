[bits 16]
rm_detectRAM :
xor bx, bx
mov ax, 0xe801	; detect continuous ram
int 0x15
cmp bx, 0x0
jne rmdramnc
mov bx, dx
rmdramnc :
mov [0x10C0], bx
ret
