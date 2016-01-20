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

