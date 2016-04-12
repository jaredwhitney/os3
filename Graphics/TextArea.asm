Textarea_type				equ 0
Textarea_image				equ 4
Textarea_x					equ 8
Textarea_y					equ 12
Textarea_w					equ 16
Textarea_h					equ 20
Textarea_text				equ Component_CLASS_SIZE
Textarea_len				equ Component_CLASS_SIZE+4
Textarea_scrolls			equ Component_CLASS_SIZE+8
Textarea_customKeyHandler	equ Component_CLASS_SIZE+12

TextArea.Create :	; int buflen, int x, int y, int w, int h, bool[as int] scrolls
	pop dword [TextArea.Create.retval]
	pop dword [TextArea.Create.scrolls]
	pop dword [TextArea.Create.h]
	pop dword [TextArea.Create.w]
	pop dword [TextArea.Create.y]
	pop dword [TextArea.Create.x]
	pop dword [TextArea.Create.len]
	push eax
	push ebx
		mov ebx, Component_CLASS_SIZE+16
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
		mov eax, [TextArea.Create.scrolls]
		mov [ebx+Textarea_scrolls], eax
		mov dword [ebx+Textarea_type], Component.TYPE_TEXTAREA
		mov dword [ebx+Component_transparent], TRUE
		mov dword [ebx+Component_renderFunc], TextArea.Render
		mov dword [ebx+Component_keyHandlerFunc], TextArea.onKeyboardEvent.handle
		mov dword [ebx+Textarea_customKeyHandler], TextArea.onKeyboardEvent.handle	; redundant and should be removed
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
TextArea.Create.scrolls :
	dd 0x0
TextArea.Render :	; textarea in ebx [NEED TO MAKE THIS NOT RENDER TEXT THAT WOULD BE DRAWN OUTSIDE THE TEXTAREA]
	pusha
			push ebx
				mov edx, ebx
				mov eax, [edx+Component_image]
				mov ecx, [edx+Component_w]
				imul ecx, [edx+Component_h]
				mov ebx, 0x00000000
				mov edx, ecx
				call Image.clear
			pop ebx
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
		mov ebx, 0xFFFFFFFF
		call RenderText
		pop ebx
		cmp al, 0x0A
			jne TextArea.Render.noNewl
			mov eax, [TextArea.Render.dest]
			add eax, [ebx+Textarea_w]
			mov [TextArea.Render.dest], eax
		TextArea.Render.noNewl :
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
		call TextArea.AppendChar
		add edx, 1
		sub ecx, 1
		cmp ecx, 0
			jg TextArea.SetText.loop
		call Component.RequestUpdate
	popa
	ret
TextArea.AppendChar :	; char in al, textarea in ebx [version that stops extra text from being rendered]
	cmp dword [ebx+Textarea_scrolls], 0xFF
		je TextArea.AppendCharScrolling
	pusha
		mov ecx, [ebx+Textarea_len]
		push ebx
			mov ebx, [ebx+Textarea_text]
			call String.getLength
			cmp edx, ecx
				jl TextArea.AppendChar.cont	; should also check to see if coord would be out of bounds
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
		push ebx
			mov ebx, [ebx+Textarea_text]
			call String.getLength
			pop ebx
			cmp edx, ecx
				jge TextArea.AppendCharScrolling.goRun 
			;jmp TextArea.AppendCharScrolling.cont
					pusha
					call TextArea.getMaxUsablePos	;check to see if coord would be out of bounds
					call TextArea.getNextCharPos
					cmp edx, ecx
					popa
						jl TextArea.AppendCharScrolling.cont
			TextArea.AppendCharScrolling.goRun :
			pop ebx
			; copy Buffer text+1 of length len-1 to Buffer text of length len-1
			pusha
			mov eax, [ebx+Textarea_text]
			mov ecx, [ebx+Textarea_len]
			sub ecx, 1
			mov edx, 1
			push ebx
			mov ebx, eax
			add eax, 1
			call Image.copyLinear
			pop ebx
			mov eax, [ebx+Textarea_image]
			mov edx, [ebx+Textarea_h]
			imul edx, [ebx+Textarea_w]
			mov ebx, 0x0
			call Image.clear
			popa
			push ebx
			sub edx, 1
		TextArea.AppendCharScrolling.cont :
		pop ebx
		mov ecx, [ebx+Textarea_text]
		add ecx, edx
		sub ecx, 1
		mov [ecx], al
	popa
	ret
TextArea.getMaxUsablePos :	; TextArea in ebx, returns in ecx
		mov ecx, [ebx+Textarea_h]
		sub ecx, FONTHEIGHT-1
		imul ecx, [ebx+Textarea_w]
		sub ecx, FONTWIDTH
	ret
TextArea.getNextCharPos :	; TextArea in ebx, returns in edx
	pusha
		push ebx
			mov ebx, [ebx+Textarea_text]
			call String.getLength
			sub edx, 1
			mov ecx, edx
		pop ebx
		;mov edx, [ebx+Textarea_image]
		mov dword [TextArea.RenderProto.dest], 0;edx
				mov edx, [TextArea.RenderProto.dest]
				add edx, [ebx+Textarea_w]
				mov [TextArea.RenderProto.nextFlip], edx
						mov edx, [TextArea.RenderProto.dest]
						mov eax, [ebx+Textarea_w]
						imul eax, FONTHEIGHT+4
						add edx, eax
						mov [TextArea.RenderProto.flipTo], edx
		xor edx, edx
		TextArea.RenderProto.loop :
		pusha
		mov eax, [ebx+Textarea_text]
		add eax, edx	; now [eax] = char
		mov al, [eax]	; al = char
		mov ecx, [TextArea.RenderProto.dest]
		mov edx, [ebx+Textarea_w]
		cmp al, 0x0A
			jne TextArea.RenderProto.noNewl
			mov eax, [TextArea.RenderProto.dest]
			add eax, [ebx+Textarea_w]
			mov [TextArea.RenderProto.dest], eax
		TextArea.RenderProto.noNewl :
		mov eax, [TextArea.RenderProto.dest]
		add eax, FONTWIDTH*4
		mov [TextArea.RenderProto.dest], eax
		cmp eax, [TextArea.RenderProto.nextFlip]
			jb TextArea.RenderProto.loop.noflip
		call TextArea.RenderProto.calcFlips
		TextArea.RenderProto.loop.noflip :
		popa
		add edx, 1
		sub ecx, 1
		cmp ecx, 0
			jg TextArea.RenderProto.loop
	popa
	mov edx, [TextArea.RenderProto.dest]
	;sub edx, [ebx+Textarea_image]
	ret
TextArea.RenderProto.calcFlips :
	pusha
		mov edx, [TextArea.RenderProto.flipTo]
		mov [TextArea.RenderProto.dest], edx
		mov edx, [TextArea.RenderProto.dest]
		add edx, [ebx+Textarea_w]
		mov [TextArea.RenderProto.nextFlip], edx
		mov edx, [TextArea.RenderProto.dest]
		mov eax, [ebx+Textarea_w]
		imul eax, FONTHEIGHT+4
		add edx, eax
		mov [TextArea.RenderProto.flipTo], edx
	popa
	ret

TextArea.RenderProto.dest :
	dd 0x0
TextArea.RenderProto.nextFlip :
	dd 0x0
TextArea.RenderProto.flipTo :
	dd 0x0

TextArea.onKeyboardEvent :
	pusha
		call dword [ebx+Textarea_customKeyHandler]
	popa
	ret
	
TextArea.onKeyboardEvent.handle :
	pusha
		mov al, [Component.keyChar]
		cmp al, 0xff
			je TextArea.onKeyboardEvent.handleBackspace
		call TextArea.AppendChar
		call Component.RequestUpdate
	popa
	ret
TextArea.onKeyboardEvent.handleBackspace :
		push ebx
		mov ebx, [ebx+Textarea_text]
		call String.getLength
		cmp edx, 1
			jle TextArea.onKeyboardEvent.handleBackspace.ret
		add ebx, edx
		sub ebx, 2
		mov byte [ebx], 0
		TextArea.onKeyboardEvent.handleBackspace.ret :
		pop ebx
		call Component.RequestUpdate
	popa
	ret

; Also make TextAreaScrollable (TextArea with scroll functions that modify which parts of the buffer are displayed at any given time)