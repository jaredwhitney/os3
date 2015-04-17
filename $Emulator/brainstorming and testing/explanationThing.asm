	Syntax.highlight.internal_1 :
		push eax	; push things
		push ebx
		push edx
		
		mov ebx, ecx	; move bufferloc to ecx
		
		Syntax.highlight_6 :
		mov cl, [eax]	; grab the value of the array to check
		call os.lenientStringMatch	; returns 0x0 or 0xFF in dh, auto-increments eax
		cmp dh, 0xFF
		jne Syntax.highlight_7	; if they were equal
		mov dl, ORANGE	; make the color orange
		mov dh, 0xFF
		mov [Syntax.highlight.set], dh	; do not change the highlight until the end of the block
		Syntax.highlight_7 :	; endif
		cmp cl, 0xFF	; check to see if the value of the array was 0xFF (if it was, at end of array)
		jne Syntax.highlight_6	; if not at the end of the array, loop
		
		pop edx	; pop things
		pop ebx
		pop eax
		
		ret	; return
		