[bits 16]
[org 0x7c00]

	; Initialize stack and segment registers
	cli
	mov bp, 0x2000
	mov sp, bp
	mov ax, 0x0
	mov ds, ax
	mov es, ax
	mov ss, ax
	sti

	; Zero out the remaining registers
	mov cx, 0x0
	mov dx, 0x0
	mov bx, 0x0

	; Change video mode from text mode (0x3) to 320x240 8bpp (0x13)
	mov al, 0x13
	mov ah, 0x0
	int 0x10

	; Print "Hello World!" to the screen
	mov bx, Greeting
	call boot.print

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

	; Alert the user that we are attempting to enable the A20 Gate
	mov bx, EnableA20
	call boot.print

	; Enable the A20 Gate
	mov ax, 0x2401
	int 0x15

	; Inform the user that the A20 Gate was successfully enabled (the computer has not rebooted or frozen).
	mov bx, SUCCESS
	call boot.print
	
	; Load the Protected Mode GDT
	lgdt [GDTdescriptor]

	; Turn on bit 0 of the cr0 register (telling the computer it should be in protected mode)
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	
	; Clear and disable interrupts (will not work in pmode until an IVT is created)
	cli
	
	; Perform a long jump to 32-bit code.
	jmp segOFFcode:enter_PM

	; If execution ever reaches here (which it shouldn't), hang indefinately.
	jmp $

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

Greeting :
	db "Hello World!", 0xD, 0xA, 0

boot_drive :
	db 0x0, 0x0

EnableA20 :
	db "Enabling A20... ", 0

LoadGDT :
	db "Loading GDT...", 0

SUCCESS :
	db "Success!", 0xD, 0xA, 0

ERRORrt :
	db "Error: Retrying...", 0xD, 0xA, 0

ERRORs :
	db "Warning: Unable to read all sectors.", 0xD, 0xA, 0


[bits 32]
enter_PM :
	
	mov ax, segOFFdata
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	
	mov ebp, 0xA00000
	mov esp, ebp
	
	mov ebx, ENTER_PM
	mov ecx, 0x280
	mov ah, 0xB
	call console.print
	
	mov al, [0x7e00]
	mov [0xb8000], al
	cmp al, 0x4a
	jne stop
	
	jmp 0x7e01
	
stop:
	mov ebx, STOPm
	mov ecx, 0x320
	mov ah, 0xC
	call console.print
	jmp $

console.print :
	pusha
	mov edx, 0xb8000
	add edx, ecx
	printitp :
		mov al, [ebx]
		cmp al, 0
			je printdonep
		mov [edx], ax
		add ebx, 1
		add edx, 2
		jmp printitp
	printdonep :
	popa
	ret

%include "..\boot\init_GDT.asm"
%include "..\boot\detection.asm"

ENTER_PM :
	db "Booted into Protected Mode.", 0

STOPm :
	db "Halting Execution", 0

times 510-($-$$) db 0
dw 0xaa55
