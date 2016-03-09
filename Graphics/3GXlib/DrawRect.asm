L3gx.lineRect :	; L3gxImage image, int x, int y, int width, int height, int Color
	pop dword [lineRect.retval]
	pop dword [lineRect.color]
	pop dword [lineRect.h]
	pop dword [lineRect.w]
	pop dword [lineRect.y]
	pop dword [lineRect.x]
	pop dword [lineRect.image]
	pusha
		mov edx, [lineRect.image]
		mov ebx, [lineRect.y]
		imul ebx, [edx+L3gxImage_w]
		mov ecx, [lineRect.x]
		shl ecx, 2	; mul by 4
		add ebx, ecx
		add ebx, [edx+L3gxImage_data]
		mov [lineRect.workingLoc], ebx
		
		mov ecx, [lineRect.w]
		;shr ecx, 2	; div by 4 so its width in pixels
		mov edx, [lineRect.color]
		lineRect.loop0 :
		mov [ebx], edx
		add ebx, 4
		dec ecx
		cmp ecx, 0
			jg lineRect.loop0
		
		mov edx, [lineRect.image]
		mov eax, [edx+L3gxImage_w]
		sub eax, [lineRect.w]
		mov ebx, [lineRect.workingLoc]
		mov ecx, [lineRect.h]
		mov edx, [lineRect.color]
		lineRect.loop1 :
		mov [ebx], edx
		add ebx, [lineRect.w]
		mov [ebx], edx
		add ebx, eax
		dec ecx
		cmp ecx, 0
			jg lineRect.loop1
		
		mov edx, [lineRect.image]
		sub ebx, [edx+L3gxImage_w]
		mov ecx, [lineRect.w]
		shr ecx, 2
		mov edx, [lineRect.color]
		lineRect.loop2 :
		mov [ebx], edx
		add ebx, 4
		dec ecx
		cmp ecx, 0
			jg lineRect.loop2
	popa
	push dword [lineRect.retval]
	ret
lineRect.retval :
	dd 0x0
lineRect.color :
	dd 0x0
lineRect.x :
	dd 0x0
lineRect.y :
	dd 0x0
lineRect.w :
	dd 0x0
lineRect.h :
	dd 0x0
lineRect.image :
	dd 0x0
lineRect.workingLoc :
	dd 0x0

L3gx.fillRect :	; L3gxImage image, int x, int y, int w, int h, int Color
	pop dword [fillRect.retval]
	pop dword [fillRect.color]
	pop dword [fillRect.h]
	pop dword [fillRect.w]
	pop dword [fillRect.y]
	pop dword [fillRect.x]
	pop dword [fillRect.image]
	pusha
		mov eax, [fillRect.color]
		mov [fillRect.kcol+0x0], eax
		mov [fillRect.kcol+0x4], eax
		mov [fillRect.kcol+0x8], eax
		mov [fillRect.kcol+0xC], eax
		movdqu xmm0, [fillRect.kcol]
		mov eax, [fillRect.image]
		mov eax, [ebx+L3gxImage_w]
		sub eax, [fillRect.w]	; amount that needs to be added each line
		mov [fillRect.addBack], eax
		mov eax, [fillRect.w]
		shr eax, 2	; 4 pixels per move... eax is the number of movdqu's
		mov ebx, eax
		shl ebx, 2
		mov ecx, [fillRect.w]
		sub ecx, ebx	; ecx is the number of leftover pixels
		push eax
		mov eax, [fillRect.image]
		mov ebx, [eax+L3gxImage_data]
		mov edx, [fillRect.x]
		shl edx, 2	; mul by 4
		add ebx, edx
		mov edx, [fillRect.y]
		imul edx, [eax+L3gxImage_w]
		add ebx, edx	; ebx is the location in the image
		pop eax
		mov edx, [fillRect.color]
		fillRect.loop :
			push eax
			fillRect.innerLoop0 :
				movdqu [ebx], xmm0
				dec eax
				add ebx, 4*4	; 4 pixels
				cmp eax, 0x0
					jg fillRect.innerLoop0
			mov eax, ecx
			fillRect.innerLoop1 :
				cmp eax, 0x0
					jle fillRect.innerLoop1_end
				mov [ebx], edx
				add ebx, 4*1	; 1 pixel
				dec eax
				jmp fillRect.innerLoop1
			fillRect.innerLoop1_end :
			pop eax
			add ebx, [fillRect.addBack]
			dec dword [fillRect.h]
			cmp dword [fillRect.h], 0x0
				jg fillRect.loop
	popa
	push dword [fillRect.retval]
	ret
fillRect.retval :
	dd 0x0
fillRect.color :
	dd 0x0
fillRect.image :
	dd 0x0
fillRect.x :
	dd 0x0
fillRect.y :
	dd 0x0
fillRect.w :
	dd 0x0
fillRect.h :
	dd 0x0
fillRect.addBack :
	dd 0x0
fillRect.kcol :
	dq 0x0, 0x0