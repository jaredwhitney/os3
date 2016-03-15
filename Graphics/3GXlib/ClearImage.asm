L3gx.clearImage :	; L3gxImage image, int color
	pop dword [clearImage.retval]
	pop dword [clearImage.color]
	pop dword [clearImage.image]
	pusha
		mov ebx, [clearImage.image]
		mov eax, [ebx+L3gxImage_data]
		mov edx, [ebx+L3gxImage_w]
		imul edx, [ebx+L3gxImage_h]
		shl edx, 2	; 4 bytes per pixel
		mov ecx, [clearImage.color]
		mov [clearImage.kcol+0x0], ecx
		mov [clearImage.kcol+0x4], ecx
		mov [clearImage.kcol+0x8], ecx
		mov [clearImage.kcol+0xC], ecx
		movdqu xmm0, [clearImage.kcol]
		push eax
		push ecx
		mov eax, edx
		xor edx, edx
		mov ecx, 0x100
		idiv ecx
		mov ebx, eax
		pop ecx
		pop eax
		clearImage_loop :
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
				jg clearImage_loop
		clearImage_loop2 :
			cmp edx, 0
				jle clearImage_ret
			mov [eax], ecx
			add eax, 4
			sub edx, 4
			jmp clearImage_loop2
	clearImage_ret :
	popa
	push dword [clearImage.retval]
	ret
clearImage.retval :
	dd 0x0
clearImage.image :
	dd 0x0
clearImage.color :
	dd 0x0
clearImage.kcol :
	dq 0x0, 0x0