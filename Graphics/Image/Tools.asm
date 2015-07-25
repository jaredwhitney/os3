Image.copy :	; eax = source, ebx = dest, cx = width, dx = height
	pusha
	mov [bstor], ebx
	Image.wupdate.loop0 :
		push cx
		Image.wupdate.loop1 :
			push eax
			mov eax, [eax]
					;cmp byte [Image_checkChange], 0xFF
					;	jne Image.wupdate.nobother
					;test eax, CHANGE_MASK
					;	jne Image.wupdate.nobother
					;jmp Image.wupdate.notnew
					;Image.wupdate.nobother :
									;or eax, CHANGE_MASK
				;Image.wupdate.notnew :
			mov [ebx], eax
			pop eax
			add ebx, 4
			add eax, 4
			sub cx, 4
			cmp cx, 0
				jg Image.wupdate.loop1
			pop cx
			sub dx, 1

			push eax
			push ecx
			push edx
			mov eax, ebx
			sub eax, [bstor]
			mov ecx, [Graphics.SCREEN_WIDTH]
			push eax
			mov edx, 0x0
			div ecx
			pop eax
			cmp edx, 0
				je Debug.wupdate.noadd
			mov ecx, [Graphics.SCREEN_WIDTH]
			sub ecx, edx
			mov edx, ecx
			add eax, edx	; edx = remainder
		Debug.wupdate.noadd :
			add eax, [bstor]
			mov ebx, eax
			pop edx
			pop ecx
			pop eax
			cmp dx, 0
				jg Image.wupdate.loop0
	popa
	ret
	
Image.copyLinear :	; eax = source, ebx = dest, ecx = width, edx = height
	pusha
	imul ecx, edx
	Image.copyLinear_loop :
	mov edx, [eax]
							or eax, CHANGE_MASK
	mov [ebx], edx
	add eax, 4
	add ebx, 4
	sub ecx, 4
	cmp ecx, 0x0
	jge Image.copyLinear_loop
	popa
	ret
	
Image.clear :	; eax = source, edx = size, ebx = color
	pusha
	mov ecx, edx
	sub ecx, 2
	mov edx, 0x0
						or ebx, CHANGE_MASK
	Image.clear_loop :
	mov [eax], ebx
	add eax, 4
	add edx, 4
	cmp edx, ecx
	jle Image.clear_loop
	popa
	ret
	
Image_checkChange :
	db 0x0
