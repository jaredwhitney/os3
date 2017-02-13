[bits 32]

os.hopToRealMode equ realModeExec	; for backwards compatibility
os_RealMode_functionPointer equ rmfunc

rmfunc :
	dd 0x0

realModeExec :
	pusha
	
	cli
	call rmeDisablePIC
	cli
	
	mov [rmeStackSave], esp
	
	sgdt [rmeGDTsave]
	
	lgdt [RMGDT]
	
	jmp rmCodeOffs:rmeBeginRealMode
	
	.ret :
	popa
	ret

[bits 16]
rmeBeginRealMode :
	cli
	mov eax, rmDataOffs
	mov ds, eax
	mov es, eax
	mov fs, eax
	mov gs, eax
	mov ss, eax
	
	mov eax, cr0
	xor eax, 1
	mov cr0, eax
	
	jmp 0x0:rmeInRealMode

rmeInRealMode :
	mov sp, 0x3000
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	lidt [rmeIDT]
	sti
		call [rmfunc]
	cli
	jmp 0x0:rmeFinishRealMode

rmeFinishRealMode :
	mov eax, cr0
	or eax, 0b1
	mov cr0, eax
	lgdt [rmeGDTsave]
	jmp codeOffs:rmeBackToPmode

[bits 32]
rmeBackToPmode :
	mov ax, dataOffs
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov esp, [rmeStackSave]
	call loadIDT	; should also re-init ps/2?
;	call ps2.init
	jmp realModeExec.ret

rmeDisablePIC :
		mov al, 0xFF
		out 0xa1, al
		out 0x21, al
	ret

align 16
rmeIDT :
	dw 0x3ff
	dd 0x0
rmeStackSave :
	dd 0x0
align 16
rmeGDTsave :
	times 2 dq 0x0
