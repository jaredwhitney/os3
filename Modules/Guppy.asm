[bits 32]

Guppy.table equ 0xA10000
MEMORY_START equ 0xF00000
; Memory is labelled as sectors in use from 0x7c00 to 0x_____
; 0x7c00 - 0xc000 is reserved for the OS (34 sectors)
Guppy.init :
pusha
mov al, 0x1
mov ah, 34
call Guppy.malloc
;call console.numOut
;call console.newline
popa
ret

Guppy.malloc :	; AL = PNUM, AH = Sectors requested
;pusha;test
;mov ebx, [Guppy.table]
;call console.numOut
;popa;tset
push eax
push edx
push ecx
mov [aStor], eax
mov ebx, Guppy.table
Guppy.malloc.loop1 :
mov cl, [ebx]
add ebx, 1
cmp cl, 0x0
jne Guppy.malloc.loop1
sub ebx, 1
push ebx	; right now just finding the first unallocated sector
Guppy.malloc.loop2 :
mov [ebx], al
sub ah, 0x1
add ebx, 0x1
cmp ah, 0x0
jg Guppy.malloc.loop2	; after this loop completes the memory should be registered as the program's to use
pop ebx
sub ebx, Guppy.table	; ebx contains # start sector
mov eax, ebx			; move # start sector to eax
	mov ecx, eax		; store eax
	pusha
	push ebx
	mov ebx, MALLOC
	mov ah, 0xB
	call debug.setColor
	call debug.print
	pop ebx
	mov eax, [aStor]
	shr eax, 8
	and eax, 0xFF	; getting ah -> eax
	add ebx, eax
	mov eax, ebx
	mov ebx, 0x200
	mul ebx
	mov ebx, eax
	add ebx, MEMORY_START
	call debug.num
	popa
	mov ebx, 0x200
	push eax
	mov eax, ecx
mul ebx
mov ebx, eax
add ebx, MEMORY_START	; beginning of memory set for use
	mov al, '-'
	call debug.cprint
	call debug.num
	call debug.newl
	call debug.restoreColor
pop eax
pop ecx
pop edx
pop eax
ret	; EBX = Start of allocated memory

MALLOC :
db "Malloc: ", 0
aStor :
dd 0x0
