%include "..\boot\config.asm"
[bits 16]
[org 0x7c00]

	jmp short bootstart
	nop
	db "EXFAT   "	; OEM ID
	times 53 db 0x0	; padding
	dq 0x0	; ??
	dq 0x77e5f00	; fs size in sectors
	dd 0x800	; sectors to start of FAT
	dd 0xF00	; sectors used by FAT
	dd 0x1800	; first cluster start sector
	dd 0x77e47	; fs size in clusters
	dd 0x4		; root directory cluster
	dq 0x10009E6A639F		; ??
	db 9, 8, 1, 0x80	; log bytes/sector, log sectors/cluster, FAT count, driveID
	db 0	; percent in use
	times 7 db 0
	
	bootstart :
	; Initialize stack and segment registers
	mov ax, 0x0
	cli
	mov ss, ax
	mov sp, 0x7c00
	sti
	
	mov ax, 0x0
	mov ds, ax

	; Zero out the remaining registers
	mov cx, 0x0
	mov dx, 0x0
	mov bx, 0x0

	; Poll BIOS for the amount of RAM present
	call rm_detectRAM

	; Store the drive the computer booted from into dl
	mov [boot_drive], dl
	
	; Load the kernel into RAM
	mov dl, 0x80
	mov ch, 0
	mov bx, S2_CODE_LOC
	mov cl, 2
	mov dh, 0x40
	call boot.ATAload

	; Call the auxilary bootloader steps
	mov bl, 0x0
	jmp (S2_CODE_LOC+1)


boot.ATAload :
	pusha
		mov di, 0x0
		mov si, boot.ATAdata
		mov ah, 0x42
		mov dl, 0x80
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
		ret

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
	db "Warning: Unable to read all sectors.", 0xD, 0xA, 0
	
%include "..\boot\detection.asm"

times 510-($-$$) db 0


dw 0xaa55
