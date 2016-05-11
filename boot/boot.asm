%include "..\boot\config.asm"
[bits 16]
[org 0x7c00]

	jmp short bootstart
	nop
	
	bootstart :
	; Initialize stack and segment registers
	mov ax, 0x0
	cli
	mov ss, ax
	mov sp, 0x7c00
	sti
	
	mov ax, 0x0
	mov ds, ax
	
	; Store the drive the computer booted from into dl
	mov [0x1008], dl

	; Zero out the remaining registers
	mov cx, 0x0
	mov dx, 0x0
	mov bx, 0x0

	; Poll BIOS for the amount of RAM present
	call rm_detectRAM
	
	mov dword [0x100A], 0x0	; [0x100A] is whether or not BIOS CHS needs to be used instead of LBA
	
	mov ah, 0x41
	mov bx, 0x55aa
	mov dl, 0x80
	int 0x13
		jc boot.fallBackLoader
	
	; Load the kernel into RAM
	mov dl, [0x1008]
	mov ch, 0
	mov bx, S2_CODE_LOC
	mov cl, 2
	mov dh, 0x40
	call boot.ATAload

	; Call the auxilary bootloader steps
	mov bl, 0x0
	boot.continue :
	jmp (S2_CODE_LOC+1)

boot.fallBackLoader :
	mov bx, FALLBACKs
	call boot.print
	boot.fallBackLoader.go :
	mov dword [0x100A], 0xFF
	mov ah, 2
	mov al, 60
	mov ch, 0&0xFF
	mov cl, 2|((0>>2)&0xC0)
	mov dh, 0
	mov bx, S2_CODE_LOC
	mov dl, [boot_drive]
	int 0x13
	mov word [0x1000], 60
	jmp boot.continue
	
boot.ATAload :
	pusha
		mov di, 0x0
		mov si, boot.ATAdata
		mov ah, 0x42
		mov dl, [0x1008]
		int 0x13
			jc sload_error
		mov ax, [boot.ATAdata.sectorsRead]
		mov [0x1000], ax
	popa
	ret
boot.ATAdata :
	db 0x10	; packet size
	db 0	; always 0
	boot.ATAdata.sectorsRead :
		dw 128	; sectors to load
	dw S2_CODE_LOC	; offs
	dw 0x0	; seg
	dd 0x1	; start LBA
	dd 0x0	; upper LBA
		
	sload_error:
		mov bx, ERRORs
		call boot.print
		popa
		pop eax
		jmp boot.fallBackLoader.go

	boot.print :
		pusha
		mov ah, 0x0E
		mov al, [bx]
		boot.print.loop :
			push bx
			mov bh, 0x0
			mov bl, 0x7
			int 0x10
			pop bx
			add bx, 1
			mov al, [bx]
			cmp al, 0
				jne boot.print.loop
		popa
		ret		

boot_drive :
	db 0x0

ERRORs :
	db "Warning: Unable to read all sectors. Falling back to CHS Read...", 0xD, 0xA, 0
FALLBACKs :
	db "Warning: INT13h Extentions Unsupported. Falling back to CHS Read...", 0xD, 0xA, 0
	
%include "..\boot\detection.asm"

times 510-($-$$) db 0


dw 0xaa55
