[bits 32]
goRealMode :
cli

; load a 16 bit GDT...

jmp segOFFcode:enter16b

[bits 16]
enter16b :

; set d/e/f/g/ss

; load rm idt (base 0x0 lim 0x3ff)

mov eax, cr0
xor eax, 1
mov cr0, eax
jmp 0:enterRM

enterRM :
mov ax, 0x0
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax

; change sp?

sti

mov ah, 0x3
int 0x13

jmp $
