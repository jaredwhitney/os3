[bits 32]
goRealMode :

cli

lidt [rmIDT]

lgdt [GDTdescriptorRM]

mov ebp, 0x2000
mov esp, ebp

mov ax, 0x10
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax

jmp 0x8:enter16b

[bits 16]
enter16b :
;lgdt [rmGDT]
;cli
;jmp $
;mov eax, RMsegOFFdata
;mov ds, eax
;hlt
;mov es, eax
;mov fs, eax
;mov gs, eax
;mov ss, eax

mov eax, cr0
xor eax, 1
mov cr0, eax
;mov eax, RMsegOFFdata	; RM data selector EDIT: should stay the same with this setup.
;mov ds, eax
;mov es, eax
;mov fs, eax
;mov gs, eax
;mov ss, eax
;hlt
jmp enterRM;RMsegOFFcode:enterRM

enterRM :

mov eax, 0
mov ds, eax
mov es, eax
mov fs, eax
mov gs, eax
mov ss, eax

mov ebx, hltinst
cli
sti
hltinst :

	mov al, 0x3
	mov ah, 0x0
	;int 0x10
	mov ah, 0x0E
	mov al, '!'
	mov bh, 0x0
	mov bl, 0x0E
	int 0x10

cli
hlt
jmp $

rmIDT :
dw 0x3ff
dd 0x0

[bits 32]