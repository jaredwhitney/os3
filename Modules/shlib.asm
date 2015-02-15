
; Shared lib

os.setEcatch		equ		0
retfunc				equ		1
Dolphin.create		equ		2
Dolphin.textUpdate	equ		3
Dolphin.clear		equ		4
clearScreenG		equ		5
debug.print			equ		6
debug.println		equ		7
debug.num			equ		8
debug.clear			equ		9

it:
	push ebx
	mov ebx, [locStor]
	
	add ebx, ebx
	add ebx, ebx
	add ebx, 0x2000
	mov eax, [ebx]
	pop ebx
	call eax
	ret
locStor :
dd 0