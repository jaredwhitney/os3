Minnow4.COMMAND_DO_TEST :
dd Minnow4.STR_DO_TEST
dd Minnow4.doTest
dd null
Minnow4.doTest :
	enter 0, 0
	
		mov eax, Minnow4.doTest.fileName
		call Minnow4.createFile
		
		mov ecx, [Dolphin2.flipBuffer]
		mov edx, [Graphics.SCREEN_WIDTH]
		imul edx, [Graphics.SCREEN_HEIGHT]
		call Minnow4.writeBuffer
		
	leave
	ret 0
Minnow4.STR_DO_TEST :
	db "screenshot", null
Minnow4.doTest.fileName :
	db "screenshot.rawimage", null

Minnow4.COMMAND_VIEW_IMAGE :
dd Minnow4.STR_VIEW_IMAGE
dd Minnow4.viewImage
dd null
Minnow4.viewImage :
	enter 0, 0
		mov eax, [ebp+8]
		call Minnow4.getFilePointer
		mov ecx, [Graphics.SCREEN_MEMPOS]
		mov edx, [Graphics.SCREEN_WIDTH]
		imul edx, [Graphics.SCREEN_HEIGHT]
		call Minnow4.readBuffer
		;mov eax, 5000*2
		;call System.sleep
		mov ebx, [Dolphin2.compositorGrouping]
		call Grouping.DoUpdate
	leave
	ret 4
Minnow4.STR_VIEW_IMAGE :
	db "vimg", null

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
			mov eax, 0x7
			mov ebx, 1
			call Guppy.malloc
			mov [Minnow4.setupFileBlock.data], ebx
			add ebx, 0x200
			mov [Minnow4.getNextFileBlock.data], ebx
		push dword Minnow4.COMMAND_DO_TEST
		call iConsole2.RegisterCommand
		push dword Minnow4.COMMAND_VIEW_IMAGE
		call iConsole2.RegisterCommand
		mov dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
	popa
	ret

Minnow4.reformatDisk :
	pusha
		mov ebx, 0x200
		mov eax, [Minnow4.readBlock.data]
		call Buffer.clear
		mov dword [eax], Minnow4_BlockDescriptor.INDEX_IS_NAMELIST
		mov eax, 0x0
		mov ecx, [Minnow4.readBlock.data]
		call Minnow4.writeBlock
		mov eax, [Minnow4.readBlock.data]
		mov dword [eax], null
		mov eax, 0x1
		mov ecx, [Minnow4.readBlock.data]
		Minnow4.reformatDisk.loop :
		call Minnow4.writeBlock
		add eax, 1
		cmp eax, [Minnow4.fs_size]
			jb Minnow4.reformatDisk.loop
	popa
	ret

Minnow4.createFile :	; eax = String name : returns eax = int block
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	push ecx
	push ebx
		mov ecx, eax
		call Minnow4.getFilePointer
		cmp ebx, Minnow4.FILE_NOT_FOUND
			jne Minnow4.createFile.ret
		mov eax, ecx
		call Minnow4.registerName
		call Minnow4.getFirstOpenBlock
		call Minnow4.registerPositionFromName
		call Minnow4.setupFileBlock
		mov eax, ecx
	Minnow4.createFile.ret :
	pop ebx
	pop ecx
	ret

Minnow4.getFilePointer :	; eax = String name : returns eax = int block, ebx = int errorCode
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	push edx
	push ecx
		mov [Minnow4.getFilePointer.name], eax
		mov eax, [Minnow4.readBlock.data]
		add eax, 0x200
		mov [Minnow4.getFilePointer.threshold], eax
		xor ecx, ecx
		Minnow4.getFilePointer.fetchNameBlock :
		mov eax, ecx
		push ecx
		call Minnow4.readFileBlock
		mov eax, ecx
		pop ecx
		Minnow4.getFilePointer.searchBlock :
		mov ebx, [Minnow4.getFilePointer.name]
		push eax
		xchg eax, ebx	; because os.seq is horrible
		call os.seq
		cmp al, 0x1
		pop eax
			je Minnow4.getFilePointer.fileFound
		mov ebx, eax
		call String.getLength
		add eax, edx
		add eax, 4
		cmp eax, [Minnow4.getFilePointer.threshold]
			jl Minnow4.getFilePointer.searchBlock
		mov ecx, [Minnow4.readBlock.data]
		add ecx, Minnow4_BlockDescriptor_nextPointer
		cmp dword [ecx], null
			jne Minnow4.getFilePointer.fetchNameBlock
		mov ebx, Minnow4.FILE_NOT_FOUND
		mov eax, null
	pop ecx
	pop edx
	ret
	Minnow4.getFilePointer.fileFound :
		mov ebx, eax
		call String.getLength
		add eax, edx
		mov eax, [eax]
		mov ebx, Minnow4.SUCCESS
	pop ecx
	pop edx
	ret
Minnow4.getFilePointer.name :
	dd 0x0
Minnow4.getFilePointer.threshold :
	dd 0x0

Minnow4.readFileBlock :	; eax = int block : returns ecx = Buffer data
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
		mov ecx, [Minnow4.readBlock.data]
		call Minnow4.readBlock
		add ecx, Minnow4.BLOCK_DESCRIPTOR_SIZE
	ret

Minnow4.writeFileBlock :	; eax = int block, ecx = Buffer data (of size 0x200-Minnow4.BLOCK_DESCRIPTOR_SIZE)
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		mov [Minnow4.writeFileBlock.block], eax
		mov edx, ecx
		call Minnow4.readFileBlock
		sub ecx, Minnow4.BLOCK_DESCRIPTOR_SIZE
		cmp dword [ecx+Minnow4_BlockDescriptor_nextPointer], Minnow4_BlockDescriptor.INDEX_BLOCK_UNUSED
			jne .dontAllocNew
		mov eax, ecx
		call Minnow4.getFirstOpenBlock
		mov dword [eax+Minnow4_BlockDescriptor_stringIndex], Minnow4_BlockDescriptor.INDEX_FILE_DATA
		mov [eax+Minnow4_BlockDescriptor_nextPointer], ecx
		call Minnow4.setupFileBlock
		mov ecx, eax
		.dontAllocNew :
		; copy buffer from edx into ecx
		push ecx
		add ecx, Minnow4.BLOCK_DESCRIPTOR_SIZE
		mov ebx, 0x200-Minnow4.BLOCK_DESCRIPTOR_SIZE
		.loop :
		mov eax, [edx]
		mov [ecx], eax
		sub ebx, 4
		add edx, 4
		add ecx, 4
		cmp ebx, 0x0
			jg .loop
		mov eax, [Minnow4.writeFileBlock.block]
		pop ecx
		call Minnow4.writeBlock
	popa
	ret
Minnow4.writeFileBlock.block :
	dd 0x0

Minnow4.writeBuffer :	; eax = int block, ecx = Buffer data, edx = int byteSize
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		Minnow4.writeBuffer.loop :
		call Minnow4.writeFileBlock
		call Minnow4.getNextFileBlock
		add ecx, 0x200-Minnow4.BLOCK_DESCRIPTOR_SIZE
		sub edx, 0x200-Minnow4.BLOCK_DESCRIPTOR_SIZE
		cmp edx, 0x0
			jg Minnow4.writeBuffer.loop
	popa
	ret

Minnow4.readBuffer :	; eax = int block, ecx = Buffer data, edx = int byteSize : returns ecx = Buffer data
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		mov [Minnow4.readBuffer.data], ecx
		mov [Minnow4.readBuffer.byteSize], edx
		mov edx, [Minnow4.readBuffer.data]
		Minnow4.readBuffer.loop :
		call Minnow4.readFileBlock
		mov ebx, 0x200-Minnow4.BLOCK_DESCRIPTOR_SIZE
		push eax
		.copyDataLoop :
		mov eax, [ecx]
		mov [edx], eax
		sub dword [Minnow4.readBuffer.byteSize], 4
		cmp dword [Minnow4.readBuffer.byteSize], 0x0
			jle Minnow4.readBuffer.ret
		sub ebx, 4
		add ecx, 4
		add edx, 4
		cmp ebx, 0x0
			jg .copyDataLoop
		pop eax
		call Minnow4.getNextFileBlock
		jmp Minnow4.readBuffer.loop
	Minnow4.readBuffer.ret :
	pop eax
	popa
	ret
Minnow4.readBuffer.data :
	dd 0x0
Minnow4.readBuffer.byteSize :
	dd 0x0

Minnow4.renameFile :	; eax = int block, ebx = String newName
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		
	popa
	ret

Minnow4.deleteFile :	; eax = int block
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		
	popa
	ret
	
Minnow4.registerName :	; eax = String name
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		mov [Minnow4.registerName.name], eax
			pusha
				mov ebx, eax
				call String.getLength
				mov ecx, edx
				mov edx, [Minnow4.readBlock.data]
				add edx, 0x200
				sub edx, ecx
				sub edx, 4	; space for the position
				mov [Minnow4.registerName.threshold], edx
			popa
		xor eax, eax
		Minnow4.registerName.fetchNameBlock :
		call Minnow4.readFileBlock
		Minnow4.registerName.searchBlock :
		mov ebx, [ecx]
		cmp ebx, null
			je Minnow4.registerName.foundEndOfList
		mov ebx, ecx
		call String.getLength
		add ecx, edx
		add ecx, 4
		cmp ecx, [Minnow4.registerName.threshold]
			jb Minnow4.registerName.searchBlock
		mov eax, [Minnow4.readBlock.data]
		add eax, Minnow4_BlockDescriptor_nextPointer
		cmp ecx, null
			jne Minnow4.registerName.fetchNameBlock
		call Minnow4.registerName.createNewNameBlock	; return block in eax, offs+[Minnow4.readBlock.data] in ecx
		Minnow4.registerName.foundEndOfList :
		push eax
		mov eax, [Minnow4.registerName.name]
		mov ebx, ecx
		call String.copy
		pop eax
		mov ecx, [Minnow4.readBlock.data]
		call Minnow4.writeBlock
	popa
	ret
	Minnow4.registerName.createNewNameBlock	: ; return block in eax, offs+[Minnow4.readBlock.data] in ecx
		call Minnow4.getFirstOpenBlock
		mov eax, ecx
		mov ecx, [Minnow4.readBlock.data]
		add ecx, Minnow4.BLOCK_DESCRIPTOR_SIZE
	ret
Minnow4.registerName.name :
	dd 0x0
Minnow4.registerName.threshold :
	dd 0x0

Minnow4.registerPositionFromName :	; eax = String name, ecx = int block
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		mov [Minnow4.registerPositionFromName.name], eax
		mov [Minnow4.registerPositionFromName.block], ecx
		mov eax, [Minnow4.readBlock.data]
		add eax, 0x200
		mov [Minnow4.registerPositionFromName.threshold], eax
		xor ecx, ecx
		Minnow4.registerPositionFromName.fetchNameBlock :
		mov eax, ecx
		push ecx
		call Minnow4.readFileBlock
		mov eax, ecx
		pop ecx
		Minnow4.registerPositionFromName.searchBlock :
		mov ebx, [Minnow4.registerPositionFromName.name]
		push ax
		call os.seq
		cmp al, 0x1
		pop ax
			je Minnow4.registerPositionFromName.fileFound
		mov ebx, eax
		call String.getLength
		add eax, edx
		add eax, 4
		cmp eax, [Minnow4.registerPositionFromName.threshold]
			jb Minnow4.registerPositionFromName.searchBlock
		mov ecx, [Minnow4.readBlock.data]
		add ecx, Minnow4_BlockDescriptor_nextPointer
		cmp ecx, null
			jne Minnow4.registerPositionFromName.fetchNameBlock
	popa	; something went horribly wrong... D:
	ret
		Minnow4.registerPositionFromName.fileFound :
		mov ebx, eax
		call String.getLength
		add eax, edx
		push edx
		mov edx, [Minnow4.registerPositionFromName.block]
		mov [eax], edx
		pop edx
		mov eax, ecx
		mov ecx, [Minnow4.readBlock.data]
		call Minnow4.writeBlock
	popa
	ret
Minnow4.registerPositionFromName.name :
	dd 0x0
Minnow4.registerPositionFromName.block :
	dd 0x0
Minnow4.registerPositionFromName.threshold :
	dd 0x0

Minnow4.setupFileBlock :	; eax = String name, ecx = int block
	pusha
		; should actually store name in file block!
		mov eax, ecx
		mov ecx, [Minnow4.setupFileBlock.data]
		call Minnow4.readBlock
		mov dword [ecx+Minnow4_BlockDescriptor_stringIndex], Minnow4_BlockDescriptor.INDEX_FILE_END
		call Minnow4.writeBlock
	popa
	ret
Minnow4.setupFileBlock.data :
	dd 0x0

Minnow4.getNextFileBlock :	; eax = int block : returns eax = int newBlock
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	push ecx
		mov ecx, [Minnow4.getNextFileBlock.data]
		call Minnow4.readBlock
		mov eax, [ecx+Minnow4_BlockDescriptor_nextPointer]
	pop ecx
	ret
Minnow4.getNextFileBlock.data :
	dd 0x0

Minnow4.getFirstOpenBlock :	; returns ecx = int block
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	push eax
		mov eax, [Minnow4.getFirstOpenBlock.lastFree]
		mov ecx, [Minnow4.readBlock.data]
		Minnow4.getFirstOpenBlock.keepSearching :
		call Minnow4.readBlock
		cmp dword [ecx+Minnow4_BlockDescriptor_stringIndex], Minnow4_BlockDescriptor.INDEX_BLOCK_UNUSED
			je Minnow4.getFirstOpenBlock.ret
		add eax, 1
		jmp Minnow4.getFirstOpenBlock.keepSearching
		Minnow4.getFirstOpenBlock.ret :
		mov ecx, eax
		add eax, 1
		mov [Minnow4.getFirstOpenBlock.lastFree], eax
	pop eax
	ret
Minnow4.getFirstOpenBlock.lastFree :
	dd 0x0

Minnow4.readBlock :	; eax = int block, ecx = Buffer buffer : returns ecx = Buffer data
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		add eax, [Minnow4.fs_base]
		cmp eax, [Minnow4.fs_base]
			jb Minnow4.readBlock.ret	; should throw some warning...
		cmp eax, [Minnow4.fs_limit]
			jae Minnow4.readBlock.ret	; should throw some warning...
		xor bx, bx
		adc bx, 0	; add overflow to bx
		mov edx, 0x200
		call AHCI.DMAreadToBuffer
	Minnow4.readBlock.ret :
	popa
	ret
Minnow4.readBlock.data :
	dd 0x0

Minnow4.writeBlock :	; eax = int block, ecx = Buffer buffer
	cmp dword [Minnow4.STATUS], Minnow4.INIT_FINISHED
		jne Minnow4.kGoRet
	pusha
		add eax, [Minnow4.fs_base]
		cmp eax, [Minnow4.fs_base]
			jb Minnow4.writeBlock.ret	; should throw some warning...
		cmp eax, [Minnow4.fs_limit]
			jae Minnow4.writeBlock.ret	; should throw some warning...
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
Minnow4_BlockDescriptor.INDEX_IS_NAMELIST	equ 0xFFFFFFFC
Minnow4_BlockDescriptor.INDEX_BLOCK_UNUSED	equ null

Minnow4.UNMOUNTED		equ 0x0
Minnow4.INIT_FINISHED	equ 0x1
Minnow4.MOUNT_FAILED	equ 0x2

Minnow4.SUCCESS			equ 0x1
Minnow4.FILE_NOT_FOUND	equ 0x2

Minnow4.STATUS :
	dd Minnow4.UNMOUNTED
Minnow4.fs_base :
	dd 0x0
Minnow4.fs_size :
	dd 0x0
Minnow4.fs_limit :
	dd 0x0
