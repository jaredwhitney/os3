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

Minnow.test :
	pusha
	
		mov byte [Minnow.test.printNext], 0xFF
		mov eax, 0x0
		Minnow.test.loop :
		call Minnow.getBuffer
		
		mov al, [Minnow.test.printNext]	; if so print it
		cmp al, 0x0
			je Minnow.test.noprintrep
		mov ebx, ecx
		add ebx, 8
		call console.println
		
		mov ebx, ecx
		add ebx, 8
		call String.getLength
		add ebx, edx
		call console.println
		Minnow.test.noprintrep :
		
		mov byte [Minnow.test.printNext], 0x00	; should it print the next info?
		mov eax, [ecx+4]
		cmp eax, 0x0
			jne Minnow.test.dontSetNext
		mov byte [Minnow.test.printNext], 0xFF
		Minnow.test.dontSetNext :
		
		mov eax, [ecx]
		cmp eax, 0x0
			jne Minnow.test.loop
	
	popa
	ret
Minnow.test.printNext :
	db 0xFF

Minnow.nameAndTypeToPointer :	; eax = namestr, ebx = typestr
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
	mov ebx, Minnow.nATTP.STR_NOTFOUND
	call console.println
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
			je Minnow.writeFile.createNewFile
		mov eax, ecx
		
		push eax
		mov eax, edx
		mov edx, 0x200
		call Minnow.getHeaderSize
		mov [Minnow.writeFile.headerSize], ecx
		sub edx, ecx
		mov ecx, edx	; ecx contains the amount of usable data in each block
		mov [Minnow.writeFile.blockSize], ecx
		xor edx, edx
		idiv ecx
		add eax, 1
		mov edx, eax
		pop eax
		mov ecx, [Minnow.writeFile.buffer]
		
		; ...
		mov eax, 0
		call Minnow.findNextOpenBlock
		mov [Minnow.writeFile.blocknum], ecx
		Minnow.writeFile.loop :
		push ecx
		call Minnow.findNextOpenBlock
		mov [Minnow.writeFile.nextblocknum], ecx
		call Minnow.writeFile.makeBufferWithHeader
		mov eax, [Minnow.writeFile.blocknum]
		call Minnow.writeBuffer
		pop ecx
		add ecx, [Minnow.writeFile.blockSize]
		sub edx, 1
		cmp edx, 0x0
			jg Minnow.writeFile.loop
		
	popa
	ret
Minnow.writeFile.createNewFile :
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
Minnow.writeFile.namestr :
	dd 0x0
Minnow.writeFile.typestr :
	dd 0x0

Minnow.findNextOpenBlock :	; block num to start at in eax, returns first free block in ecx
	push eax
		Minnow.findNextOpenBlock.loop :	; should make sure it won't return blocks outside of the partition!
		call Minnow.getBuffer
		cmp dword [ecx], 0x0
			je Minnow.findNextOpenBlock.ret
		add eax, 1
		jmp Minnow.findNextOpenBlock.loop
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