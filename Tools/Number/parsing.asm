Integer.decimalFromString :	; String in ebx, returns num in ecx
	push ebx
	push eax
	
		xor ecx, ecx
		xor eax, eax
		cmp byte [ebx], '-'
			jne .notNeg
		mov byte [.neg], TRUE
		inc ebx
		.notNeg :
		mov al, [ebx]
		cmp al, 0x0
			jmp .loopDone
		sub al, 0x30	; get the num from the char
		imul ecx, 10
		add ecx, eax
		inc ebx
		jmp .loop
		.loopDone :
		
	pop eax
	pop ebx
	ret
