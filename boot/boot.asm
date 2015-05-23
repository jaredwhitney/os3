; NOTE: If this documentation appears to be formatted oddly, make sure that you are viewing it
; 	- In a fixed-width font
;	- With a tab size of 4 (tab aligns text to the next chunk of 4 spaces)

; boot.asm
;	Created :		12-19-14
;	Uploaded :		2-4-15 (https://github.com/jaredwhitney/os3/blob/f2e74ca82ff9382242103e0ef4cfe8b0c671e882/boot/boot.asm)
;	Commented :		5-21-15
;	Modified :		5-23-15
;	Documented :	Not yet documented.

;
; Contains os3's stage 1 bootloader.
;


; Constants

	; Bootloader constants
	BOOTLOADER_END					equ 0x7e00	; location of the end of the bootloader
	BOOTLOADER_MAGIC_NUMBER			equ 0xaa55	; marks this sector as containing a bootloader
	STAGE2_ENTRY					equ 0x7e01	; where the stage 2 bootloader code begins
	
	; Misc constants
	NON_USB_BOOT					equ 0x1000	; where to store whether or not the system was booted from a thumbdrive or not
	STACK_BASE						equ 0x2000	; where the stack should be positioned
	
	; Interrupt constants
	DISK_COMMAND					equ 0x13	; BIOS interrupt to perform disk operations
		FUNC_DISK_READ				equ 0x02	; BIOS function to read from a disk
			REAL_DRIVE				equ 0x00	; drive that is used by the default harddrive
			USB_DRIVE 				equ 0x80	; drive that is used by BIOS for USB emulation
		FUNC_FLOPPY_RESET			equ 0x00	; BIOS function to reset the floppy controller
		
	DISPLAY_COMMAND					equ 0x10	; BIOS interrupt to 
		FUNC_TELETYPE_PRINTCHAR		equ 0x0e	; BIOS interrupt to output a character in teletype mode
			COLOR_GRAY				equ 0x07	; a gray color in the default palette
			TELETYPE_DEFAULT_PAGE	equ 0x00	; default page for teletype operations
			
	; String constants
	CARRIAGE_RETURN					equ 0x0D	; carriage return character
	LINE_FEED						equ 0x0A	; line feed character
	STRING_END						equ 0x00	; null-byte which signals termination of a String
	
	; Boolean constants
	FALSE							equ 0x00	; the value 'false'
	TRUE							equ 0xFF	; the value 'true'


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
	mov bp, STACK_BASE
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

	; Store that we are booting from a thumbdrive (it will be overridden later if not)
	mov ax, FALSE
	mov [NON_USB_BOOT], ax
	
	; Load the kernel into RAM (NOTE: ax=0x0 from above)
	mov dl, USB_DRIVE		; try the USB drive first
	mov ch, 0
	mov bx, BOOTLOADER_END
	mov cl, 2
	mov dh, 0x40
	call boot.load

	; Call the auxilary bootloader steps
	mov bl, 0x0
	jmp STAGE2_ENTRY

	
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
		mov ah, FUNC_FLOPPY_RESET
		int DISK_COMMAND
	pop ax
	
	; Shuffle around registers (the function accepts its values in different registers than are expected by int 0x13)
	mov dl, bl	
	push es			; ensure that $es can be restored later
	mov es, ax
	mov ah, FUNC_DISK_READ
	mov al, dh		; number of sectors to read
	mov dh, 0x0		; head to read from

	; Call the actual interrupt! (read the data)
	int DISK_COMMAND
	
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
	mov ax, TRUE
	mov [NON_USB_BOOT], ax	; set the word at [NON_USB_BOOT] to TRUE in order keep a record that the system retried the read
	popa				; restore all of the values used to originally call the function
	mov dl, REAL_DRIVE			; set drive to 0x0
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
	mov ah, FUNC_TELETYPE_PRINTCHAR
	mov al, [bx]	; move the first character into $al
	boot.print.loop :
		push bx
		mov bh, TELETYPE_DEFAULT_PAGE	; write to page 0
		mov bl, COLOR_GRAY	; use a gray color
		int DISPLAY_COMMAND	; call the interrupt (display the character)
		pop bx
		add bx, 1	; read from the next character in the String
		mov al, [bx]
		cmp al, STRING_END	; if it does not equal 0, repeat (Strings are null-terminated)
			jne boot.print.loop
popa
ret		
	
	
; Data
	; Strings
		Greeting :
			db "Hello World!", CARRIAGE_RETURN, LINE_FEED, STRING_END
			
		LoadGDT :
			db "Loading GDT...", STRING_END
			
		ERRORrt :
			db "Error: Retrying...", CARRIAGE_RETURN, LINE_FEED, STRING_END
			
		ERRORs :
			db "Warning: Unable to read all sectors.", CARRIAGE_RETURN, LINE_FEED, STRING_END
	; Words
		boot_drive :
			dw 0x0



; Include files
	%include "..\boot\detection.asm"



; Padding
	; Bootloaders must contain the magic number 0xaa55 at the end of the sector they are stored in so that BIOS can find them
	
	times 510-($-$$) db 0	; pad the remaining space with 0's (one sector = 512 bytes)
	dw BOOTLOADER_MAGIC_NUMBER				; put the 'magic number' in the remaining two bytes of the sector

	
	
; Useful Links
	; University of Birmingham Guide (goes from bootloaders up to basic kernels) <http://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf>
	; Wikipedia page on INT 0x10 <http://en.wikipedia.org/wiki/INT_10H>
	; Wikipedia page on INT 0x13 <http://en.wikipedia.org/wiki/INT_13H>
	; OSDev Wiki page on BIOS <http://wiki.osdev.org/BIOS>
	; OSDev Wiki page on ATA in real mode <http://wiki.osdev.org/ATA_in_x86_RealMode_%28BIOS%29>
	; OSDev Bare Bones tutorial <http://wiki.osdev.org/Bare_Bones>
	; OSDev Fourm <http://forum.osdev.org>
	

