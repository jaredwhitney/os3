;	programLoader.asm
;
;	loads programs into memory and executes them
;


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

