Dolphin.windowExists :	; windowNum in ebx, returns either 0x0 or 0xF (F|T) in eax
methodTraceEnter
push ebx
add ebx, Dolphin.windowStructs
mov eax, [ebx]
pop ebx
cmp eax, 0x0
je Dolphin.windowExists.false
mov eax, 0xF
methodTraceLeave
ret
Dolphin.windowExists.false :
mov eax, 0x0
methodTraceLeave
ret

Dolphin.activateNext :	; activates the next window in the list
methodTraceEnter
pusha
xor ebx, ebx
mov bl, [Dolphin.activeWindow]
mov cl, bl
mov ch, 0x0
	Dolphin.activeNext.loop :
	cmp ch, 0x0
	je Dolphin.activeNext.loop.ncjo
	cmp bl, cl
		je Dolphin.activeNext.ret
	Dolphin.activeNext.loop.ncjo :
	add ch, 1
	add bl, 4
	cmp bl, 0x40
		jl Dolphin.activateNext.cont_1
	mov bl, 0x0
	Dolphin.activateNext.cont_1 :
	call Dolphin.windowExists
	cmp eax, 0x0
	je Dolphin.activeNext.loop
	Dolphin.activeNext.ret :
	mov [Dolphin.activeWindow], bl
	call debug.num
popa
methodTraceLeave
ret

Dolphin.registerWindow :	; eax = pointer to windowStruct; returns bl contains windowNum
methodTraceEnter
push ecx
push edx
mov edx, Dolphin.windowStructs
Dolphin.registerWindow.loop1 :
mov ecx, [edx]
add edx, 4
cmp ecx, 0x0
jne Dolphin.registerWindow.loop1
sub edx, 4
mov [edx], eax
sub edx, Dolphin.windowStructs
mov ebx, edx
and ebx, 0xFF
mov [Dolphin.activeWindow], bl
	pusha
	call debug.num
	mov ebx, Dolphin.REG_MSG
	call debug.log.system
	popa
pop edx
pop ecx
methodTraceLeave
ret

Dolphin.getAttribDouble :	; returns eax. bl = offset
methodTraceEnter
push edx
push ecx
push ebx
mov eax, [Dolphin.currentWindow]
add eax, Dolphin.windowStructs
mov eax, [eax]
and ebx, 0xFF
add eax, ebx
mov eax, [eax]
pop ebx
pop ecx
pop edx
methodTraceLeave
ret

Dolphin.getAttribWord :	; returns eax
methodTraceEnter
push edx
push ecx
push ebx
mov eax, [Dolphin.currentWindow]
add eax, Dolphin.windowStructs
mov eax, [eax]
and ebx, 0xFF
add eax, ebx
mov ax, [eax]
pop ebx
pop ecx
pop edx
and eax, 0xFFFF
methodTraceLeave
ret

Dolphin.getAttribByte :	; returns eax
methodTraceEnter
push edx
push ecx
push ebx
mov eax, [Dolphin.currentWindow]
add eax, Dolphin.windowStructs
mov eax, [eax]
and ebx, 0xFF
add eax, ebx
mov al, [eax]
pop ebx
pop ecx
pop edx
and eax, 0xFF
methodTraceLeave
ret


Dolphin.setAttribDouble :	; attrib val in eax
methodTraceEnter
push edx
push ecx
push ebx
push eax
mov eax, [Dolphin.currentWindow]
add eax, Dolphin.windowStructs
mov eax, [eax]
and ebx, 0xFF
add eax, ebx
mov ecx, eax
pop eax

mov [ecx], eax

pop ebx
pop ecx
pop edx
methodTraceLeave
ret


Dolphin.setAttribWord :	; attrib val in ax
methodTraceEnter
push edx
push ecx
push ebx
push eax
mov eax, [Dolphin.currentWindow]
add eax, Dolphin.windowStructs
mov eax, [eax]
and ebx, 0xFF
add eax, ebx
mov ecx, eax
pop eax

mov [ecx], ax

pop ebx
pop ecx
pop edx
methodTraceLeave
ret


Dolphin.setAttribByte :	; attrib val in al
methodTraceEnter
push edx
push ecx
push ebx
push eax
mov eax, [Dolphin.currentWindow]
add eax, Dolphin.windowStructs
mov eax, [eax]
and ebx, 0xFF
add eax, ebx
mov ecx, eax
pop eax

mov [ecx], al

pop ebx
pop ecx
pop edx
methodTraceLeave
ret

Dolphin.unregisterWindow :	; winNum in bl
methodTraceEnter
pusha
mov byte [Dolphin_WAIT_FLAG], 0xFF

mov ecx, 0x0
and ebx, 0xFF
	mov [Dolphin.currentWindow], ebx
	call Window.makeGlass
mov eax, Dolphin.windowStructs
add eax, ebx
mov [eax], ecx
mov bh, [Dolphin.activeWindow]
cmp bl, bh
jne Dolphin.registerWindow.noActiveChange
call Dolphin.activateNext
Dolphin.registerWindow.noActiveChange :
	call debug.num
	mov ebx, Dolphin.UNDolphin.REG_MSG
	call debug.log.system

mov byte [Dolphin_WAIT_FLAG], 0x0
popa
methodTraceLeave
ret

Dolphin.moveWindow :	; xchange in eax, y change in ebx
methodTraceEnter
pusha
mov byte [Dolphin_WAIT_FLAG], 0xFF

	call Window.makeGlassSmart

	mov edx, eax
	mov ecx, ebx
	
	mov bl, [Window.X_POS]
	call Dolphin.getAttribWord
	add eax, edx
	call Dolphin.setAttribWord
	
	mov bl, [Window.Y_POS]
	call Dolphin.getAttribWord
	add eax, ecx
	call Dolphin.setAttribWord
	
mov byte [Dolphin_WAIT_FLAG], 0x0
popa
methodTraceLeave
ret

Dolphin.moveWindowAbsolute :	; x in eax, y in ebx
methodTraceEnter
pusha
;mov byte [Dolphin_WAIT_FLAG], 0xFF
mov ecx, ebx

pusha
	mov bl, [Window.X_POS]
	call Dolphin.getAttribWord
	mov bl, [Window.LASTX_POS]
	call Dolphin.setAttribWord
	mov bl, [Window.Y_POS]
	call Dolphin.getAttribWord
	mov bl, [Window.LASTY_POS]
	call Dolphin.setAttribWord
popa

mov bl, [Window.X_POS]
call Dolphin.setAttribWord

mov eax, ecx
mov bl, [Window.Y_POS]
call Dolphin.setAttribWord

call Window.makeGlassSmart

;mov byte [Dolphin_WAIT_FLAG], 0x0
popa
methodTraceLeave
ret

Dolphin.anyActiveWindows :	; eax ret
methodTraceEnter
push ebx
push ecx
push edx
xor edx, edx
mov ebx, Dolphin.windowStructs
Dolphin.anyActiveWindows.loop :
mov ecx, [ebx]
cmp ecx, 0x0
	jne Dolphin.anyActiveWindows.yes
add edx, 1
add ebx, 4
cmp edx, 0x10
	jl Dolphin.anyActiveWindows.loop
mov eax, 0x0
pop edx
pop ecx
pop ebx
methodTraceLeave
ret
Dolphin.anyActiveWindows.yes :
mov eax, edx
add eax, 1
pop edx
pop ecx
pop ebx
methodTraceLeave
ret

Dolphin.activeWinNum :
	methodTraceEnter
	pusha
	xor edx, edx
	mov [Dolphin.awctcnt], edx
	mov ebx, Dolphin.windowStructs
	Dolphin.awct.loop :
	mov ecx, [ebx]
	cmp ecx, 0x0
		jne Dolphin.awct.yes
	Dolphin.awct.yre :
	add edx, 1
	add ebx, 4
	cmp edx, 0x10
		jl Dolphin.awct.loop
	mov eax, 0x0
	popa
	mov eax, [Dolphin.awctcnt]
	methodTraceLeave
	ret
	Dolphin.awct.yes :
	push eax
	mov eax, [Dolphin.awctcnt]
	add eax, 1
	mov [Dolphin.awctcnt], eax
	pop eax
	jmp Dolphin.awct.yre
	Dolphin.awctcnt :
	dd 0x0

Dolphin.sizeWindow :	; xchange in eax, y change in ebx
methodTraceEnter
pusha
mov byte [Dolphin_WAIT_FLAG], 0xFF

	call Window.makeGlass
	
	mov edx, eax
	mov ecx, ebx
	
	pusha
	mov bl, [Window.WIDTH]
	call Dolphin.getAttribWord
	add eax, edx
	call Dolphin.setAttribWord
	popa
	
	mov bl, [Window.HEIGHT]
	call Dolphin.getAttribWord
	add eax, ecx
	call Dolphin.setAttribWord
	
	;call Window.forceFlush

mov byte [Dolphin_WAIT_FLAG], 0x0
popa
methodTraceLeave
ret

Dolphin.drawBorder :	; ebx = image buffer, cx = width, dx = height
methodTraceEnter
pusha
and ecx, 0xFFFF
push ecx
mov al, 0x03	; red
	push ebx
	mov bl, [Dolphin.activeWindow]
	mov bh, [Dolphin.currentWindow]
	cmp bl, bh
	jne Dolphin.drawBorder.nonactive
	mov al, 0x3d	; light blue
	Dolphin.drawBorder.nonactive :
	pop ebx
push ebx
Dolphin.drawBorder.loop1 :
mov [ebx], al
add ebx, 0x1
sub cx, 0x1
cmp cx, 0x0
jg Dolphin.drawBorder.loop1
mov [ebx], al
pop ebx
pop ecx
Dolphin.drawBorder.loop2 :
mov [ebx], al
add ebx, ecx
sub dx, 0x1
cmp dx, 0x0
jg Dolphin.drawBorder.loop2
mov [ebx], al

popa
methodTraceLeave
ret

Dolphin.drawTitle :	; [currentWindow] contains window data
methodTraceEnter
pusha
push dword [TextHandler.charpos]
push dword [TextHandler.textWidth]
push word [TextHandler.solidChar]
	mov bl, [Window.X_POS]
	call Dolphin.getAttribWord
	mov cx, ax
	
	mov bl, [Window.Y_POS]
	call Dolphin.getAttribWord
	sub ax, 8
	mov dx, ax
	
	mov ebx, [Dolphin.currentWindow]
	add ebx, Dolphin.windowStructs
	mov ebx, [ebx]
	mov ebx, [ebx]
	
	mov eax, [Graphics.SCREEN_MEMPOS]
	and ecx, 0xFFFF
	add eax, ecx
	and edx, 0xFFFF
	imul edx, [Graphics.SCREEN_WIDTH]
	add eax, edx
	
	push eax
	mov eax, [Graphics.SCREEN_WIDTH]
	mov [TextHandler.textWidth], eax
	pop eax
	mov [TextHandler.charpos], eax
	mov eax, [Graphics.SCREEN_MEMPOS]
	mov dword [TextHandler.textSizeMultiplier], 1
	mov byte [TextHandler.solidChar], 0x0
	
		Dolphin.drawTitle.loop :
			mov al, [ebx]
			cmp al, 0x0
				je Dolphin.drawTitle.ret
			mov ah, 0xFF
			call TextHandler.drawChar
			add ebx, 1
			jmp Dolphin.drawTitle.loop
Dolphin.drawTitle.ret :
pop word [TextHandler.solidChar]
pop dword [TextHandler.textWidth]
pop dword [TextHandler.charpos]
popa
methodTraceLeave
ret



;Dolphin.newWindow :	; windowStruct in eax, pnum in bl, returns winNum
;pusha
;call Dolphin.create
;and bx, 0xFF
;mov [atwstor], bx
;call Dolphin.registerWindow
;push ebx
;mov bl, 26
;mov eax, ecx
;call Dolphin.setAttribute
;pop ebx
;mov eax, ebx
;mov bl, 30
;call Dolphin.setAttribute
;popa
;mov bx, [atwstor]
;ret
