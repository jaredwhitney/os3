[bits 32]

dd MinnowTest.$FILE_END - MinnowTest.$FILE_START
db "OrcaHLL Class", 0
db "MinnowTest", 0
MinnowTest.$FILE_START :

MinnowTest.$global.nameToDelete :
	dd 0x0
MinnowTest.$global.type :
	dd 0x0
MinnowTest.$global.fileContents :
	dd 0x0
MinnowTest.$global.nameToUse :
	dd 0x0
MinnowTest.$global.name1 :
	dd 0x0
MinnowTest.$global.name0 :
	dd 0x0
MinnowTest.$global.switch :
	db 0x0
MinnowTest._init: 
pop dword [MinnowTest._init.returnVal]
push eax
push ebx
push edx
mov ecx, 20
push ecx
mov ax, 0x0502
int 0x30
mov [MinnowTest.$global.nameToUse], ecx
mov ecx, 20
push ecx
mov ax, 0x0502
int 0x30
mov [MinnowTest.$global.nameToDelete], ecx
mov ecx, [MinnowTest._init.string_0]
mov [MinnowTest.$global.name0], ecx
mov ecx, [MinnowTest._init.string_1]
mov [MinnowTest.$global.name1], ecx
mov ecx, [MinnowTest._init.string_2]
mov [MinnowTest.$global.type], ecx
mov ecx, [MinnowTest._init.string_3]
mov [MinnowTest.$global.fileContents], ecx
pop edx
pop ebx
pop eax
push dword [MinnowTest._init.returnVal]
ret
	;Vars:
MinnowTest._init.string_3 :
	dd MinnowTest._init.string_3_data
MinnowTest._init.string_0_data :
	db "Write Test", 0
MinnowTest._init.string_0 :
	dd MinnowTest._init.string_0_data
MinnowTest._init.string_1_data :
	db "Filesystem Test", 0
MinnowTest._init.string_2_data :
	db "Text", 0
MinnowTest._init.string_3_data :
	db "This is some test text that has been written to the filesystem with the new Minnow.WriteFile() command!", 0
MinnowTest._init.string_1 :
	dd MinnowTest._init.string_1_data
MinnowTest._init.string_2 :
	dd MinnowTest._init.string_2_data
MinnowTest._init.returnVal:
	dd 0x0


MinnowTest.RunTest: 
pop dword [MinnowTest.RunTest.returnVal]
push eax
push ebx
push edx
push ebx
mov ebx, MinnowTest.$global.nameToUse
mov ecx, 0
push ecx
mov ecx, 0
push ecx
call String.SetChar
pop ebx
push ebx
mov ebx, MinnowTest.$global.nameToDelete
mov ecx, 0
push ecx
mov ecx, 0
push ecx
call String.SetChar
pop ebx
mov ecx, [MinnowTest.$global.name1]
push ecx
mov ecx, [MinnowTest.$global.type]
push ecx
call Minnow.CheckExists
cmp cl, 0xFF
	jne MinnowTest.$loop_if.0_close
push ebx
mov ebx, MinnowTest.$global.nameToUse
mov ecx, [MinnowTest.$global.name0]
push ecx
call String.Append
pop ebx
push ebx
mov ebx, MinnowTest.$global.nameToDelete
mov ecx, [MinnowTest.$global.name1]
push ecx
call String.Append
pop ebx
MinnowTest.$loop_if.0_close :

mov ecx, [MinnowTest.$global.name0]
push ecx
mov ecx, [MinnowTest.$global.type]
push ecx
call Minnow.CheckExists
cmp cl, 0xFF
	jne MinnowTest.$loop_if.1_close
push ebx
mov ebx, MinnowTest.$global.nameToUse
mov ecx, [MinnowTest.$global.name1]
push ecx
call String.Append
pop ebx
push ebx
mov ebx, MinnowTest.$global.nameToDelete
mov ecx, [MinnowTest.$global.name0]
push ecx
call String.Append
pop ebx
MinnowTest.$loop_if.1_close :

mov ecx, [MinnowTest.$global.nameToDelete]
push ecx
mov ecx, [MinnowTest.$global.type]
push ecx
call Minnow.DeleteFile
mov ecx, [MinnowTest.$global.nameToUse]
push ecx
mov ecx, [MinnowTest.$global.type]
push ecx
mov ecx, [MinnowTest.$global.fileContents]
push ecx
push ebx
mov ebx, MinnowTest.$global.fileContents
call String.GetLength
pop ebx
push ecx
call Minnow.WriteFile
pop edx
pop ebx
pop eax
push dword [MinnowTest.RunTest.returnVal]
ret
	;Vars:
MinnowTest.RunTest.returnVal:
	dd 0x0


MinnowTest.$FILE_END :
; *** LIB IMPORT 'Minnow' ***
[bits 32]
dd Minnow.$FILE_END - Minnow.$FILE_START
db "OrcaHLL Class", 0
db "Minnow", 0
Minnow.$FILE_START :

Minnow.ReadFileBlock: 
pop dword [Minnow.ReadFileBlock.returnVal]
pop ecx
mov [Minnow.ReadFileBlock.$local.block], ecx
pop ecx
mov [Minnow.ReadFileBlock.$local.fileType], ecx
pop ecx
mov [Minnow.ReadFileBlock.$local.fileName], ecx
push eax
push ebx
push edx
mov ecx, [Minnow.ReadFileBlock.$local.fileName]
mov eax, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.ReadFileBlock.$local.fileType]
mov ebx, ecx	; INLINE ASSEMBLY
call Minnow.nameAndTypeToPointer	; INLINE ASSEMBLY
mov eax, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.ReadFileBlock.$local.block]
mov ebx, ecx	; INLINE ASSEMBLY
call Minnow.readFileBlock	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [Minnow.ReadFileBlock.returnVal]
ret
	;Vars:
Minnow.ReadFileBlock.$local.fileName :
	dd 0x0
Minnow.ReadFileBlock.$local.block :
	dd 0x0
Minnow.ReadFileBlock.$local.fileType :
	dd 0x0
Minnow.ReadFileBlock.returnVal:
	dd 0x0


Minnow.WriteFile: 
pop dword [Minnow.WriteFile.returnVal]
pop ecx
mov [Minnow.WriteFile.$local.bufferSize], ecx
pop ecx
mov [Minnow.WriteFile.$local.buffer], ecx
pop ecx
mov [Minnow.WriteFile.$local.fileType], ecx
pop ecx
mov [Minnow.WriteFile.$local.fileName], ecx
push eax
push ebx
push edx
mov ecx, [Minnow.WriteFile.$local.fileName]
mov eax, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.WriteFile.$local.fileType]
mov ebx, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.WriteFile.$local.bufferSize]
mov edx, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.WriteFile.$local.buffer]
call Minnow.writeFile	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [Minnow.WriteFile.returnVal]
ret
	;Vars:
Minnow.WriteFile.$local.fileName :
	dd 0x0
Minnow.WriteFile.$local.buffer :
	dd 0x0
Minnow.WriteFile.$local.fileType :
	dd 0x0
Minnow.WriteFile.$local.bufferSize :
	dd 0x0
Minnow.WriteFile.returnVal:
	dd 0x0


Minnow.CheckExists: 
pop dword [Minnow.CheckExists.returnVal]
pop ecx
mov [Minnow.CheckExists.$local.fileType], ecx
pop ecx
mov [Minnow.CheckExists.$local.fileName], ecx
push eax
push ebx
push edx
mov ecx, [Minnow.CheckExists.$local.fileName]
mov eax, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.CheckExists.$local.fileType]
mov ebx, ecx	; INLINE ASSEMBLY
call Minnow.nameAndTypeToPointer	; INLINE ASSEMBLY
cmp cl, 0xFF
	jne Minnow.$loop_if.0_close
mov ecx, 0x0
pop edx
pop ebx
pop eax
push dword [Minnow.CheckExists.returnVal]
ret
Minnow.$loop_if.0_close :

mov ecx, 0xFF
pop edx
pop ebx
pop eax
push dword [Minnow.CheckExists.returnVal]
ret
	;Vars:
Minnow.CheckExists.$local.fileName :
	dd 0x0
Minnow.CheckExists.$local.fileType :
	dd 0x0
Minnow.CheckExists.returnVal:
	dd 0x0


Minnow.DeleteFile: 
pop dword [Minnow.DeleteFile.returnVal]
pop ecx
mov [Minnow.DeleteFile.$local.fileType], ecx
pop ecx
mov [Minnow.DeleteFile.$local.fileName], ecx
push eax
push ebx
push edx
mov ecx, [Minnow.DeleteFile.$local.fileName]
mov eax, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.DeleteFile.$local.fileType]
mov ebx, ecx	; INLINE ASSEMBLY
call Minnow.nameAndTypeToPointer	; INLINE ASSEMBLY
mov eax, ecx	; INLINE ASSEMBLY
call Minnow.deleteFile	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [Minnow.DeleteFile.returnVal]
ret
	;Vars:
Minnow.DeleteFile.$local.fileName :
	dd 0x0
Minnow.DeleteFile.$local.fileType :
	dd 0x0
Minnow.DeleteFile.returnVal:
	dd 0x0


Minnow.$FILE_END :



