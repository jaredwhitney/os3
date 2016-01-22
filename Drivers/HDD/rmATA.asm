rmATA.DMAread :	; HBA low = eax, HBA high = bx, length = edx, returns ecx = data buffer
	push eax
	push ebx
	push edx
		call rmATA.DMAread.storeVals
		call rmATA.DMAread.getSectorCount
		call rmATA.DMAread.allocateBuffer
		call rmATA.DMAread.readData
	mov ecx, [rmATA.DMAread.dataBuffer]	
	pop edx
	pop ebx
	pop eax
	ret
rmATA.DMAread.HBA_low :
	dd 0x0
rmATA.DMAread.HBA_high :
	dd 0x0
rmATA.DMAread.byteCount :
	dd 0x0
rmATA.DMAread.sectorCount :
	dd 0x0
rmATA.DMAread.dataBuffer :
	dd 0x0

rmATA.DMAreadToBuffer :	; HBA low = eax, HBA high = bx, length = edx
	push eax
	push ebx
	push edx
		call rmATA.DMAread.storeVals
		call rmATA.DMAread.getSectorCount
		call rmATA.DMAread.readData
	mov ecx, [rmATA.DMAread.dataBuffer]	
	pop edx
	pop ebx
	pop eax
	
rmATA.DMAread.storeVals :
	pusha
		mov [rmATA.DMAread.HBA_low], eax
		and ebx, 0xFFFF
		mov [rmATA.DMAread.HBA_high], ebx
		mov [rmATA.DMAread.byteCount], edx
	popa
	ret
rmATA.DMAread.getSectorCount :
	pusha
		mov eax, [rmATA.DMAread.byteCount]
		mov ecx, 0x200
		xor edx, edx
		idiv ecx
		add eax, 1
		mov [rmATA.DMAread.sectorCount], eax
	popa
	ret
rmATA.DMAread.allocateBuffer :
	pusha
		mov eax, 0x8	; really need to keep track of these somehow...
		mov ebx, [rmATA.DMAread.sectorCount]
		call Guppy.malloc
		mov [rmATA.DMAread.dataBuffer], ebx
	popa
	ret
rmATA.DMAread.readData :
	pusha
		mov dword [os_RealMode_functionPointer], rmATA.DMAread.loadFunc
		mov edx, [rmATA.DMAread.sectorCount]
		mov ebx, [rmATA.DMAread.dataBuffer]
		rmATA.DMAread.loop :
		call os.hopToRealMode
		mov eax, 0x7c00
		mov ecx, 0x200
		push edx
		mov edx, 1
		call Image.copyLinear	; could really use a buffer copy func at some point
		pop edx
		add ebx, 0x200
		mov ecx, [rmATA.DMAread.HBA_low]
		add ecx, 1
		cmp ecx, 0x0
			jne rmATA.DMAread.noRollover
		mov ecx, [rmATA.DMAread.HBA_high]
		add ecx, 1
		mov [rmATA.DMAread.HBA_high], ecx
		mov ecx, 0x0
		rmATA.DMAread.noRollover :
		mov [rmATA.DMAread.HBA_low], ecx
		sub edx, 1
		cmp edx, 0
			jg rmATA.DMAread.loop
	popa
	ret

[bits 16]
rmATA.DMAread.loadFunc :
		mov eax, [rmATA.DMAread.HBA_low]
		mov bx, [rmATA.DMAread.HBA_high]
		call realMode.ATAload
	ret
[bits 32]