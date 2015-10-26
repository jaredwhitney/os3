
loadIDT :
	lidt [IDT_INFO]
	; need to init Programmable Interrupt Chip (PIC) before enabling interrupts
	sti
	call setupPIC
	call setupPIT
	;int 0x1
	;hlt
	ret
	
setupPIT :
	pusha
	cli
		mov al, 0b00110110
		mov dx, 0x43
		out dx, al
		mov ax, 1193180/5000	; 5000 tics per second ... CHANGING THIS CAUSES PROBLEMS!
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
	mov al, 0b11111100	; 01
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
		dw (0x7e00+_IRQ0-$$) & 0xFFFF	; INT 0
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+_IRQ0-$$) >> 16

		dw (0x7e00+_IRQ1-$$) & 0xFFFF	; INT 1
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+_IRQ1-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 2
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 3
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 4
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 5
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 6
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 7
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+EXCEPTION8HANDLER-$$) & 0xFFFF	; INT 8
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+EXCEPTION8HANDLER-$$) >> 16
		
		dw (0x7e00+_PRINTSTRING-$$) & 0xFFFF	; INT 9
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+_PRINTSTRING-$$) >> 16

		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT A
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT B
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT C
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT D
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+_PAGEFAULT-$$) & 0xFFFF	; INT E
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+_PAGEFAULT-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT F
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 10
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 11
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 12
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 13
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 14
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 15
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 16
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 17
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 18
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 19
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 1A
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 1B
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 1C
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 1D
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 1E
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 1F
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 20
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 21
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 22
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 23
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 24
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 25
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 26
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 27
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 28
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 29
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 2A
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 2B
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 2C
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 2D
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 2E
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 2F
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+_HANDLEFUNC1-$$) & 0xFFFF	; INT 30
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+_HANDLEFUNC1-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 31
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 32
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 33
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 34
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 35
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 36
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 37
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 38
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 39
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 3A
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 3B
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 3C
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 3D
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 3E
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 3F
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 40
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 41
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16
		
		dw (0x7e00+IDTHANDLER-$$) & 0xFFFF	; INT 42
		dw 0x8
		db 0x0
		db 0b10001110
		dw (0x7e00+IDTHANDLER-$$) >> 16

IDTEND :



IDTHANDLER :
	pusha
		;call USB_PrintActivePorts
		;call Manager.customLock
		;call Manager.doLock
		;hlt
		call IRQ_FINISH
	popa
	iret
	
_IRQ0 :
	pusha
		call IRQ_FINISH
		mov eax, [Clock.tics]
		add eax, 1
		mov [Clock.tics], eax
		; timer code goes here!
		cmp byte [Manager.locked], 0x0
			jne _IRQ0.ret
		call Dolphin.updateScreen
	_IRQ0.ret :
	popa
	iret
	
_IRQ1 :
	push ax
	push dx
	call Keyboard.poll
	call IRQ_FINISH
	pop dx
	pop ax
	iret
	
_PRINTSTRING :
	pusha
	mov ah, 0x30
	call console.println
	popa
	iret
	
IRQ_FINISH :
		pusha
		mov dx, 0x20
		mov al, 0x20
		out dx, al
		popa
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