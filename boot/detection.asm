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

rmDetectAllRAM :
	; get a memory buffer held in [RAMMap] (does malloc work in real mode)
	xor ebx, ebx
ret

RAMMap :
	dd 0x0

region_base		equ 0x0		; qword
region_length	equ 0x8		; qword
region_type		equ 0x10	; dword
region_attribs	equ 0x14	; dword