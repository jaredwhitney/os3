[bits 16]	; BIOS boots the bootloader into 16-bit mode
[org 0x7c00]	; The code will be loaded into memory at 0x7c00

	; Begin with a jmp short instruction as needed for some BIOSes to recognize it as a bootloader
		jmp short bootstart
		nop

		
bootstart :

	; Initialize stack and segment registers
		
		xor eax, eax	; set eax to 0
		
		cli	; disable interrupts
		mov ss, ax	; set the stack segment to 0
		mov sp, 0x7c00	; set the stack offset to 0x7c00 (it will grow downwards)
		sti	; re-enable interrupts
		
		mov ds, ax	; set the data segment to 0

	; Store the drive the computer booted from
	
		mov [boot_drive], dl
		
	; Zero out the remaining general registers
	
		xor ecx, ecx
		xor edx, edx
		xor ebx, ebx

	; Poll BIOS for the amount of RAM present
	
		call rm_detectRAM

	; Load the Stage 2 bootloader and the beginning of the kernel into RAM
	
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
	
		; Initialize the registers to the appropriate values
		
			mov di, 0x0	; di:si point to the ATA packet
			mov si, boot.ATAdata
			
			mov dl, 0x80	; dl is the drive to read from
		
		; Call the interrupt
		
			mov ah, 0x42	; int 0x13 ah = 0x42 is BIOS' ATA read function
			int 0x13
				jc sload_error	; if the carry flag was set, display a warning
		
		; Store the number of sectors read
		
			mov ax, [boot.ATAdata.sectorsRead]
			mov [0x1000], ax
		
	popa
	ret
	
	sload_error:
			mov bx, ERRORs
			call boot.print
		popa
		ret

		
; Bootloader print function (called with a null-terminated String in ebx)

boot.print :
	pusha
		mov ah, 0x0E
		mov al, [bx]	; first character -> al
		boot.print.loop :
			push bx
			mov bh, 0x0
			mov bl, 0x7	; set the text color
			int 0x10	; write the character
			pop bx
			inc bx	; move onto the next char in the String
			mov al, [bx]	; next character -> al
			cmp al, 0
				jne boot.print.loop
	popa
	ret		

	
; Includes

	%include "..\boot\config.asm"
	%include "..\boot\detection.asm"
	%include "..\boot\stringConstants.asm"
	

; Data

	boot_drive :
		db 0x0
	
	ERRORs :
		db "Warning: Unable to read all sectors.", carriage_return, linefeed, endstring

	; BIOS ATA packet

		boot.ATAdata :
			db 0x10	; packet size
			db 0	; always 0
			boot.ATAdata.sectorsRead :
				dw 128	; sectors to load
			dw S2_CODE_LOC	; data buffer offset
			dw 0x0	; data buffer segment
			dd 0x1	; LBA to read from
			dd 0x0	; upper part of LBA


; Pad the file until it is 510 bytes long...

	times 510-($-$$) db 0

; Then set bytes 511 and 512 to 0x55 and 0xAA to mark this sector as containing a bootloader

	dw 0xaa55
