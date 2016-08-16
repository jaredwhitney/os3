;	programLoader.asm
;
;	loads programs into memory and executes them
;	NEEDS REFORMATTING!


program.register :		; ebx contains location of program

mov eax, 0x0
mov al, [setLocation]
mov ecx, programLocations
add ecx, eax
mov [ecx], ebx
add al, 0x4
mov [setLocation], al

ret

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
add eax, ebx ; SHOULD NOT BE COMMENTED OUT!
mov ecx, [eax]
cmp ecx, 0x0
	je pinitdonecall
mov [0x3000], ecx	; so the program knows where it is in memory!
add ecx, 0x5

pusha
call ecx	; calling init
popa

pinitdonecall :
add bl, 0x4
cmp bl, 44
jl pinitnoz2
mov bl, 0x0
pinitnoz2 :
mov [callLocation], bl
ret

program.post_init :		; THIS SHOULD BE MODIFIED MORE! (also init with multiple programs will kill it, etc)
mov ebx, 0x0
mov bl, [callLocation]
mov eax, programLocations
add eax, ebx ; SHOULD NOT BE COMMENTED OUT!
mov ecx, [eax]
cmp ecx, 0x0
	je ppinitdonecall
mov [0x3000], ecx	; so the program knows where it is in memory!
add ecx, 0x5
sub ecx, 4
mov ecx, [ecx]

pusha
call ecx	; calling postinit
popa

ppinitdonecall :
add bl, 0x4
cmp bl, 44
jl ppinitnoz2
mov bl, 0x0
ppinitnoz2 :
mov [callLocation], bl
ret

ProgramManager.getProgramNumber :	; returns pnum in bl
	mov bl, [ProgramManager.PnumCounter]
	add bl, 1
	mov [ProgramManager.PnumCounter], bl
	push ebx
	mov ebx, ProgramManager.PROGRAM_REGISTERED
	call debug.print
	pop ebx
	and ebx, 0xFF
	call debug.num
	call debug.newl
	ret
	
ProgramManager.setActive :	; bl = pNum, SHOULD NOT BE CALLED BY ANYTHING OTHER THAN THE KERNEL!!~!
pusha
	mov [ProgramManager.pNum], bl
	and ebx, 0xFF
	imul ebx, 4
	mov eax, ProgramManager.pMemStor
	add eax, ebx
	mov eax, [eax]
	mov [ProgramManager.memoryStart], eax
	mov eax, ProgramManager.pOffsStor
	add eax, ebx
	mov eax, [eax]
	mov [ProgramManager.memoryStart], eax
popa
ret

ProgramManager.finalize :
pusha
	mov bl, [ProgramManager.pNum]
	and ebx, 0xFF
	mov eax, ProgramManager.pMemStor
	add eax, ebx
	mov eax, [eax]
	mov [ProgramManager.memoryStart], eax
	mov eax, ProgramManager.pOffsStor
	add eax, ebx
	mov eax, [eax]
	mov [ProgramManager.memoryStart], eax
popa
ret
	
ProgramManager.requestMemory :
pusha
	mov al, [ProgramManager.pNum]
	call Guppy.malloc
	mov [ProgramManager.memoryStart], ebx
popa
ret

ProgramManager.reserveMemory :	; ebx contains bytes to reserve, returns ebx = location
;push eax
;push ecx
jmp Guppy2.malloc ;	call Guppy2.malloc
;	mov ecx, ebx
;	push dword [ProgramManager.creationOffset]
;	mov eax, [ProgramManager.creationOffset]
;	add eax, ebx
;	mov [ProgramManager.creationOffset], eax
;	pop ebx
;	add ebx, [ProgramManager.memoryStart]
;	push ebx
;	mov eax, ebx
;	mov ebx, ecx
;	call Buffer.clear
;	pop ebx
;pop ecx
;pop eax
;ret

	
ProgramManager.PROGRAM_REGISTERED :
db "A program has been registered: PNUM=", 0

ProgramManager.PnumCounter :
dd 0x0

ProgramManager.memoryStart :
dd 0x0
ProgramManager.creationOffset :
dd 0x0

ProgramManager.pMemStor :
times 0xFF dd 0x0
ProgramManager.pOffsStor :
times 0xFF dd 0x0
ProgramManager.pNum :
db 0x0
