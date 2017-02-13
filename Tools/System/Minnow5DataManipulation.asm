Minnow5.appendDataBlock :	; qword buffer (file) in eax, returns eax=blockptr
	methodTraceEnter
	pusha
		push eax	; interface setting
		mov eax, [eax+0x0]
		call Minnow5.setInterfaceSmart
		pop eax
		mov eax, [eax+0x4]
		mov dword [.base], eax
		
		call Minnow5.findFreeBlock	; find a free block
		mov dword [.block], ebx
		
		mov ebx, [Minnow5._dat]	; figure out what should point to it; make it do so
		mov ecx, [.block]		
		call Minnow5.readBlock
		mov edx, [ebx+Minnow5.Block_innerPointer]
		cmp edx, null
			jne .noInner
			
			mov [ebx+Minnow5.Block_innerPointer], ecx
			call Minnow5.writeBlock
			jmp .doPlacementEnd
		
		.noInner :
		mov eax, edx
		
		.loopGoOn :
		call Minnow5.readBlock
		cmp dword [ebx+Minnow5.Block_nextPointer], null
			je .loopDone
		mov eax, [ebx+Minnow5.Block_nextPointer]
		jmp .loopGoOn
		.loopDone :
		
		mov [ebx+Minnow5.Block_nextPointer], ecx
		call Minnow5.writeBlock
		.doPlacementEnd :
		
		
		mov eax, [Minnow5._dat]	; clear a buffer
		mov ebx, 0x200
		call Buffer.clear
		
		mov dword [eax], "MINF"	; fill it with the proper headers
		mov dword [eax+Minnow5.Block_signatureHigh], Minnow5.SIGNATURE_HIGH
		mov dword [eax+Minnow5.Block_nextPointer], null
		mov ecx, [.base]
		mov dword [eax+Minnow5.Block_upperPointer], ecx
		mov dword [eax+Minnow5.Block_type], Minnow5.BLOCK_TYPE_DATA
		
		mov ebx, eax	; write it out to the disk
		mov eax, [.block]
		call Minnow5.writeBlock
	popa
	mov eax, [.block]
	methodTraceLeave
	ret
	.base :
		dd 0x0
	.block :
		dd 0x0

Minnow5.writeBuffer :	; eax = qword buffer (file), ebx = buffer (data), ecx = buffer size, edx = position in file
	methodTraceEnter
	pusha
		mov [.file], eax
		mov [.dataBuffer], ebx
		mov [.buffersize], ecx
		mov [.writePos], edx
		push eax	; interface setting
		mov eax, [eax+0x0]
		call Minnow5.setInterfaceSmart
		pop eax
		mov eax, [eax+0x4]
	;	mov dword [.base], eax
		
		mov ebx, [Minnow5._dat]
		call Minnow5.readBlock
		
		mov ecx, [ebx+Minnow5.Block_byteSize]
	;	mov [.oldsize], ecx
		mov edx, [.buffersize]
		add edx, [.writePos]
		cmp edx, ecx
			jbe .noSizeUp
		mov dword [ebx+Minnow5.Block_byteSize], edx
		.noSizeUp :
		
		call Minnow5.writeBlock
		
		cmp dword [ebx+Minnow5.Block_innerPointer], null
			jne .notEmptyFile
			
			mov eax, [.file]
			call Minnow5.appendDataBlock
			mov eax, [.file]
			mov eax, [eax+0x4]
			call Minnow5.readBlock
			
		.notEmptyFile :
		
		mov eax, [ebx+Minnow5.Block_innerPointer]
		mov ecx, [.writePos]
		shr ecx, 9	; div by 0x200 (ecx is now the start sector)
		push ecx
		
		.goToPosLoop :
			call Minnow5.readBlock
			cmp ecx, 0
				je .gotoPosDone
			dec ecx
			mov edx, [ebx+Minnow5.Block_nextPointer]
			cmp edx, null
				jne .noMake
			mov eax, [.file]
			call Minnow5.appendDataBlock
			jmp .gtpmdone
			.noMake :
			mov eax, edx
			.gtpmdone :
			jmp .goToPosLoop
		.gotoPosDone :
		mov [.currentBlock], eax	; also already read into [ebx]
		
		mov ecx, [.writePos]
		pop edx
		shl edx, 9
		sub ecx, edx
		mov [.startOffs], ecx
		
		; ;
		; Now that we know where to start, do the actual copying
		; ;
		
		mov ecx, 0x200-Minnow5.Block_data
		sub ecx, [.startOffs]
		add ebx, [.startOffs]
		
		
			.innerLoop :
			
			mov eax, [.currentBlock]
			mov ebx, [Minnow5._dat]
			call Minnow5.readBlock
			
			cmp [.buffersize], ecx
				jae .nosmod
			mov ecx, [.buffersize]
			.nosmod :
			sub [.buffersize], ecx
			mov eax, [.dataBuffer]
			add dword [.dataBuffer], ecx
			add ebx, Minnow5.Block_data
			
			; copy from [eax] to [ebx]... size = ecx
			.copyLoop :
				mov dl, [eax]
				mov [ebx], dl
				add ebx, 1
				add eax, 1
				sub ecx, 1
				cmp ecx, 0
					jg .copyLoop
				
			mov eax, [.currentBlock]
			mov ebx, [Minnow5._dat]
			call Minnow5.writeBlock
			
			mov eax, [ebx+Minnow5.Block_nextPointer]
			cmp eax, null
				jne .noMake2
			mov eax, [.file]
			call Minnow5.appendDataBlock
			.noMake2 :
			
			mov [.currentBlock], eax
			
			mov ecx, 0x200-Minnow5.Block_data
			cmp dword [.buffersize], 0
				jg .innerLoop
		
	popa
	methodTraceLeave
	ret
	.file :
		dd 0x0
	.startOffs :
		dd 0x0
	.dataBuffer :
		dd 0x0
	.buffersize :
		dd 0x0
	.writePos :
		dd 0x0
	.currentBlock :
		dd 0x0
	
Minnow5.readBuffer :	; eax = qword buffer (file), ebx = buffer (data), ecx = buffer size, edx = position in file, ecx out = bytes read
	methodTraceEnter
	pusha
		mov [.dataBuffer], ebx
		mov [.buffersize], ecx
		mov [.readPos], edx
		push eax
		mov eax, [eax+0x0]
		call Minnow5.setInterfaceSmart
		pop eax
		mov eax, [eax+0x4]
		
		mov ebx, [Minnow5._dat]
		call Minnow5.readBlock
		
		mov ecx, [ebx+Minnow5.Block_byteSize]
	;	mov [.filesize], ecx
		
		; Check / correct actual read size... return if the offset is at or after the EOF
		
		mov edx, [.buffersize]
		add edx, [.readPos]
		cmp ecx, edx
			jae .nosizelimit
		cmp ecx, [.readPos]
			ja .readOffsetExistsInFile
		mov dword [.bytesread], 0
		jmp .readLoopDone
		.readOffsetExistsInFile :
		sub ecx, [.readPos]
		mov [.buffersize], ecx
		mov [.bytesread], ecx
		.nosizelimit :
		
		; Navigate to the read offset
		
		mov eax, [ebx+Minnow5.Block_innerPointer]
		mov ecx, [.readPos]
		shr ecx, 9	; div by 0x200 (ecx is now the start sector)
		push ecx
		
		.goToPosLoop :
		call Minnow5.readBlock
		cmp ecx, 0
			je .gotoPosDone
		dec ecx
		mov eax, [ebx+Minnow5.Block_nextPointer]
		jmp .goToPosLoop
		.gotoPosDone :	; the first block has already been read into [ebx]
		
		; Calculate the starting offset
		
		mov ecx, [.readPos]
		pop edx
		shl edx, 9
		sub ecx, edx
		mov [.offs], ecx
		
		; Figure out values for the first read (the offset one) then jump into the loop
		
		mov ecx, [ebx+Minnow5.Block_nextPointer]	; ready next sector
		mov [.next], ecx
		
		mov ecx, 0x200-Minnow5.Block_data	; get read size
		sub ecx, [.offs]
		
		cmp [.buffersize], ecx	; fix read size if it should be an incomplete read
			jge .startNoReadLimit
		mov ecx, [.buffersize]
		.startNoReadLimit :
		sub [.buffersize], ecx
		
		add ebx, [.offs]
		
		jmp .readLoopEntryPoint
		
		; Read / copy the actual data
		
		.readLoop :
			
			cmp dword [.buffersize], 0
				jle .readLoopDone
			
			mov ebx, [Minnow5._dat]
			call Minnow5.readBlock
			
			mov ecx, [ebx+Minnow5.Block_nextPointer]
			mov [.next], ecx
			
			mov ecx, 0x200-Minnow5.Block_data
			cmp [.buffersize], ecx
				jge .noReadLimit
			mov ecx, [.buffersize]
			.noReadLimit :
			sub [.buffersize], ecx
			
			.readLoopEntryPoint :
			mov eax, [.dataBuffer]
			add [.dataBuffer], ecx
			add ebx, Minnow5.Block_data
			
			; copy from [ebx] to [eax]... size = ecx
			.copyLoop :
				mov dl, [ebx]
				mov [eax], dl
				inc eax
				inc ebx
				dec ecx
				cmp ecx, 0
					jg .copyLoop
			
			mov eax, [.next]
			jmp .readLoop
		
		.readLoopDone :
		
	popa
	mov ecx, [.bytesread]
	methodTraceLeave
	ret
	.dataBuffer :
		dd 0x0
	.buffersize :
		dd 0x0
	.readPos :
		dd 0x0
	.bytesread :
		dd 0x0
	.offs :
		dd 0x0
	.next :
		dd 0x0