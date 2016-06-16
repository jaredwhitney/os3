Guppy2.table equ 0xA10000	; not 0xA10000 to avoid conflicts until Guppy is removed
Guppy2.tableEnd	equ 0x1000000
Guppy2.MEMORY_START equ 0x1000000	; not 0x1000000 for the above reason

Region.OBJ_SIZE		equ 0x8
Region_pointer	equ 0x0
Region_size		equ 0x4

Guppy2.init :
	pusha
		mov eax, Guppy2.table
		mov ebx, Guppy2.tableEnd - Guppy2.table
		call Buffer.clear
	popa
	ret

Guppy2.runTest :
	pusha
		call console.newline
		push dword 1000
		call Guppy2.malloc
		call console.numOut
		mov [.region0], ebx
		
		call console.newline
		push dword 100
		call Guppy2.malloc
		call console.numOut
		mov [.region1], ebx
		
		call console.newline
		push dword 293
		call Guppy2.malloc
		call console.numOut
		mov [.region2], ebx
		
		push dword [.region1]
		call Guppy2.dealloc
		
		call console.newline
		push dword 101
		call Guppy2.malloc
		call console.numOut
		
		call console.newline
		push dword 75
		call Guppy2.malloc
		call console.numOut
		
		call console.newline
		push dword 10
		call Guppy2.malloc
		call console.numOut
		
	popa
	ret
	.region0 :
		dd 0x0
	.region1 :
		dd 0x0
	.region2 :
		dd 0x0

Guppy2.malloc :
enter 0, 0
pusha
	mov eax, Guppy2.table
	.loop :
	cmp dword [eax], 0x0
		je .foundSpot
	add eax, Region.OBJ_SIZE
	jmp .loop
	.foundSpot :
	mov dword [.newRegion], eax
	mov eax, Guppy2.table
	call Guppy2.advanceEAXregion
	cmp dword [eax], 0xFFFFFFFF
		jne .notEmptyList
	mov ebx, Guppy2.MEMORY_START	; WILL CAUSE PROBLEMS IF RETURNS FULLPTR FOR ACTUAL HIT END OF LIST SPACE
	jmp .foundMem
	.notEmptyList :
	mov ebx, [eax+Region_pointer]
	sub ebx, Guppy2.MEMORY_START
	cmp ebx, [ebp+8]
		jge .foundMem
	.findMemLoop :
	mov ebx, [eax+Region_pointer]
	add ebx, [eax+Region_size]
	call Guppy2.advanceEAXregion
	mov ecx, [eax+Region_pointer]
	sub ecx, ebx
	cmp ecx, [ebp+8]
		jge .foundMem
	jmp .findMemLoop
	.foundMem :
	mov eax, [.newRegion]
	mov [eax+Region_pointer], ebx
	mov [.ret], ebx
	mov ebx, [ebp+8]
	mov [eax+Region_size], ebx
	call Guppy2.sortItem
	;call ps2.resetCPU
popa
mov ebx, [.ret]
leave
ret 4
	.newRegion :
		dd 0x0
	.ret :
		dd 0x0

Guppy2.advanceEAXregion :
		.loopFindNext :
		add eax, Region.OBJ_SIZE
		cmp eax, Guppy2.tableEnd
			jl .goOn
		mov eax, fullptr
		ret
		.goOn :
		cmp dword [eax], 0x0
			je .loopFindNext
	ret

Guppy2.decreaseEAXregion :
		.loopFindNext :
		sub eax, Region.OBJ_SIZE
		cmp eax, Guppy2.table
			jg .goOn
		mov eax, nullptr
		ret
		.goOn :
		cmp dword [eax], 0x0
			je .loopFindNext
	ret

Guppy2.dealloc :
enter 0, 0
pusha
	mov edx, [ebp+8]
	mov eax, Guppy2.table
	.findLoop :
	cmp [eax+Region_pointer], edx
		je .dealloc
	add eax, Region.OBJ_SIZE
	jmp .findLoop
	.dealloc :
	mov dword [eax+Region_pointer], 0x0
	mov dword [eax+Region_size], 0x0
popa
leave
ret 4

Guppy2.sortItem :
	pusha
		mov [.stor], eax
		
		.muloop :
		mov ecx, eax
		mov ebx, [eax+Region_pointer]
		call Guppy2.advanceEAXregion
		cmp [eax+Region_pointer], ebx
			jb .loopMoveUp
		
		.mdloop :
		mov eax, [.stor]
		mov ecx, eax
		mov ebx, [eax+Region_pointer]
		call Guppy2.decreaseEAXregion
		cmp [eax+Region_pointer], ebx
			ja .loopMoveDown
	popa
	ret
	.loopMoveUp :
		call Guppy2.sortItem.objswap
		jmp Guppy2.sortItem.muloop
	.loopMoveDown :
		call Guppy2.sortItem.objswap
		jmp Guppy2.sortItem.mdloop
	.objswap :
		mov edx, [eax+Region_pointer]
		mov ebx, [ecx+Region_pointer]
		mov [eax+Region_pointer], ebx
		mov [eax+Region_pointer], edx
		
		mov edx, [eax+Region_size]
		mov ebx, [ecx+Region_size]
		mov [eax+Region_size], ebx
		mov [eax+Region_size], edx
	ret
	.stor :
		dd 0x0