AHCI.DMAread :	; HBA low = eax, HBA high = bx, length = edx, returns ecx = data buffer
	push eax
	push ebx
	push edx
		call AHCI.DMAread.allocateMemory
		call AHCI.DMAread.buildFIS
		call AHCI.DMAread.buildPRDTs
		call AHCI.DMAread.findFreeSlot
		call AHCI.DMAread.buildCommandHeader
		call AHCI.DMAread.sendCommand
		; then wait for the command to finish and handle any errors...
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
		add ecx, 1
		mov [AHCI_DMAread_PRDTcount], ecx; need ecx PRDTs
		imul ecx, 32	; 32 bytes per PRDT
		add ecx, 0x80	; other bytes needed in the command
		mov eax, ecx
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
	popa
	ret

AHCI.DMAread.buildFIS :
	pusha
		mov ebx, [AHCI_DMAread_commandLoc]
		mov byte [ebx+0x0], 0x27	; h2d
		mov byte [ebx+0x1], 0x01	; no port mul, is a command
		mov byte [ebx+0x2], 0x25	; the command [means ATA DMA...?]
		mov byte [ebx+0x3], 0x00	; should be the feature low byte?
		mov byte [ebx+0x4], [AHCI_DMAread_LL]
		mov byte [ebx+0x5], [AHCI_DMAread_LM]
		mov byte [ebx+0x6], [AHCI_DMAread_LH]
		mov byte [ebx+0x7], 0b1000000	; should be the device register [this means LBA...?]
		mov byte [ebx+0x8], [AHCI_DMAread_HL]
		mov byte [ebx+0x9], [AHCI_DMAread_HM]
		mov byte [ebx+0xA], [AHCI_DMAread_HH]
		mov byte [ebx+0xB], 0x00	; should be the feature high byte
		mov eax, edx
		sub eax, 1
		mov ecx, 0x1000
		xor edx, edx
		idiv ecx
		add eax, 1
		mov byte [ebx+0xC], ax	; CALCLUATE COUNT LOW (SECTORS) AND PUT IT HERE
		shr eax, 8
		mov byte [ebx+0xD], ax	; CALCULATE COUNT HIGH (SECTORS) AND PUT IT HERE
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
				jl AHCI.DMAread.buildPRDTs.handleSmallRead
			mov dword [ecx+12], 0b111111111111111111111	; size, although NOT REALLY! the last PRDT should NOT have this size reported! (size-1)
			jmp AHCI.DMAread.buildPRDTs.countHandlingDone
			push edx
			sub edx, 1
			mov dword [ecx+12], edx	; the size of the final smaller packet
			pop edx
			AHCI.DMAread.buildFIS.countHandlingDone :
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
		add ebx, 0x100	; Port 0
		add ebx, 0x38	; PxCI
		mov ecx, [ebx]
		mov ebx, [AHCI_MEMLOC]
		add ebx, 0x100	; Port 0
		add ebx, 0x34	; PxSACT
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
		mov [AHCI_DMAread_commandSlot], eax
	popa
	ret

AHCI.DMAread.buildCommandHeader :
	pusha
		mov eax, [AHCI_DMAread_commandSlot]
		mov ecx, 0x20
		imul ecx
		mov ecx, [AHCI_PORTALLOCEDMEM]
		add ecx, eax
		; FIS size is 20
	popa
	ret

AHCI.DMAread.sendCommand :
	pusha
	
	popa
	ret

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