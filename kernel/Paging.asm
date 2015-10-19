Paging.init :
pusha

	mov al, 0xFE
	mov ebx, 0x1
	call Guppy.malloc	; alloc space for the page directory
	mov [Paging.directory], ebx
	
	mov eax, 0x0
	Paging.init.setClearLoop :
	mov dword [ebx], 0x2
	add ebx, 4
	add eax, 1
	cmp eax, 0x400
		jl Paging.init.setClearLoop
	
	mov eax, 0x0
	mov ebx, 0x0
	call Paging.identityMapPage
	
	mov eax, [Paging.directory]
	mov cr3, eax
	
	mov eax, cr0
	or eax, 0x80000000
	;mov cr0, eax
	;cli
	;jmp Paging.ret
	;jmp $
popa	
ret

Paging.identityMapPage :
pusha
	mov [Paging.moffs], eax
	mov [Paging.doffs], ebx
	
	mov al, 0xFE
	mov ebx, 0x1
	call Guppy.malloc	; alloc space for the first page table
	mov [Paging.page], ebx
	
	;mov ebx, [Paging.page]
	mov eax, 0x0
	Paging.init.mapFirstPage :
	mov ecx, eax
	imul ecx, 0x1000
	add ecx, [Paging.moffs]
	or ecx, 0b111
			mov [P.ledat], ecx
			mov [P.lepos], ebx
	mov [ebx], ecx
	add ebx, 4
	add eax, 1
	cmp eax, 0x400
		jl Paging.init.mapFirstPage
	
	mov ecx, [Paging.page]
	or ecx, 0b111
	mov edx, [Paging.directory]
	add edx, [Paging.doffs]
		mov [P.dedat], ecx
		mov [P.depos], edx
	mov [edx], ecx
popa
ret

_PAGEFAULT :
pop dword [Paging.faultCode]
pusha
	; handle things in here
	hlt
	jmp $
popa
iret
	
Paging.directory :
dd 0x0
Paging.page :
dd 0x0
Paging.faultCode :
dd 0x0
Paging.moffs :
dd 0x0
Paging.doffs :
dd 0x0

P.ledat :
dd 0x0
P.lepos :
dd 0x0
P.dedat :
dd 0x0
P.depos :
dd 0x0