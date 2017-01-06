L3gx.drawImage :	; L3gxImage dest, L3gxImage source, int x, int y
	pop dword [.retval]
	pop dword [.y]
	pop dword [.x]
	pop dword [.source]
	pop dword [.dest]
	pusha
		
		mov eax, [.dest]
		mov eax, [eax+L3gxImage_w]
		mov ebx, eax
		shl ebx, 2
		mov [.shiftedDestWidth], ebx
		imul eax, [.y]
			mov ebx, eax
			add ebx, [.y]
		add eax, [.x]
			sub ebx, eax
			mov [.copyWidth], ebx	; need to ensure copyWidth < dest.w-x
			add ebx, [.x]
			shl ebx, 2
			cmp ebx, [.shiftedDestWidth]
				jl .noLimitWidth
			mov ebx, [.shiftedDestWidth]
			shr ebx, 2
			mov [.copyWidth], ebx
			.noLimitWidth :	; copyWidth now set [IN PIXELS!]
		
		shl eax, 2	; eax -> ul corner of dest image
		
		mov edx, [.dest]
		add eax, [edx+L3gxImage_data]
		
		mov ecx, [.source]
			mov edx, [ecx+L3gxImage_h]
			mov [.copyHeight], edx	; need to ensure copyHeight < dest.h-y
			add edx, [.y]
			mov ebx, [.dest]
			cmp edx, [ebx+L3gxImage_h]
				jl .noLimitHeight
			mov edx, [ebx+L3gxImage_h]
			mov [.copyHeight], edx
			.noLimitHeight :	; copyHeight now set
		mov edx, [ecx+L3gxImage_w]
		shl edx, 2
		mov [.shiftedSourceWidth], edx
		mov ecx, [ecx+L3gxImage_data]
		
		.loop1 :	; copy a strip of [copyHeight] pixels from ecx to eax (DONT MODIFY EAX OR ECX)
			
			push ecx
			push eax
			
			mov edx, [.copyWidth]
			.loop2 :
			cmp edx, 4
				jl .handlePartialMove
			movdqu xmm0, [ecx]
			movdqu [eax], xmm0
			add eax, 0x10
			add ecx, 0x10
			sub edx, 4
			jmp .loop2
			
			.handlePartialMove :
			.loop3 :
			cmp edx, 0
				jle .innerDone
			mov ebx, [ecx]
			mov [eax], ebx
			add eax, 4
			add ecx, 4
			dec edx
			jmp .loop3
			.innerDone :
			
			pop eax
			pop ecx
		
		add eax, [.shiftedDestWidth]
		add ecx, [.shiftedSourceWidth]
		dec dword [.copyHeight]
		cmp dword [.copyHeight], 0
			jg .loop1
		
	popa
	push dword [.retval]
	ret
	.retval :
		dd 0x0
	.y :
		dd 0x0
	.x :
		dd 0x0
	.source :
		dd 0x0
	.dest :
		dd 0x0
	.shiftedDestWidth :
		dd 0x0
	.shiftedSourceWidth :
		dd 0x0
	.copyHeight :
		dd 0x0
	.copyWidth :
		dd 0x0

L3gx.drawSubImage :	; L3gxImage dest, L3gxImage source, int x, int y, int w, int h
