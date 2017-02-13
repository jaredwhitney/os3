;BOOT BLOCK
;	jmp short __
;	nop
;	dd "MINFS5.0"

;DISK BLOCK
;	dd "MINFS5.0"
;	dd 0xDEADD15C
;	dd null
;	dd DISK_DESCRIPTOR
;	dd diskSize
;	dd rootFolderPointer
;	dd attribs
;	db... disk nice name

;FOLDER BLOCK
;	dd "MINFS5.0"
;	dd nextObjectPointer
;	dd upperPointer
;	dd FOLDER_BLOCK
;	dd fileCount
;	dd firstFilePointer
;	dd attribs
;	db... folder nice name

;FILE BLOCK
;	dd "MINFS5.0"
;	dd nextObjectPointer
;	dd upperPointer
;	dd FILE_BLOCK
;	dd dataSize
;	dd firstDataPointer
;	dd attribs
;	db... file nice name

;DATA BLOCK
;	dd "MINFS5.0"
;	dd nextObjectPointer
;	dd upperPointer
;	dd DATA_BLOCK
;	db... data

; attribs	[see list at the bottom of the file]
;	0: unreadable?
;	1: unwriteable?
;	

Minnow5.preinit :
	methodTraceEnter
	pusha
	
		push dword Minnow5.COMMAND_LIST_DISK
		call iConsole2.RegisterCommand
	
	popa
	methodTraceLeave
	ret

Minnow5.init :
	methodTraceEnter
	pusha
	
		; alloc some space for temp reads if not already alloc'd
		cmp dword [Minnow5._dat], null
			jne .noalloc
		mov ebx, 0x203	; 0x200 (block size) + 3 (safe dword writes)
		call Guppy2.malloc
		mov [Minnow5._dat], ebx
		mov eax, 0
		mov bx, 0
		mov edx, 0x200
		call AHCI.DMAread	; baaaaad! (but works!)
		.noalloc :
		
		call Minnow5.checkDisk
		cmp dword [Minnow5.inited], true
			jne .aret
		call Minnow5.getRootFolder
		cmp eax, null
			je .dontGetRootFolderInfo
;		mov ebx, [Minnow5._dat]
;		call Minnow5.readBlock
;		mov ecx, ebx
;		add ecx, Minnow5.Block_namePtr
;		push ecx
;		call iConsole2.Echo
;		push dword .COMMA_SPACE_STR
;		call iConsole2.Echo
;		push dword [ebx+Minnow5.Block_fileCount]
;		call iConsole2.EchoDec
;		push dword .FILE_COUNT_STR
;		call iConsole2.Echo
;		push dword newlPointer
;		call iConsole2.EchoChar
		jmp .getRootFolderInfoDone
		.dontGetRootFolderInfo :
		push dword .NO_ROOT_FOLDER_FOUND_STR
		call iConsole2.Echo
		.getRootFolderInfoDone :
		
	.aret :
	popa
	methodTraceLeave
	ret
.NO_ROOT_FOLDER_FOUND_STR :
	db "No root folder present.", 0
.COMMA_SPACE_STR :
	db ", ", 0
.FILE_COUNT_STR :
	db " files", 0

Minnow5.checkDisk :
	methodTraceEnter
	pusha
		; load first sector
		; check for 0xEBxy90, "MINFS5.0"
		; if not found: give up; it is not a Minnow5 disk
		; search every sector afterwords until "MINFS5.0", 0xDEADD15C is found; OR give up if a certain limit is reached (eg:50M)
		; congratulations, you've found the disk block!
		mov dword [Minnow5.filesystemBase], 0	; this whole section is a really bad idea...
		mov dword [Minnow5.inited], true
		mov ebx, [Minnow5._dat]
		mov eax, 0
		call Minnow5.readBlock
		
		mov ecx, ebx
		cmp byte [ecx], 0xEB
			jne .noMatchBootsector
		add ecx, 2
		cmp byte [ecx], 0x90
			jne .noMatchBootsector
		add ecx, 1
		cmp dword [ecx], "MINF"
			jne .noMatchBootsector
		add ecx, 4
		cmp dword [ecx], Minnow5.SIGNATURE_HIGH
			jne .noMatchBootsector
		
		.searchLoop :
		inc eax
		cmp eax, 0x2000
			ja .noMatch
		call Minnow5.readBlock
		mov ecx, ebx
		cmp dword [ecx], "MINF"
			jne .searchLoop
		add ecx, 4
		cmp dword [ecx], Minnow5.SIGNATURE_HIGH
			jne .searchLoop
		add ecx, 4
		cmp dword [ecx], 0xDEADD15C
			jne .searchLoop
			
		mov [Minnow5.filesystemBase], eax
		mov ecx, [ebx+Minnow5.Block_byteSize]
		mov [Minnow5.filesystemSize], ecx
		
		; cannot really validate it with the signature, because if the signature wasn't correct there would have been no match...
		call Minnow5.validateAndRegenerateRootFolder
		
		.remergePoint :
		
	popa
	methodTraceLeave
	ret
	.noMatch :
	popa
	methodTraceLeave
	ret
		
	.noMatchBootsector :
		mov ecx, ebx
		add ecx, 0x1BE
		mov edx, 4
		.partitionLookupLoop :
		add ecx, 4
		mov bl, [ecx]
		cmp bl, Minnow5.MFS_PARTITION_CODE
			je .goMountFromPartition
		add ecx, 0xC
		dec edx
		cmp edx, 0x0
			ja .partitionLookupLoop
	mov dword [Minnow5.inited], false
	jmp .noMatch
	
	.goMountFromPartition :
	add ecx, 4
	mov ebx, [ecx]
	mov [Minnow5.filesystemBase], ebx
	add ecx, 4
	mov ebx, [ecx]
	mov [Minnow5.filesystemSize], ebx
	call Minnow5.validateAndRegenerateDiskBlock
	call Minnow5.validateAndRegenerateRootFolder
	jmp .remergePoint
	
newlPointer :
	db 0x0A

Minnow5.getDiskBlock : ; return in eax
	mov eax, -1
	cmp dword [Minnow5.inited], true
	jne .ret
		mov eax, 0
	.ret :
	ret

Minnow5.getRootFolder :	; return in eax
	methodTraceEnter
	mov eax, -1
	cmp dword [Minnow5.inited], true
	jne .ret
	push ebx
		mov eax, 0
		mov ebx, [Minnow5._dat]
		call Minnow5.readBlock
		mov eax, [ebx+Minnow5.Block_innerPointer]
	pop ebx
	.ret :
	methodTraceLeave
	ret
		
Minnow5.findFreeBlock :	; return in ebx
	methodTraceEnter
	push eax
		mov eax, -1
		.searchLoop :
		inc eax
		mov ebx, [Minnow5._dat]
		call Minnow5.readBlock
		cmp dword [ebx+Minnow5.Block_signatureLow], "MINF"
			jne .foundMatch
		cmp dword [ebx+Minnow5.Block_signatureHigh], Minnow5.SIGNATURE_HIGH
			je .searchLoop
		.foundMatch :
		mov ebx, eax
	pop eax
	methodTraceLeave
	ret

Minnow5.readBlock :	; eax = block, ebx = buffer
	methodTraceEnter
	cmp dword [Minnow5.inited], true
		jne .ret
	pusha
		add eax, [Minnow5.filesystemBase]
		cmp dword [Minnow5.interface], Minnow5.DRIVE_AHCI
			je Minnow5.readBlockAHCI
		mov [rmATAdata.lowP], eax
		mov dword [rmfunc], realModeAtaLoad
		call realModeExec
		mov esi, 0x7c00
		mov edi, ebx
		mov ecx, 0x200
		.copyLoop :
		mov edx, [esi]
		mov [edi], edx
		sub ecx, 4
		add esi, 4
		add edi, 4
		cmp ecx, 0
			ja .copyLoop
	.aret :
	popa
	.ret :
	methodTraceLeave
	ret
Minnow5.readBlockAHCI :
	mov ecx, ebx
	xor bx, bx
	adc bx, 0
	mov edx, 0x200
	call AHCI.DMAreadToBuffer
	jmp Minnow5.readBlock.aret

Minnow5.writeBlock :	; eax = block, ebx = buffer
	methodTraceEnter
	cmp dword [Minnow5.inited], true
		jne .ret
	pusha
		add eax, [Minnow5.filesystemBase]
		cmp dword [Minnow5.interface], Minnow5.DRIVE_AHCI
			je Minnow5.writeBlockAHCI
		mov esi, ebx
		mov edi, 0x7c00
		mov ecx, 0x200
		.copyLoop :
		mov edx, [esi]
		mov [edi], edx
		sub ecx, 4
		add esi, 4
		add edi, 4
		cmp ecx, 0
			ja .copyLoop
		mov [rmATAdata.lowP], eax
		mov dword [rmfunc], realModeAtaSave
		call realModeExec
	.aret :
	popa
	.ret :
	methodTraceLeave
	ret
Minnow5.writeBlockAHCI :
	mov ecx, ebx
	xor bx, bx
	adc bx, 0
	mov edx, 0x200
	call AHCI.DMAwriteNoAlloc
	jmp Minnow5.readBlock.aret

Minnow5.setInterface :	; eax = interface
	methodTraceEnter
	pusha
		;mov dword [Minnow5.inited], false ; sadly this still needs to stay inited...
		cmp eax, Minnow5.DRIVE_AHCI
			jne .noAHCIcheck
		mov bl, [AHCI_STATUS]
		cmp bl, 0x0
			je .rret
		.noAHCIcheck :
		mov [Minnow5.interface], eax
		call Minnow5.init
	.rret :
	popa
	methodTraceLeave
	ret
	
Minnow5.validateAndRegenerateDiskBlock :
	pusha
		call Minnow5.getDiskBlock
		mov ebx, [Minnow5._dat]
		call Minnow5.readBlock
		cmp dword [ebx+Minnow5.Block_signatureLow], "MINF"
			jne .needsRegen
		cmp dword [ebx+Minnow5.Block_signatureHigh], Minnow5.SIGNATURE_HIGH
			jne .needsRegen
		jmp .aret
		.needsRegen :
		mov dword [ebx+Minnow5.Block_signatureLow], "MINF"
		mov dword [ebx+Minnow5.Block_signatureHigh], Minnow5.SIGNATURE_HIGH
		mov dword [ebx+Minnow5.Block_discSignature], 0xDEADD15C
		mov dword [ebx+Minnow5.Block_type], Minnow5.BLOCK_TYPE_DISK
		; if [filesystemSize] is 0, set to -1 (filesystem covers the entire medium)
		mov ecx, [Minnow5.filesystemSize]
		cmp ecx, null
			jne .nfixnull
		mov ecx, -1
		mov [Minnow5.filesystemSize], ecx
		.nfixnull :
		mov [ebx+Minnow5.Block_byteSize], ecx
		mov dword [ebx+Minnow5.Block_innerPointer], null
		mov dword [ebx+Minnow5.Block_upperPointer], null
		mov dword [ebx+Minnow5.Block_attribs], 0
		mov dword [ebx+Minnow5.Block_namePtr+0x0], "GENE"
		mov dword [ebx+Minnow5.Block_namePtr+0x4], "RATE"
		mov dword [ebx+Minnow5.Block_namePtr+0x8], "D_DI"
		mov byte [ebx+Minnow5.Block_namePtr+0xC], "S"
		mov byte [ebx+Minnow5.Block_namePtr+0xD], "C"
		mov byte [ebx+Minnow5.Block_namePtr+0xE], 0
		call Minnow5.writeBlock
		push dword .NEEDED_TO_REGENERATE_DISK_BLOCK_STR
		call iConsole2.Echo
	.aret :
	popa
	ret
.NEEDED_TO_REGENERATE_DISK_BLOCK_STR :
	db "Minnow5 needed to regenerate a disk block (all files have been unlinked from the drive).", 0xA, 0
	
Minnow5.validateAndRegenerateRootFolder :
	methodTraceEnter
	pusha
		call Minnow5.getRootFolder
		cmp eax, null
			jne .allGood
		mov eax, [Minnow5.interface]
		mov [.driveFile+0x0], eax
		call Minnow5.getDiskBlock
		mov [.driveFile+0x4], eax
		mov eax, .driveFile
		mov ebx, .ROOT_FOLDER_NAME
		mov ecx, 0
		call Minnow5.makeFolder
	.allGood :
	popa
	methodTraceLeave
	ret
.ROOT_FOLDER_NAME :
	db "root", 0
.driveFile :
	dq 0x0

Minnow5.makeFolder :	; qword buffer (file) in eax, nameptr in ebx, attribs in ecx, returns eax = folderptr
	methodTraceEnter
	pusha
		push eax
		mov eax, [eax+0x0]	; drive
		call Minnow5.setInterfaceSmart
		pop eax
		mov eax, [eax+0x4]	; block
		mov dword [.base], eax
		mov dword [.attribs], ecx
		mov dword [.nameptr], ebx
		call Minnow5.findFreeBlock	; ebx = free block num
		mov dword [.block], ebx
		
		mov ebx, [Minnow5._dat]
		call Minnow5.readBlock	; base
		mov ecx, [.block]
		mov edx, [ebx+Minnow5.Block_innerPointer]
		mov [ebx+Minnow5.Block_innerPointer], ecx
		mov [.nextLinked], edx
		call Minnow5.writeBlock
		
		mov eax, [Minnow5._dat]
		mov ebx, 0x200
		call Buffer.clear
		
		mov dword [eax+Minnow5.Block_signatureLow], "MINF"
		mov dword [eax+Minnow5.Block_signatureHigh], Minnow5.SIGNATURE_HIGH
		mov ecx, [.nextLinked]
		mov dword [eax+Minnow5.Block_nextPointer], ecx
		mov dword [eax+Minnow5.Block_type], Minnow5.BLOCK_TYPE_FOLDER
		mov dword [eax+Minnow5.Block_fileCount], 0
		mov dword [eax+Minnow5.Block_innerPointer], null
		mov ecx, [.base]
		mov dword [eax+Minnow5.Block_upperPointer], ecx
		mov ecx, [.attribs]
		mov dword [eax+Minnow5.Block_attribs], ecx
		add eax, Minnow5.Block_namePtr
		mov ebx, [.nameptr]
		xchg eax, ebx
		call String.copy
		mov eax, [.block]
		mov ebx, [Minnow5._dat]
		call Minnow5.writeBlock
		
	popa
	mov eax, [.block]
	methodTraceLeave
	ret
	.base :
		dd 0x0
	.block :
		dd 0x0
	.nextLinked :
		dd 0x0
	.attribs :
		dd 0x0
	.nameptr :
		dd 0x0
	
Minnow5.makeFile :	; qword buffer (file) in eax, nameptr in ebx, attribs in ecx, returns eax=fileptr [should merge with makeFolder]
	methodTraceEnter
	pusha
		push eax
		mov eax, [eax+0x0]	; drive
		call Minnow5.setInterfaceSmart
		pop eax
		mov eax, [eax+0x4]	; block
		mov dword [.base], eax
		mov dword [.attribs], ecx
		mov dword [.nameptr], ebx
		call Minnow5.findFreeBlock
		mov dword [.block], ebx
		
		mov ebx, [Minnow5._dat]
		call Minnow5.readBlock	; base
		mov ecx, [.block]
		mov edx, [ebx+Minnow5.Block_innerPointer]
		mov [ebx+Minnow5.Block_innerPointer], ecx
		mov [.nextLinked], edx
		call Minnow5.writeBlock
		
		mov eax, [Minnow5._dat]
		mov ebx, 0x200
		call Buffer.clear
		
		mov dword [eax], "MINF"
		mov dword [eax+Minnow5.Block_signatureHigh], Minnow5.SIGNATURE_HIGH
		mov ecx, [.nextLinked]
		mov dword [eax+Minnow5.Block_nextPointer], ecx
		mov dword [eax+Minnow5.Block_type], Minnow5.BLOCK_TYPE_FILE
		mov dword [eax+Minnow5.Block_byteSize], 0
		mov dword [eax+Minnow5.Block_innerPointer], null
		mov ecx, [.base]
		mov dword [eax+Minnow5.Block_upperPointer], ecx
		mov ecx, [.attribs]
		mov dword [eax+Minnow5.Block_attribs], ecx
		add eax, Minnow5.Block_namePtr
		mov ebx, [.nameptr]
		xchg eax, ebx
		call String.copy
		mov eax, [.block]
		mov ebx, [Minnow5._dat]
		call Minnow5.writeBlock
	popa
	mov eax, [.block]
	methodTraceLeave
	ret
	.base :
		dd 0x0
	.block :
		dd 0x0
	.nextLinked :
		dd 0x0
	.attribs :
		dd 0x0
	.nameptr :
		dd 0x0
	
Minnow5.nameFile :	; qword buffer (file) in eax, nameptr in ebx
	pusha
		mov [.nameptr], ebx
		
		push eax
		mov eax, [eax+0x0]	; drive
		call Minnow5.setInterfaceSmart
		pop eax
		mov eax, [eax+0x4]	; block
		
		mov ebx, [Minnow5._dat]
		call Minnow5.readBlock
		
		mov ecx, ebx
		mov edx, eax
		
			add ebx, Minnow5.Block_namePtr
			mov eax, [.nameptr]
			call String.copy
		
		mov eax, edx
		mov ebx, ecx
		
		call Minnow5.writeBlock
	popa
	ret
	.nameptr :
		dd 0x0

Minnow5.getPathString :	; eax = qword buffer (file), ebx = buffer (string)
	pusha
	
		mov ecx, [eax+0x4]	; block
			mov eax, [eax+0x0]	; drive
			call Minnow5.setInterfaceSmart
		mov eax, ecx
		
		xor edx, edx
		mov [.strbuf], ebx
		
		.searchLoop :
		
			mov ebx, [Minnow5._dat]
			call Minnow5.readBlock
			
			cmp dword [ebx+Minnow5.Block_type], Minnow5.BLOCK_TYPE_FILE
				je .goPr
			cmp dword [ebx+Minnow5.Block_type], Minnow5.BLOCK_TYPE_FOLDER
				je .goPr
			cmp dword [ebx+Minnow5.Block_type], Minnow5.BLOCK_TYPE_DISK
				je .goPrDone
			jmp .noPr
			.goPr :
			push eax
			inc edx
			.noPr :
			mov eax, [ebx+Minnow5.Block_upperPointer]
			jmp .searchLoop
		
		.goPrDone :
		push eax
		inc edx
		
		
		mov ecx, edx	; number of blocks to print for in ecx
		mov dword [.offs], 0
		
		.printLoop :
			
			pop eax	; current block
			dec ecx
			
			mov ebx, [Minnow5._dat]
			call Minnow5.readBlock
			
		;	mov ebx, eax
			add ebx, Minnow5.Block_namePtr
			call String.getLength	; len in edx
			
			mov eax, ebx
			mov ebx, [.strbuf]
			add ebx, [.offs]
			call String.copy
			
			mov byte [ebx+edx-1], '/'
			cmp dword [.offs], 0
				jne .noChange
			mov byte [ebx+edx-1], ':'
			.noChange :
			
			add [.offs], edx
			
			cmp ecx, 0
				ja .printLoop
			
			mov byte [ebx+edx-1], 0
		
	popa
	ret
	.offs :
		dd 0x0
	.strbuf :
		dd 0x0
	
Minnow5.setInterfaceSmart :	; interface in eax
	ret
	pusha
		cmp eax, [Minnow5.interface]
			je .noswap
		call Minnow5.setInterface
		cmp eax, Minnow5.DRIVE_LEGACY_BIOS
			jne .noPS2fix
	;	call Keyboard.poll
		.noPS2fix :
	.noswap :
	popa
	ret

Minnow5.COMMAND_LIST_DISK :
	dd .str
	dd Minnow5.listDisks
	dd null
	.str :
		db "ldisk", 0
Minnow5.listDisks :
	methodTraceEnter
	enter 0, 0
	pusha
		
		mov edx, 0
		
		.loop :
			mov eax, edx
			call Minnow5.setInterfaceSmart
			
			call Minnow5.getDiskBlock
			mov ebx, [Minnow5._dat]
			call Minnow5.readBlock
			
			add ebx, Minnow5.Block_namePtr
			push ebx
			call iConsole2.Echo
			
			push .commastr
			call iConsole2.Echo
			
			inc edx
			cmp edx, Minnow5.NUMBER_OF_INTERFACES
				jb .loop
		
	popa
	leave
	methodTraceLeave
	ret 0
	.commastr :
		db ", ", 0

Minnow5.getDiskByName :	; name in eax, return disk in eax
	methodTraceEnter
	enter 0, 0
	push edx
	push ecx
	push ebx
		mov ecx, eax
		
		mov edx, 0
		
		.loop :
			mov eax, edx
			call Minnow5.setInterfaceSmart
			
			call Minnow5.getDiskBlock
			mov ebx, [Minnow5._dat]
			call Minnow5.readBlock
			
			add ebx, Minnow5.Block_namePtr
			mov eax, ecx
			call os.seq
			cmp al, 1
				jne .nomatch
			
				jmp .aret
			
			.nomatch :
			inc edx
			cmp edx, Minnow5.NUMBER_OF_INTERFACES
				jb .loop
		
		mov edx, -1
		.aret :
		mov eax, edx
	pop ebx
	pop ecx
	pop edx
	leave
	methodTraceLeave
	ret 0

Minnow5.getBlockByName :	; root in eax, name in ebx, drive in ecx, return block in eax
	methodTraceEnter
	enter 0, 0
	push edx
	push ecx
	push ebx
		mov [.root], eax	; edx is root
		mov [.name], ebx	; name is ebx
		mov eax, [Minnow5.interface]
		
		mov eax, ecx
		call Minnow5.setInterfaceSmart
		
		
		mov eax, [.root]
		mov ebx, [Minnow5._dat]
		call Minnow5.readBlock
		
		mov eax, [.name]
		cmp byte [eax], '^'	; upper folder
			jne .notUpper
		
				mov eax, [ebx+Minnow5.Block_upperPointer]
				jmp .aret
		
		.notUpper :
		
		mov eax, [.name]
		cmp byte [eax], '.'	; current folder
			jne .notCurrent
				
				mov eax, [.root]
				jmp .aret
		
		.notCurrent :
		
		mov eax, [ebx+Minnow5.Block_innerPointer]
		
		cmp eax, null
			jne .innerFound
		mov eax, -1
		jmp .aret
		.innerFound :
		
		.checkLoop :
		call Minnow5.readBlock
		
			push eax
			push ebx
			
				mov eax, [.name]
				add ebx, Minnow5.Block_namePtr
				call os.seq
				cmp al, 1
					jne .nomatch
					
					pop ebx
					pop eax
					jmp .aret
			
				.nomatch :
				
			pop ebx
			pop eax
		
		mov eax, [ebx+Minnow5.Block_nextPointer]
		cmp eax, null
			jne .checkLoop
		
		mov eax, -1
		.aret :
	pop ebx
	pop ecx
	pop edx
	leave
	methodTraceLeave
	ret 0
	.name :
		dd 0x0
	.root :
		dd 0x0

Minnow5.getNext :	; block in eax, drive in ebx, return block in eax
	methodTraceEnter
	enter 0, 0
	push edx
	push ecx
	push ebx
		mov edx, eax	; edx is root
	;	mov eax, [Minnow5.interface]
		
		mov eax, ebx
		call Minnow5.setInterfaceSmart
		
		
		mov eax, edx
		mov ebx, [Minnow5._dat]
		call Minnow5.readBlock
		
		mov eax, [ebx+Minnow5.Block_nextPointer]
		
		.aret :
	pop ebx
	pop ecx
	pop edx
	leave
	methodTraceLeave
	ret 0

Minnow5.getInner :	; block in eax, drive in ebx, return block in eax
	methodTraceEnter
	enter 0, 0
	push edx
	push ecx
	push ebx
		mov edx, eax	; edx is root
		mov eax, [Minnow5.interface]
		
		mov eax, ebx
		call Minnow5.setInterfaceSmart
		
		
		mov eax, edx
		mov ebx, [Minnow5._dat]
		call Minnow5.readBlock
		
		mov eax, [ebx+Minnow5.Block_innerPointer]
		
		.aret :
	pop ebx
	pop ecx
	pop edx
	leave
	methodTraceLeave
	ret 0
	
Minnow5.getSize :	; block in eax, drive in ebx, return size in eax
	methodTraceEnter
	enter 0, 0
	push edx
	push ecx
	push ebx
		mov edx, eax	; edx is root
		mov eax, [Minnow5.interface]
		
		mov eax, ebx
		call Minnow5.setInterfaceSmart
		
		
		mov eax, edx
		mov ebx, [Minnow5._dat]
		call Minnow5.readBlock
		
		mov eax, [ebx+Minnow5.Block_byteSize]
		
	.aret :
	pop ebx
	pop ecx
	pop edx
	leave
	methodTraceLeave
	ret 0
	
Minnow5.getBlockName :	; block in eax, drive in ebx, string buffer in ecx
	methodTraceEnter
	pusha
		mov edx, eax	; edx is root
		
		mov eax, ebx
		call Minnow5.setInterfaceSmart
		
		
		mov eax, edx
		mov ebx, [Minnow5._dat]
		call Minnow5.readBlock
		
		mov eax, ebx
		add eax, Minnow5.Block_namePtr
		mov ebx, ecx
		call String.copy

	popa
	methodTraceLeave
	ret

Minnow5.byName :	; name in eax, qword buffer in/out in ebx. if ebx:drive or ebx:file is not null or -1, they will be used as a base (if not over-ridden)
	methodTraceEnter
	pusha
		mov [.base], eax
		mov byte [.done], false
		
		push eax
		mov eax, [Minnow5.interface]
		
		mov eax, [ebx+0x0]	; drive specified
		cmp eax, -1
			je .noset
		call Minnow5.setInterfaceSmart
		.noset :
		pop eax

		.delimsLoop :

			cmp byte [eax], ':'
				jne .notDrive
				
				mov byte [eax], 0
				push eax
				mov eax, [.base]
				call Minnow5.getDiskByName
				mov [ebx+0x0], eax	; set drive of the return
				mov dword [ebx+0x4], null	; ignore any specified file base, b/c drive was present this must be a FULL path
				pop eax
				inc eax
				mov [.base], eax
				dec eax
				mov byte [eax], ':'
				cmp dword [ebx+0x0], -1	; return if drive not found
					je .ret
				cmp byte [eax+1], 0
					jne .notDriveOnly
				mov dword [ebx+0x4], null
				jmp .ret
				.notDriveOnly :
					
				jmp .nextIter
				
			.notDrive :
			
			cmp byte [eax], '/'
				je .pathMark
			cmp byte [eax], 0
				jne .notPathMark
				
				mov byte [.done], true
				.pathMark :
				mov byte [eax], 0
				push eax
				
				mov eax, [ebx+0x4]	; current block
				cmp eax, -1
					jne .ninvblockfix
				mov eax, null
				.ninvblockfix :
				mov ecx, [ebx+0x0]	; current drive
				mov edx, ebx
				mov ebx, [.base]	; name of next block
				call Minnow5.getBlockByName
				mov ebx, edx
				mov [ebx+0x4], eax
				
				pop eax
				cmp byte [.done], true
					je .ret
				cmp dword [ebx+0x4], -1	; return if path part not found
					je .ret
				inc eax
				mov [.base], eax
				dec eax
				mov byte [eax], '/'
				
			.notPathMark :
			.nextIter :
			inc eax
			jmp .delimsLoop
		
	.ret :
	popa
	methodTraceLeave
	ret
	.name :
		dd 0x0
	.base :
		dd 0x0
	.done :
		dd 0x0

%include "../Tools/System/Minnow5FileDeletion.asm"
%include "../Tools/System/Minnow5DataManipulation.asm"

Minnow5.inited :
	dd 0x0
Minnow5.interface :
	dd 1
Minnow5._dat :
	dd 0x0
Minnow5.filesystemBase :
	dd 0x0
Minnow5.filesystemSize :
	dd 0x0

Minnow5.MFS_PARTITION_CODE	equ 0x30

Minnow5.SIGNATURE_HIGH		equ "S5.1"
	
Minnow5.DRIVE_LEGACY_BIOS		equ 0
Minnow5.DRIVE_AHCI				equ 1
Minnow5.NUMBER_OF_INTERFACES	equ 2

Minnow5.BLOCK_TYPE_DISK		equ 0x30
Minnow5.BLOCK_TYPE_FOLDER	equ 0x3A
Minnow5.BLOCK_TYPE_FILE		equ 0x3B
Minnow5.BLOCK_TYPE_DATA		equ 0x3C

Minnow5.Block_signatureLow	equ 0x00
Minnow5.Block_signatureHigh	equ 0x04
Minnow5.Block_nextPointer	equ 0x08
Minnow5.Block_discSignature	equ 0x08
Minnow5.Block_upperPointer	equ 0x0C
Minnow5.Block_type			equ 0x10
Minnow5.Block_byteSize		equ 0x14
Minnow5.Block_fileCount		equ 0x14
Minnow5.Block_data			equ 0x14
Minnow5.Block_innerPointer	equ 0x18
Minnow5.Block_attribs		equ 0x1C
Minnow5.Block_namePtr		equ 0x20

Minnow5.ATTRIB_NO_WRITE			equ 0x00	; Currently no attributes are implemented.
Minnow5.ATTRIB_NO_READ			equ 0x01
Minnow5.ATTRIB_NO_VIEW			equ 0x02
Minnow5.ATTRIB_DELETED			equ 0x03
Minnow5.ATTRIB_WRITE_PROTECTED	equ 0x04
Minnow5.ATTRIB_READ_PROTECTED	equ 0x05
Minnow5.ATTRIB_VIEW_PROTECTED	equ 0x06
Minnow5.ATTRIB_DELETE_PROTECTED	equ 0x07
Minnow5.ATTRIB_IS_EXECUTABLE	equ 0x08

