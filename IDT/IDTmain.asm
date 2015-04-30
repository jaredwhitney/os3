
loadIDT :
	call copyIDTloop
	lidt [IDT_INFO]
	; need to init Programmable Interrupt Chip (PIC) before enabling interrupts
	sti
	call setupPIC
	call setupPIT
	;int 0x1
	;hlt
	ret

copyIDTloop :
	pusha
	mov ecx, IDTCOPYSTART
	xor edx, edx
	copyIDTloop.loop :
		mov ebx, IDTDescriptor_GENERIC
		mov eax, [ebx]
		mov [ecx], eax
		add ebx, 4
		add ecx, 4
		mov eax, [ebx]
		mov [ecx], eax
		add ecx, 4
		add edx, 1
		cmp edx, 0x40-1
			jl copyIDTloop.loop
	popa
	ret
	
setupPIT :
	pusha
	cli
		mov al, 0b00110110	; they do 0100
		mov dx, 0x43
		out dx, al
		mov ax, 0x0	; lowest possible tick rate (dont need to spam the interrupt too quickly)
		mov dx, 0x40
		out dx, al
		mov al, ah
		out dx, al
	sti
	popa
	ret
	
setupPIC :
	pusha
	mov dx, 0x21
	in al, dx
	mov bl, al	; storing interrupt masks
	mov dx, 0xa1
	in al, dx
	mov cl, al	; storing interrupt masks
	
	mov al, 0x10	; initialization code
	mov dx, 0x20
	out dx, al	; tell the master PIC to initialize
	mov dx, 0xa0
	out dx, al	; tell the slave PIC to initialize
	
	mov al, 0x0	; where IRQs 0-7 should be mapped
	mov dx, 0x21
	out dx, al
	mov al, 0x20	; where IRQs 8-15 should be mapped
	mov dx, 0xa1
	out dx, al
	
	mov dx, 0x21
	mov al, 4
	out dx, al
	mov dx, 0xa1
	mov al, 2
	out dx, al
	
	mov dx, 0x21
	mov al, 0x1
	out dx, al
	mov dx, 0xa1
	out dx, al
	
	mov dx, 0x21
	mov al, 0b11111101
	out dx, al
	mov dx, 0xa1
	mov al, 0b11111111
	out dx, al
	
	popa
	;pop eax	; if things are not working keep this uncommented, it will skip enabling interrupts
	ret

;IDTDescriptor :
;	dw loweroffs
;	dw codeSegSelector	(see GDT, should be same as kernel)
;	db 0x0
;	db (bit_present, 2bit_ringLevel, bit_storage_seg (usually 0), nibble_gate_type)
;	dw higheroffs
IDTSTART :

	_IDT0 :
		dw (0x7e00+_IRQ0-$$) & 0xFFFF
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+_IRQ0-$$) >> 16

		dw (0x7e00+_IRQ1-$$) & 0xFFFF
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+_IRQ1-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+EXCEPTION8HANDLER-$$) & 0xFFFF
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+EXCEPTION8HANDLER-$$) >> 16
		
		dw (0x7e00+_PRINTSTRING-$$) & 0xFFFF
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+_PRINTSTRING-$$) >> 16
	IDTDescriptor_GENERIC :
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
	IDTCOPYSTART :
		times 0x40 dq 0	; the remaining INTS (subtract 1 more for every hard-coded ISR)
IDTEND :



IDTHANDLER :
	pusha
		call IRQ_FINISH
	popa
	iret
	
_IRQ0 :
	pusha
		; timer code goes here!
	call IRQ_FINISH
	popa
	iret
	
_IRQ1 :
	pusha
	call Keyboard.poll
	call IRQ_FINISH
	popa
	iret
	
_PRINTSTRING :
	pusha
	mov ah, 0x30
	call console.println
	popa
	iret
	
IRQ_FINISH :
		mov dx, 0x20
		mov al, 0x20
		out dx, al
		ret
		
EXCEPTION8HANDLER :
	pushad
	mov bl, 0x3
	call Manager.customLock
	call Manager.handleLock
	popad
	iret
	
IDT_INFO :
	dw IDTEND-IDTSTART-1	; IDT SIZE - 1
	dd IDTSTART
	
INT_CALL :
db "Hello from inside an interrupt handler!", 0
INT0_CALL :
db "I choose you, Pikachu!", 0