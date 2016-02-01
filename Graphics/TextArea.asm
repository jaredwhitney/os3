Textarea_type	equ 0
Textarea_image	equ 4
Textarea_x		equ 8
Textarea_y		equ 12
Textarea_w		equ 16
Textarea_h		equ 20
Textarea_text	equ 28
Textarea_len	equ 32
Textarea_isE	equ 36

TextArea.Create :	; int buflen, int x, int y, int w, int h
	pop dword [TextArea.Create.retval]
	pop dword [TextArea.Create.h]
	pop dword [TextArea.Create.w]
	pop dword [TextArea.Create.y]
	pop dword [TextArea.Create.x]
	pop dword [TextArea.Create.len]
	push eax
	push ebx
		mov ebx, 40
		call ProgramManager.reserveMemory
		mov eax, [TextArea.Create.len]
		mov [ebx+Textarea_len], eax
		pusha
			mov edx, ebx
			mov ebx, eax
			call ProgramManager.reserveMemory
			mov [edx+Textarea_text], ebx
		popa
		mov eax, [TextArea.Create.x]
		mov [ebx+Textarea_x], eax
		mov eax, [TextArea.Create.y]
		mov [ebx+Textarea_y], eax
		mov eax, [TextArea.Create.w]
		mov [ebx+Textarea_w], eax
		mov eax, [TextArea.Create.h]
		mov [ebx+Textarea_h], eax
		pusha
			mov edx, ebx
			mov eax, [ebx+Textarea_w]
			imul eax, [ebx+Textarea_h]
			mov ebx, eax
			call ProgramManager.reserveMemory
			mov [edx+Textarea_image], ebx
		popa
		mov dword [ebx+Textarea_type], Component.TYPE_TEXTAREA
		mov byte [ebx+Textarea_isE], 0x00
		mov ecx, ebx
	pop ebx
	pop eax
	push dword [TextArea.Create.retval]
	ret
TextArea.Create.retval :
	dd 0x0
TextArea.Create.x :
	dd 0x0
TextArea.Create.y :
	dd 0x0
TextArea.Create.w :
	dd 0x0
TextArea.Create.h :
	dd 0x0
TextArea.Create.len :
	dd 0x0
TextArea.Render :	; textarea in ebx [NEED TO MAKE THIS NOT RENDER TEXT THAT WOULD BE DRAWN OUTSIDE THE TEXTAREA]
	pusha
		push ebx
			mov ebx, [ebx+Textarea_text]
			call String.getLength
			sub edx, 1
			mov ecx, edx
		pop ebx
		mov edx, [ebx+Textarea_image]
		mov [TextArea.Render.dest], edx
				mov edx, [TextArea.Render.dest]
				add edx, [ebx+Textarea_w]
				mov [TextArea.Render.nextFlip], edx
						mov edx, [TextArea.Render.dest]
						mov eax, [ebx+Textarea_w]
						imul eax, FONTHEIGHT+4
						add edx, eax
						mov [TextArea.Render.flipTo], edx
		xor edx, edx
		TextArea.Render.loop :
		pusha
		mov eax, [ebx+Textarea_text]
		add eax, edx	; now [eax] = char
		mov al, [eax]	; al = char
		mov ecx, [TextArea.Render.dest]
		mov edx, [ebx+Textarea_w]
		push ebx
		mov ebx, 0xFFFFFF
		call RenderText
		pop ebx
		; figure out the best way to increment TextArea.Render.dest!
		mov eax, [TextArea.Render.dest]
		add eax, FONTWIDTH*4
		mov [TextArea.Render.dest], eax
		cmp eax, [TextArea.Render.nextFlip]
			jb TextArea.Render.loop.noflip
		call TextArea.Render.calcFlips
		TextArea.Render.loop.noflip :
		popa
		add edx, 1
		sub ecx, 1
		cmp ecx, 0
			jg TextArea.Render.loop
	popa
	ret
TextArea.Render.dest :
	dd 0x0
TextArea.Render.nextFlip :
	dd 0x0
TextArea.Render.flipTo :
	dd 0x0
TextArea.Render.calcFlips :
	pusha
		mov edx, [TextArea.Render.flipTo]
		mov [TextArea.Render.dest], edx
		mov edx, [TextArea.Render.dest]
		add edx, [ebx+Textarea_w]
		mov [TextArea.Render.nextFlip], edx
		mov edx, [TextArea.Render.dest]
		mov eax, [ebx+Textarea_w]
		imul eax, FONTHEIGHT+4
		add edx, eax
		mov [TextArea.Render.flipTo], edx
	popa
	ret
TextArea.SetText :	; text in eax, textarea in ebx
	pusha
		mov ecx, [Textarea_text]
		mov byte [ecx], 0x0
		call TextArea.AppendText
	popa
	ret
TextArea.SetText.obj :
	dd 0x0
TextArea.AppendText :	; text in eax, textarea in ebx
	pusha
		mov edx, eax
		push edx
		push ebx
			mov ebx, edx
			call String.getLength
			mov ecx, edx
		pop ebx
		pop edx
		TextArea.SetText.loop :
		mov al, [edx]	; char
		call TextArea.AppendCharScrolling
		add edx, 1
		sub ecx, 1
		cmp ecx, 0
			jg TextArea.SetText.loop
	popa
	ret
TextArea.AppendChar :	; char in al, textarea in ebx [version that stops extra text from being rendered]
	pusha
		mov ecx, [ebx+Textarea_len]
		push ebx
			mov ebx, [ebx+Textarea_text]
			call String.getLength
			cmp edx, ecx
				jl TextArea.AppendChar.cont
			pop ebx
			popa
			ret
		TextArea.AppendChar.cont :
		pop ebx
		mov ecx, [ebx+Textarea_text]
		add ecx, edx
		sub ecx, 1
		mov [ecx], al
	popa
	ret
TextArea.AppendCharScrolling :	; char in al, textarea in ebx [version that scrolls the buffer]
	pusha
		mov ecx, [ebx+Textarea_len]
		push ebx
			mov ebx, [ebx+Textarea_text]
			call String.getLength
			cmp edx, ecx
				jl TextArea.AppendCharScrolling.cont
			pop ebx
			; copy Buffer text+1 of length len-1 to Buffer text of length len-1
			pusha
			mov eax, [ebx+Textarea_text]
			mov ecx, [ebx+Textarea_len]
			sub ecx, 1
			mov edx, 1
			mov ebx, eax
			add eax, 1
			call Image.copyLinear
			popa
			push ebx
		TextArea.AppendCharScrolling.cont :
		pop ebx
		mov ecx, [ebx+Textarea_text]
		add ecx, edx
		sub ecx, 1
		mov [ecx], al
	popa
	ret