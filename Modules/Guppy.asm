[bits 32]

Guppy.table equ 0xA10000
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
push ecx
push eax
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
sub ebx, Guppy.table
mov eax, ebx
mov ebx, 0x200	; size of a sector
	mov ecx, eax
	pop eax
	pusha
	pusha
	mov ebx, MALLOC
	mov ah, 0x3
	call debug.setColor
	call debug.print
	popa
	shr eax, 8
	and eax, 0xFF	; getting ah -> eax
	add ebx, eax
	mov ebx, 0x200
	mul ebx
	add ebx, 0xbffff
	call debug.num
	popa
	push eax
	mov eax, ecx
mul ebx
mov ebx, eax
add ebx, 0xbffff	; beginning of memory set for use
	mov al, '-'
	call debug.cprint
	call debug.num
	call debug.newl
	call debug.restoreColor
pop eax
pop ecx
ret	; EBX = Start of allocated memory

MALLOC :
db "Malloc: ", 0
