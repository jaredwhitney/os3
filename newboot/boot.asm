[bits 16]
[org 0x7c00]

jmp short bootstart
nop
dd "MINFS5.0"

bootstart :

cli

xor eax, eax
xor ebx, ebx
xor ecx, ecx

mov ds, ax
mov ss, ax
mov sp, 0x7c00

sti

mov [boot_drive], dl
and edx, 0xFF

			pusha
			mov bh, 0x0
			mov bl, 0x7
			mov ah, 0xE
			mov al, '0'
			int 0x10
			popa

mov ah, 0x41
mov bx, 0x55AA
mov dl, 0x80
int 0x13
	jc ataLoadOther

ataLoad :
	mov dl, 0x80
	mov ch, 0
	mov bx, S2_CODE_LOC
	mov cl, 2
	mov dh, 0x40
	
	mov di, 0x0
	mov si, ataLoad.packetData
	mov ah, 0x42
	int 0x13
	
	mov ax, [sectorCount]
	mov [0x1000], ax

			pusha
			mov bh, 0x0
			mov bl, 0x7
			mov ah, 0xE
			mov al, '1'
			int 0x10
			popa
			

jmp S2_CODE_LOC

ataLoadOther :

			pusha
			mov bh, 0x0
			mov bl, 0x7
			mov ah, 0xE
			mov al, '@'
			int 0x10
			popa
			
			ataLoadOtherLoop :
			
			cmp dword [.loadTime], 127
				je .loopDone
			
			inc dword [.loadTime]
			
			mov ah, 2
			mov al, 1
			mov ch, 0 &0xFF
			mov cl, [.loadTime]
			add cl, 1
			or cl, ((0>>2)&0xC0)
			mov dh, 0
			mov bx, [.otherPosUpper]
			mov es, bx
			mov bx, [.otherPosLower]
			add word [.otherPosUpper], 0x20
			mov dl, [boot_drive]
			int 0x13
				jnc ataLoadOther
			cmp ah, 0
				je ataLoadOther
			cmp dword [.loadTime], 1
				je halt
		
		.loopDone :
		
		mov ax, [.loadTime]
		sub ax, 1	; ?
		mov [0x1000], ax

			pusha
			mov bh, 0x0
			mov bl, 0x7
			mov ah, 0xE
			mov al, '1'
			int 0x10
			popa
			
	jmp S2_CODE_LOC
	
.loadTime :
	dd 0
.otherPosUpper :
	dw 0
.otherPosLower :
	dw S2_CODE_LOC
halt :
		mov bh, 0x0
		mov bl, 0x7
		mov ah, 0xE
		mov al, '!'
		int 0x10
	cli
	hlt
ataLoad.packetData :
	db 0x10
	db 0
	sectorCount :
	dw 128
	dw S2_CODE_LOC
	dw 0x0
	dd 0x1
	dd 0x0

boot_drive :
	db 0x0
	
times 510-($-$$) db 0
dw 0xaa55

%include "../newboot/oldconfig.asm"
