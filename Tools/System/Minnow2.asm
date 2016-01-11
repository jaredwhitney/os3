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

Minnow.getBuffer :	; byte of offs in eax, returns 0x200+ size buffer in ecx
	push edx
	push ebx
	push eax
		push eax
			xor edx, edx
			mov ecx, 0x200
			idiv ecx	; eax now contains the sector offset
			add eax, [Minnow.dev_offs]	; add dev offset
			xor bx, bx
			adc bx, 0	; i think this works?
			mov ecx, [Minnow.data]
			mov edx, 0x400	; 0x200 + size of buffer
			call AHCI.DMAreadToBuffer
		pop eax
		xor edx, edx
		push ecx
		mov ecx, 0x200
		idiv ecx
		pop ecx
		add ecx, edx	; ecx now points to the correct position in the returned buffer
	pop eax
	pop ebx
	pop edx
	ret

; NOTE: Should make writeBuffer work like getBuffer so that it will figure out which sector the offs is in, read the data prior to the start of the buffer, append the buffer back to it, then write the combined buffer back out to the disk!
Minnow.writeBuffer :	; sector of offs in eax, buffer of 0x200 bytes in ecx
	pusha
		add eax, [Minnow.dev_offs]
		xor bx, bx
		adc bx, 0
		mov edx, 0x200
		call AHCI.DMAwrite
	popa
	ret

Minnow.checkFSsize :
	pusha
		mov eax, 0x0
		Minnow.checkFSsize.loop :
		call Minnow.getBuffer
		mov ebx, [ecx]
		cmp ebx, 0x0
			je Minnow.checkFSsize.done
		call Minnow.checkFSsize.navToEndOfSubs
		add eax, ebx
		jmp Minnow.checkFSsize.loop
	Minnow.checkFSsize.done :
		mov ebx, eax
		call console.numOut
		call console.newline
	popa
	ret
	Minnow.checkFSsize.navToEndOfSubs :
	push ebx
	push edx
	push ecx
		add ecx, 4	; in buffer
		add eax, 4	; in offset
		mov ebx, ecx
		call String.getLength
		add ecx, edx	; in buffer
		add eax, edx	; in offset
		mov ebx, ecx
		call String.getLength
		add eax, edx	; in offset
	pop ecx
	pop edx
	pop ebx
	ret

Minnow.nameAndTypeToPointer :	; eax = namestr, ebx = typestr, return ecx = offs
	pusha
		; save things
		mov eax, 0x0
		Minnow.nameAndTypeToPointer.loop :
		call Minnow.getBuffer
		mov ebx, [ecx]
		mov [Minnow.nameAndTypeToPointer.sizeStor], ebx
		cmp ebx, 0x0
			je Minnow.nameAndTypeToPointer.doesNotExist
		mov ebx, ecx
		add ebx, 4
		mov eax, [Minnow.nameAndTypeToPointer.namestr]
		call os.seq
			cmp al, 0x0
				je Minnow.nameAndTypeToPointer.failed
		call String.getLength
		add ebx, edx
		mov eax, [Minnow.nameAndTypeToPointer.typestr]
		call os.seq
			cmp al, 0x0
				jne Minnow.nameAndTypeToPointer.foundMatch
		call String.getLength
		add ebx, edx
		add ebx, 4	; does not work... ebx isnt the thing that needs to be increased this whole time... eax is...
		add ebx, [Minnow.nameAndTypeToPointer.sizeStor]
		jmp Minnow.nameAndTypeToPointer
		
	popa
	ret

Minnow.readFile :	; eax = offs, return ecx = buffer and edx = buffersize
	pusha
	
	popa
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