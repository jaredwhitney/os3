;	programLoader.asm
;
;	loads programs into memory and executes them
;


program.register :		; ebx contains location of program
;push ebx
	mov ecx, ebx	; ecx contains program location
	add ebx, 1	; >> should be 1
	mov eax, 0xA;[ebx]	; should be program's size in sectors
	mov edx, 0x200
		div edx	; 0x200 = sector size
	cmp eax, 0xFF
	jl pregnoover
		jmp $	;			should throw some error here with an error handler where the text displayed is "Program at [" + (ebx-1) + "] has a size of " + eax + " sectors, which is greater than the amount of RAM allowed to any single program.
;							The program will not be loaded."
	pregnoover :
	cmp eax, 0x0
	jl pregnoadd
		add eax, 0x1
	pregnoadd :
	mov al, 0x2	; SHOULD BE THE PROGRAM's PNUM
	call Guppy.malloc
	mov ebx, 0xe000	; ignoring the malloc for now.
push ebx	; ebx contains where program should go
mov edx, 0x0
lpopreg :
mov ah, [ecx]
mov [ebx], ah
add edx, 0x1
	cmp edx, 0x2000
	jl pregkret
	jmp pregDone
pregkret :
add ebx, 0x1
add ecx, 0x1
jmp lpopreg
pregDone :

pop ebx
mov eax, 0x0
mov al, [setLocation]
mov ecx, programLocations
;add ecx, eax ; SHOULD NOT BE COMMENTED OUT!

mov [ecx], ebx
;add al, 0x4 ; SHOULD NOT BE COMMENTED OUT!
;mov [setLocation], al ; SHOULD NOT BE COMMENTED OUT!

;pop ebx
ret		; returns the program's location in RAM in ebx

setLocation :
db 0x0
callLocation :
db 0x0
programLocations :
dd 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0	; currently only supporting 12 programs running at once


program.init :
mov ebx, 0x0
mov bl, [callLocation]
mov eax, programLocations
;add eax, ebx ; SHOULD NOT BE COMMENTED OUT!
mov ecx, [eax]
;mov ecx, console.asm.start
		;cmp ecx, 0x0
		;jne pinitcont
		;jmp $	; right now if address is invalid, PANIC
		;add bl, 0x4
		;cmp bl, 44
		;jl pinitnoz1
		;mov bl, 0x0
		;pinitnoz1 :
		;mov [callLocation], bl
		;ret
		;pinitcont :
	;mov ecx, console.asm.start
	;add ecx, 0x24		; THIS NUMBER IS CORRECT !!!
	;add ecx, 0x79	; gets us to start of file...
	;add ecx, 0x	; gets us to start tag???
	add ecx, 0x2
		;mov eax, 0x9000
		;mov [console.buffer], eax
		;mov eax, 0x20
		;mov [console.width], eax
		;mov [console.height], eax
		;mov ebx, [ecx]
		;call console.numOut
		;jmp $

pusha
call ecx	; calling init
popa

add bl, 0x4
cmp bl, 44
jl pinitnoz2
mov bl, 0x0
pinitnoz2 :
;mov [callLocation], bl
ret

