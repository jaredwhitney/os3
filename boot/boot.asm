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
	call boot.load

	; Call the auxilary bootloader steps
	mov bl, 0x0
	jmp 0x7e01
	
	; Alert the user that we are attempting to enable the A20 Gate
	;mov bx, EnableA20
	;call boot.print

	boot.load :
		pusha
		push ax
		push bx
		mov ah, 0	; reset floppy controller
		mov bl, dl
		mov dl, 0
		int 0x13
		mov dl, bl
		pop bx
		pop ax
		push es
		mov es, ax
		mov ah, 0x02	;telling bios we want to read from memory	|	location to read to sent in as BX
		mov al, dh		;the number of sectors to read				|	sent in as DH
		mov dh, 0x0	;head to read from

		int 0x13
		pop es
		
		cmp ah, 0x0
			jne lret
		
		cmp dh, al
			jne sload_error
		
		popa
		ret
		
	lret:
		mov bx, ERRORrt
		call boot.print
		mov ax, 0xF
		mov [0x1000], ax
		popa
		mov dl, 0x0
		jmp boot.load
		
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
