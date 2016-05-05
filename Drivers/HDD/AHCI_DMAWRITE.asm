AHCI.DMAwrite :	; HBA low = eax, HBA high = bx, length = edx, buffer = ecx
	pusha
		mov [AHCI_DMAread_dataBuffer], ecx
		call AHCI.DMAread.storeHBAvals
		call AHCI.DMAwrite.allocateMemory
		call AHCI.DMAwrite.buildFIS
		call AHCI.DMAread.buildPRDTs
		call AHCI.DMAread.findFreeSlot
		call AHCI.DMAwrite.buildCommandHeader
		call AHCI.DMAread.sendCommand
		call AHCI.DMAread.waitForCompletion
	popa
	ret
AHCI.DMAwriteNoAlloc :	; HBA low = eax, HBA high = bx, length = edx, buffer = ecx
	pusha
		mov [AHCI_DMAread_dataBuffer], ecx
		call AHCI.DMAread.storeHBAvals
		call AHCI.DMAwrite.getSomeValues
		call AHCI.DMAwrite.buildFIS
		call AHCI.DMAread.buildPRDTs
		call AHCI.DMAread.findFreeSlot
		call AHCI.DMAwrite.buildCommandHeader
		call AHCI.DMAread.sendCommand
		call AHCI.DMAread.waitForCompletion
	popa
	ret

AHCI.DMAwrite.buildFIS :
	pusha
		mov ebx, [AHCI_DMAread_commandLoc]
		mov byte [ebx+0x0], 0x27	; h2d
		mov byte [ebx+0x1], 0x80
		mov byte [ebx+0x2], 0x35	; command [ATA DMA WRITE]
		mov byte [ebx+0x3], 0x00
		mov cl, [AHCI_DMAread_LL]
		mov [ebx+0x4], cl
		mov cl, [AHCI_DMAread_LM]
		mov [ebx+0x5], cl
		mov cl, [AHCI_DMAread_LH]
		mov [ebx+0x6], cl
		mov byte [ebx+0x7], 0x40
		mov cl, [AHCI_DMAread_HL]
		mov [ebx+0x8], cl
		mov cl, [AHCI_DMAread_HM]
		mov [ebx+0x9], cl
		mov cl, [AHCI_DMAread_HH]
		mov [ebx+0xA], cl
		mov byte [ebx+0xB], 0x00
		mov eax, edx
		sub eax, 12
		mov ecx, 0x1000
		xor edx, edx
		idiv ecx
		add eax, 1
		mov [ebx+0xC], al
		mov [ebx+0xD], ah
		mov byte [ebx+0xE], 0x00
		mov byte [ebx+0xF], 0x00
		mov dword [ebx+0x10], 0x0
	popa
	ret

AHCI.DMAwrite.allocateMemory :
	pusha
		mov eax, edx
		mov [AHCI_DMAread_byteCount], eax
		sub eax, 1
		mov ecx, 40000000
		xor edx, edx
		idiv ecx
		add eax, 1
		mov [AHCI_DMAread_PRDTcount], eax
		imul eax, 32
		add eax, 0x80
		sub eax, 12
		mov ecx, 0x1000
		xor edx, edx
		idiv ecx
		add eax, 12
		imul eax, 0x1000
		mov ebx, eax
		mov eax, [ProgramManager.creationOffset]
		and eax, ~(0xFFF)
		add eax, 0x1000
		mov [ProgramManager.creationOffset], eax
		call ProgramManager.reserveMemory
		mov [AHCI_DMAread_commandLoc], ebx
		; no need to allocate a data buffer
	popa
	ret
	
AHCI.DMAwrite.getSomeValues :
	pusha
		mov eax, edx
		mov [AHCI_DMAread_byteCount], eax
		sub eax, 1
		mov ecx, 40000000
		xor edx, edx
		idiv ecx
		add eax, 1
		mov [AHCI_DMAread_PRDTcount], eax
	popa
	ret
	
AHCI.DMAwrite.buildCommandHeader :
	pusha
		;;;xor eax, eax
		;;;mov al, [AHCI_DMAread_commandSlot]
		;;;mov ecx, 0x20
		;;;imul ecx
		mov ecx, [AHCI_PORTALLOCEDMEM]
		;;;add ecx, eax	; ecx points to the command header
		; FIS size is 20
		mov eax, [AHCI_DMAread_PRDTcount]
		shl eax, 16-5
		or eax, 0b00000000010;0b00000100000;	PMP (4) | resv | clearBusy | BIST | Reset | Prefetch | Write | ATAPI
		shl eax, 5
		or eax, 5	; 5 dwords in the FIS
		mov [ecx], eax	; write the first dword
			;pusha
			;mov ebx, eax
			;call console.numOut
			;call console.newline
			;popa
		mov eax, [AHCI_DMAread_byteCount]
		mov dword [ecx+0x4], eax	; stores the number of bytes to be transferred?;;that have already been transferred
		mov eax, [AHCI_DMAread_commandLoc]
		mov [ecx+0x8], eax	; write the third dword
		mov dword [ecx+0xC], 0x0	; upper dword of last
		mov dword [ecx+0x10], 0x0	; resv
		mov dword [ecx+0x14], 0x0
		mov dword [ecx+0x18], 0x0
		mov dword [ecx+0x1C], 0x0
	popa
	ret