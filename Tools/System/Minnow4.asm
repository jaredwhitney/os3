Minnow4.init :
	pusha
		mov al, [AHCI_STATUS]
		cmp al, 0x0
			je Minnow4.init.ret
		xor eax, eax
		xor ebx, ebx
		mov edx, 0x200
		call AHCI.DMAread
		mov [Minnow4.readBlock.data], ecx
		add ecx, 0x1BE
		mov edx, 4
		Minnow4.init.partitionLookupLoop :
		add ecx, 4
		mov bl, [ecx]
		cmp bl, UFSS.FILESYSTEM_MFS
			je Minnow4.init.goMount
		add ecx, 12
		sub edx, 1
		cmp edx, 0x0
			jg Minnow4.init.partitionLookupLoop
	Minnow4.init.ret :
	mov dword [Minnow4.STATUS], Minnow4.MOUNT_FAILED
	popa
	Minnow4.kGoRet :
	ret
	Minnow4.init.goMount :
		add ecx, 4
		mov ebx, [ecx]
		add ebx, 1
		mov [Minnow4.fs_base], ebx
		add ecx, 4
		mov ebx, [ecx]
		mov [Minnow4.fs_size], ebx
		mov eax, [Minnow4.fs_base]
		add eax, [Minnow4.fs_size]
		mov [Minnow4.fs_limit], eax
		mov dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
	popa
	ret

Minnow4.createFile :	; eax = String name
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		mov ecx, eax
		call Minnow4.getFilePointer
		cmp ebx, Minnow4.FILE_NOT_FOUND
			jne Minnow4.createFile.ret
		mov eax, ecx
		call Minnow4.registerName
	Minnow4.createFile.ret :
	popa
	ret

Minnow4.getFilePointer :	; eax = String name : returns eax = int block, ebx = int errorCode
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		mov ebx, eax
		mov eax, 0x0
		call Minnow4.readFileBlock
		mov eax, [Minnow4.readBlock.data]
		call os.seq
		cmp al, 0x1
			je Minnow4.getFilePointer.fileFound
		mov ebx, eax
		call String.getLength
		add eax, ebx
		; TODO: Finish implementing this!
	popa
	ret

Minnow4.readFileBlock :	; eax = int block : returns ecx = Buffer data
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
		mov ecx, [Minnow4.readBlock.data]
		call Minnow4.readBlock
		add ecx, Minnow4.BLOCK_DESCRIPTOR_SIZE
	ret

Minnow4.writeFileBlock :
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		
	popa
	ret

Minnow4.writeBuffer :
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		
	popa
	ret

Minnow4.readBuffer :
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		
	popa
	ret

Minnow4.renameFile :
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		
	popa
	ret

Minnow4.deleteFile :
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		
	popa
	ret
	
Minnow4.registerName :	; eax = String name
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		
	popa
	ret

Minnow4.getNextFileBlock :
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		
	popa
	ret

Minnow4.getLastNameBlock :
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		
	popa
	ret

Minnow4.getFirstOpenBlock :
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		
	popa
	ret

Minnow4.readBlock :	; eax = int block, ecx = Buffer buffer : returns ecx = Buffer data
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		add eax, [Minnow4.fs_base]
		cmp eax, [Minnow4.fs_base]
			jl Minnow4.readBlock.ret	; should throw some warning...
		cmp eax, [Minnow4.fs_limit]
			jge Minnow4.readBlock.ret	; should throw some warning...
		xor bx, bx
		adc bx, 0	; add overflow to bx
		mov edx, 0x200
		call AHCI.DMAreadToBuffer
	Minnow4.readBlock.ret :
	popa
	ret

Minnow4.writeBlock :	; eax = int block, ecx = Buffer buffer
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		add eax, [Minnow4.fs_base]
		cmp eax, [Minnow4.fs_base]
			jl Minnow4.writeBlock.ret	; should throw some warning...
		cmp eax, [Minnow4.fs_limit]
			jge Minnow4.writeBlock.ret	; should throw some warning...
		xor bx, bx
		adc bx, 0	; add overflow to bx
		mov edx, 0x200
		call AHCI.DMAwrite
	Minnow4.writeBlock.ret :
	popa
	ret

UFSS.FILESYSTEM_MFS				equ 0x30	; Declaration should be moved to UFSS file.

Minnow4.BLOCK_DESCRIPTOR_SIZE		equ 3*4
Minnow4_BlockDescriptor_stringIndex	equ 0
Minnow4_BlockDescriptor_nextPointer	equ 4
Minnow4_BlockDescriptor_RESERVED	equ 8	; likely will be used for directory listing

Minnow4_BlockDescriptor.INDEX_FILE_DATA		equ 0xFFFFFFFF
Minnow4_BlockDescriptor.INDEX_FILE_END		equ 0xFFFFFFFE
Minnow4_BlockDescriptor.INDEX_FILE_DELETED	equ 0xFFFFFFFD
Minnow4_BlockDescriptor.INDEX_BLOCK_UNUSED	equ null

Minnow4.UNMOUNTED		equ 0x0
Minnow4.INIT_FINISHED	equ 0x1
Minnow4.MOUNT_FAILED	equ 0x2

Minnow4.STATUS :
	dd Minnow4.UNMOUNTED
Minnow4.fs_base :
	dd 0x0
Minnow4.fs_size :
	dd 0x0
Minnow4.fs_limit :
	dd 0x0
