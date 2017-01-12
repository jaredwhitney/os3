; Dolphin.drawTextNew :	; eax = text buffer, ebx = dest, cx = width, edx = old text buffer
; pusha
		; push eax
		; mov eax, 0
		; mov [Dolphin.dcount], eax
		; pop eax
	
	; mov [bstor], ebx
	; ;call Dolphin.dTN.checkUnsmartClear
	; call Dolphin.dTN.alignTo_start	; text buffer (eax) -> ecx
	
	; call Dolphin.dTN.calc_newlineCutoff
	
	; call Dolphin.dTN.s_Rcalcs
	
	; Dolphin.drawTextNew.loop :
		; call Dolphin.dTN.ccharcheck_ecxedx
		; mov bl, [ecx]
		; cmp bl, 0x0
			; jne Dolphin.drawTextNew.loop
		; mov bl, [edx]
		; cmp bl, 0x0
			; jne Dolphin.drawTextNew.loop
	
	; call Dolphin.dTN.updateTempBuffer
	
	; ;call Dolphin.dTN.upTest
	
	; call Dolphin.dTN.e_Rcalcs

; mov byte [Dolphin_WAIT_FLAG], 0x0
; popa
; ret

; Dolphin.dTN.upTest :
; pusha
	; ; mov [u_espStor], esp
	; ; mov [u_ebpStor], ebp
	; ; mov bl, [Window.RECTL_BASE]
	; ; call Dolphin.getAttribDouble
	; ; mov ebp, eax
	; ; mov esp, eax
	; ; push dword 0x0
	; ; push dword 0x6
	; ; mov eax, esp
	; ; mov ebp, [u_ebpStor]
	; ; mov esp, [u_espStor]
	; ; mov bl, [Window.RECTL_TOP]
	; ; call Dolphin.setAttribDouble
	; ; mov al, 0xFF
	; ; mov bl, [Window.NEEDS_RECT_UPDATE]
	; ; call Dolphin.setAttribByte
	; mov eax, 0x0
	; call Dolphin.dTN.addR
	; mov eax, 0x6
	; call Dolphin.dTN.addR
; popa
; ret

; Dolphin.dTN.s_Rcalcs :
; pusha
	; mov bl, [Window.RECTL_BASE]
	; call Dolphin.getAttribDouble
	; mov [uRectsBase], eax
	; mov [uRectsEnd], eax
; popa
; ret

; Dolphin.dTN.addR :	; pos in eax
; pusha
	; mov eax, [TextHandler.charpos]
	; sub eax, [bstor]
			; ;	call DebugLogEAX
	; mov ebx, [uRectsEnd]
	; mov [ebx], eax
	; sub ebx, 4
	
	; mov [uRectsEnd], ebx
	
	; mov al, 0xFF
	; mov bl, [Window.NEEDS_RECT_UPDATE]
	; call Dolphin.setAttribByte
	
; popa
; ret

; Dolphin.dTN.e_Rcalcs :
; pusha
	; mov eax, [uRectsEnd]
	; mov bl, [Window.RECTL_TOP]
	; call Dolphin.setAttribDouble
; popa
; ret

; ;uRectsBase :
	; ;dd 0x0
; ;uRectsEnd :
	; ;dd 0x0
	
; Dolphin.dTN.checkUnsmartClear :
; pusha
	; push edx
	; push edx
		; mov ebx, eax
		; call String.getLength
		; mov ecx, edx
	; pop edx
		; mov ebx, edx
		; call String.getLength
		; sub edx, 4
	; cmp ecx, edx
	; pop edx
		; jge Dolphin.dTN.checkUnsmartClear.noShrink
			; mov eax, edx
			; mov edx, [Graphics.SCREEN_SIZE]
			; mov ebx, 0x0
			; call Image.clear
		; mov eax, [bstor]
		; mov edx, [Graphics.SCREEN_SIZE]
		; mov ebx, 0x0
		; call Image.clear
; Dolphin.dTN.checkUnsmartClear.noShrink :
; popa
; ret

; Dolphin.dTN.updateTempBuffer :
; pusha
	; mov bl, [Window.OLDBUFFER]
	; call Dolphin.getAttribDouble
	; mov ebx, eax
	; push ebx
	; mov bl, [Window.BUFFER]
	; call Dolphin.getAttribDouble
	; pop ebx
			; pusha
			; push eax
			; call os.seq
			; cmp al, 0x0
			; pop eax
				; jne Thioasdf
			; call TextMode.println
			; mov ebx, eax
			; call TextMode.println
			; Thioasdf :
			; popa
			
	; call String.copyUntilBothZeroed
; popa
; ret

; Dolphin.dTN.calc_newlineCutoff :
; pusha
	; mov ebx, [TextHandler.textWidth]
	; add ebx, [TextHandler.charpos]
	; sub ebx, 6	; char width-1
	; mov [dstor], ebx
; popa
; ret

; Dolphin.dTN.check_newlineCutoff :
; pusha
	; mov ecx, [TextHandler.charpos]
	; cmp ecx, [dstor]
		; jle Dolphin.dTN.check_newlineCutoff.dontWorry
	; call Dolphin.dTN.newline
; Dolphin.dTN.check_newlineCutoff.dontWorry :
; popa
; ret

; Dolphin.dTN.newline :
; pusha
; mov eax, [dstor]
; add eax, 6
; mov ebx, [TextHandler.textWidth]
; imul ebx, 11
; add eax, ebx
		; mov [TextHandler.charpos], eax
		; call Dolphin.dTN.calc_newlineCutoff
; popa
; ret

; Dolphin.dTN.cchar_ecx :
; push ax
	; mov ax, [ecx]
	; cmp al, 0x0a
		; jne Dolphin.dTN.cchar_ecx.notnewl
	; call Dolphin.dTN.newline
	; jmp Dolphin.dTN.cchar_ecx.cont
	; Dolphin.dTN.cchar_ecx.notnewl :
	; call Dolphin.dTN.printCharPlain
	; Dolphin.dTN.cchar_ecx.cont :
	; add ecx, 2
; pop ax
; ret

; Dolphin.dTN.ccharcheck_ecxedx :
; push ax
; push bx
		; mov ax, [ecx]
		; mov bx, [edx]
		; cmp ax, bx
			; jne Dolphin.dTN.ccharcheck_ecxedx.updateIt	; SHOULD BE JNE
			; cmp al, 0x0a
				; jne Dolphin.dTN.ccharcheck_ecxedx.noup.notnewl
			; call Dolphin.dTN.newline
			; jmp Dolphin.dTN.ccharcheck_ecxedx.cont
			; Dolphin.dTN.ccharcheck_ecxedx.noup.notnewl :
			; push ecx
			; mov ecx, [TextHandler.charpos]
			; add ecx, 7
			; mov [TextHandler.charpos], ecx
			; pop ecx
			; call Dolphin.dTN.check_newlineCutoff
			; jmp Dolphin.dTN.ccharcheck_ecxedx.cont
	; Dolphin.dTN.ccharcheck_ecxedx.updateIt :	; if something has changed
	; ;				push eax
	; ;				mov eax, [Dolphin.dcount]
	; ;				add eax, 1
	; ;				mov [Dolphin.dcount], eax
	; ;				pop eax
	; ;mov ax, [ecx]
				; ;mov ax, bx
	; cmp al, 0x0a
		; jne Dolphin.dTN.ccharcheck_ecxedx.notnewl
	; call Dolphin.dTN.newline
	; jmp Dolphin.dTN.ccharcheck_ecxedx.cont
	; Dolphin.dTN.ccharcheck_ecxedx.notnewl :
	; call Dolphin.dTN.printCharPlain
	; ;					mov ax, bx
	; ;					call Dolphin.dTN.printCharPlain
	; Dolphin.dTN.ccharcheck_ecxedx.cont :
	; add ecx, 2	; 1-2 in these lines doesnt skip things but makes every other char invalid
	; add edx, 2	; 2-1 in these lines doesnt skip things but makes a lot of invalid chars at the end
; pop bx
; pop ax
; ret

; Dolphin.dTN.printCharPlain :	; char in ax
	; push ecx
		; call Dolphin.dTN.addR
		; mov ah, 0xFF
		; ;mov al, '&'
		; call TextHandler.drawChar
		; call Dolphin.dTN.fixV_align
		; call Dolphin.dTN.check_newlineCutoff
	; pop ecx
	; ret

; Dolphin.dTN.alignTo_start :
		; mov [TextHandler.textWidth], cx
		; call Dolphin.dTN.s_calc
		; add ebx, [dstor2]
		; mov [TextHandler.charpos], ebx
	; mov ecx, eax
; ret

; Dolphin.dTN.fixV_align :
	; mov ecx, [TextHandler.charpos]
	; add ecx, [dstor2]
	; mov [TextHandler.charpos], ecx
; ret

; Dolphin.dTN.s_calc :
		; push ebx
		; xor ebx, ebx
		; mov bx, [TextHandler.textWidth]
		; imul ebx, 2
		; mov [dstor2], ebx
		; pop ebx
		; ret

; dbgcnt :
	; dd 0
	
	
	
	; NEW THINGS
	
	
	
Dolphin.drawTextNew2 :
methodTraceEnter
pusha
push dword [TextHandler.charpos]
push dword [TextHandler.textWidth]
push word [TextHandler.solidChar]
	mov bl, [Window.BUFFER]
	call Dolphin.getAttribDouble
	mov [D.dTN2.buf], eax	; buffer -> buf
	mov ecx, eax
	mov bl, [Window.OLDBUFFER]
	call Dolphin.getAttribDouble
	mov [D.dTN2.obuf], eax	; old buffer -> obuf
	mov edx, eax
	mov bl, [Window.WIDTH]
	call Dolphin.getAttribWord
	and eax, 0xFFFF
	mov [D.dTN2.width], eax
	mov [TextHandler.textWidth], ax
	mov bl, [Window.WINDOWBUFFER]
	call Dolphin.getAttribDouble
	mov ebx, [D.dTN2.width]
	imul ebx, 2
	add eax, ebx	; padding!
	mov [D.dTN2.imgbase], eax
	mov [TextHandler.charpos], eax
	
	; mov al, 'H'
	; mov ah, 0xFF
	; call TextHandler.drawChar
	; popa
	; ret
	; while they are not both 0
	D.dTN2.loop :
	mov bx, [ecx]
	or bx, word [edx]
	cmp bx, 0
		je D.dTN2.ret
	;{
		; if they are not equal
		mov bx, [ecx]
		xor bx, word [edx]
		cmp bx, 0x0
			je D.dTN2.noupadd
		;{
			mov ax, [ecx]
			; if it is a newline
			cmp al, 0x0A
				jne D.dTN2.notAnewl
			;{
				mov byte [D.dTN2.forceNewl], 0xFF
			;}
			jmp D.dTN2.noup
			D.dTN2.notAnewl :
			
			; else draw it
			call TextHandler.drawChar
			mov [edx], ax
		;}
		jmp D.dTN2.noup
		D.dTN2.noupadd :
		push eax
		mov eax, 6
		imul eax, [Graphics.bytesPerPixel]
		add dword [TextHandler.charpos], eax
		pop eax
		D.dTN2.noup :
		mov eax, [TextHandler.charpos]
		sub eax, [D.dTN2.imgbase]
		
		; if it should wrap to a newline
		call D.dTN2.checkNeedsNewl
		cmp ebx, 0x0
			je D.dTN2.nonewl
		;{
			call D.dTN2.handleNewl
		;}
		D.dTN2.nonewl :
		add eax, [D.dTN2.imgbase]
		mov [TextHandler.charpos], eax
		add ecx, 2
		add edx, 2
	;}
	jmp D.dTN2.loop
D.dTN2.ret :
pop word [TextHandler.solidChar]
pop dword [TextHandler.textWidth]
pop dword [TextHandler.charpos]
popa
methodTraceLeave
ret

D.dTN2.checkNeedsNewl :
methodTraceEnter
push eax
push ecx
push edx
	cmp byte [D.dTN2.forceNewl], 0xFF
		jne D.dTN2.cNN.noforce
			mov byte [D.dTN2.forceNewl], 0x0
			mov ebx, 0x1
			jmp D.dTN2.cNN.ret
	D.dTN2.cNN.noforce :
	push ecx
	mov ecx, 5
	imul ecx, [Graphics.bytesPerPixel]
	add eax, ecx
	pop ecx
	xor edx, edx
	mov ecx, [TextHandler.textWidth]
	idiv ecx
	push ecx
	mov ecx, 7
	imul ecx, [Graphics.bytesPerPixel]
	cmp edx, ecx
	pop ecx
		jge D.dTN2.cNN.noNeed
	mov ebx, 0x1
	jmp D.dTN2.cNN.ret
	D.dTN2.cNN.noNeed :
	mov ebx, 0x0
D.dTN2.cNN.ret :
pop edx
pop ecx
pop eax
methodTraceLeave
ret

D.dTN2.handleNewl :
methodTraceEnter
push ebx
push ecx
push edx
	xor edx, edx
	mov ecx, [TextHandler.textWidth]
	idiv ecx
	add eax, 9
	imul eax, ecx
pop edx
pop ecx
pop ebx
methodTraceLeave
ret

D.dTN2.imgbase :
	dd 0x0
D.dTN2.buf :
	dd 0x0
D.dTN2.obuf :
	dd 0x0
D.dTN2.width :
	dd 0x0
D.dTN2.forceNewl :
	db 0x0