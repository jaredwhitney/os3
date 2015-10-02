[bits 32]

dd MathTest.$FILE_END - MathTest.$FILE_START
db "OrcaHLL Class", 0
db "MathTest", 0
MathTest.$FILE_START :
dd MathTest._init

MathTest._init: 
pop dword [MathTest._init.returnVal]
push eax
push ebx
push edx
mov ax, 0x0104
int 0x30
call MathTest.getNumber
mov [MathTest._init.$local.y], ecx
mov ecx, [MathTest._init.string_0]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, [MathTest._init.$local.y]
push ecx
mov ax, 0x0102
int 0x30
mov ax, 0x0103
int 0x30
push edx	; Math start
mov ecx, 5
mov edx, ecx
mov ecx, [MathTest._init.$local.y]
add ecx, edx
pop edx	; Math end
mov [MathTest._init.$local.y], ecx
mov ecx, [MathTest._init.string_1]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, [MathTest._init.$local.y]
push ecx
mov ax, 0x0102
int 0x30
mov ax, 0x0103
int 0x30
mov ecx, [MathTest._init.string_2]
push ecx
mov ax, 0x0100
int 0x30
push edx	; Math start
mov ecx, 2
mov edx, ecx
mov ecx, [MathTest._init.$local.y]
sub ecx, edx
pop edx	; Math end
push ecx
mov ax, 0x0102
int 0x30
pop edx
pop ebx
pop eax
push dword [MathTest._init.returnVal]
ret
	;Vars:
MathTest._init.string_0_data :
	db "Y is 0x", 0
MathTest._init.string_1 :
	dd MathTest._init.string_1_data
MathTest._init.string_2_data :
	db "Y-2 = 0x", 0
MathTest._init.string_1_data :
	db "Y is now 0x", 0
MathTest._init.$local.y :
	dd 0x0
MathTest._init.string_0 :
	dd MathTest._init.string_0_data
MathTest._init.string_2 :
	dd MathTest._init.string_2_data
MathTest._init.returnVal:
	dd 0x0


MathTest.getNumber: 
pop dword [MathTest.getNumber.returnVal]
push eax
push ebx
push edx
mov ecx, 3
pop edx
pop ebx
pop eax
push dword [MathTest.getNumber.returnVal]
ret
	;Vars:
MathTest.getNumber.returnVal:
	dd 0x0


MathTest.$FILE_END :

