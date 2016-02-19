;;;;;;;;
	[bits 32]
	s2copyDataToHighMem :
		pusha
			mov esi, 0x9000
			mov edi, 0xD0000
			mov ecx, 0x200
			rep movsb
		popa
		ret
	[bits 16]
	s2loadDataToLowMem :
		pusha
			mov eax, 1
			mov bx, 0x0
			call realMode.ATAload
		popa
		ret
;;;;;;;;

[bits 32]
s2.hopToRealMode :
	pusha
		
		cli
		
		; save stack position
		mov [s2.stack_locSave], esp
		
		; swap out gdt and idt
		sgdt [s2.pmode_gdtSave]
		sidt [s2.pmode_idtSave]
		
		lgdt [s2.GDTdescriptorRM]
		
		jmp RMsegOFFreal:s2.beginRealMode
		
	s2.hopToRealMode.ret :
	popa
	ret
	
[bits 16]
s2.beginRealMode :

	cli
	
	mov eax, RMsegOFFdata
	mov ds, eax
	mov es, eax
	mov fs, eax
	mov gs, eax
	mov ss, eax
	
	mov eax, cr0
	xor eax, 1
	mov cr0, eax
	
	jmp 0x0:s2.inRealMode	;??
	
s2.inRealMode :
	mov sp, 0x3000	; emm... but k cause it grows downwards...
	mov ax, 0x0
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	lidt [s2.realModeIDT]
	sti
		call [s2.s2hopbackcode]
	cli
	jmp 0x0:s2.finishRealMode

s2.finishRealMode :
	mov eax, cr0
	or eax, 0b1
	mov cr0, eax
	lgdt [s2.pmode_gdtSave]
	jmp segOFFcode:s2.backToPmode

[bits 32]
s2.backToPmode :
	mov ax, segOFFdata
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov esp, [s2.stack_locSave]
	jmp s2.hopToRealMode.ret


s2.stack_locSave :
	dd 0x0
align 16
s2.pmode_gdtSave :
	times 2 dq 0x0
align 16
s2.pmode_idtSave :
	times 2 dq 0x0
s2.outVal0 :
	dd 0x0
align 16
s2.realModeIDT :
	dw 0x3ff
	dd 0x0
	
s2hopbackcode :
	dd 0x0