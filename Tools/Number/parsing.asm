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
		.loop :
		mov al, [ebx]
		cmp al, 0x30
			jl .loopDone
		cmp al, 0x39
			jg .loopDone
		sub al, 0x30	; get the num from the char
		imul ecx, 10
		add ecx, eax
		inc ebx
		jmp .loop
		.loopDone :
		cmp byte [.neg], true
			jne .dontFlip
		imul ecx, -1
		.dontFlip :
		
	pop eax
	pop ebx
	ret
.neg :
	db 0x0