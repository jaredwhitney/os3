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

	; Zero out the remaining registers
	mov cx, 0x0
	mov dx, 0x0
	mov bx, 0x0

	; Poll BIOS for the amount of RAM present
	call rm_detectRAM

	; Store the drive the computer booted from into dl
	mov [boot_drive], dl

	; Store that we are booting in real hardware (it will be overridden later if not running on a real computer)
	mov ax, 0x0
	mov [0x1000], ax
	
	; Load the kernel into RAM
	mov dl, 0x80
	mov ch, 0
	mov bx, 0x7e00
	mov cl, 2
	mov dh, 0x40
	call boot.ATAload

	; Call the auxilary bootloader steps
	mov bl, 0x0
	jmp 0x7e01


boot.ATAload :
	pusha
		mov di, 0x0
		mov si, boot.ATAdata
		mov ah, 0x42
		mov dl, 0x80
		int 0x13
			jc sload_error
	popa
	ret
boot.ATAdata :
	db 0x10	; packet size
	db 0	; always 0
	dw 126	; sectors to load
	dw 0x7e00	; offs
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

Greeting :
	db "Hello World!", 0xD, 0xA, 0

boot_drive :
	db 0x0, 0x0

LoadGDT :
	db "Loading GDT...", 0

ERRORrt :
	db "Error: Retrying...", 0xD, 0xA, 0

ERRORs :
	db "Warning: Unable to read all sectors.", 0xD, 0xA, 0
	
%include "..\boot\detection.asm"

times 510-($-$$) db 0
dw 0xaa55
