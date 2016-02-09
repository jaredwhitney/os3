Minnow3.loadFS :
	pusha
	
		mov al, [AHCI_STATUS]
		cmp al, 0x0
			je Minnow3.loadFS.ret
		
		mov eax, 0
		xor ebx, ebx
		mov edx, 0x200
		call AHCI.DMAread
		mov [Minnow3.data0], ecx
		add ecx, 0x1BE
		
		mov edx, 4
		Minnow3.loadFS.partitionLookupLoop :
		add ecx, 4
		mov bl, [ecx]
		cmp bl, 0x30
			je Minnow3.loadFS.mountFromPartition
		add ecx, 12
		sub edx, 1
		cmp edx, 0x0
			jg Minnow3.loadFS.partitionLookupLoop
		
		mov ebx, Minnow3.loadFS.STR_NO_PARTITION
		call console.println
		
	Minnow3.loadFS.ret :
	popa
	ret

Minnow3.loadFS.mountFromPartition :

		add ecx, 4
		mov ebx, [ecx]
		add ebx, 1
		mov [Minnow3.table_start], ebx
		add ecx, 4
		mov ebx, [ecx]
		mov [Minnow3.dev_size], ebx
		
		cmp ebx, 0x493E0
			jle Minnow3.loadFS.deviceTooSmall
		
		mov eax, [Minnow3.table_start]
		xor ebx, ebx
		mov ecx, [Minnow3.data0]
		mov edx, 0x200
		call AHCI.DMAreadToBuffer
		
		mov eax, [ecx]
		cmp eax, Minnow3_SIGNATURE
			jne Minnow3.loadFS.promptForPartitionFormat
			
		mov eax, [ecx+4]
		mov [Minnow3.fs_ver], eax
		mov eax, [ecx+8]
		mov [Minnow3.mask_start], eax
		mov eax, [ecx+12]
		mov [Minnow3.data_start], eax
		
		mov ebx, Minnow3.loadFS.STR_SUCCESS
		call console.println
		
		mov ah, 0x2
		mov ebx, Minnow3.loadFS.STR_VER
		call console.print
		mov ebx, [Minnow3.fs_ver]
		call console.numOut
		call console.newline
		mov ebx, Minnow3.loadFS.STR_SIZE
		call console.print
		mov ebx, [Minnow3.dev_size]
		call console.numOut
		call console.newline
		
		; allocate other needed buffers
		mov eax, 0x7
		mov ebx, 1
		call Guppy.malloc
		mov [Minnow3.data1], ebx
		
	popa
	ret

Minnow3.loadFS.promptForPartitionFormat :
		mov ebx, Minnow3.loadFS.STR_FORMAT_PROMPT
		call console.println
	popa
	ret
Minnow3.loadFS.deviceTooSmall :
		mov ebx, Minnow3.loadFS.STR_SMALLDEV
		call console.println
	popa
	ret

Minnow3.doFormatPartition :
	pusha
		mov eax, [Minnow3.data0]
		mov ebx, 0x200
		call Buffer.clear
		
		mov eax, [Minnow3.data0]
		mov dword [eax], Minnow3_SIGNATURE
		mov dword [eax+4], 0x00000001
		mov ebx, [Minnow3.table_start]
		add ebx, 0x493E0	; table size
		mov [Minnow3.mask_start], ebx
		mov dword [eax+8], ebx	; mask start
			push eax
			push ebx
				mov eax, [Minnow3.dev_size]
				xor edx, edx
				mov ecx, 0x200*8
				idiv ecx
			pop ebx
				add ebx, eax
				mov [Minnow3.data_start], ebx
			pop eax
		mov dword [eax+12], ebx
		
		mov ebx, [Minnow3.data0]
		add ebx, Minnow3.TABLE_HEADER_SIZE
		mov dword [ebx+Mdesc_nextStruct], 0
		mov dword [ebx+Mdesc_lastStruct], 0
		mov dword [ebx+Mdesc_type], Mdesc.TYPE_DIRECTORY
		mov dword [ebx+Mdesc_pos], 0
		mov dword [ebx+Mdesc_size], 0
		mov dword [ebx+Mdesc_upperBase], 0
		mov dword [ebx+Directory_innerStruct], 0
		mov eax, Minnow3.doFormatPartition.STR_ROOT
		add ebx, Directory_name
		call String.copy
		
		mov eax, [Minnow3.table_start]
		xor ebx, ebx
		mov ecx, [Minnow3.data0]
		mov edx, 0x200
		call AHCI.DMAwrite
		
		mov eax, [Minnow3.data0]
		mov ebx, 0x200
		call Buffer.clear
		
		mov eax, [Minnow3.table_start]
		add eax, 1
		Minnow3.doFormatPartition.clearLoop :
		xor ebx, ebx
		mov ecx, [Minnow3.data0]
		mov edx, 0x200
		call AHCI.DMAwriteNoAlloc
		add eax, 1
		pusha
			cmp al, 0x0
				jne noprinty
			mov ebx, eax
			mov ah, 0x1
			call console.numOut
			call console.newline
			noprinty :
		popa
		cmp eax, [Minnow3.data_start]
			jl Minnow3.doFormatPartition.clearLoop	; clears out table and mask
		
		call Minnow3.loadFS
		
	popa
	ret

Minnow3.data0 :
	dd 0x0
Minnow3.data1 :
	dd 0x0
Minnow3.dev_size :
	dd 0x0
Minnow3.data_start :
	dd 0x0
Minnow3.table_start :
	dd 0x0
Minnow3.fs_ver :
	dd 0x0
Minnow3_SIGNATURE equ ((0x30<<24) | "MFS")
Minnow3.loadFS.STR_SUCCESS :
	db "[Minnow3] Filesystem successfully mounted.", 0
Minnow3.loadFS.STR_VER :
	db "  MFS Version: ", 0
Minnow3.loadFS.STR_SIZE :
	db "  Disk Size:   ", 0
Minnow3.loadFS.STR_SMALLDEV :
	db "[Minnow3] Device too small to mount.", 0
Minnow3.loadFS.STR_NO_PARTITION :
	db "[Minnow3] No compatible partition found.", 0
Minnow3.loadFS.STR_FORMAT_PROMPT :
	db "[Minnow3] The partition appears to be unformatted.", 0
Minnow3.doFormatPartition.STR_ROOT :
	db "root", 0


Minnow3.cprint :
	pusha
		mov ebx, Minnow3.TABLE_HEADER_SIZE
		call Minnow3.cprint.handlePart
	Minnow3.cprint.ret :
	popa
	ret
Minnow3.cprint.handlePart :	; part loc in ebx
	pusha
		cmp ebx, 0x0
			je Minnow3.cprint.handlePart.ret
		
		mov eax, ebx
		xor edx, edx
		mov ecx, 0x200
		idiv ecx
		push edx
			add eax, [Minnow3.table_start]	; sector to read the entry from
			xor ebx, ebx
			mov ecx, [Minnow3.data0]
			mov edx, 0x200
			call AHCI.DMAreadToBuffer
		pop edx
		mov ecx, [Minnow3.data0]
		add ecx, edx	; add the remainder
		
		cmp dword [ecx+Mdesc_type], Mdesc.TYPE_UNALLOCATED
			je Minnow3.cprint.handlePart.ret
		cmp dword [ecx+Mdesc_type], Mdesc.TYPE_FILE
			jne Minnow3.cprint.handlePart.notFile
		mov ebx, Minnow3.cprint.STR_FILE
		call console.println
			jmp Minnow3.cprint.handlePart.ret
		Minnow3.cprint.handlePart.notFile :
		cmp dword [ecx+Mdesc_type], Mdesc.TYPE_DIRECTORY
			jne Minnow3.cprint.handlePart.notDir
		mov ebx, Minnow3.cprint.STR_DIR
		call console.print
		mov ebx, ecx
		add ebx, Directory_name
		mov al, 0x2
		call console.println
		mov ebx, [ecx+Directory_innerStruct]
		call Minnow3.cprint.handlePart
		Minnow3.cprint.handlePart.notDir :
	Minnow3.cprint.handlePart.ret :
	popa
	ret
Minnow3.cprint.STR_FILE :
	db "[FILE] ", 0
Minnow3.cprint.STR_DIR :
	db "[DIR] ", 0
	
Minnow3.gotoFirstUnallocatedBlock :	; returns pos in ecx
	push eax
	push ebx
	push edx
		mov eax, [Minnow3.table_start]
		xor ebx, ebx
		mov ecx, [Minnow3.data0]
		mov edx, 0x200
		call AHCI.DMAreadToBuffer
		mov ecx, [Minnow3.data0]
		add ecx, Minnow3.TABLE_HEADER_SIZE
		jmp Minnow3.gotoFirstUnallocatedBlock.startloop
		Minnow3.gotoFirstUnallocatedBlock.mainloop :
		xor ebx, ebx
		mov ecx, [Minnow3.data0]
		mov edx, 0x200
		call AHCI.DMAreadToBuffer
		mov ecx, [Minnow3.data0]
		Minnow3.gotoFirstUnallocatedBlock.startloop :
		pusha
			Minnow3.gotoFirstUnallocatedBlock.searchSectorLoop :
			mov [Minnow3.gotoFirstUnallocatedBlock.current], ecx
			cmp dword [ecx+Mdesc_type], Mdesc.TYPE_UNALLOCATED
				je Minnow3.gotoFirstUnallocatedBlock.goret
			cmp dword [ecx+Mdesc_type], Mdesc.TYPE_BLOCK
				jne Minnow3.gotoFirstUnallocatedBlock.notBlock
			add ecx, 7*4
			jmp Minnow3.gotoFirstUnallocatedBlock.doneAdding
			Minnow3.gotoFirstUnallocatedBlock.notBlock :
			cmp dword [ecx+Mdesc_type], Mdesc.TYPE_DIRECTORY
				jne Minnow3.gotoFirstUnallocatedBlock.notDir
			add ecx, 4*7
			mov ebx, ecx
			call String.getLength
			add ecx, edx
			add ecx, 1
			jmp Minnow3.gotoFirstUnallocatedBlock.doneAdding
			Minnow3.gotoFirstUnallocatedBlock.notDir :
			; assume its a file
			mov ebx, ecx
			call String.getLength
			add ecx, edx
			mov ebx, ecx
			call String.getLength
			add ecx, edx
			Minnow3.gotoFirstUnallocatedBlock.doneAdding :
			mov eax, ecx
			sub eax, [Minnow3.data0]
			cmp eax, 0x200
				jl Minnow3.gotoFirstUnallocatedBlock.searchSectorLoop
		popa
		add eax, 1
		jmp Minnow3.gotoFirstUnallocatedBlock.mainloop
	Minnow3.gotoFirstUnallocatedBlock.ret :
	pop edx
	pop ebx
	pop eax
	ret
	Minnow3.gotoFirstUnallocatedBlock.goret :
	popa
	mov ecx, [Minnow3.gotoFirstUnallocatedBlock.current]
	sub ecx, [Minnow3.data0]
	jmp Minnow3.gotoFirstUnallocatedBlock.ret
Minnow3.gotoFirstUnallocatedBlock.current :
	dd 0x0

Minnow3.findChunkMatchingSize :	; chunk size in edx, returns chunk in ecx
	push eax
	push ebx
	push edx
	
		mov [Minnow3.chunkMatchSize], edx
		
		mov eax, [Minnow3.mask_start]
		xor ebx, ebx
		mov ecx, [Minnow3.data0]
		mov edx, 0x200
		call AHCI.DMAreadToBuffer	; this section should be looped too; rn can only handle up to 2gb worth of mapping
		
		; ecx points to buffer
		xor ebx, ebx
		mov al, 0
		Minnow3.findChunkMatchingSize.kgoloopagain :
		mov edx, [ecx]
		add ecx, 1
		test edx, 0b1
			je Minnow3.findChunkMatchingSize.knop
		add ebx, 1
		jmp Minnow3.findChunkMatchingSize.loopcont
		Minnow3.findChunkMatchingSize.knop :
		mov ebx, 0
		Minnow3.findChunkMatchingSize.loopcont :
		add al, 1
		shr edx, 1
		cmp ebx, [Minnow3.chunkMatchSize]
			je Minnow3.foundMatchingChunk
		cmp al, 8
			je Minnow3.findChunkMatchingSize.kgoloopagain
		Minnow3.foundMatchingChunk :
		
		and eax, 0xFF	; bit offs
		add ecx, eax
		sub ecx, [Minnow3.data0]	; bit offs + byte offs
		add ecx, [Minnow3.data_start]
		sub ecx, [Minnow3.chunkMatchSize]
		
	pop edx
	pop ebx
	pop eax
	ret
	
Minnow3.mask_start :
	dd 0x0
Minnow3.chunkMatchSize :
	dd 0x0
	
Minnow3.makeFile :	; blockptr head, String name, String type, Buffer data, int size [DO NOT USE UNTIL THE add table_starts HAVE BEEN ADDED, WILL ZERO OUT THE PARTITION TABLE :\]
	pop dword [Minnow3.makeFile.retval]
	pop dword [Minnow3.makeFile.size]
	pop dword [Minnow3.makeFile.data]
	pop dword [Minnow3.makeFile.type]
	pop dword [Minnow3.makeFile.name]
	pop dword [Minnow3.makeFile.head]
	pusha
		
		call Minnow3.gotoFirstUnallocatedBlock
		mov [Minnow3.makeFile.descptr], ecx
		
		mov eax, ecx
		xor edx, edx
		mov ecx, 0x200
		idiv ecx
		push edx
		xor ebx, ebx
		mov ecx, [Minnow3.data0]
		mov edx, 0x200
		call AHCI.DMAreadToBuffer
		pop edx
		add ecx, edx
		mov [Minnow3.makeFile.desc], ecx
		
		mov eax, [Minnow3.makeFile.head]
		xor edx, edx
		mov ecx, 0x200
		idiv ecx
		push edx
		xor ebx, ebx
		mov ecx, [Minnow3.data1]
		mov edx, 0x200
		call AHCI.DMAreadToBuffer
		pop edx
		add ecx, edx
		
		mov ebx, [Minnow3.makeFile.desc]
		mov eax, [ecx+Mdesc_nextStruct]
		mov [ebx+Mdesc_nextStruct], eax
		mov eax, [Minnow3.makeFile.descptr]
		mov [ecx+Mdesc_nextStruct], eax
		mov dword [ebx+Mdesc_type], Mdesc.TYPE_FILE
		push eax
		push ebx
		push edx
			mov eax, [Minnow3.makeFile.size]
			sub eax, 1
			xor edx, edx
			mov ecx, 0x200
			idiv ecx
			add eax, 1
			mov edx, eax
			call Minnow3.findChunkMatchingSize
		pop edx
		pop ebx
		pop eax
		mov [ebx+Mdesc_pos], ecx
		mov [ebx+Mdesc_size], edx
		mov eax, [Minnow3.makeFile.head]
		mov [ebx+Mdesc_upperBase], eax
		
		mov eax, [Minnow3.makeFile.name]
		add ebx, File_name
		call String.copy
		call String.getLength
		add ebx, edx
		mov eax, [Minnow3.makeFile.type]
		call String.copy
		
		; write head back to disk
		mov eax, [Minnow3.makeFile.head]
		xor edx, edx
		mov ecx, 0x200
		idiv ecx
		xor ebx, ebx
		mov ecx, [Minnow3.data1]
		mov edx, 0x200
		call AHCI.DMAwriteNoAlloc
		
		; write new mdesc to disk
		mov eax, [Minnow3.makeFile.descptr]
		xor edx, edx
		mov ecx, 0x200
		idiv ecx
		push edx	; eax is the block that this stuff is going in
			xor ebx, ebx
			mov ecx, [Minnow3.data1]	; don't need data1 to hold the head anymore
			mov edx, 0x300
			call AHCI.DMAreadToBuffer
		pop edx
		add ecx, edx	; where the file block data should be copied
		mov ebx, ecx
		push eax
		mov eax, [Minnow3.data0]	; the actual file block data
		mov ecx, 0x200
		mov edx, 1
		call Image.copyLinear
		pop eax
		xor ebx, ebx
		mov ecx, [Minnow3.data1]
		mov edx, 0x300
		call AHCI.DMAwriteNoAlloc
		
	popa
	push dword [Minnow3.makeFile.retval]
	ret
Minnow3.makeFile.retval :
	dd 0x0
Minnow3.makeFile.size :
	dd 0x0
Minnow3.makeFile.data :
	dd 0x0
Minnow3.makeFile.type :
	dd 0x0
Minnow3.makeFile.name :
	dd 0x0
Minnow3.makeFile.head :
	dd 0x0
Minnow3.makeFile.desc :
	dd 0x0
Minnow3.makeFile.descptr :
	dd 0x0

Mdesc.TYPE_UNALLOCATED equ 0
Mdesc.TYPE_FILE equ 1
Mdesc.TYPE_DIRECTORY equ 2
Mdesc.TYPE_BLOCK equ 3

Minnow3.TABLE_HEADER_SIZE equ 16

Mdesc_nextStruct equ 0
Mdesc_lastStruct equ 4
Mdesc_type equ 8
Mdesc_pos equ 12
Mdesc_size equ 16
Mdesc_upperBase equ 20
Directory_innerStruct equ 24
Directory_name equ 28
File_name equ 24
