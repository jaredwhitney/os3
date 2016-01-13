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
	
Minnow.readFileBlock :	; eax = ptr, ebx = block (H->L), return ecx = buffer
	push eax
	push ebx
	push edx
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
	
Minnow.writeFile :	; eax = offs, ecx = buffer, edx = buffersize	NOTE:: need to figure out what to do if buffersize increases
	pusha
	
	popa
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