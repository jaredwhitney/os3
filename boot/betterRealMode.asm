[bits 32]
os.hopToRealMode :
	pusha
	
		cli
		
		; save stack position
		mov [stack_locSave], esp
		mov [stack_locSave+4], ebp
		
		; swap out gdt and idt
		sgdt [pmode_gdtSave]
		sidt [pmode_idtSave]
		
		lgdt [GDTdescriptorRM]
		
		jmp RMsegOFFreal:os.beginRealMode
		
	os.hopToRealMode.ret :
	popa
	ret
	
[bits 16]
os.beginRealMode :

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
	
	jmp 0x0:os.inRealMode	;??
	
os.inRealMode :
	mov sp, 0x7c00	; emm... but k cause it grows downwards...
	mov ax, 0x0
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	lidt [rmIDT]
	sti
			; do things!
			mov dword [outVal0], 0xDEADF154
	cli
	jmp 0x0:os.finishRealMode

os.finishRealMode :
	mov eax, cr0
	or eax, 0b1
	mov cr0, eax
	lgdt [pmode_gdtSave]
	jmp segOFFcode:os.backToPmode

[bits 32]
os.backToPmode :
	mov ax, segOFFdata
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	lidt [pmode_idtSave]
	mov esp, [stack_locSave]
	mov ebp, [stack_locSave+4]
	sti
	jmp os.hopToRealMode.ret

stack_locSave :
	dd 0x0
	dd 0x0
align 16
pmode_gdtSave :
	times 2 dq 0x0
align 16
pmode_idtSave :
	times 2 dq 0x0
outVal0 :
	dd 0x0
