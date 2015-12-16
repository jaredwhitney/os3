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
		mov eax, ecx
		mov ebx, 0x5
		call Guppy.malloc
		mov [AHCI_DMAread_commandLoc], ebx
		; need to also allocate data buffer here!!!!~!
	popa
	ret

AHCI.DMAread.buildFIS :
	pusha
		
	popa
	ret

AHCI.DMAread.buildPRDTs :
	pusha
		
	popa
	ret

AHCI.DMAread.findFreeSlot :
	pusha
	
	popa
	ret

AHCI.DMAread.buildCommandHeader :
	pusha
	
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