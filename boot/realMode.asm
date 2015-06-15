[bits 32]
goRealMode :

mov [ebpstor], ebp
mov [espstor], esp

cli

lidt [rmIDT]			; load IDT

lgdt [GDTdescriptorRM]	; load GDT

mov ebp, 0x2000	; set stack
mov esp, ebp

mov ax, 0x10	; update segment registers for 16b pmode
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax

jmp 0x8:enter16b	; long jump to 16b pmode

[bits 16]
enter16b :

mov eax, cr0	; get out of pmode and into rmode
xor eax, 1
mov cr0, eax

mov eax, 0		; update segment registers for rmode
mov ds, eax
mov es, eax
mov fs, eax
mov gs, eax
mov ss, eax

jmp 0:enterRM

enterRM :

;cli				; make sure there are no queue'd interrupts
sti				; enable interrupts
	
	mov al, 0x3		; change the screen mode back into text
	mov ah, 0x0
	int 0x10
	mov bx, REALMODEMSG
	call boot.print
	hlt
	; ************************************** CODE GOES HERE ********************************* ;
	;mov dl, 0x80	; NEEDS TO STAY
	;mov ch, 0		; CAN CHANGE?
	;mov bx, MINNOW_START	; where to load data to
	;mov cl, 2		; CAN CHANGE?
	;mov dh, 0x40	; CAN CHANGE?
	;call rRM.load
	; ***************************************** END CODE ************************************ ;

jmp goProtectedMode

goProtectedMode :
	;call VESA.getMode
	;call boot.useVGAmode
	;mov bx, 0x11b
	;call VESA.mode
	jmp goIntoPMODE
goIntoPMODE :
	lgdt [GDTdescriptor]
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	cli
	jmp segOFFcode:goIntoPMODE_final
[bits 32]
goIntoPMODE_final :
	mov ax, segOFFdata
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	
	mov ebp, [ebpstor]
	mov esp, [espstor]
	
	;mov al, [0x7e00]
	;mov [0xb8000], al
	;cmp al, 0x4a
	;jne stop
	
	call loadIDT
	
	;call Graphics.init
	
	ret
[bits 16]
	rRM.load :
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
			jne rRM.sload_error
		
		cmp dh, al
			jne rRM.sload_error
		hlt
		popa
		ret
		
	rRM.lret:
		mov bx, rRM.ERRORrt
		;call boot.print
		mov ax, 0xF
		mov [0x1000], ax
		popa
		mov dl, 0x0
		jmp rRM.load
		
	rRM.sload_error:
		mov bx, rRM.ERRORs
		;call boot.print
		popa
		ret
		
rRM.ERRORrt :
	db "Error: Retrying...", 0xD, 0xA, 0

rRM.ERRORs :
	db "Warning: Unable to read all sectors.", 0xD, 0xA, 0

rmIDT :
dw 0x3ff
dd 0x0
REALMODEMSG :
db "The computer is currently in Real Mode. If it does not return to Protected Mode shortly, it has probably crashed.", 0xA, 0xA, 0xD, 0x0
[bits 32]
ebpstor :
	dd 0x0
espstor :
	dd 0x0