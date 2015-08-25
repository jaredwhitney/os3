[bits 16]
[org 0x7e00]
db 0x4a

MODE_TEXT equ 0x0
MODE_GRAPHICS equ 0x1

stage2:
	;	Perform extraneous tasks here	;
	sgdt [RMGDTSAVE]
	
	mov dword [DisplayMode], MODE_TEXT
	call boot.useVGAmode
								;jmp stage2.novesa	; if left uncommented (ALONG WITH THE OTHER LINE), disable VESA mode.
	;call VESA.getMode
	;mov bx, 0x11b
	;call VESA.mode
	stage2.novesa :
	;	Shift into Protected Mode	;
	jmp boot.Protected_Mode

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

VESA.getMode :
	pusha
	mov ax, 0x8000
	mov es, ax	; ret seg
	xor di, di	; ret off
	mov cx, 0x11b	; MODE NUMBER
	add cx, 0x4000	; make the mode linear
	mov ax, 0x4f01
	int 0x10
	
	popa
	ret

VESA.mode :	; mode in bx
	pusha
	mov ax, 0x4f02
	add bx, 0x4000	; assuming we want to use a linear framebuffer!
	int 0x10
	cmp ax, 0x4f
	mov ax, 0xFF
	je VESA.mode.good
	mov ax, 0x0
	VESA.mode.good :
	mov [Graphics.VESA_SUPPORTED], ax
	popa
	ret
	
boot.useVGAmode :
	; Change video mode from text mode (0x3) to 320x240 8bpp (0x13)
	mov al, 0x13
	mov ah, 0x0
	int 0x10
	ret

boot.Protected_Mode :
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
	
	; Clear and disable interrupts (will not work in pmode until an IDT is created)
	cli
	
	; Perform a long jump to 32-bit code.
	jmp segOFFcode:enter_PM

	; If execution ever reaches here (which it shouldn't), hang indefinately.
	jmp $
	
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
	call consolePM.print
	
	mov al, [0x7e00]
	mov [0xb8000], al
	cmp al, 0x4a
	jne stop
	
	call loadIDT
	
	jmp Kernel.init
	
stop:
	mov ebx, STOPm
	mov ecx, 0x320
	mov ah, 0xC
	call consolePM.print
	jmp $

consolePM.print :
	pusha
	mov edx, 0xb8000
	add edx, ecx
	printitpPM :
		mov al, [ebx]
		cmp al, 0
			je printdonepPM
		mov [edx], ax
		add ebx, 1
		add edx, 2
		jmp printitpPM
	printdonepPM :
	popa
	ret
	
;VESA.cinfo :
	;pusha
	;mov edx, 0x2000
	;add edx, 15
	;mov ebx, [edx]
	;mov ebx, [ebx]
	;call console.numOut
	;popa
	;ret
;
;VESA.cprintall :
	;pusha
	;mov edx, 0x2000
	;call console.newline
;	
	;call VESAhandle16	; mode attribs
	;call VESAhandle8	; win a attribs
	;call VESAhandle8	; win b attribs
	;call VESAhandle16	; win granularity
	;call VESAhandle16	; win size
	;call VESAhandle16	; win a start seg
	;call VESAhandle16	; win b start seg
	;call VESAhandle32	; rm ptr to win func
	;call VESAhandle16	; bytes per scanline
	;call console.newline
;	
	;call VESAhandle16	; x res
	;call VESAhandle16	; y res
	;call VESAhandle8	; x charsize
	;call VESAhandle8	; y charsize
	;call console.newline
;	
	;call VESAhandle8	; num of planes
	;call VESAhandle8	; bpp
	;call VESAhandle8	; num of banks
	;call VESAhandle8	; mem model num
	;call VESAhandle8	; bank size
	;call VESAhandle8	; num of image pages
	;call VESAhandle8	; reserved (should be 1)
	;call console.newline
	
	;	NEVERMIND, this isn't working at all :\
	
	;call VESAhandle32
	;call VESAhandle32
	;call VESAhandle16
	;call console.newline
	
;	popa
	;ret
;VESAhandle32 :
		;xor ebx, ebx
		;mov ebx, [edx]
		;call console.numOut
		;add edx, 32
		;call VESA.sep
		;ret
;VESAhandle16 :
		;xor ebx, ebx
		;mov bx, [edx]
		;call console.numOut
		;add edx, 16
		;call VESA.sep
		;ret
;VESAhandle8 :
		;xor ebx, ebx
		;mov bl, [edx]
		;call console.numOut
		;add edx, 8
		;call VESA.sep
		;ret
;VESA.sep :
	;push ax
	;mov al, ':'
	;mov ah, 0xFF
	;call console.cprint
	;pop ax
	;ret
	
%include "..\boot\init_GDT.asm"

ENTER_PM :
	db "Booted into Protected Mode.", 0

STOPm :
	db "Halting Execution", 0

SUCCESS :
	db "Success!", 0xD, 0xA, 0

RMGDTSAVE :
	dd 0x0
	dd 0x0
	
DisplayMode :
	dd 0x0
	
%include "..\kernel\kernel.asm"