betterPaging.init :
	pusha
		call betterPaging.createPageDirectory
		call betterPaging.doIdentityMapAllMemory
		call betterPaging.enablePaging
	popa
	ret

betterPaging.enablePaging :
	pusha
		
		mov eax, [Paging.directory]
		mov cr3, eax
		
		mov eax, cr0
		or eax, 0x80000000
		mov cr0, eax
	
	popa
	ret

betterPaging.createPageDirectory :
	pusha
		mov al, 0xFE
		mov ebx, 0x1
		call Guppy.malloc	; alloc space for the page directory
		mov [Paging.directory], ebx
		test ebx, 0xFFF
			jnz .haltNotPageAligned
		
		mov edx, 1024
		.loop :
		mov dword [ebx], 0x00000002
		add ebx, 4
		dec edx
		cmp edx, 0
			jg .loop
	popa
	ret
	
	.haltNotPageAligned :
		mov eax, SysHaltScreen.KILL
		mov ebx, .MESSAGE
		mov ecx, 5
		call SysHaltScreen.show
	.MESSAGE :
		db "Paging directory not page-aligned.", 0x0

betterPaging.createPageTable :
	pusha
		mov al, 0xFE
		mov ebx, 0x1
		call Guppy.malloc	; alloc space for the page directory
		mov [Paging.newestPage], ebx
		test ebx, 0xFFF
			jnz .haltNotPageAligned
	popa
	ret

	.haltNotPageAligned :
		mov eax, SysHaltScreen.KILL
		mov ebx, .MESSAGE
		mov ecx, 5
		call SysHaltScreen.show
	.MESSAGE :
		db "Paging table not page-aligned.", 0x0

betterPaging.addTableToDirectory :
	pusha
		mov eax, [Paging.pageNumber]
		shl eax, 2
		add eax, [Paging.directory]
		mov ebx, [Paging.newestPage]
		or ebx, 3
		mov [eax], ebx
	popa
	ret
	
betterPaging.doIdentityMapAllMemory :
	pusha
		
		xor ebx, ebx
		mov dword [Paging.pageNumber], 0x0
		
		mov dword [.endThresh], 0x0
		
		.outerLoop :
		
			call betterPaging.createPageTable
			mov eax, [Paging.newestPage]
			xor ecx, ecx
			
			.loop :
				mov edx, ecx
				imul edx, 0x1000
				or edx, 3
				add edx, ebx
				mov dword [eax], edx
				add eax, 4
				inc ecx
				cmp ecx, 1024
					jl .loop
			
			call betterPaging.addTableToDirectory
			
			inc dword [Paging.pageNumber]
			
			add ebx, 0x1000*1024
		
			cmp ebx, [.endThresh]
				jne .outerLoop
	popa
	ret
	.endThresh :
		dd 0x0

Paging.newestPage :
	dd 0x0
Paging.pageNumber :
	dd 0x0