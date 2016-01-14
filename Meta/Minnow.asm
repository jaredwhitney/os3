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

