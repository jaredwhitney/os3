; OLD
ProgramManager.reserveMemory :	; ebx contains bytes to reserve, returns ebx = location
push eax
	push dword [ProgramManager.creationOffset]
	mov eax, [ProgramManager.creationOffset]
	add eax, ebx
	mov [ProgramManager.creationOffset], eax
	pop ebx
	add ebx, [ProgramManager.memoryStart]
pop eax
ret

; NEW
ProgramManager.reserveMemoryNew :	; ebx contains bytes to reserve, returns ebx = location
push eax
push ecx
push edx
	mov ecx, ebx	; ecx = size
	push dword [ProgramManager.creationOffset]
	mov eax, [ProgramManager.creationOffset]
	add eax, ebx
	mov [ProgramManager.creationOffset], eax
	pop ebx
	add ebx, [ProgramManager.memoryStart]	; ebx is the allocated memory
	mov eax, [ProgramManager.tableLoc]	; tableLoc holds a pointer to the proccess' memory table
	mov eax, [eax]
	add eax, [ProgramManager.tableOffset]	; tableOffset holds the offset to the end of the table
	mov [eax], ebx	; pos
	mov [eax+4], ecx	; size
	mov eax, [ProgramManager.tableOffset]
	add eax, 8
	mov [ProgramManager.tableOffset], eax	; update tableOffset
pop edx
pop ecx
pop eax
ret

ProgramManager.deallocateMemory :	; ebx contains object to deallocate
pusha
	mov eax, [ProgramManager.tableLoc]
	xor edx, edx
	ProgramManager.deallocateMemory.loop :
		mov ecx, [eax]
		cmp ecx, ebx	; if the locations match
			jne ProgramManager.deallocateMemory.nogo
		mov ebx, ecx
		call ProgramManager.deleteTableEntry
		jmp ProgramManager.deallocateMemory.ret
		ProgramManager.deallocateMemory.nogo :
		add eax, 2
		add edx, 2
		cmp edx, [ProgramManager.tableOffset]
			jg ProgramManager.deallocateMemory.ret	; should probably show a warn screen
		jmp ProgramManager.deallocateMemory.loop
ProgramManager.deallocateMemory.ret :
popa
ret

ProgramManager.deleteTableEntry :	; ebx contains the index to remove
pusha
	mov eax, [ProgramManager.tableLoc]
	mov ecx, eax
	add ecx, [ProgramManager.tableOffset]
	add eax, ebx
	;loop
	ProgramManager.deleteTableEntry.loop :
	mov dword [eax], [eax+8]
	mov dword [eax+4], [eax+12]
	add eax, 8
	cmp eax, ecx
		jl ProgramManager.deleteTableEntry.loop
	;endloop
	mov eax, [ProgramManager.tableOffset]
	sub eax, 8
	mov [ProgramManager.tableOffset], eax
popa
ret

; In addition to the above changes need to make:
;	in getProgramNumber allocate 1 page (up to 512 vars) for a table
;	in getProgramNumber store the location in pTabStor
;	in setActive load pTabStor->tableLoc and pToffsStor->tableOffset
;	in finalize save tableLoc->pTabStor and tableOffset->pToffsStor
;	add 0xFF dd 0x0: pTabStor and pToffsStor
;	add dd 0x0: tableOffset and tableLoc
;
;	Then programs should be able to do:
;		mov bl, [ProgramNumber]
;		call ProgramManager.setActive
;		push dword _TITLE
;		push dword Window.TYPE_TEXT
;		call Window.create
;		mov [_WINDOW], ebx
;		... do things with the window here then when done
;		mov ebx, [_WINDOW]
;		call ProgramManager.deallocateMemory
;		call ProgramManager.finalize
;
;	Or in OrcaHLL (eventually):
;		Window win = new Window("Title", Window.TYPE_TEXT)
;		... do things with the window here then when done
;		dealloc win
;
;	[Also a Window is a bad example to use because it most likely wouldn't be deallocated so quickly but it demonstrates the point]
;
; Only thing then is to make reserveMemoryNew smarter so that it actually makes use of the new "holes" that appear in memory (as atm deallocating marks the memory as free but reserveMemoryNew is still using the old allocation system which doesn't take the table into account)
