Minnow.loadFS :
	pusha
		
		mov al, [AHCI_STATUS]
		cmp al, 0x0
			je Minnow.loadFS.ret
	
		mov eax, 0x0
		mov bx, 0x0
		mov edx, 0x200
		call AHCI.DMAread
		mov [Minnow.data], ecx
		add ecx, 0x1BE
		
		mov edx, 4
		Minnow.loadFS.loop :
		add ecx, 4
		mov bl, [ecx]
		cmp bl, 0x30
			je Minnow.loadFS.mount
		add ecx, 12
		sub edx, 1
		cmp edx, 0x0
			jg Minnow.loadFS.loop
	
	Minnow.loadFS.ret :
	popa
	ret

Minnow.loadFS.mount :
		add ecx, 4	; already at offs 4, jump to offs 8
		mov ebx, [ecx]
		mov [Minnow.dev_offs], ebx
		add ecx, 4
		mov ebx, [ecx]
		mov [Minnow.dev_size], ebx
		
		mov ebx, Minnow.loadFS.STR_SUCCESS
		call console.println
		
	popa
	ret

Minnow.getBuffer :	; sector in eax, returns 0x200 size buffer in ecx
	push edx
	push ebx
	push eax
			add eax, [Minnow.dev_offs]	; add dev offset
			xor bx, bx
			adc bx, 0	; i think this works?
			mov ecx, [Minnow.data]
			mov edx, 0x200
			call AHCI.DMAreadToBuffer
	pop eax
	pop ebx
	pop edx
	ret

Minnow.writeBuffer :	; sector of offs in eax, buffer of 0x200 bytes in ecx
	pusha
		add eax, [Minnow.dev_offs]
		xor bx, bx
		adc bx, 0
		mov edx, 0x200
		call AHCI.DMAwrite
	popa
	ret

Minnow.ctree :
	pusha
	
		mov byte [Minnow.ctree.printNext], 0xFF
		mov eax, 0x0
		Minnow.ctree.loop :
		call Minnow.getBuffer
		
		mov al, [Minnow.ctree.printNext]	; if so print it
		cmp al, 0x0
			je Minnow.ctree.noprintrep
		
		mov ebx, ecx
		add ebx, 8
		call console.print
		
		mov ebx, Minnow.ctree.sep0
		call console.print
		
		mov ebx, ecx
		add ebx, 8
		call String.getLength
		add ebx, edx
		call console.print
		
		mov ebx, Minnow.ctree.sep1
		call console.print
		
		mov ebx, [ecx+4]
		add ebx, 1
		call console.numOut
		
		mov ebx, Minnow.ctree.sep2
		call console.println
		
		Minnow.ctree.noprintrep :
		
		mov byte [Minnow.ctree.printNext], 0x00	; should it print the next info?
		mov eax, [ecx+4]
		cmp eax, 0x0
			jne Minnow.ctree.dontSetNext
		mov byte [Minnow.ctree.printNext], 0xFF
		Minnow.ctree.dontSetNext :
		
		mov eax, [ecx]
		cmp eax, 0x0
			jne Minnow.ctree.loop
		
	popa
	ret
Minnow.ctree.printNext :
	db 0xFF
Minnow.ctree.sep0 :
	db " (", 0
Minnow.ctree.sep1 :
	db ", ", 0
Minnow.ctree.sep2 :
	db ")", 0
Minnow.nameAndTypeToPointer :	; eax = namestr, ebx = typestr (still looks in headers of blocks with non-full headers!! D:)
	push eax
	push ebx
	push edx
		mov [Minnow.nameAndTypeToPointer.namestr], eax
		mov [Minnow.nameAndTypeToPointer.typestr], ebx
		mov eax, 0x0
		Minnow.nameAndTypeToPointer.loop :
		call Minnow.getBuffer
		push eax
		mov ebx, ecx
		add ebx, 8
		mov eax, [Minnow.nameAndTypeToPointer.namestr]
		call os.seq	; check 1
		cmp al, 0x0
			je Minnow.nameAndTypeToPointer.goon
		mov ebx, ecx
		add ebx, 8
		call String.getLength
		add ebx, edx
		mov eax, [Minnow.nameAndTypeToPointer.typestr]
		call os.seq	; check 2
		cmp al, 0x0
			jne Minnow.nameAndTypeToPointer.gotPointer
		Minnow.nameAndTypeToPointer.goon :
		pop eax
		add eax, [ecx]
		cmp dword [ecx], 0x0
			je Minnow.nameAndTypeToPointer.notFound
		jmp Minnow.nameAndTypeToPointer.loop
	Minnow.nameAndTypeToPointer.notFound :
	;mov ebx, Minnow.nATTP.STR_NOTFOUND
	;call console.println
	mov ecx, 0xFFFFFFFF
	pop edx
	pop ebx
	pop eax
	ret
Minnow.nameAndTypeToPointer.gotPointer :
	pop eax
	mov ecx, eax
	pop edx
	pop ebx
	pop eax
	ret
Minnow.nATTP.STR_NOTFOUND :
	db "[Minnow] File not found.", 0
Minnow.nameAndTypeToPointer.namestr :
	dd 0x0
Minnow.nameAndTypeToPointer.typestr :
	dd 0x0
	
Minnow.readFileBlock :	; eax = ptr, ebx = block (L->H), return ecx = buffer
	push eax
	push ebx
	push edx
		call Minnow.getBuffer
		mov edx, [ecx+0x4]
		sub edx, ebx
		mov ebx, edx
		Minnow.readFileBlock.loop :
		call Minnow.getBuffer
		cmp dword [ecx+0x4], ebx
			je Minnow.readFileBlock.cont
			jg Minnow.readFileBlock.err
		mov eax, [ecx]
		jmp Minnow.readFileBlock.loop
		Minnow.readFileBlock.cont :
		; ecx is already pointing to the buffer
	pop edx
	pop ebx
	pop eax
	ret
Minnow.readFileBlock.err :
	mov eax, SysHaltScreen.KILL
	mov ebx, Minnow.rFB.STR_ERR
	mov ecx, 5
	call SysHaltScreen.show
	hlt
Minnow.rFB.STR_ERR :
	db "[Minnow] A program attempted to access an invalid block.", 0

Minnow.skipHeader :	; pos in ecx, returns ecx = file start
	push ebx
	push edx
		add ecx, 8
		mov ebx, ecx
		call String.getLength
		add ecx, edx
		mov ebx, ecx
		call String.getLength
		add ecx, edx
	pop edx
	pop ebx
	ret

Minnow.getHeaderSize :	; buffer in ecx, returns ecx = header length
	push eax
		mov eax, ecx
		call Minnow.skipHeader
		sub ecx, eax
	pop eax
	ret
	
Minnow.writeFile :	; eax = namestr, ebx = typestr, ecx = buffer, edx = buffersize	[UNFINISHED!]
	pusha
		mov [Minnow.writeFile.namestr], eax
		mov [Minnow.writeFile.typestr], ebx
		mov [Minnow.writeFile.buffer], ecx
		call Minnow.nameAndTypeToPointer
		cmp ecx, 0xFFFFFFFF
			jne Minnow.writeFile.editExistingFile
		mov eax, ecx	; Ends with eax -> file
		
		push eax
		mov eax, edx
		mov edx, 0x200
			mov ecx, 24
			;	Calculating the header size
			mov ecx, 0x8
			push edx
			push ebx
			mov ebx, [Minnow.writeFile.namestr]
			call String.getLength
			add ecx, edx
			mov ebx, [Minnow.writeFile.typestr]
			call String.getLength
			add ecx, edx
			pop ebx
			pop edx
			;
		mov [Minnow.writeFile.headerSize], ecx
		add eax, ecx	; buffersize + headersize = totalsize
		sub eax, 8
		mov ecx, 0x200-0x8
		xor edx, edx
		idiv ecx
		add eax, 1	; edx = number of writes needed
		mov edx, eax
		pop eax
		
		mov eax, 0x200
		sub eax, [Minnow.writeFile.headerSize]
		mov [Minnow.writeFile.blockSize], eax
		
		; ...
		mov eax, 0
		call Minnow.findNextOpenBlock
		mov [Minnow.writeFile.firstBlockLoc], ecx
		mov [Minnow.writeFile.blocknum], ecx
		
		mov byte [Minnow.writeFile.firstBlock], 0xFF
		mov ecx, [Minnow.writeFile.buffer]	; ecx = buffer to read from
		
		Minnow.writeFile.loop :
		sub edx, 1
		push ecx
		push ecx
			mov ecx, 0x0
			cmp edx, 0x0
				je Minnow.writeFile.loop.noNextBlock
			mov eax, [Minnow.writeFile.blocknum]
			add eax, 1
			call Minnow.findNextOpenBlock
			Minnow.writeFile.loop.noNextBlock :
			mov [Minnow.writeFile.nextblocknum], ecx
			
		cmp byte [Minnow.writeFile.firstBlock], 0x0
			je Minnow.writeFile.loop.notFirstBlock
			mov byte [Minnow.writeFile.firstBlock], 0x0
			pop ecx
			call Minnow.writeFile.makeBufferWithHeader
			mov eax, [Minnow.writeFile.blocknum]
			call Minnow.writeBuffer
		pop ecx
		add ecx, [Minnow.writeFile.blockSize]
		jmp Minnow.writeFile.loop.kcont
		
		Minnow.writeFile.loop.notFirstBlock :
			pop ecx
			call Minnow.writeFile.makeBufferWithPartialHeader
			mov eax, [Minnow.writeFile.blocknum]
			call Minnow.writeBuffer
		pop ecx
		add ecx, 0x200-0x8
		
		Minnow.writeFile.loop.kcont :
		mov eax, [Minnow.writeFile.nextblocknum]
		mov [Minnow.writeFile.blocknum], eax
		cmp edx, 0x0
			jg Minnow.writeFile.loop
		
		mov eax, 0x0
		mov ebx, [Minnow.writeFile.firstBlockLoc]
		call Minnow.replaceTargetRef
		
	popa
	ret
Minnow.writeFile.editExistingFile :
		; code goes here
	popa
	ret
Minnow.writeFile.makeBufferWithHeader :
	push eax
	push ebx
	push edx
	push edx
		mov eax, ecx
		mov ebx, [Minnow.data]
		add ebx, 0x500
		add ebx, [Minnow.writeFile.headerSize]
		mov ecx, [Minnow.writeFile.blockSize]
		mov edx, 1
		call Image.copyLinear
		sub ebx, [Minnow.writeFile.headerSize]
		mov ecx, ebx
		mov edx, [Minnow.writeFile.nextblocknum]	; should be a pointer to the next data block!
		mov [ecx], edx
		pop edx
		mov [ecx+4], edx	; blocks left in the file
		mov ebx, ecx
		add ebx, 8
		mov eax, [Minnow.writeFile.namestr]
		call String.copy
		call String.getLength
		add ebx, edx
		mov eax, [Minnow.writeFile.typestr]
		call String.copy
	pop edx
	pop ebx
	pop eax
	ret
Minnow.writeFile.makeBufferWithPartialHeader :
	push eax
	push ebx
	push edx
	push edx
		mov eax, ecx
		mov ebx, [Minnow.data]
		add ebx, 0x500
		add ebx, 0x8
		mov ecx, 0x200-0x8
		mov edx, 1
		call Image.copyLinear
		sub ebx, 0x8
		mov ecx, ebx
		mov edx, [Minnow.writeFile.nextblocknum]
		mov [ecx], edx
		pop edx
		mov [ecx+4], edx
	pop edx
	pop ebx
	pop eax
	ret
Minnow.writeFile.namestr :
	dd 0x0
Minnow.writeFile.typestr :
	dd 0x0
Minnow.writeFile.buffer :
	dd 0x0
Minnow.writeFile.nextblocknum :
	dd 0x0
Minnow.writeFile.blocknum :
	dd 0x0
Minnow.writeFile.headerSize :
	dd 0x0
Minnow.writeFile.blockSize :
	dd 0x0
Minnow.writeFile.firstBlock :
	db 0x0
Minnow.writeFile.firstBlockLoc :
	dd 0x0

Minnow.findNextOpenBlock :	; block num to start at in eax, returns first free block in ecx
	push eax
		Minnow.findNextOpenBlock.loop :	; should make sure it won't return blocks outside of the partition!
		call Minnow.getBuffer
		cmp dword [ecx], 0x0	; end of filesystem ONLY IF blocksleft = 0
			jne Minnow.findNextOpenBlock.cont
		cmp dword [ecx+4], 0x0
			jne Minnow.findNextOpenBlock.ret
		Minnow.findNextOpenBlock.cont :
		add eax, 1
		jmp Minnow.findNextOpenBlock.loop
	Minnow.findNextOpenBlock.ret :
	mov ecx, eax
	pop eax
	ret

Minnow.makeBlockAndOffset :	; in ecx = number, out eax = blocklow edx=offs
	push ebx
	push ecx
		xor edx, edx
		mov eax, ecx
		mov ecx, 0x200
		idiv ecx
	pop ecx
	pop ebx
	ret

Minnow.deleteFile :	; sector in eax
	pusha
		push eax
		Minnow.deleteFile.loop :
		call Minnow.getBuffer
		mov edx, [ecx]
		mov dword [ecx], 0x0
		mov ebx, [ecx+4]
		mov dword [ecx+4], 0xFFFFFFFF
		call Minnow.writeBuffer
		mov eax, ebx
		cmp eax, 0x0
			je Minnow.deleteFile.gotRef
		mov eax, edx
		jmp Minnow.deleteFile.loop
		Minnow.deleteFile.gotRef :
		pop eax
		mov ebx, edx
		call Minnow.replaceTargetRef	; finds refs that pointed to the original file and replaces them with refs pointing to the next file in the chain
	popa
	ret

Minnow.replaceTargetRef :
	pusha
		mov [Minnow.replaceTargetRef.old], eax
		mov [Minnow.replaceTargetRef.new], ebx
		mov eax, 0x0
		Minnow.replaceTargetRef.loop :
		call Minnow.getBuffer
		mov ebx, [ecx]
		cmp ebx, [Minnow.replaceTargetRef.old]
			je Minnow.replaceTargetRef.gotRef
		mov eax, [ecx]
		jmp Minnow.replaceTargetRef.loop
		Minnow.replaceTargetRef.gotRef :
		mov ebx, [Minnow.replaceTargetRef.new]
		mov [ecx], ebx
		call Minnow.writeBuffer
	popa
	ret

Minnow.assumeDefragmentedAndFormatSpace :
	pusha
		mov eax, 0x0
		Minnow.SafeFormatSpace.loop :
			call Minnow.getBuffer
			mov edx, eax
			mov eax, [ecx]
			cmp dword [ecx], 0x0
				jne Minnow.SafeFormatSpace.loop
		add edx, 1
		mov eax, edx
		mov edx, 40000
		Minnow.AssumeDefragmentedAndFormatSpace.loop :
			call Minnow.getBuffer
			mov dword [ecx], 0x0
			mov dword [ecx+0x4], 0xFFFFFFFF
			call Minnow.writeBuffer
			add eax, 1
			sub edx, 1
			cmp edx, 0x0
				jg Minnow.AssumeDefragmentedAndFormatSpace.loop
	popa
	ret

Minnow.replaceTargetRef.old :
	dd 0x0
Minnow.replaceTargetRef.new :
	dd 0x0

Minnow.checkFSsize.loc :
	dd 0x0

Minnow.dev_offs :
	dd 0x0
Minnow.dev_size :
	dd 0x0
Minnow.loadFS.STR_SUCCESS :
	db "Filesystem successfully loaded.", 0
	
Minnow.data :
	db 0x0