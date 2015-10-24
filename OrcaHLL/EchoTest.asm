[bits 32]

dd EchoTest.$FILE_END - EchoTest.$FILE_START
db "OrcaHLL Class", 0
db "EchoTest", 0
EchoTest.$FILE_START :

EchoTest.$global.nul :
	db 0x0
EchoTest.$global.text :
	dd 0x0
EchoTest._init: 
pop dword [EchoTest._init.returnVal]
push eax
push ebx
push edx
mov ecx, 80
push ecx
mov ax, 0x0502
int 0x30
mov [EchoTest.$global.text], ecx
mov ecx, [EchoTest._init.string_0]
push ecx
mov ax, 0x0100
int 0x30
pop edx
pop ebx
pop eax
push dword [EchoTest._init.returnVal]
ret
	;Vars:
EchoTest._init.string_0_data :
	db ":: ", 0
EchoTest._init.string_0 :
	dd EchoTest._init.string_0_data
EchoTest._init.returnVal:
	dd 0x0


EchoTest._loop: 
pop dword [EchoTest._loop.returnVal]
push eax
push ebx
push edx
mov ax, 0x0404
int 0x30
cmp cl, 0xFF
	jne EchoTest.$loop_if.0_close
mov ecx, [console.windowStructLoc]	; INLINE ASSEMBLY
push ecx
mov ax, 0x0405
int 0x30
mov [EchoTest.$loop_if.0.$local.ch], cl
push edx
xor ecx, ecx
mov cl, [EchoTest.$loop_if.0.$local.ch]
mov edx, ecx
mov ecx, 0xFE
cmp edx, ecx
pop edx
je EchoTest.$comp_8.true
mov cl, 0x0
jmp EchoTest.$comp_8.done
EchoTest.$comp_8.true :
mov cl, 0xFF
EchoTest.$comp_8.done :

cmp cl, 0xFF
	jne EchoTest.$loop_if.1_close
mov ax, 0x0103
int 0x30
mov ecx, [EchoTest.$global.text]
push ecx
mov ax, 0x0100
int 0x30
mov ax, 0x0103
int 0x30
push ebx
mov ebx, EchoTest.$global.text
mov ecx, 0
push ecx
xor ecx, ecx
mov cl, [EchoTest.$global.nul]
push ecx
call String.SetChar
pop ebx
EchoTest.$loop_if.1_close :

push edx
xor ecx, ecx
mov cl, [EchoTest.$loop_if.0.$local.ch]
mov edx, ecx
mov ecx, 0xFE
cmp edx, ecx
pop edx
jne EchoTest.$comp_13.true
mov cl, 0x0
jmp EchoTest.$comp_13.done
EchoTest.$comp_13.true :
mov cl, 0xFF
EchoTest.$comp_13.done :

cmp cl, 0xFF
	jne EchoTest.$loop_if.2_close
push ebx
mov ebx, EchoTest.$global.text
xor ecx, ecx
mov cl, [EchoTest.$loop_if.0.$local.ch]
push ecx
call String.AppendChar
pop ebx
xor ecx, ecx
mov cl, [EchoTest.$loop_if.0.$local.ch]
push ecx
mov ax, 0x0105
int 0x30
EchoTest.$loop_if.2_close :

EchoTest.$loop_if.0_close :

pop edx
pop ebx
pop eax
push dword [EchoTest._loop.returnVal]
ret
	;Vars:
EchoTest.$loop_if.0.$local.ch :
	db 0x0
EchoTest._loop.returnVal:
	dd 0x0


EchoTest.$FILE_END :
; *** LIB IMPORT 'String' ***
[bits 32]
dd String.$FILE_END - String.$FILE_START
db "OrcaHLL Class", 0
db "String", 0
String.$FILE_START :

String.Append: 
pop dword [String.Append.returnVal]
pop ecx
mov [String.Append.$local.s], ecx
push eax
push ebx
push edx
mov ecx, 0
mov [String.Append.$local.q], ecx
push ebx
mov ebx, ebx
mov ecx, [String.Append.$local.q]
push ecx
call String.GetChar
pop ebx
mov [String.Append.$local.ch], cl
String.$loop_while.0_open :
push edx
xor ecx, ecx
mov cl, [String.Append.$local.ch]
mov edx, ecx
mov ecx, 0
cmp edx, ecx
pop edx
jne String.$comp_4.true
mov cl, 0x0
jmp String.$comp_4.done
String.$comp_4.true :
mov cl, 0xFF
String.$comp_4.done :

cmp cl, 0xFF
	jne String.$loop_while.0_end
mov ecx, [ebx]
add ecx, [String.Append.$local.q]	; INLINE ASSEMBLY
sub ecx, 1	; INLINE ASSEMBLY
mov dl, [String.Append.$local.ch]	; INLINE ASSEMBLY
mov [ecx], dl	; INLINE ASSEMBLY
push edx	; Math start
mov ecx, 1
mov edx, ecx
mov ecx, [String.Append.$local.q]
add ecx, edx
pop edx	; Math end
mov [String.Append.$local.q], ecx
push ebx
mov ebx, ebx
mov ecx, [String.Append.$local.q]
push ecx
call String.GetChar
pop ebx
mov [String.Append.$local.ch], cl
	jmp String.$loop_while.0_open
String.$loop_while.0_end :
mov ecx, [ebx]
mov ecx, [String.Append.$local.q]	; INLINE ASSEMBLY
sub ecx, 1	; INLINE ASSEMBLY
mov byte [ecx], 0x0	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [String.Append.returnVal]
ret
	;Vars:
String.Append.$local.q :
	dd 0x0
String.Append.$local.s :
	dd 0x0
String.Append.$local.ch :
	db 0x0
String.Append.returnVal:
	dd 0x0


String.GetChar: 
pop dword [String.GetChar.returnVal]
pop ecx
mov [String.GetChar.$local.pos], ecx
push eax
push ebx
push edx
mov ecx, [ebx]
add ecx, [String.GetChar.$local.pos]	; INLINE ASSEMBLY
mov cl, [ecx]	; INLINE ASSEMBLY
and ecx, 0xFF	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [String.GetChar.returnVal]
ret
	;Vars:
String.GetChar.$local.pos :
	dd 0x0
String.GetChar.returnVal:
	dd 0x0


String.SetChar: 
pop dword [String.SetChar.returnVal]
pop ecx
mov [String.SetChar.$local.ch], cl
pop ecx
mov [String.SetChar.$local.pos], ecx
push eax
push ebx
push edx
mov ecx, [ebx]
add ecx, [String.SetChar.$local.pos]	; INLINE ASSEMBLY
mov al, [String.SetChar.$local.ch]	; INLINE ASSEMBLY
mov byte [ecx], al	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [String.SetChar.returnVal]
ret
	;Vars:
String.SetChar.$local.pos :
	dd 0x0
String.SetChar.$local.ch :
	db 0x0
String.SetChar.returnVal:
	dd 0x0


String.AppendChar: 
pop dword [String.AppendChar.returnVal]
pop ecx
mov [String.AppendChar.$local.ch], cl
push eax
push ebx
push edx
push ebx
mov ebx, ebx
call String.GetLength
pop ebx
mov [String.AppendChar.$local.length], ecx
mov ecx, 0
mov [String.AppendChar.$local.blank], cl
push ebx
mov ebx, ebx
mov ecx, [String.AppendChar.$local.length]
push ecx
xor ecx, ecx
mov cl, [String.AppendChar.$local.ch]
push ecx
call String.SetChar
pop ebx
push ebx
mov ebx, ebx
push edx	; Math start
mov ecx, 1
mov edx, ecx
mov ecx, [String.AppendChar.$local.length]
add ecx, edx
pop edx	; Math end
push ecx
xor ecx, ecx
mov cl, [String.AppendChar.$local.blank]
push ecx
call String.SetChar
pop ebx
pop edx
pop ebx
pop eax
push dword [String.AppendChar.returnVal]
ret
	;Vars:
String.AppendChar.$local.blank :
	db 0x0
String.AppendChar.$local.ch :
	db 0x0
String.AppendChar.$local.length :
	dd 0x0
String.AppendChar.returnVal:
	dd 0x0


String.RawToWhite: 
pop dword [String.RawToWhite.returnVal]
push eax
push ebx
push edx
push ebx
mov ebx, ebx
call String.GetLength
pop ebx
push ecx
mov ax, 0x0501
int 0x30
mov [String.RawToWhite.$local.ret], ecx
push ebx
mov ebx, ebx
call String.GetLength
pop ebx
mov [String.RawToWhite.$local.length], ecx
mov ecx, 0xFF
mov [String.RawToWhite.$local.white], cl
mov ecx, 0
mov [String.$loop_for.0.$local.z], ecx
String.$loop_for.0_open :
push edx	; Math start
mov ecx, 2
mov edx, ecx
mov ecx, [String.$loop_for.0.$local.z]
imul ecx, edx
pop edx	; Math end
mov [String.$loop_for.0.$local.offs], ecx
;			k.	; INLINE ASSEMBLY
push ebx
mov ebx, ebx
push edx	; Math start
mov ecx, 2
mov edx, ecx
mov ecx, [String.$loop_for.0.$local.z]
imul ecx, edx
pop edx	; Math end
push ecx
call String.GetChar
pop ebx
mov [String.$loop_for.0.$local.ch], cl
push ebx
mov ebx, String.RawToWhite.$local.ret
push edx	; Math start
mov ecx, 2
mov edx, ecx
mov ecx, [String.$loop_for.0.$local.z]
imul ecx, edx
pop edx	; Math end
push ecx
xor ecx, ecx
mov cl, [String.$loop_for.0.$local.ch]
push ecx
call String.SetChar
pop ebx
push ebx
mov ebx, String.RawToWhite.$local.ret
push edx	; Math start
push edx	; Math start
mov ecx, 1
mov edx, ecx
mov ecx, 2
add ecx, edx
pop edx	; Math end
mov edx, ecx
mov ecx, [String.$loop_for.0.$local.z]
add ecx, edx
pop edx	; Math end
push ecx
xor ecx, ecx
mov cl, [String.RawToWhite.$local.white]
push ecx
call String.SetChar
pop ebx
push edx	; Math start
mov ecx, 1
mov edx, ecx
mov ecx, [String.$loop_for.0.$local.z]
add ecx, edx
pop edx	; Math end
mov [String.$loop_for.0.$local.z], ecx
push edx
mov ecx, [String.$loop_for.0.$local.z]
mov edx, ecx
mov ecx, [String.RawToWhite.$local.length]
cmp edx, ecx
pop edx
jl String.$comp_46.true
mov cl, 0x0
jmp String.$comp_46.done
String.$comp_46.true :
mov cl, 0xFF
String.$comp_46.done :

cmp cl, 0xFF
	je String.$loop_for.0_open

pop edx
pop ebx
pop eax
push dword [String.RawToWhite.returnVal]
ret
	;Vars:
String.RawToWhite.$local.ret :
	dd 0x0
String.RawToWhite.$local.white :
	db 0x0
String.RawToWhite.$local.length :
	dd 0x0
String.$loop_for.0.$local.offs :
	dd 0x0
String.$loop_for.0.$local.ch :
	db 0x0
String.$loop_for.0.$local.z :
	dd 0x0
String.RawToWhite.returnVal:
	dd 0x0


String.GetLength: 
pop dword [String.GetLength.returnVal]
push eax
push ebx
push edx
mov ecx, 0
mov [String.GetLength.$local.ret], ecx
push ebx
mov ebx, ebx
mov ecx, [String.GetLength.$local.ret]
push ecx
call String.GetChar
pop ebx
mov [String.GetLength.$local.ch], cl
String.$loop_while.1_open :
push edx
xor ecx, ecx
mov cl, [String.GetLength.$local.ch]
mov edx, ecx
mov ecx, 0
cmp edx, ecx
pop edx
jne String.$comp_49.true
mov cl, 0x0
jmp String.$comp_49.done
String.$comp_49.true :
mov cl, 0xFF
String.$comp_49.done :

cmp cl, 0xFF
	jne String.$loop_while.1_end
push edx	; Math start
mov ecx, 1
mov edx, ecx
mov ecx, [String.GetLength.$local.ret]
add ecx, edx
pop edx	; Math end
mov [String.GetLength.$local.ret], ecx
push ebx
mov ebx, ebx
mov ecx, [String.GetLength.$local.ret]
push ecx
call String.GetChar
pop ebx
mov [String.GetLength.$local.ch], cl
	jmp String.$loop_while.1_open
String.$loop_while.1_end :
mov ecx, [String.GetLength.$local.ret]
pop edx
pop ebx
pop eax
push dword [String.GetLength.returnVal]
ret
	;Vars:
String.GetLength.$local.ret :
	dd 0x0
String.GetLength.$local.ch :
	db 0x0
String.GetLength.returnVal:
	dd 0x0


String.$FILE_END :



