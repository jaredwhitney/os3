KERNEL_START :

%include "../newboot/bootdefinitions.asm"
%include "../Tools/methodTraceMacros.asm"
[map all labels.map]

[bits 16]
[org KERNEL_LOADER_LOC]
			pusha
			mov bh, 0x0
			mov bl, 0x7
			mov ah, 0xE
			mov al, '2'
			int 0x10
			popa

xor ax, ax
mov es, ax
mov ax, 0x2000
mov di, ax
mov ax, 0x4F00
int 0x10

			pusha
			mov bh, 0x0
			mov bl, 0x7
			mov ah, 0xE
			mov al, '3'
			int 0x10
			popa

mov ax, [0x2010]
mov es, ax
mov ax, [0x200E]
mov di, ax
modeSearchLoop :

mov cx, [es:di]
cmp cx, 0xFFFF
	je modeSearchLoop.done

push es
push di

xor ax, ax
mov es, ax
mov ax, 0x3000
mov di, ax
mov ax, 0x4F01
int 0x10

mov dx, [0x3012]
mov ax, MAX_XRES
sub ax, [closestXres]
mov bx, MAX_XRES
sub bx, dx
cmp dx, MAX_XRES
	jg modeSearchLoop.checkNotBetter
cmp bx, ax
	jge modeSearchLoop.checkNotBetter
	
mov dx, [0x3014]
mov ax, MAX_YRES
sub ax, [closestYres]
mov bx, MAX_YRES
sub bx, dx
cmp dx, MAX_YRES
	jg modeSearchLoop.checkNotBetter
cmp bx, ax
	jge modeSearchLoop.checkNotBetter

mov dx, [0x3000]
and dx, 0b10010000
cmp dx, 0b10010000
	jne modeSearchLoop.checkNotBetter

mov dl, [0x3019]
cmp dl, 32
	jne modeSearchLoop.checkNotBetter

mov edx, [0x3028]
mov [closestBufferLoc], edx

;mov dl, [0x3019]
;cmp dl, 32
;	jne modeSearchLoop.checkNotBetter

mov ax, [0x3012]
mov bx, [0x3014]
mov [closestXres], ax
mov [closestYres], bx
mov [closestMatch], cx

modeSearchLoop.checkNotBetter :
pop di
pop es

mov ax, di
add ax, 2
mov di, ax
jmp modeSearchLoop
modeSearchLoop.done :

			pusha
			mov bh, 0x0
			mov bl, 0x7
			mov ah, 0xE
			mov al, '4'
			int 0x10
			popa

mov ax, 0x4F02
xor bx, bx
mov es, bx
mov bx, 0x3000
mov di, bx
mov bx, [closestMatch]
or bx, 0x4000
int 0x10

;mov edx, [closestBufferLoc]
;mov dword [edx], 0xFF00FF
jmp goPmode

goPmode :

mov ax, 0x2401
int 0x15

lgdt [PMGDT]

mov eax, cr0
or eax, 1
mov cr0, eax

cli

;mov edx, [closestBufferLoc]
;mov dword [edx], 0xFF0000

jmp codeOffs:pmStart

[bits 32]

pmStart :

;mov dword [edx], 0x0000FF

mov ax, dataOffs
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax

mov ebp, 0xA00000
mov esp, ebp

;mov edx, [closestBufferLoc]
;mov dword [edx], 0xFFB233

call loadIDT

jmp finishLoading

loadIDT :
lidt [PMIDT]
sti
call setupPIC
call setupPIT
ret

setupPIT :
cli
mov al, 0b00110110
mov dx, 0x43
out dx, al
mov ax, 1193180/1000
mov dx, 0x40
out dx, al
mov al, ah
out dx, al
sti
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
	mov al, 0b11111000	; bit 2 cleared enables the slave (IRQs 7-15)
	out dx, al
	mov dx, 0xa1
	mov al, 0b11101111
	out dx, al
	
	popa
	;pop eax	; if things are not working keep this uncommented, it will skip enabling interrupts
	ret

KERNEL_SIZE equ (((KERNEL_END-KERNEL_START)-1)/0x200)+1
finishLoading :

mov ax, [0x1000]
and eax, 0xFFFF
mov edx, KERNEL_SIZE
sub edx, eax
inc edx
push eax
mov ecx, KERNEL_LOADER_LOC
imul eax, 0x200
add ecx, eax
pop eax
sub ecx, 0x200

mov dword [sloadcount2], eax
mov dword [sloadcount], ecx

mov dword [rmfunc], realModeAtaDetectLBAsupport
call realModeExec
cmp byte [realModeAtaDetectLBAsupport.result], 0xFF
	je .goOn
	mov edx, [closestBufferLoc]
	mov dword [edx], 0xFF0000
	mov dword [edx+0x08], 0xFF0000
	mov dword [edx+0x10], 0xFF0000
	cli
	hlt
.goOn :

mov dword [rmfunc], realModeAtaLoad
finishLoading.loop :

mov [rmATAdata.lowP], eax
call realModeExec

mov esi, 0x7c00
mov edi, ecx

push ax
xor ax, ax
mov es, ax
pop ax

push ecx

mov ecx, 0x200/4
finishLoading.copyDataLoop :
mov ebx, [esi]
mov [edi], ebx
add esi, 4
add edi, 4
dec ecx
cmp ecx, 0x0
	jg finishLoading.copyDataLoop
	
pop ecx

inc eax
dec edx
add ecx, 0x200
cmp edx, 0
	jg finishLoading.loop
	
;xor ebx, ebx	; fix needed as os3 expects screen width in bytes
;mov bx, [closestXres]
;shl ebx, 2
;mov [closestXres], ebx
call ps2.init

jmp Kernel.init

[bits 16]

realModeAtaDetectLBAsupport :
		mov ah, 0x41
		mov bx, 0x55AA
		mov dl, 0x80
		int 0x13
			jc .nosupport
		mov byte [.result], 0xFF
	ret
		.nosupport :
		mov byte [.result], 0x00
	ret
	.result :
		db 0x0

realModeAtaLoad :	; this will not work properly on Bochs! (add in workaround)
		mov di, 0x0
		mov si, rmATAdata
		mov dl, 0x80
		mov ah, 0x42
		int 0x13
	ret

rmATAdata :
	db 0x10
	db 0
	dw 1
	dw 0x7c00
	dw 0
	rmATAdata.lowP :
		dd 0x0
	rmATAdata.highP :
		dd 0x0

[bits 32]

%include "..\newboot\pmdata.asm"

closestXres :
	dd 0x0
closestYres :
	dd 0x0
closestBufferLoc :
	dd 0x0
closestMatch :
	dd 0x0
sloadcount :
	dd 0x0
sloadcount2 :
	dd 0x0

DisplayMode :	; for backwards compatibility
	dd 1
INTERRUPT_DISABLE :
	dd 0x00
os_imageDataBaseLBA equ 0
[bits 16]
realMode.ATAload :
realMode.ATAwrite :
	ret
[bits 32]

%include "..\newboot\rmexec.asm"
%include "..\kernel\kernel.asm"


KERNEL_END :
