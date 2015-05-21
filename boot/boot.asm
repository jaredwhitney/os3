; NOTE: If this documentation appears to be formatted oddly, make sure that you are viewing it
; 	- In a fixed-width font
;	- With a tab size of 4 (tab aligns text to the next chunk of 4 spaces)

; boot.asm
;	Created :		12-19-14
;	Uploaded :		2-4-15 (https://github.com/jaredwhitney/os3/blob/f2e74ca82ff9382242103e0ef4cfe8b0c671e882/boot/boot.asm)
;	Commented :		5-21-15
;	Documented :	Not yet documented.

;
; Contains os3's stage 1 bootloader.
;

; The proccessor is currently in 16-bit mode, make sure the assembler knows this.
[bits 16]

; This code will be loaded in at 0x7c00 (the location that BIOS should always copy bootloader code to).
[org 0x7c00]

; Where execution will begin (function tag only included for completeness).
;Params :
;	none
;Returns :
;	none (jump to 0x7e01)
;Modifies :
;	$ax, $cx, $dx, $bx
;	$es, $ss, $ds
;	$sp, $bp
;Preconditions :
;	processor in 16-bit mode
;	processor in real or unreal mode
;	function must be loaded in memory at 0x7c00
boot.entryPoint :

	; Initialize stack and segment registers
	cli
	mov bp, 0x2000
	mov sp, bp
	xor ax, ax		; xor'ing any number with itself will equal 0, and is slightly faster than a "mov $reg, 0x0"
	mov ds, ax
	mov es, ax
	mov ss, ax
	sti

	; Zero out the remaining registers
	mov cx, 0x0
	mov dx, 0x0
	mov bx, 0x0

	; Poll BIOS for the amount of RAM present
	call rm_detectRAM

	; Store the drive the computer booted from into [boot_drive]
	mov [boot_drive], dl

	; Store that we are booting in real hardware (it will be overridden later if not running on a real computer)
	mov ax, 0x0
	mov [0x1000], ax
	
	; Load the kernel into RAM (NOTE: ax=0x0 from above)
	mov dl, 0x80	; drive 0x80 is used by BIOS for USB emulation, try it first
	mov ch, 0
	mov bx, 0x7e00
	mov cl, 2
	mov dh, 0x40
	call boot.load

	; Call the auxilary bootloader steps
	mov bl, 0x0
	jmp 0x7e01

	
; Loads data from a disk using BIOS int 0x13.
;Params :
;	$ax = 'segment' of the location to read the data to
;	$bx = 'offset' of the location to read the data to
;	$cl = 'sector' | ((cylinder >> 2) & 0xC0)
;	$ch = 'cylinder' & 0xFF
;	$dl = Number of the 'drive' to read from
;	$dh = Number of sectors to be read
;Returns :
;	none (return to caller)
;Modifies :
;	none
;Preconditions :
;	processor in 16-bit mode
;	processor in real or unreal mode

boot.load :
pusha

	; Reset the floppy controller (in case it is being booted from a floppy disc)
	push ax
		mov ah, 0	; BIOS function to use (int 0x13 function 0) to reset the floppy controller
		int 0x13
	pop ax
	
	; Shuffle around registers (the function accepts its values in different registers than are expected by int 0x13)
	mov dl, bl	
	push es			; ensure that $es can be restored later
	mov es, ax
	mov ah, 0x02	; BIOS function to use (int 0x13 function 2) to read from a disk
	mov al, dh		; number of sectors to read
	mov dh, 0x0		; head to read from

	; Call the actual interrupt! (read the data)
	int 0x13
	
	; Restore the previous value of $es
	pop es
	
	; If there was an error (BIOS sets $ah to 0x0 on success), jump to @lret to retry
	cmp ah, 0x0
		jne lret
	
	; If the number of sectors actually read ($al) isn't equal to the number of sectors expected ($dh), there was an error (jump to @sload_error)
	cmp dh, al
		jne sload_error
	
popa
ret

; Retries a failed disk load with drive 0x0.
;Params :
;	INTERNAL_USE_ONLY <@boot.load>
;Returns :
;	N/A (jump to @boot.load)
;Modifies :
;	pops all reg words
;Preconditions :
;	INHERIT_FROM_PARENT

lret:
	mov bx, ERRORrt
	call boot.print		; alert the user that there was an error
	mov ax, 0xF
	mov [0x1000], ax	; set the word at [0x1000] to 0xFF in order keep a record that the system retried the read
	popa				; restore all of the values used to originally call the function
	mov dl, 0x0			; set drive to 0x0
	jmp boot.load		; retry the load

; Alerts the user that a disk load has failed to read the appropriate amount of sectors.
;Params :
;	INTERNAL_USE_ONLY <@boot.load>
;Returns :
;	none (return to parent caller)
;Modifies :
;	pops all reg words
;Preconditions :
;	INHERIT_FROM_PARENT

sload_error:
	mov bx, ERRORs
	call boot.print		; alert the user that not all sectors could be read
popa
ret


; Prints out a String to the teletype screen.
;Params :
;	$bx = location of the text to be printed
;Returns :
;	none (return to caller)
;Modifies :
;	none
;Preconditions :
;	processor in 16-bit mode
;	processor in real or unreal mode

boot.print :
pusha
	mov ah, 0x0E	; BIOS function to use (int 0x10 function 0xE) to output a character in teletype mode
	mov al, [bx]	; move the first character into $al
	boot.print.loop :
		push bx
		mov bh, 0x0	; write to page 0
		mov bl, 0x7	; use a gray color
		int 0x10	; call the interrupt (display the character)
		pop bx
		add bx, 1	; read from the next character in the String
		mov al, [bx]
		cmp al, 0	; if it does not equal 0, repeat (Strings are null-terminated)
			jne boot.print.loop
popa
ret		
	
	
; Data
	; Strings
		Greeting :
			db "Hello World!", 0xD, 0xA, 0	; 0xD = carriage return, 0xA = line feed
			
		LoadGDT :
			db "Loading GDT...", 0
			
		ERRORrt :
			db "Error: Retrying...", 0xD, 0xA, 0
			
		ERRORs :
			db "Warning: Unable to read all sectors.", 0xD, 0xA, 0
	; Words
		boot_drive :
			dw 0x0



; Include files
	%include "..\boot\detection.asm"



; Padding
	; Bootloaders must contain the magic number 0xaa55 at the end of the sector they are stored in so that BIOS can find them)
	
	times 510-($-$$) db 0	; pad the remaining space with 0's (one sector = 512 bytes)
	dw 0xaa55				; put the 'magic number' in the remaining two bytes of the sector

	
	
; Useful Links
	; University of Birmingham Guide (goes from bootloaders up to basic kernels) <http://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf>
	; Wikipedia page on INT 0x10 <http://en.wikipedia.org/wiki/INT_10H>
	; Wikipedia page on INT 0x13 <http://en.wikipedia.org/wiki/INT_13H>
	; OSDev Wiki page on BIOS <http://wiki.osdev.org/BIOS>
	; OSDev Wiki page on ATA in real mode <http://wiki.osdev.org/ATA_in_x86_RealMode_%28BIOS%29>
	; OSDev Bare Bones tutorial <http://wiki.osdev.org/Bare_Bones>
	; OSDev Fourm <http://forum.osdev.org>
	

