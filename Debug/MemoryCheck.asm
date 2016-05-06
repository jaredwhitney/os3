MemoryCheck.run :
	pusha
		mov ebx, MemoryCheck.START_STR
		call TextMode.println
		
		mov ebx, 0x3000000
		mov edx, 0x3000000
		.loop :
		mov ecx, [ebx]
		inc ecx
		mov [ebx], ecx
		wbinvd
		cmp ecx, [ebx]
			jne .fail
		.cont :
		dec ecx
		mov [ebx], ecx
		add ebx, 0x4	; check a dword from every 31 bytes
		sub edx, 0x4	; check a dword from every 31 bytes
			push edx
			push ebx
			and edx, 0xFFFF
			cmp edx, 0x0
				jne .noprint
			push eax
			mov eax, MemoryCheck.WORKING_NUM
			mov ebx, [esp+4]
			call String.fromHex
			pop eax
			mov ebx, MemoryCheck.WORKING_STR
			call TextMode.println
			.noprint :
			pop ebx
			pop edx
		cmp edx, 0x0
			jg .loop
		mov ebx, MemoryCheck.DONE_STR
		call TextMode.println
	popa
	ret
	.fail :
	push ebx
	mov ebx, MemoryCheck.ERR_STR
	call TextMode.print
	pop ebx
	mov eax, ebx
	call DebugLogEAX
	call TextMode.newline
	jmp .cont
MemoryCheck.ERR_STR :
	db "Possible error at 0x", 0
MemoryCheck.DONE_STR :
	db "Memory check finished.", 0
MemoryCheck.WORKING_STR :
	db "Still working... "
MemoryCheck.WORKING_NUM :
	times 3 dq 0
MemoryCheck.START_STR :
	db "Begin MemoryCheck...", 0