KERNEL_START :
%include "..\boot\config.asm"
[bits 16]
[org S2_CODE_LOC]
db 0x4a

stage2:
	;	Perform extraneous tasks here	;
	sgdt [RMGDTSAVE]
	sidt [RMIDTSAVE]
	
	;call stage2.checkBootFlags
	
	mov dword [DisplayMode], DISPLAY_MODE	; MODE_TEXT or MODE_GRAPHICS
	
	cmp dword [DisplayMode], MODE_TEXT
		je stage2.novesa
		
	call boot.useVGAmode	; as a fallback
	
	mov ax, 0x0
	mov es, ax
	mov ax, 0x2000
	mov di, ax
	mov ax, 0x4f00
	int 0x10	; get controller info
	mov [VESACNTERRCODE], ax
	
	cmp ax, 0x4F
		jne stage2.novesa
		
	mov ax, [0x2010]
	mov es, ax
	mov ax, [0x200E]
	mov di, ax
	VESA_loopStart :
	mov cx, [es:di]
	cmp cx, 0xFFFF
		je VESA_loopOver
	push es
	push di
		mov ax, 0x0	; load mode info
		mov es, ax
		mov ax, 0x3000
		mov di, ax
		mov ax, 0x4f01
		int 0x10
		mov dx, [0x3012]	; check width
		mov ax, DESIRED_XRES
		sub ax, [VESA_CLOSEST_XRES]
		mov bx, DESIRED_XRES
		sub bx, dx
			cmp dx, DESIRED_XRES
				jg Vesa.checkNotBetter
		cmp bx, ax
			jge Vesa.checkNotBetter
		mov dx, [0x3014]	; check height
		mov ax, DESIRED_YRES
		sub ax, [VESA_CLOSEST_YRES]
		mov bx, DESIRED_YRES
		sub bx, dx
			cmp dx, DESIRED_YRES
				jg Vesa.checkNotBetter
		cmp bx, ax
			jge Vesa.checkNotBetter
		mov dx, [0x3000]	; check to make sure it is linear
		and dx, 0b10010000
			cmp dx, 0b10010000
				jne Vesa.checkNotBetter
		mov edx, [0x3028]
			mov [VESA_CLOSEST_BUFFERLOC], edx
		mov dl, [0x3019]
			cmp dl, 32
				jne Vesa.checkNotBetter
			mov [VESA_CLOSEST_BPP], dl
		mov ax, [0x3012]	; save it as the closest found
		mov bx, [0x3014]
		mov [VESA_CLOSEST_XRES], ax
		mov [VESA_CLOSEST_YRES], bx
		mov [VESA_CLOSEST_MATCH], cx
		Vesa.checkNotBetter :
		pop di
		pop es
		mov ax, di
		add ax, 2
		mov di, ax
		jmp VESA_loopStart
	VESA_loopOver :
	
	mov ax, 0x4f02
	xor bx, bx
	mov es, bx
	mov bx, 0x3000
	mov di, bx
	mov bx, [VESA_CLOSEST_MATCH]
	or bx, 0x4000	; get the linear version
	int 0x10
	
	mov byte [Graphics.VESA_SUPPORTED], 0xFF
	
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
	
	mov al, [S2_CODE_LOC]
	mov [0xb8000], al
	cmp al, 0x4a
	jne stop
	
	call loadIDT
	call ps2.init
	
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

[bits 16]
realMode.ATAload :	; eax = LBA low, bx = LBA high
	pusha
		mov [rm.ATAdata.LBA_low], eax
		and ebx, 0xFFFF
		mov [rm.ATAdata.LBA_high], ebx
		
		mov di, 0x0
		mov si, rm.ATAdata
		mov dl, 0x80
		mov ah, 0x42
		int 0x13
			jc sload_error
	popa
	ret
rm.ATAdata :
	db 0x10	; packet size
	db 0	; always 0
	dw 1	; sectors to load
	dw 0x7c00	; offs
	dw 0x0	; seg
	rm.ATAdata.LBA_low :
		dd 0x0	; start LBA
	rm.ATAdata.LBA_high :
		dd 0x0	; upper LBA
sload_error:
	popa
	ret
realMode.ATAwrite :	; eax = LBA low, bx = LBA high (data to copy at 0x7c00)
	pusha
		mov [rm.ATAdata.LBA_low], eax
		and ebx, 0xFFFF
		mov [rm.ATAdata.LBA_high], ebx
		
		mov di, 0x0
		mov si, rm.ATAdata
		mov dl, 0x80
		mov ah, 0x43
		int 0x13
			jc swrite_error
	popa
	ret
swrite_error:
	popa
	ret
[bits 32]

%include "..\boot\init_GDT.asm"

ENTER_PM :
	db "Booted into Protected Mode.", 0

STOPm :
	db "Halting Execution", 0

SUCCESS :
	db "Success!", 0xD, 0xA, 0
	
VESA_OEMMSG :
	db "OEM String: ", 0x0
	
VESA_VER :
	db "VESA Version: ", 0x0

VESA_TAGMSG :
	db "VESA Signature: ", 0x0

VESA_TAG :
	dd 0x0, 0x0

VESA_VMODENUMMSG :
	db "Modes Available: 0x", 0x0
VESA_CLOSEST_RESMSG :
	db "    Resolution: ", 0x0
VESA_CLOSEST_RESDIV :
	db "x", 0x0
VESA_CLOSEST_MATCHMSG :
	db "Found mode: ", 0x0
VESA_CLOSEST_BPPMSG :
	db ", bpp = ", 0x0
VESA_CLOSEST_BUFFERLOCMSG :
	db "    Buffer position: ", 0x0
	
VESACNTERRCODE :
	dw 0x0

VESA_CLOSEST_MATCH :
	dw 0x0
VESA_CLOSEST_XRES :
	dw 0x0
VESA_CLOSEST_YRES :
	dw 0x0
VESA_CLOSEST_BPP :
	db 0x0
VESA_CLOSEST_BUFFERLOC :
	dd 0x0

MEMORY_BUFFMAXMSG :
	db "Memory allocated up to: 0x", 0x0

RMGDTSAVE :
	dd 0x0
	dd 0x0
RMIDTSAVE :
	dd 0x0
	dd 0x0

DisplayMode :
	dd 0x0

%include "..\kernel\kernel.asm"