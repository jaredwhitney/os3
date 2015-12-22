AHCI.DMAread :	; HBA low = eax, HBA high = bx, length = edx, returns ecx = data buffer
	push eax
	push ebx
	push edx
		call AHCI.DMAread.storeHBAvals
		call AHCI.DMAread.allocateMemory
		call AHCI.DMAread.buildFIS
		call AHCI.DMAread.buildPRDTs
		call AHCI.DMAread.findFreeSlot
		call AHCI.DMAread.buildCommandHeader
		call AHCI.DMAread.sendCommand
		call AHCI.DMAread.waitForCompletion
		mov eax, SysHaltScreen.WARN
		mov ebx, AHCI_DMAread_COMPLETEMSG
		mov ecx, 5
		call SysHaltScreen.show
		mov ecx, [AHCI_DMAread_dataBuffer]
	pop edx
	pop ebx
	pop eax
	ret

AHCI.DMAread.allocateMemory :
	pusha
		mov eax, edx
		mov [AHCI_DMAread_byteCount], eax
		sub eax, 1
		mov ecx, 40000000
		xor edx, edx
		idiv ecx
		add eax, 1
		mov [AHCI_DMAread_PRDTcount], eax; need ecx PRDTs
		imul eax, 32	; 32 bytes per PRDT
		add eax, 0x80	; other bytes needed in the command
		sub eax, 1
		mov ecx, 0x1000	; sector size
		xor edx, edx
		idiv ecx
		add ecx, 1
		; need to allocate ecx sectors for the command
		mov eax, 0x5
		mov ebx, ecx
		call Guppy.malloc
		mov [AHCI_DMAread_commandLoc], ebx
		; need to also allocate data buffer here!!!!~!
		mov eax, [AHCI_DMAread_byteCount]
		sub eax, 1
		mov ecx, 0x1000	; sector size
		xor edx, edx
		idiv ecx
		add eax, 1
		mov ebx, eax
		mov eax, 0x5
		call Guppy.malloc
		mov [AHCI_DMAread_dataBuffer], ebx
		
		; zero out the buffer
		mov eax, [AHCI_DMAread_dataBuffer]
		mov ebx, [AHCI_DMAread_byteCount]
		call Buffer.clear
		
	popa
	ret

AHCI.DMAread.buildFIS :
	pusha
		mov ebx, [AHCI_DMAread_commandLoc]
		mov byte [ebx+0x0], 0x27	; h2d
		mov byte [ebx+0x1], 0x01	; no port mul, is a command	... OR 0x80 ??
		mov byte [ebx+0x2], 0x25	; the command [means ATA DMA READ]
		mov byte [ebx+0x3], 0x00	; should be the feature low byte?	zeroed for now
		mov cl, [AHCI_DMAread_LL]
		mov [ebx+0x4], cl
		mov cl, [AHCI_DMAread_LM]
		mov [ebx+0x5], cl
		mov cl, [AHCI_DMAread_LH]
		mov [ebx+0x6], cl
		mov byte [ebx+0x7], 0b1000000	; should be the device register [this means LBA...?]
		mov cl, [AHCI_DMAread_HL]
		mov [ebx+0x8], cl
		mov cl, [AHCI_DMAread_HM]
		mov [ebx+0x9], cl
		mov cl, [AHCI_DMAread_HH]
		mov [ebx+0xA], cl
		mov byte [ebx+0xB], 0x00	; should be the feature high byte	zeroed for now
		mov eax, edx
		sub eax, 1
		mov ecx, 0x1000
		xor edx, edx
		idiv ecx
		add eax, 1
		mov [ebx+0xC], al	; CALCLUATE COUNT LOW (SECTORS) AND PUT IT HERE
		mov [ebx+0xD], ah	; CALCULATE COUNT HIGH (SECTORS) AND PUT IT HERE
		mov byte [ebx+0xE], 0x00	; should be isync command completion
		mov byte [ebx+0xF], 0x00	; should be the control register?
		mov dword [ebx+0x10], 0x00	; resv
	popa
	ret

AHCI.DMAread.buildPRDTs :
	pusha
		mov eax, [AHCI_DMAread_PRDTcount]
		mov ebx, [AHCI_DMAread_dataBuffer]
		mov ecx, [AHCI_DMAread_commandLoc]
		add ecx, 0x80	; PRDT location
		mov edx, [AHCI_DMAread_byteCount]
		AHCI.DMAread.buildPRDTs.loop :
			mov [ecx], ebx	; position
			mov dword [ecx+4], 0x0	; upper dword
			mov dword [ecx+8], 0x0	; resv
			cmp edx, 0b1000000000000000000000	; the number of bytes in a max size PRDT
				jmp AHCI.DMAread.buildPRDTs.handleSmallRead
			mov dword [ecx+12], 0b111111111111111111111	; size, although NOT REALLY! the last PRDT should NOT have this size reported! (size-1)
			jmp AHCI.DMAread.buildPRDTs.countHandlingDone
			AHCI.DMAread.buildPRDTs.handleSmallRead :
			push edx
			sub edx, 1
			mov dword [ecx+12], edx	; the size of the final smaller packet
			pop edx
			AHCI.DMAread.buildPRDTs.countHandlingDone :
			add ebx, 0b111111111111111111111	; the max size of a PRDT
			add ecx, 0x10	; length of a PRDT
			sub edx, 0b1000000000000000000000	; the number of bytes in a max size PRDT
		sub eax, 1
		cmp eax, 0
			jg AHCI.DMAread.buildPRDTs.loop
	popa
	ret

AHCI.DMAread.findFreeSlot :	; based off of http://wiki.osdev.org/AHCI
	pusha
		; if the bit in PxSACT and PxCI are both free, the slot is free
		mov ebx, [AHCI_MEMLOC]
		add ebx, AHCI_PORT0	; Port 0
		add ebx, AHCI_PxCI	; PxCI
		mov ecx, [ebx]
		mov ebx, [AHCI_MEMLOC]
		add ebx, AHCI_PORT0	; Port 0
		add ebx, AHCI_PxSACT	; PxSACT
		or ecx, [ebx]
		mov eax, 0x0
		AHCI.DMAread.findFreeSlot.loop :
			test ecx, 0b1
				je AHCI.DMAread.findFreeSlot.ret
			add eax, 1
			cmp eax, 32	; slot 32 and above do not exist!
				jmp AHCI.DMAread.showFailMsg
			shr ecx, 1
			jmp AHCI.DMAread.findFreeSlot.loop
		AHCI.DMAread.findFreeSlot.ret :
		mov [AHCI_DMAread_commandSlot], al
	popa
	ret

AHCI.DMAread.buildCommandHeader :
	pusha
		xor eax, eax
		mov al, [AHCI_DMAread_commandSlot]
		mov ecx, 0x20
		imul ecx
		mov ecx, [AHCI_PORTALLOCEDMEM]
		add ecx, eax	; ecx points to the command header
		; FIS size is 20
		mov eax, [AHCI_DMAread_PRDTcount]
		shl eax, 16-5
		or eax, 0b00000100000;	PMP (4) | resv | clearBusy | BIST | Reset | Prefetch | Write | ATAPI
		shl eax, 5
		or eax, 5	; 5 dwords in the FIS
		mov [ecx], eax	; write the first dword
			pusha
			mov ebx, eax
			call console.numOut
			call console.newline
			popa
		mov dword [ecx+0x4], 0	; stores the number of bytes that have already been transferred
		mov eax, [AHCI_DMAread_commandLoc]
		mov [ecx+0x8], eax	; write the third dword
		mov dword [ecx+0xC], 0x0	; upper dword of last
		mov dword [ecx+0x10], 0x0	; resv
		mov dword [ecx+0x14], 0x0
		mov dword [ecx+0x18], 0x0
		mov dword [ecx+0x1C], 0x0
	popa
	ret

AHCI.DMAread.sendCommand :
	pusha
		mov ebx, [AHCI_MEMLOC]
		add ebx, AHCI_PORT0	; Port 0
		add ebx, AHCI_PxCI	; PxCI
		mov cl, [AHCI_DMAread_commandSlot]
		mov eax, 1
		shl eax, cl	; mask into position
		mov edx, [ebx]
		or edx, eax	; 'or' it back in
		mov [ebx], edx
	popa
	ret

AHCI.DMAread.waitForCompletion :
	pusha
		mov ebx, [AHCI_MEMLOC]
		add ebx, AHCI_PORT0	; Port 0
		add ebx, AHCI_PxCI	; PxCI
		mov cl, [AHCI_DMAread_commandSlot]
		mov eax, 1
		;shl eax, cl
		AHCI.DMAread.waitForCompletion.loop :
		mov edx, [ebx]
		test edx, eax
			jnz AHCI.DMAread.waitForCompletion.loop
				pusha
				mov ebx, [AHCI_PORTALLOCEDMEM]
				add ebx, 0x1000
				mov ebx, [ebx]
				call console.numOut
				call console.newline
				popa
	popa
	ret

AHCI.DMAread.storeHBAvals :
	pusha
		mov [AHCI_DMAread_HH], bh
		mov [AHCI_DMAread_HM], bl
		mov [AHCI_DMAread_LL], al
		mov [AHCI_DMAread_LM], ah
		shr eax, 16
		mov [AHCI_DMAread_LH], al
		mov [AHCI_DMAread_HL], ah
	popa
	ret

AHCI.DMAread.showFailMsg :
	pusha
		mov eax, SysHaltScreen.KILL
		mov ebx, AHCI_DMAread_FAILMSG
		mov ecx, 5
		call SysHaltScreen.show
	popa
	ret

AHCI_DMAread_COMPLETEMSG :
	db "AHCI: Finished reading data.", 0
AHCI_DMAread_FAILMSG :
	db "AHCI: Failed to read data.", 0
AHCI_DMAread_commandLoc :
	dd 0x0
AHCI_DMAread_commandSlot :
	db 0x0
AHCI_DMAread_FISsize :
	dd 0x0
AHCI_DMAread_PRDTcount :
	dd 0x0
AHCI_DMAread_dataBuffer :
	dd 0x0
AHCI_DMAread_byteCount :
	dd 0x0
AHCI_DMAread_HH :
	db 0x0
AHCI_DMAread_HM :
	db 0x0
AHCI_DMAread_HL :
	db 0x0
AHCI_DMAread_LH :
	db 0x0
AHCI_DMAread_LM :
	db 0x0
AHCI_DMAread_LL :
	db 0x0