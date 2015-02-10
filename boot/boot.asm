[bits 16]
[org 0x7c00]

cli
mov ax, 0x0
mov ds, ax
mov es, ax
mov ss, ax
sti

mov cx, 0x0	; zeroing out pointers
mov dx, 0x0
mov bx, 0x0

mov al, 0x13	; 0x3 = text, 0x13 = graphics
mov ah, 0x0
int 0x10	; changing video mode

;mov ah, 0x0E
;mov cx, 0x0
;mov al, 65
;mov bh, 0x00
;mov bl, 0x07
;int 0x10
;jmp $
mov bx, Greeting
call boot.print

mov [boot_drive], dl

;mov ah, 0x41
;mov bx, 0x55AA
;mov dl, 0x80
;int 0x13
;jnc ner
;mov bx, ERRORc
;jmp g
;ner:
;mov bx, SUCCESS
;g:
;call boot.print

;mov bx, 0x7e00
;mov cl, 0x2
;mov ch, 0x0
;mov dh, 1
;mov dl, [boot_drive]	; should be the boot drive

mov ax, 0x0			; changes to 0xF if booting from bochs
mov [0x1000], ax

mov dl, 0x80
call boot.load
mov bx, EnableA20
call boot.print

mov ax, 0x2401
int 0x15

mov bx, SUCCESS
call boot.print
lgdt [GDTdescriptor]

mov eax, cr0
or eax, 1
mov cr0, eax

cli
jmp segOFFcode:enter_PM

jmp $

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

boot.load :
pusha

mov ah, 0	; reset floppy controller
mov bl, dl
mov dl, 0
int 0x13
mov dl, bl

mov bx, 0x7e00
push es
mov ax, 0x0
mov es, ax
mov ah, 0x02	;telling bios we want to read from memory	|	location to read to sent in as BX
mov al, 0x10		;the number of sectors to read				|	sent in as DH
mov dh, 0x0	;head to read from
;mov dl, 0x80	;drive to read from [0x80] if machine, [0x00] is bochs
mov ch, 0	; track to read from
mov cl, 2

int 0x13
pop es

cmp ah, 0x0
jne lret

cmp dh, al
jne sload_error

popa
ret
lret:
mov bx, ERRORrt
call boot.print
mov ax, 0xF
mov [0x1000], ax
popa
mov dl, 0x0
jmp boot.load
;jmp $
sload_error:
mov bx, ERRORs
call boot.print
popa
ret


;jmp $

;boot.load :
;pusha
;mov ax, 0x0
;mov ds, ax
;mov si, DAPS
;mov ah, 0x42
;mov dl, [boot_drive]
;or dl, 0x80
;int 0x13
;jc errc
;cmp ah, 0
;jne errs
;popa
;ret
;errc :
;mov bx, ERRORc
;call boot.print
;jmp $
;errs :
;mov bx, ERRORs
;call boot.print
;jmp $

;DAPS :
;db 0x10, 0	; size of packet, 0
;dw 1	; number of segments to read
;dd 0x7e00, 0x0	; offset:segment to read to
;dd 2	; position to read from (LBA)
;dd 0

Greeting :
db "Hello World!", 0xD, 0xA, 0

boot_drive :
db 0x0, 0x0

EnableA20 :
db "Enabling A20... ", 0

LoadGDT :
db "Loading GDT...", 0

SUCCESS :
db "Success!", 0xD, 0xA, 0

ERRORrt :
db "Error: Retrying...", 0xD, 0xA, 0

ERRORs :
db "Warning: Unable to read all sectors.", 0xD, 0xA, 0


[bits 32]
enter_PM :

mov ax, segOFFdata
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax

mov ebp, 0x9000
mov esp, ebp

;mov ebx, 'P'
;mov [0xb8000], ebx
mov ebx, ENTER_PM
mov ecx, 0x280
mov ah, 0xB
call console.print

mov al, [0x7e00]
mov [0xb8000], al
cmp al, 0x4a
jne stop

jmp 0x7e01

stop:
mov ebx, STOPm
mov ecx, 0x320
mov ah, 0xC
call console.print
jmp $

console.print :
pusha
mov edx, 0xb8000
add edx, ecx
printitp :
mov al, [ebx]
;mov ah, 0x0c ; or 0x0f... you get the point
cmp al, 0
je printdonep
mov [edx], ax
add ebx, 1
add edx, 2
jmp printitp
printdonep :
popa
ret

%include "..\boot\init_GDT.asm"

ENTER_PM :
db "Booted into Protected Mode.", 0

STOPm :
db "Halting Execution", 0

times 510-($-$$) db 0
dw 0xaa55
