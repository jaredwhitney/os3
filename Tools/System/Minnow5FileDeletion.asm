Minnow5.deleteFile :	; eax = qword buffer (file)
	methodTraceEnter
	pusha
	
		; SETUP (ENSURE CORRECT DRIVE)

			mov ecx, eax
			mov eax, [eax+0x0]	; drive
			call Minnow5.setInterfaceSmart
			mov eax, [ecx+0x4]	; block
			mov [.block], eax
		
		; INVALIDATE DELETED BLOCK
		; invalidate signature of block

			mov ebx, [Minnow5._dat]
			call Minnow5.readBlock
			
			mov dword [ebx+Minnow5.Block_signatureLow], "MINf"
			
			call Minnow5.writeBlock
			
			mov ecx, [ebx+Minnow5.Block_innerPointer]
			mov [.inner], ecx
			mov ecx, [ebx+Minnow5.Block_nextPointer]
			; mov [.next], ecx	; just keep track of this in ecx... it should never get overwritten anyway
			mov eax, [ebx+Minnow5.Block_upperPointer]
		
		; REMOVE REFERENCES TO THE DELETED BLOCK
		; load upper
		; if inner is the block being deleted, replace inner with the block's next
		; else loop over the inner's next's, when the next = the block, replace it with the block's next
		
			mov edx, [.block]
			
			call Minnow5.readBlock
			cmp [ebx+Minnow5.Block_innerPointer], edx
				jne .notInner
			
				mov dword [ebx+Minnow5.Block_innerPointer], ecx	; innerPointer := ecx = [.next]
				call Minnow5.writeBlock
				jmp .removeRefDone
			
			.notInner :
			
			mov eax, [ebx+Minnow5.Block_innerPointer]
			
			.removeRefCheckLoop :
			
				call Minnow5.readBlock
				
				cmp [ebx+Minnow5.Block_nextPointer], edx
					je .removeRefFoundMatch
				
				mov eax, [ebx+Minnow5.Block_nextPointer]
				
				cmp eax, null
					je kernel.halt	; something's seriously messed up with the filesystem
				
				jmp .removeRefCheckLoop
				
			.removeRefFoundMatch :
			
			mov [ebx+Minnow5.Block_nextPointer], ecx	; innerPointer := ecx = [.next]
			call Minnow5.writeBlock
			
			.removeRefDone :
		
		; INVALIDATE ALL SUB-BLOCKS OF THE DELETED BLOCK
		; load the block's inner
		; invalidate its signature
		; load each of its next's
		; invalidate their signature's
		; repeat for each of their inner's...
		
			xor edx, edx
			
			cmp dword [.inner], null
				je .noInner
			push dword [.inner]
			inc edx
			.noInner :
			
			.invLoop :
			
				cmp edx, 0
					je .invDone
					
				pop eax
				dec edx
				
				call Minnow5.readBlock
				
				mov dword [ebx+Minnow5.Block_signatureLow], "MINf"
				call Minnow5.writeBlock
				
				cmp dword [ebx+Minnow5.Block_type], Minnow5.BLOCK_TYPE_DATA
					je .noset
				cmp dword [ebx+Minnow5.Block_innerPointer], null
					je .noset
				push dword [ebx+Minnow5.Block_innerPointer]
				inc edx
				.noset :
				
				cmp dword [ebx+Minnow5.Block_nextPointer], null
					je .noset2
				push dword [ebx+Minnow5.Block_nextPointer]
				inc edx
				.noset2 :
				
				jmp .invLoop
			
			.invDone :
		
	popa
	methodTraceLeave
	ret
	
	.inner :
		dd 0x0
	.block :
		dd 0x0
	
