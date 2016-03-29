Image.copy :	; eax = source, ebx = dest, cx = width, dx = height
	pusha
	push dword [bstor]
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
	pop dword [bstor]
	popa
	ret
	
Image.copyLinear :	; eax = source, ebx = dest, ecx = width, edx = height [IS BROKEN!!!]
	pusha
		mov ecx, ebx
		imul edx, ecx
		push eax
		push ecx
		mov eax, edx
		xor edx, edx
		mov ecx, 0x80
		idiv ecx
		mov ebx, eax
		pop ecx
		pop eax
		Image.copyLinear_loop :
			movdqu xmm0, [ecx]
			movdqu xmm1, [ecx+0x10]
			movdqu xmm2, [ecx+0x20]
			movdqu xmm3, [ecx+0x30]
			movdqu xmm4, [ecx+0x40]
			movdqu xmm5, [ecx+0x50]
			movdqu xmm6, [ecx+0x60]
			movdqu xmm7, [ecx+0x70]
			movdqu [eax], xmm0
			movdqu [eax+0x10], xmm1
			movdqu [eax+0x20], xmm2
			movdqu [eax+0x30], xmm3
			movdqu [eax+0x40], xmm4
			movdqu [eax+0x50], xmm5
			movdqu [eax+0x60], xmm6
			movdqu [eax+0x70], xmm7
			add eax, 0x80
			dec ebx
			cmp ebx, 0
				jg Image.copyLinear_loop
		Image.copyLinear_loop2 :
			cmp edx, 0
				jle Image.copyLinear_ret
			mov [eax], ecx
			add eax, 4
			sub edx, 4
			jmp Image.copyLinear_loop2
	Image.copyLinear_ret :
	popa
	ret
	
Image.clear :	; eax = source, edx = size, ebx = color
	pusha
		mov ecx, ebx
		mov [Image.clear.color+0x0], ecx
		mov [Image.clear.color+0x4], ecx
		mov [Image.clear.color+0x8], ecx
		mov [Image.clear.color+0xC], ecx
		movdqu xmm0, [Image.clear.color]
		push eax
		push ecx
		mov eax, edx
		xor edx, edx
		mov ecx, 0x100
		idiv ecx
		mov ebx, eax
		pop ecx
		pop eax
		Image.clear_loop :
			movdqu [eax], xmm0
			movdqu [eax+0x10], xmm0
			movdqu [eax+0x20], xmm0
			movdqu [eax+0x30], xmm0
			movdqu [eax+0x40], xmm0
			movdqu [eax+0x50], xmm0
			movdqu [eax+0x60], xmm0
			movdqu [eax+0x70], xmm0
			movdqu [eax+0x80], xmm0
			movdqu [eax+0x90], xmm0
			movdqu [eax+0xA0], xmm0
			movdqu [eax+0xB0], xmm0
			movdqu [eax+0xC0], xmm0
			movdqu [eax+0xD0], xmm0
			movdqu [eax+0xE0], xmm0
			movdqu [eax+0xF0], xmm0
			add eax, 0x100
			dec ebx
			cmp ebx, 0
				jg Image.clear_loop
		Image.clear_loop2 :
			cmp edx, 0
				jle Image.clear_ret
			mov [eax], ecx
			add eax, 4
			sub edx, 4
			jmp Image.clear_loop2
	Image.clear_ret :
	popa
	ret

Image.clear.color :
	times 2 dq 0

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

Image.copyRegion :
	pusha
		mov eax, [Image.copyRegion.ow]
		sub eax, [Image.copyRegion.w]
		;sub eax, 4
		mov [Image.copyRegion.owa], eax
		mov eax, [Image.copyRegion.nw]
		sub eax, [Image.copyRegion.w]
		;sub eax, 4
		mov [Image.copyRegion.nwa], eax

		mov edx, [Image.copyRegion.h]
		mov eax, [Image.copyRegion.obuf]
		mov ebx, [Image.copyRegion.nbuf]
		Image.copyRegion.loop1 :
			push edx
			mov edx, [Image.copyRegion.w]
			Image.copyRegion.loop2 :
				mov ecx, [eax]
				or ecx, 0xFF000000	; full transparency
				mov [ebx], ecx
				add eax, 4
				add ebx, 4
				sub edx, 4
				cmp edx, 0x0
					jg Image.copyRegion.loop2
			pop edx
			add ebx, [Image.copyRegion.nwa]
			add eax, [Image.copyRegion.owa]
			sub edx, 1
			cmp edx, 0x0
				jg Image.copyRegion.loop1
	popa
	ret
Image.copyRegion.w :
	dd 0x0
Image.copyRegion.ow :
	dd 0x0
Image.copyRegion.nw :
	dd 0x0
Image.copyRegion.h :
	dd 0x0
Image.copyRegion.obuf :
	dd 0x0
Image.copyRegion.nbuf :
	dd 0x0
Image.copyRegion.owa :
	dd 0x0
Image.copyRegion.nwa :
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
