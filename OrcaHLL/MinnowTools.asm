[bits 32]

dd MinnowTools.$FILE_END - MinnowTools.$FILE_START
db "OrcaHLL Class", 0
db "MinnowTools", 0
MinnowTools.$FILE_START :

MinnowTools.$global.lastBlocks :
	dd 0x0
MinnowTools.$global.dat :
	dd 0x0
MinnowTools.ValidateFS: 
pop dword [MinnowTools.ValidateFS.returnVal]
push eax
push ebx
push edx
mov ecx, 0
push ecx
call Minnow.ReadBlock
mov [MinnowTools.$global.dat], ecx
push ebx
mov ebx, MinnowTools.$global.dat
mov ecx, 4
push ecx
call Buffer.ReadInt
pop ebx
mov [MinnowTools.$global.lastBlocks], ecx
call MinnowTools.ValidateFS_Loop
pop edx
pop ebx
pop eax
push dword [MinnowTools.ValidateFS.returnVal]
ret
	;Vars:
MinnowTools.ValidateFS.returnVal:
	dd 0x0


MinnowTools.ValidateFS_Loop: 
pop dword [MinnowTools.ValidateFS_Loop.returnVal]
push eax
push ebx
push edx
ValidateFS_Loop.__START :	; INLINE ASSEMBLY
push ebx
mov ebx, MinnowTools.$global.dat
mov ecx, 0
push ecx
call Buffer.ReadInt
pop ebx
mov [MinnowTools.ValidateFS_Loop.$local.ptr], ecx
push ebx
mov ebx, MinnowTools.$global.dat
mov ecx, 4
push ecx
call Buffer.ReadInt
pop ebx
mov [MinnowTools.ValidateFS_Loop.$local.blocks], ecx
push edx
mov ecx, [MinnowTools.$global.lastBlocks]
mov edx, ecx
mov ecx, 0
cmp edx, ecx
pop edx
jne MinnowTools.$comp_11.true
mov cl, 0x0
jmp MinnowTools.$comp_11.done
MinnowTools.$comp_11.true :
mov cl, 0xFF
MinnowTools.$comp_11.done :

cmp cl, 0xFF
	jne MinnowTools.$loop_if.0_close
push edx
mov ecx, [MinnowTools.ValidateFS_Loop.$local.blocks]
mov edx, ecx
mov ecx, [MinnowTools.$global.lastBlocks]
cmp edx, ecx
pop edx
jne MinnowTools.$comp_12.true
mov cl, 0x0
jmp MinnowTools.$comp_12.done
MinnowTools.$comp_12.true :
mov cl, 0xFF
MinnowTools.$comp_12.done :

cmp cl, 0xFF
	jne MinnowTools.$loop_if.1_close
mov ecx, [MinnowTools.$loop_if.1.string_0]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, 0
pop edx
pop ebx
pop eax
push dword [MinnowTools.ValidateFS_Loop.returnVal]
ret
MinnowTools.$loop_if.1_close :

MinnowTools.$loop_if.0_close :

push edx
mov ecx, [MinnowTools.$global.lastBlocks]
mov edx, ecx
mov ecx, 0
cmp edx, ecx
pop edx
je MinnowTools.$comp_15.true
mov cl, 0x0
jmp MinnowTools.$comp_15.done
MinnowTools.$comp_15.true :
mov cl, 0xFF
MinnowTools.$comp_15.done :

cmp cl, 0xFF
	jne MinnowTools.$loop_if.2_close
mov ecx, [MinnowTools.$loop_if.2.string_0]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, [MinnowTools.ValidateFS_Loop.$local.ptr]
push ecx
mov ax, 0x0102
int 0x30
mov ax, 0x0103
int 0x30
mov ecx, [MinnowTools.$loop_if.2.string_1]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, [MinnowTools.ValidateFS_Loop.$local.blocks]
push ecx
mov ax, 0x0102
int 0x30
mov ax, 0x0103
int 0x30
push edx	; Math start
mov ecx, 8
mov edx, ecx
mov ecx, [MinnowTools.$global.dat]
add ecx, edx
pop edx	; Math end
mov [MinnowTools.$loop_if.2.$local.name], ecx
push edx	; Math start
push ebx
mov ebx, MinnowTools.$loop_if.2.$local.name
call String.GetLength
pop ebx
mov edx, ecx
mov ecx, [MinnowTools.$loop_if.2.$local.name]
add ecx, edx
pop edx	; Math end
mov [MinnowTools.$loop_if.2.$local.type], ecx
mov ecx, [MinnowTools.$loop_if.2.string_2]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, [MinnowTools.$loop_if.2.$local.name]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [MinnowTools.$loop_if.2.string_3]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, [MinnowTools.$loop_if.2.$local.type]
push ecx
mov ax, 0x0101
int 0x30
MinnowTools.$loop_if.2_close :

push edx
mov ecx, [MinnowTools.ValidateFS_Loop.$local.ptr]
mov edx, ecx
mov ecx, 0
cmp edx, ecx
pop edx
je MinnowTools.$comp_28.true
mov cl, 0x0
jmp MinnowTools.$comp_28.done
MinnowTools.$comp_28.true :
mov cl, 0xFF
MinnowTools.$comp_28.done :

cmp cl, 0xFF
	jne MinnowTools.$loop_if.3_close
push edx
mov ecx, [MinnowTools.ValidateFS_Loop.$local.blocks]
mov edx, ecx
mov ecx, 0
cmp edx, ecx
pop edx
jne MinnowTools.$comp_29.true
mov cl, 0x0
jmp MinnowTools.$comp_29.done
MinnowTools.$comp_29.true :
mov cl, 0xFF
MinnowTools.$comp_29.done :

cmp cl, 0xFF
	jne MinnowTools.$loop_if.4_close
mov ecx, [MinnowTools.$loop_if.4.string_0]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, 0
pop edx
pop ebx
pop eax
push dword [MinnowTools.ValidateFS_Loop.returnVal]
ret
MinnowTools.$loop_if.4_close :

mov ecx, [MinnowTools.$loop_if.3.string_0]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, 0xFF
pop edx
pop ebx
pop eax
push dword [MinnowTools.ValidateFS_Loop.returnVal]
ret
MinnowTools.$loop_if.3_close :

mov ecx, [MinnowTools.ValidateFS_Loop.$local.blocks]
mov [MinnowTools.$global.lastBlocks], ecx
mov ecx, [MinnowTools.$global.dat]
push ecx
call Minnow.ReadBlock
mov [MinnowTools.$global.dat], ecx
jmp ValidateFS_Loop.__START	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [MinnowTools.ValidateFS_Loop.returnVal]
ret
	;Vars:
MinnowTools.ValidateFS_Loop.$local.blocks :
	dd 0x0
MinnowTools.ValidateFS_Loop.$local.ptr :
	dd 0x0
MinnowTools.$loop_if.3.string_0_data :
	db "[End Filesystem]", 0
MinnowTools.$loop_if.2.string_2_data :
	db "Name: ", 0
MinnowTools.$loop_if.2.string_0_data :
	db "Ptr: ", 0
MinnowTools.$loop_if.2.$local.type :
	dd 0x0
MinnowTools.$loop_if.2.string_1_data :
	db "Blocks: ", 0
MinnowTools.$loop_if.3.string_0 :
	dd MinnowTools.$loop_if.3.string_0_data
MinnowTools.$loop_if.2.string_2 :
	dd MinnowTools.$loop_if.2.string_2_data
MinnowTools.$loop_if.2.string_1 :
	dd MinnowTools.$loop_if.2.string_1_data
MinnowTools.$loop_if.2.string_3_data :
	db "Type: ", 0
MinnowTools.$loop_if.2.string_3 :
	dd MinnowTools.$loop_if.2.string_3_data
MinnowTools.$loop_if.2.string_0 :
	dd MinnowTools.$loop_if.2.string_0_data
MinnowTools.$loop_if.2.$local.name :
	dd 0x0
MinnowTools.$loop_if.1.string_0 :
	dd MinnowTools.$loop_if.1.string_0_data
MinnowTools.$loop_if.4.string_0 :
	dd MinnowTools.$loop_if.4.string_0_data
MinnowTools.$loop_if.4.string_0_data :
	db "Quitting on invalid block!", 0
MinnowTools.$loop_if.1.string_0_data :
	db "Quitting on invalid block!", 0
MinnowTools.ValidateFS_Loop.returnVal:
	dd 0x0


MinnowTools.$FILE_END :
; *** LIB IMPORT 'Buffer' ***
[bits 32]
dd Buffer.$FILE_END - Buffer.$FILE_START
db "OrcaHLL Class", 0
db "Buffer", 0
Buffer.$FILE_START :

Buffer.Create: 
pop dword [Buffer.Create.returnVal]
pop ecx
mov [Buffer.Create.$local.size], ecx
push eax
push ebx
push edx
mov ecx, [Buffer.Create.$local.size]
push ecx
mov ax, 0x0502
int 0x30
mov [Buffer.Create.$local.ret], ecx
mov ecx, [Buffer.Create.$local.ret]
pop edx
pop ebx
pop eax
push dword [Buffer.Create.returnVal]
ret
	;Vars:
Buffer.Create.$local.ret :
	dd 0x0
Buffer.Create.$local.size :
	dd 0x0
Buffer.Create.returnVal:
	dd 0x0


Buffer.ReadByte: 
pop dword [Buffer.ReadByte.returnVal]
pop ecx
mov [Buffer.ReadByte.$local.offs], ecx
push eax
push ebx
push edx
mov ecx, [Buffer.ReadByte.$local.offs]
add ebx, ecx	; INLINE ASSEMBLY
xor ecx, ecx	; INLINE ASSEMBLY
mov cl, [ebx]	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [Buffer.ReadByte.returnVal]
ret
	;Vars:
Buffer.ReadByte.$local.offs :
	dd 0x0
Buffer.ReadByte.returnVal:
	dd 0x0


Buffer.ReadIntSmall: 
pop dword [Buffer.ReadIntSmall.returnVal]
pop ecx
mov [Buffer.ReadIntSmall.$local.offs], ecx
push eax
push ebx
push edx
mov ecx, [Buffer.ReadIntSmall.$local.offs]
add ebx, ecx	; INLINE ASSEMBLY
xor ecx, ecx	; INLINE ASSEMBLY
mov cx, [ebx]	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [Buffer.ReadIntSmall.returnVal]
ret
	;Vars:
Buffer.ReadIntSmall.$local.offs :
	dd 0x0
Buffer.ReadIntSmall.returnVal:
	dd 0x0


Buffer.ReadInt: 
pop dword [Buffer.ReadInt.returnVal]
pop ecx
mov [Buffer.ReadInt.$local.offs], ecx
push eax
push ebx
push edx
mov ecx, [Buffer.ReadInt.$local.offs]
add ebx, ecx	; INLINE ASSEMBLY
mov ecx, [ebx]	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [Buffer.ReadInt.returnVal]
ret
	;Vars:
Buffer.ReadInt.$local.offs :
	dd 0x0
Buffer.ReadInt.returnVal:
	dd 0x0


Buffer.$FILE_END :



