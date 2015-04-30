os.seq :
	push ebx
	push ecx
	push edx
	seq.loop_0.start :
		mov cl, [eax]
		mov dl, [ebx]
		cmp cl, 0
			je seq.loop_0.go
		cmp cl, dl
			jne seq.loop_0.end
		add eax, 1
		add ebx, 1
		jmp seq.loop_0.start
	seq.loop_0.go :
		pop edx
		pop ecx
		pop ebx
		mov al, 0x1
		ret
	seq.loop_0.end :
		pop edx
		pop ecx
		pop ebx
		mov al, 0x0
		ret

os.lenientStringMatch :	; eax is null-terminated, ebx is NOT; return in dh
	push ecx
	push ebx
	os.lenientStringMatch.loop :
		mov cl, [eax]
		mov ch, [ebx]
		
		add eax, 1
		add ebx, 1
		cmp cl, ch
			je os.lenientStringMatch.loop
		cmp cl, 0x0
			je os.lenientStringMatch.equal
		sub eax, 1
		os.lenientStringMatch.eloop :
		mov cl, [eax]
		add eax, 1
		cmp cl, 0x0
		jne os.lenientStringMatch.eloop
	mov dh, 0x0
	jmp os.lenientStringMatch.ret
	os.lenientStringMatch.equal :
	mov dh, 0xFF
	os.lenientStringMatch.ret :
	call debug.newl
	pop ebx
	pop ecx
	ret
	
	