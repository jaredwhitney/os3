Dolphin.drawTextNew :	; eax = text buffer, ebx = dest, cx = width, edx = old text buffer
pusha
mov byte [Dolphin_WAIT_FLAG], 0xFF
	
		push eax
		mov eax, 0
		mov [Dolphin.dcount], eax
		pop eax
	
	mov [bstor], ebx
	call Dolphin.dTN.checkUnsmartClear
	call Dolphin.dTN.alignTo_start	; text buffer (eax) -> ecx
	
	call Dolphin.dTN.calc_newlineCutoff
	
	Dolphin.drawTextNew.loop :
		call Dolphin.dTN.ccharcheck_ecxedx
		mov bl, [ecx]
		cmp bl, 0x0
			jne Dolphin.drawTextNew.loop
		mov bl, [edx]
		cmp bl, 0x0
			jne Dolphin.drawTextNew.loop
	
	call Dolphin.dTN.updateTempBuffer
	
mov byte [Dolphin_WAIT_FLAG], 0x0
popa
ret

Dolphin.dTN.checkUnsmartClear :
pusha
	push edx
	push edx
		mov ebx, eax
		call String.getLength
		mov ecx, edx
	pop edx
		mov ebx, edx
		call String.getLength
		sub edx, 4
	cmp ecx, edx
	pop edx
		jge Dolphin.dTN.checkUnsmartClear.noShrink
			mov eax, edx
			mov edx, [Graphics.SCREEN_SIZE]
			mov ebx, 0x0
			call Image.clear
		mov eax, [bstor]
		mov edx, [Graphics.SCREEN_SIZE]
		mov ebx, 0x0
		call Image.clear
Dolphin.dTN.checkUnsmartClear.noShrink :
popa
ret

Dolphin.dTN.updateTempBuffer :
pusha
	mov bl, [Window.OLDBUFFER]
	call Dolphin.getAttribDouble
	mov ebx, eax
	push ebx
	mov bl, [Window.BUFFER]
	call Dolphin.getAttribDouble
	pop ebx
	call String.copy
popa
ret

Dolphin.dTN.calc_newlineCutoff :
pusha
	mov ebx, [TextHandler.textWidth]
	add ebx, [TextHandler.charpos]
	sub ebx, 6	; char width-1
	mov [dstor], ebx
popa
ret

Dolphin.dTN.check_newlineCutoff :
pusha
	mov ecx, [TextHandler.charpos]
	cmp ecx, [dstor]
		jle Dolphin.dTN.check_newlineCutoff.dontWorry
	call Dolphin.dTN.newline
Dolphin.dTN.check_newlineCutoff.dontWorry :
popa
ret

Dolphin.dTN.newline :
pusha
mov eax, [dstor]
add eax, 6
mov ebx, [TextHandler.textWidth]
imul ebx, 11
add eax, ebx
		mov [TextHandler.charpos], eax
		call Dolphin.dTN.calc_newlineCutoff
popa
ret

Dolphin.dTN.cchar_ecx :
push ax
	mov ax, [ecx]
	cmp al, 0x0a
		jne Dolphin.dTN.cchar_ecx.notnewl
	call Dolphin.dTN.newline
	jmp Dolphin.dTN.cchar_ecx.cont
	Dolphin.dTN.cchar_ecx.notnewl :
	call Dolphin.dTN.printCharPlain
	Dolphin.dTN.cchar_ecx.cont :
	add ecx, 2
pop ax
ret

Dolphin.dTN.ccharcheck_ecxedx :
push ax
push bx
		mov ax, [ecx]
		mov bx, [edx]
		cmp ax, bx
			jne Dolphin.dTN.ccharcheck_ecxedx.updateIt
			cmp al, 0x0a
				jne Dolphin.dTN.ccharcheck_ecxedx.noup.notnewl
			call Dolphin.dTN.newline
			jmp Dolphin.dTN.ccharcheck_ecxedx.cont
			Dolphin.dTN.ccharcheck_ecxedx.noup.notnewl :
			push ecx
			mov ecx, [TextHandler.charpos]
			add ecx, 7
			mov [TextHandler.charpos], ecx
			pop ecx
			call Dolphin.dTN.check_newlineCutoff
			jmp Dolphin.dTN.ccharcheck_ecxedx.cont
	Dolphin.dTN.ccharcheck_ecxedx.updateIt :	; if something has changed
					push eax
					mov eax, [Dolphin.dcount]
					add eax, 1
					mov [Dolphin.dcount], eax
					pop eax
	mov ax, [ecx]
	cmp al, 0x0a
		jne Dolphin.dTN.ccharcheck_ecxedx.notnewl
	call Dolphin.dTN.newline
	jmp Dolphin.dTN.ccharcheck_ecxedx.cont
	Dolphin.dTN.ccharcheck_ecxedx.notnewl :
	call Dolphin.dTN.printCharPlain
	Dolphin.dTN.ccharcheck_ecxedx.cont :
	add ecx, 2
	add edx, 2
pop bx
pop ax
ret

Dolphin.dTN.printCharPlain :	; char in ax
	push ecx
		call TextHandler.drawChar
		call Dolphin.dTN.fixV_align
		call Dolphin.dTN.check_newlineCutoff
	pop ecx
	ret

Dolphin.dTN.alignTo_start :
		mov [TextHandler.textWidth], cx
		call Dolphin.dTN.s_calc
		add ebx, [dstor2]
		mov [TextHandler.charpos], ebx
	mov ecx, eax
ret

Dolphin.dTN.fixV_align :
	mov ecx, [TextHandler.charpos]
	add ecx, [dstor2]
	mov [TextHandler.charpos], ecx
ret

Dolphin.dTN.s_calc :
		push ebx
		xor ebx, ebx
		mov bx, [TextHandler.textWidth]
		imul ebx, 2
		mov [dstor2], ebx
		pop ebx
		ret