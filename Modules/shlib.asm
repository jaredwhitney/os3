
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
	mov [locStor], ebx
	pop eax
	pop ebx
	push eax
	add ebx, ebx
	add ebx, ebx
	add ebx, 0x2000
	mov eax, [ebx]
	mov ebx, [locStor]
	call eax
	ret
fmtEAX :
	add eax, [0x3000]
	sub eax, 0x10
	ret
fmtEBX :
	add ebx, [0x3000]
	sub ebx, 0x10
	ret
fmtECX :
	add ecx, [0x3000]
	sub ecx, 0x10
	ret
fmtEDX :
	add edx, [0x3000]
	sub edx, 0x10
	ret
locStor :
dd 0