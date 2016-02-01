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
		mov edx, 0x200
		mov ebx, 0x0
		call Image.clear
		
		mov eax, [Minnow3.data0]
		mov dword [eax], Minnow3_SIGNATURE
		mov dword [eax+4], 0x00000001
		mov ebx, [Minnow3.table_start]
		add ebx, 0x493E0
		mov dword [eax+8], ebx
		
		mov ebx, [Minnow3.data0]
		add ebx, 12
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
		mov edx, 0x200
		mov ebx, 0x0
		call Image.clear
		
		mov eax, [Minnow3.table_start]
		add eax, 1
		push eax
		add eax, 0x493E0
		mov [Minnow3.data_start], eax
		pop eax
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
			jl Minnow3.doFormatPartition.clearLoop
		
		call Minnow3.loadFS
		
	popa
	ret

Minnow3.data0 :
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
		mov ebx, 12
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
		add ecx, 12
		jmp Minnow3.gotoFirstUnallocatedBlock.startloop
		Minnow3.gotoFirstUnallocatedBlock.mainloop :
		xor ebx, ebx
		mov ecx, [Minnow3.data0]
		mov edx, 0x200
		call AHCI.DMAreadToBuffer
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
					pusha
						mov ebx, ecx
						sub ebx, [Minnow3.data0]
						call console.numOut
						call console.newline
					popa
			mov eax, ecx
			sub eax, [Minnow3.table_start]
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

Mdesc.TYPE_UNALLOCATED equ 0
Mdesc.TYPE_FILE equ 1
Mdesc.TYPE_DIRECTORY equ 2
Mdesc.TYPE_BLOCK equ 3

Mdesc_nextStruct equ 0
Mdesc_lastStruct equ 4
Mdesc_type equ 8
Mdesc_pos equ 12
Mdesc_size equ 16
Mdesc_upperBase equ 20
Directory_innerStruct equ 24
Directory_name equ 28
