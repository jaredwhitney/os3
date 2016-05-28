SimpleRender.drawLine :	; L3gxImage image, int x1, int y1, int x2, int y2
	pop dword [.retval]
	pop dword [.y2]
	pop dword [.x2]
	pop dword [.y1]
	pop dword [.x1]
	pop dword [.image]
	pusha
		mov eax, [.x1]
		mov ebx, [.y1]
		mov ecx, [.x2]
		mov edx, [.y2]
		cmp eax, ecx
			jl .noFix
		xchg eax, ecx
		mov [.x1], eax
		mov [.x2], ecx
		xchg ebx, edx
		mov [.y1], ebx
		mov [.y2], edx
		.noFix :
		mov [.drawX], eax
		sub eax, ecx
		sub ebx, edx
		mov [.dx], eax
		mov [.dy], ebx
		cmp ebx, 0
			jge .dyK
		imul ebx, -1
		.dyK :
		cmp eax, 0
			jge .dxK
		imul eax, -1
		.dxK :
		cmp eax, ebx
			jb SimpleRender.drawLineVertical
		
		fild dword [.dy]
		fidiv dword [.dx]
		fstp dword [.m]
		
		fild dword [.y1]
		fstp dword [.yacc]
		
		mov eax, [.image]
		mov ebx, [eax+L3gxImage_data]
		mov edx, [eax+L3gxImage_w]
		shl edx, 2
		mov [.width], edx
		mov edx, [.x1]
		shl edx, 2
		add ebx, edx
		mov [.bufPos], ebx
		
		
		mov ecx, [.x2]
		
		.loop :
		fld dword [.yacc]
		fadd dword [.m]
		fst dword [.yacc]
		fistp dword [.drawY]
		inc dword [.drawX]
			
			; plot pixel
			
			add dword [.bufPos], 4
			
			cmp dword [.drawY], 0
				jl .noDraw
			cmp dword [.drawY], 400
				jge .noDraw
			cmp dword [.drawX], 0
				jl .noDraw
			cmp dword [.drawX], 400
				jge .noDraw
			
			pusha
			mov eax, [.drawY]
			imul eax, [.width]
			mov ebx, [.bufPos]
			add ebx, eax
			mov dword [ebx], 0xFF00FF00
			popa
			
			.noDraw :
			
		cmp dword [.drawX], ecx
			jl .loop
	.ret :
	popa
	push dword [.retval]
	ret
.retval :
	dd 0x0
.image :
	dd 0x0
.x1 :
	dd 0x0
.x2 :
	dd 0x0
.y1 :
	dd 0x0
.y2 :
	dd 0x0
.drawX :
	dd 0x0
.drawY :
	dd 0x0
.m :
	dd 0.5
.yacc :
	dd 0x0
.bufPos :
	dd 0x0
.width :
	dd 0x0
.dx :
	dd 0x0
.dy :
	dd 0x0
	
SimpleRender.drawLineVertical :
	mov eax, [SimpleRender.drawLine.retval]
	mov [.retval], eax
	mov eax, [SimpleRender.drawLine.y2]
	mov [.y2], eax
	mov eax, [SimpleRender.drawLine.x2]
	mov [.x2], eax
	mov eax, [SimpleRender.drawLine.y1]
	mov [.y1], eax
	mov eax, [SimpleRender.drawLine.x1]
	mov [.x1], eax
	mov eax, [SimpleRender.drawLine.dx]
	mov [.dx], eax
	mov eax, [SimpleRender.drawLine.dy]
	mov [.dy], eax
	mov eax, [SimpleRender.drawLine.image]
	mov [.image], eax
		
		mov eax, [.x1]
		mov ebx, [.y1]
		mov ecx, [.x2]
		mov edx, [.y2]
		cmp ebx, edx
			jl .noFix
		xchg eax, ecx
		mov [.x1], eax
		mov [.x2], ecx
		xchg ebx, edx
		mov [.y1], ebx
		mov [.y2], edx
		.noFix :
		mov [.drawY], ebx
		sub eax, ecx
		sub ebx, edx
		mov [.dx], eax
		mov [.dy], ebx
		cmp dword [.dy], 0
			je .ret
		
		fild dword [.dx]
		fidiv dword [.dy]
		fstp dword [.m]
		
		fild dword [.x1]
		fstp dword [.xacc]
		
		mov eax, [.image]
		mov ebx, [eax+L3gxImage_data]
		mov edx, [eax+L3gxImage_h]
		shl edx, 2
		mov [.height], edx
		mov edx, [eax+L3gxImage_w]
		shl edx, 2
		mov [.width], edx
		mov edx, [.y1]
		imul edx, [.width]
		add ebx, edx
		mov [.bufPos], ebx
		
		
		mov ecx, [.y2]
		
		.loop :
		fld dword [.xacc]
		fadd dword [.m]
		fst dword [.xacc]
		fistp dword [.drawX]
		inc dword [.drawY]
			
			; plot pixel
			
			mov eax, [.width]
			add dword [.bufPos], eax
			
			cmp dword [.drawY], 0
				jl .noDraw
			cmp dword [.drawY], 400
				jge .noDraw
			cmp dword [.drawX], 0
				jl .noDraw
			cmp dword [.drawX], 400
				jge .noDraw
			
			pusha
			mov eax, [.drawX]
			shl eax, 2
			mov ebx, [.bufPos]
			add ebx, eax
			mov dword [ebx], 0xFF00FF00
			popa
			
			.noDraw :
			
		cmp dword [.drawY], ecx
			jl .loop
	.ret :
	popa
	push dword [.retval]
	ret
.retval :
	dd 0x0
.image :
	dd 0x0
.x1 :
	dd 0x0
.x2 :
	dd 0x0
.y1 :
	dd 0x0
.y2 :
	dd 0x0
.drawX :
	dd 0x0
.drawY :
	dd 0x0
.m :
	dd 0.5
.xacc :
	dd 0x0
.bufPos :
	dd 0x0
.width :
	dd 0x0
.height :
	dd 0x0
.dx :
	dd 0x0
.dy :
	dd 0x0