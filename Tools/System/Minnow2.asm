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
Minnow.writeBuffer :	; sector of offs in eax, buffer of 200 bytes in ecx
	pusha
		add eax, [Minnow.dev_offs]
		xor bx, bx
		adc bx, 0
		mov edx, 0x200
		call AHCI.DMAwrite
	popa
	ret
; Minnow.checkFSsize :
	; pusha
		
		; mov eax, [Minnow.dev_offs]
		; mov bx, 0x0
		; mov ecx, [Minnow.data]
		; call AHCI.DMAreadToBuffer
		; mov ebx, [ecx]
		; call console.numOut
		; call console.newline
		; mov ebx, [ecx+4]
		; call console.numOut
		; call console.newline
		; mov ebx, [Minnow.dev_offs]
		; call console.numOut
		; call console.newline
		; ;mov ecx, [Minnow.dev_offs]
		; ;imul ecx, 0x200
		; ;mov [Minnow.checkFSsize.loc], ecx
		; ;
		; ;Minnow.checkFSsize.loop :
		; ;	mov ecx, [Minnow.checkFSsize.loc]
		; ;	call Minnow.makeBlockAndOffset
		; ;	mov ecx, [Minnow.data]
		; ;	mov bx, 0x0
		; ;	push edx
		; ;	mov edx, 0x300
		; ;	call AHCI.DMAreadToBuffer
		; ;	pop edx
		; ;	add ecx, edx
		; ;	mov eax, [ecx]
		; ;				push ebx
		; ;				mov ebx, ecx
		; ;				call console.numOut
		; ;				call console.newline
		; ;				mov ebx, eax
		; ;				call console.numOut
		; ;				call console.newline
		; ;				pop ebx
		; ;	cmp eax, 0x0
		; ;		je Minnow.checkFSsize.done
		; ;	mov ecx, [Minnow.checkFSsize.loc]
		; ;	add ecx, eax
		; ;	mov [Minnow.checkFSsize.loc], ecx
		; ;	;jmp Minnow.checkFSsize.loop
		; ;
		; ;Minnow.checkFSsize.done :
		; ;mov ebx, [Minnow.checkFSsize.loc]
		; ;mov eax, [Minnow.dev_offs]
		; ;imul eax, 0x200
		; ;sub ebx, eax
		; ;call console.numOut
		; ;call console.newline
	; popa
	; ret

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