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
	;						or eax, CHANGE_MASK
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

Image.clearRegion :	; eax = ulcoord, ebx = width, ecx = height, edx = color
pusha
	Image.clearRegion.loop1 :
		; store lineflip
		push eax
		add eax, ebx
		mov [Image.clearRegion.lineFlip], eax
		pop eax
			
		Image.clearRegion.loop0 :
		mov [eax], edx
		add eax, 4
		cmp eax, [Image.clearRegion.lineFlip]
			jl Image.clearRegion.loop0
	add eax, [Image.clearRegion.imagewidth]
	sub eax, ebx
	
	sub ecx, 1
	cmp ecx, 0
		jne Image.clearRegion.loop1
popa
ret
Image.clearRegion.imagewidth :
	dd 0x0
Image.clearRegion.lineFlip :
	dd 0x0


Image.copyFromWinSource :	; eax = source, ebx = dest, cx = regionWidth, dx = regionHeight, currentWindow = window
pusha
	and ecx, 0xFFFF
	and edx, 0xFFFF
	
	mov [Image.source], eax
	mov [Image.dest], ebx
	mov [Image.regionWidth], cx
	mov bl, [Window.WIDTH]
	call Dolphin.getAttribDouble
	mov [Image.width], eax
	sub eax, ecx
	mov [Image.w_width], eax
	mov eax, [Graphics.SCREEN_WIDTH]
	sub eax, ecx
	mov [Image.w2_width], eax
	mov bl, [Window.WINDOWBUFFER]
	call Dolphin.getAttribDouble
	mov [Image.WinBufPos], eax
	
	call Image.cFWS.fixDest
	
	mov eax, [Image.source]
	mov ebx, [Image.dest]
	
	; dx = regionHeight
	Image.cFWS.loop1 :
	;{
		; cx = regionWidth
		mov cx, [Image.regionWidth]
		Image.cFWS.loop2 :
		;{
			push cx
			mov cl, [eax]
			mov [ebx], cl
			add eax, 1
			add ebx, 1
			pop cx
		;}
		sub cx, 1
		cmp cx, 0
			jg Image.cFWS.loop2
		
		add eax, [Image.w_width]
		add ebx, [Image.w2_width]
	;}
		sub dx, 1
		cmp dx, 0
			jg Image.cFWS.loop1
popa
ret

Image.cFWS.fixDest :	; dest in [Image.dest]
pusha
	xor edx, edx
	mov eax, [Image.source]
	sub eax, [Image.WinBufPos]
	mov ecx, [Image.width]
	idiv ecx
	mov ecx, [Graphics.SCREEN_WIDTH]
	sub ecx, [Image.width]
	imul ecx;(screenwidth-imagewidth)
	add eax, [Image.dest]
	mov [Image.dest], eax
popa
ret

Image.source :
	dd 0x0
Image.dest :
	dd 0x0
Image.w_width :
	dd 0x0
Image.w2_width :
	dd 0x0
Image.regionWidth :
	dd 0x0
Image.width :
	dd 0x0
Image.WinBufPos :
	dd 0x0
	
Image_checkChange :
	db 0x0
