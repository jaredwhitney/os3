ATA_SIMPLE.read :	; ecx contains a buffer :)
pusha

	mov dx, 0x1F1
	mov al, 0x0
	out dx, al

	mov dx, 0x1F2
	mov al, 0x01	; sectorcount
	out dx, al

	mov dx, 0x1F3
	mov al, 0x0	; low byte
	out dx, al

	mov dx, 0x1F4
	mov al, 0x0	; mid byte
	out dx, al

	mov dx, 0x1F5
	mov al, 0x0	; high byte
	out dx, al

	mov dx, 0x1F6
	mov al, 0x0	; high nibble
	mov bl, 0xE0	; magic bits
	or al, bl
	mov bl, 0x1	; drive number
	shl bl, 4
	or al, bl
	out dx, ax

	mov dx, 0x1F7
	ATAS.read.waitfor :
		in al, dx
		test al, 0b1000
			jz ATAS.read.waitfor

	mov dx, 0x1F0
	xor ebx, ebx
	ATAS.read.loop :
	in ax, dx
	mov [ecx], ax
	add ecx, 2
	add ebx, 2
	cmp ebx, 0xFF
		jl ATAS.read.loop
	
popa
ret