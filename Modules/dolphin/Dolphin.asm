[bits 32]
;Dolphin.SCREEN_BUFFER	equ 0xA20000
;Graphics.SCREEN_WIDTH	equ 0x140
;Graphics.SCREEN_HEIGHT	equ 0xc8

CHANGE_MASK equ 0x80000000

Dolphin.init :
	; whatever needs to be done here
pusha
mov bl, [Graphics.VESA_MODE]
cmp bl, 0x0
je Dolphin.NONVESAinit
mov al, 0x1
mov ebx, 0x2800
call Guppy.malloc
mov [Dolphin.SCREEN_BUFFER], ebx
mov ebx, 0x2800
call Guppy.malloc
mov [Dolphin.SCREEN_FLIPBUFFER], ebx

call Dolphin.redrawBG

popa
ret

Dolphin.NONVESAinit :
mov al, 0x1
mov ebx, 0x7D
call Guppy.malloc
mov [Dolphin.SCREEN_BUFFER], ebx
mov ebx, 0x7D
call Guppy.malloc
mov [Dolphin.SCREEN_FLIPBUFFER], ebx

call Dolphin.redrawBG

popa
ret

Dolphin.drawTextNew :	; eax = text buffer, ebx = dest, cx = width, edx = old text buffer
pusha
mov byte [Dolphin_WAIT_FLAG], 0xFF
	
	mov [bstor], ebx
	call Dolphin.dTN.alignTo_start	; text buffer (eax) -> ecx
	
	call Dolphin.dTN.calc_newlineCutoff
	
	Dolphin.drawTextNew.loop :
		call Dolphin.dTN.cchar_ecx
		mov bl, [ecx]
		cmp bl, 0x0
			jne Dolphin.drawTextNew.loop
	
mov byte [Dolphin_WAIT_FLAG], 0x0
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
	mov eax, [TextHandler.charpos]
	sub eax, [bstor]	; where it is relative the the start
		xor edx, edx	; idiv setup
		xor ecx, ecx
		mov cx, [TextHandler.textWidth]
		idiv ecx	; what line are we on? (y-position)
		mov ebx, 11
		xor edx, edx	; idiv setup
		idiv ebx		; height of the font
		
			add eax, 1	; next line :D
		
		imul eax, 11
		xor ecx, ecx
		mov cx, [TextHandler.textWidth]
		imul eax, ecx
		add eax, [bstor]
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


; Dolphin.drawText :	; eax = text buffer, ebx = dest, cx = width, edx = bufferSize (chars)
	; pusha
	; mov byte [Dolphin_WAIT_FLAG], 0xFF
	; call Syntax.reset
	; and ecx, 0xFFFF
	; mov [dstor], edx
	; mov [bposstor], ebx
	; mov [TextHandler.textWidth], cx
		; pusha		;NOTE: this being commented breaks stuff :)
		; mov eax, ebx
		; mov edx, [Graphics.SCREEN_SIZE]
		; mov ebx, 0x0
		; call Image.clear
		; popa
	; mov ecx, [TextHandler.charpos]
		; push ecx
		; xor ecx, ecx
		; mov cx, [TextHandler.textWidth]
		; add ebx, ecx	; so the border isn't overlapping the text
		; add ebx, ecx
		; pop ecx
	; mov [bstor], ebx
	; mov [TextHandler.charposStor], ecx
	; mov ecx, ebx	; dest buffer
	; call Dolphin.checkCharLine
	; mov [TextHandler.charpos], ecx
	; mov ebx, eax	; src buffer
	; mov ah, 255
	; mov [Dolphin.bsizstor], edx
	; mov edx, 0x0
	; Dolphin.drawText_loop :
		; mov ax, [ebx]
		; push ebx
		; mov ebx, [Dolphin.bsizstor]
		; ;call debug.num
		; push ecx
		; mov ecx, [dstor]
		; cmp edx, ecx	; size of buffer
		; pop ecx
		; pop ebx
			; jg Dolphin.drawText_ret
				; ;pusha
				; ;mov eax, [TextHandler.charpos]	; where we are in destination buffer + destination buffer pos
				; ;mov ebx, [bposstor]
				; ;add ebx, [Graphics.SCREEN_SIZE]
				; ;cmp eax, ebx
				; ;popa
				; ;	jge Dolphin.drawText_ret
		; add edx, 1
		; cmp al, 0x0
			; je Dolphin.drawText.nodraw
		; cmp al, 0xD
			; je Dolphin.drawText.nodraw
		; cmp al, 0x0A
			; je Dolphin.drawText.newl
			; push bx
			; mov bl, [Dolphin.colorOverride]
			; cmp bl, 0
			; je Dolphin.drawText_noOverride1
			; mov ah, bl
			; Dolphin.drawText_noOverride1 :
			; pop bx
			; ;call Syntax.highlight
			; call TextHandler.drawChar
		; mov ecx, [TextHandler.charpos]
			; push ebx
			; xor ebx, ebx
			; mov bx, [TextHandler.textWidth]
			; imul ebx, 2
			; add ecx, ebx
			; ;add ecx, 0xa0*2
			; pop ebx
		; Dolphin.drawText.doCheck :
		; call Dolphin.checkCharLine	; EXPERIMENTAL!!!
		; mov [TextHandler.charpos], ecx
		; jmp Dolphin.drawText.cont1
		; Dolphin.drawText.nodraw :
			; push ecx
			; mov ecx, [TextHandler.charpos]
			; add ecx, 6
			; mov [TextHandler.charpos], ecx
			; pop ecx
		; Dolphin.drawText.cont1 :
			; add ebx, 0x1
				; push ax
				; mov al, [Dolphin.colorOverride]
				; cmp al, 0
				; jne Dolphin.drawText_noOverride2
				; add ebx, 0x1
				; Dolphin.drawText_noOverride2 :
				; pop ax
			; jmp Dolphin.drawText_loop
	; Dolphin.drawText_ret :
	; mov ecx, [TextHandler.charposStor]
	; mov [TextHandler.charpos], ecx
	; mov byte [Dolphin_WAIT_FLAG], 0x0
	; popa
	; ret
	
	; Dolphin.drawText.newl :	; move one space down, checkCharLine will move to the next line
	; push edx
	; mov ecx, [TextHandler.charpos]
	; mov edx, [Graphics.SCREEN_WIDTH]
	; add ecx, edx
	; mov [TextHandler.charpos], ecx
	; pop edx
	; ret
	
	; Dolphin.checkCharLine :	; TextHandler.charpos in ecx, width in TextHandler.textWidth, buffer loc in bstor
	; push eax
	; push ebx
	; push edx
		; mov eax, [bstor]
		; sub ecx, eax
		; push eax
		; push ecx
		; add ecx, 6
		; mov eax, ecx
		; xor ebx, ebx
		; mov bx, [TextHandler.textWidth]
		; xor edx, edx
		; div ebx	; eax now contains the line number
		
		; push ecx
		; mov ecx, 7
		; imul ecx, [TextHandler.textSizeMultiplier]
		; add ecx, 2
		; xor edx, edx
		; idiv ecx
		; pop ecx
		
		; cmp edx, 0x0
		; je Dolphin.checkCharLine.kret
		;;if the line is invalid :
		; mov ecx, edx	; ecx now contains the remainder, if non 0 the line is invalid
		; add eax, 1	; eax contains last valid line
		; xor edx, edx
		
		; push ebx
		; mov ebx, 7
		; imul ebx, [TextHandler.textSizeMultiplier]
		; add ebx, 2
		; imul eax, ebx	; should be 8
		; pop ebx
		
		; xor ecx, ecx
		; mov cx, [TextHandler.textWidth]
		; xor edx, edx
		; imul eax, ecx
			; mov ebx, eax
		; pop ecx
		; pop eax
			; mov ecx, ebx
			; add ecx, eax
		; add ecx, 1
		; noreadd :
		; jmp Dolphin.checkCharLine.ret
		
		; Dolphin.checkCharLine.kret :
		; pop ecx
		; pop eax
		; add ecx, eax
	; Dolphin.checkCharLine.ret :
	; pop edx
	; pop ebx
	; pop eax
	; ret
	
	

Dolphin.drawBorder :	; ebx = image buffer, cx = width, dx = height
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
ret

Dolphin.drawTitle :	; [currentWindow] contains window data
pusha
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
	;mov dword [eax], 0xFFFFFFFF
	;jmp Dolphin.drawTitle.ret
	
		Dolphin.drawTitle.loop :
			mov al, [ebx]
			cmp al, 0x0
				je Dolphin.drawTitle.ret
			mov ah, 0xFF
			call TextHandler.drawChar
					push ecx
					mov ecx, [TextHandler.charpos]
					push ebx
					mov ebx, [Graphics.SCREEN_WIDTH]
					add ebx, [Graphics.SCREEN_WIDTH]
					add ecx, ebx
					mov [TextHandler.charpos], ecx
					pop ebx
					pop ecx
			add ebx, 1
			jmp Dolphin.drawTitle.loop
Dolphin.drawTitle.ret :
	
popa
ret

Dolphin.redrawBG :
push ebx
mov ebx, [bglocstor]
call Dolphin.makeBG
pop ebx
ret

Dolphin.makeBG :	; ebx contains location of data
pusha
mov [bglocstor], ebx
cmp ebx, 0x0
je Dolphin.solidBG
mov eax, ebx
mov ebx, [Graphics.SCREEN_MEMPOS]
mov ecx, [Graphics.SCREEN_WIDTH]
mov edx, [Graphics.SCREEN_HEIGHT]
call Image.copy
Dolphin.makeBG.ret :
popa
ret

Dolphin.solidBG :
mov eax, [Graphics.SCREEN_MEMPOS]
mov edx, [Graphics.SCREEN_SIZE]
mov ebx, 0x10101010
mov cl, [Graphics.VESA_MODE]
cmp cl, 0x0
	je Dolphin.solidBGNOVESA
mov ebx, 0x0000C7
Dolphin.solidBGNOVESA :
call Image.clear
popa
ret

Dolphin.updateScreen :
pusha
	cmp byte [Dolphin_WAIT_FLAG], 0xFF
		je Dolphin.updateScreen.ret
	push word [Dolphin.currentWindow]
			; 	If an exception occurs, blame Dolphin.	;
			mov bl, Manager.CONTROL_DOLPHIN
			mov [os.mlloc], bl
			; has active window changed? if so, every window with a lower depth than its previous depth should have their depth incremented by 1, the new active window should have its depthset to 0.
		;mov al, [Dolphin.dcount]
		;cmp al, 0x10
		;add al, 0x1
		;	jne Dolphin.updateScreen.nbgup
		
		;mov al, 0x0
		;Dolphin.updateScreen.nbgup :
		;mov [Dolphin.dcount], al

;
;	Draw windows in here!
		mov ebx, 0x0
		mov ecx, 0x0
		Dolphin.updateScreen.checkWindow :
						; loop through each window, find the one with the highest depth, then highest depth lower than that depth, etc. (run through all of the windows in order of decreasing depth)
			cmp ebx, 0x3C;0xF*4	; num of windows * 4 bytes per windowStruct location
				jge Dolphin.doneDrawingWindows
					;cmp ebx, 8										; REMOVE THIS LINE
					;	jg Dolphin.doneDrawingWindows;kernel.halt	; REMOVE THIS LINE
			call Dolphin.windowExists
			add ebx, 4
			cmp eax, 0x0
				je Dolphin.updateScreen.checkWindow
		push ebx
		sub ebx, 4
		
		mov [Dolphin.currentWindow], ebx
		add ebx, Dolphin.windowStructs
		mov edx, [ebx]
		push edx
		
		mov [atwstorX], ax
		
		
		mov [atwstor2X], ax
		
		mov eax, [edx+14]	; windowbuffer
		
		xor ecx, ecx
		mov cx, [edx+4]	; width
		mov dx, [edx+6]	; height
		and edx, 0xFFFF

			mov ebx, eax
			call Dolphin.drawBorder
			call Dolphin.drawTitle

		mov ebx, [Graphics.SCREEN_MEMPOS]
		
			pop edx
			push eax
			xor eax, eax
			mov ax, [edx+10]	; ypos
			imul eax, [Graphics.SCREEN_WIDTH]
			
		add ebx, eax	; add ypos
		xor eax, eax
		mov ax, [edx+8]
		add ebx, eax	; add xpos
		pop eax
		mov dx, [edx+6]	; height back

		
		;pusha
		;mov bl, [Window.TYPE]
		;call Dolphin.getAttribByte
		;cmp al, 0x0	; text window, dont bother rechecking
		;	je Dolphin.updateScreen.notText
		;mov byte [Image_checkChange], 0xFF	; enabling causes a *slight* slowdown
		;Dolphin.updateScreen.notText :
		;popa
		call Image.copy
		;mov byte [Image_checkChange], 0x0
		
		pop ebx
		jmp Dolphin.updateScreen.checkWindow			;COMMENTED: KILLS >1 WINDOWS
		
Dolphin.doneDrawingWindows :
;
	;call Dolphin.anyActiveWindows	; DO NOT CHECK EVERY FRAME !!!
	;cmp eax, 0x0	; no windows to draw :(
	;	jne Dolphin.doneDrawingWindows.cont
	;call Manager.freezePanic
;Dolphin.doneDrawingWindows.cont :
;call debug.update	; ensuring that debug information stays updated and 'on top'
		; mov eax, [Dolphin.SCREEN_FLIPBUFFER]	; THIS MAKES IT GO WAAAY FASTER!
		; mov ebx, [Dolphin.SCREEN_BUFFER]
		; mov ecx, [Graphics.SCREEN_SIZE]
		; mov edx, [Graphics.SCREEN_MEMPOS]
		; call Dolphin.xorImage
;mov eax, [Dolphin.SCREEN_BUFFER]
;mov ebx, [Graphics.SCREEN_MEMPOS]
;mov ecx, [Graphics.SCREEN_WIDTH]
;mov edx, [Graphics.SCREEN_HEIGHT]
;call Image.copyLinear	; need to be checking each frame and only updating memory that has changed

;mov eax, [Dolphin.SCREEN_BUFFER]
;mov ebx, [Graphics.SCREEN_MEMPOS]
;mov ecx, [Graphics.SCREEN_SIZE]
;call Dolphin.copyChanged

	pop word [Dolphin.currentWindow]
Dolphin.updateScreen.ret :
popa
ret

Dolphin.uUpdate :	; currentWindow is the window
pusha
	mov bl, [Window.TYPE]
	call Dolphin.getAttribByte
	cmp al, 0x0
		jne Dolphin.uUpdate.notText
	mov bl, [Window.WIDTH]
	call Dolphin.getAttribWord
	mov cx, ax
	mov bl, [Window.OLDBUFFER]
	call Dolphin.getAttribDouble
	mov edx, eax
	mov bl, [Window.WINDOWBUFFER]
	call Dolphin.getAttribDouble
	mov ebx, eax
	push ebx
	mov bl, [Window.BUFFER]
	call Dolphin.getAttribDouble
	pop ebx
	call Dolphin.drawTextNew
			;mov bl, [Window.OLDBUFFER]
			;call Dolphin.getAttribDouble
			;mov ebx, eax
			;push ebx
			;mov bl, [Window.BUFFER]
			;call Dolphin.getAttribDouble
			;pop ebx
			;call String.copy
	Dolphin.uUpdate.notText :
popa
ret

Dolphin.copyChanged :	; eax = buffer1, ebx = buffer2, ecx = buffersize
	xor edx, edx
	mov [cval], edx
	Dolphin.copyChanged.loop :
		mov edx, [eax]
		;cmp byte [Graphics.VESA_MODE], 0x0
			;je nobother
		test edx, CHANGE_MASK
			jz Dolphin.copyChanged.noChange
		and edx, 0xFFFFFF
		nobother :
		mov [ebx], edx
					mov edx, [cval]
					add edx, 1
					mov [cval], edx
		
		Dolphin.copyChanged.noChange :
		sub ecx, 4
		add eax, 4
		add ebx, 4
		cmp ecx, 0
			jg Dolphin.copyChanged.loop
ret
cval :
dd 0x0

Dolphin.xorImage :	; eax = buffer1, ebx = buffer2, ecx = buffersize, edx = buffer3
	pusha
	mov [Dolphin.xbufsize], ecx
	mov [Dolphin.xbuf1pos], eax
	mov [Dolphin.xbuf2pos], ebx
	mov [Dolphin.xbuf3pos], edx
	Dolphin.xorImage.loop :
	mov ecx, [eax]
	mov edx, [ebx]
	push eax
	mov eax, [Dolphin.xbuf3pos]
	xor ecx, edx
	cmp ecx, 0x0
		je Dolphin.xorImage.noUpdate
		;mov edx, 0x0CFF0CFF
	mov [eax], edx
	jmp DxoIcnt
	Dolphin.xorImage.noUpdate :
	;		mov edx, [ebx]
	;mov [eax], edx
	DxoIcnt :
	add eax, 4
	mov [Dolphin.xbuf3pos], eax
	mov eax, [Dolphin.xbufsize]
	sub eax, 4
	mov [Dolphin.xbufsize], eax
	cmp eax, 0x4
		jle Dolphin.xorImage.ret
	pop eax
	add eax, 4
	add ebx, 4
	jmp Dolphin.xorImage.loop
	Dolphin.xorImage.ret :
	pop eax
	popa
	ret

Dolphin.windowExists :	; windowNum in ebx, returns either 0x0 or 0xF (F|T) in eax
push ebx
add ebx, Dolphin.windowStructs
mov eax, [ebx]
pop ebx
cmp eax, 0x0
je Dolphin.windowExists.false
mov eax, 0xF
ret
Dolphin.windowExists.false :
mov eax, 0x0
ret

Dolphin.activateNext :	; activates the next window in the list
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
ret

Dolphin.toggleColored :
pusha
mov eax, [Dolphin.tuskip]
cmp eax, 0x2
je Dolphin.toggleColored.toNonColored
mov eax, 0x2
mov [Dolphin.tuskip], eax
mov al, 0x0
mov [Dolphin.colorOverride], al
jmp Dolphin.toggleColored.ret
Dolphin.toggleColored.toNonColored :
mov eax, 0x1
mov [Dolphin.tuskip], eax
mov al, 0xFF
mov [Dolphin.colorOverride], al
Dolphin.toggleColored.ret :
popa
ret

Dolphin.registerWindow :	; eax = pointer to windowStruct; returns bl contains windowNum
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
ret

;																	NEW ***
Dolphin.getAttribDouble :	; returns eax. bl = offset
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
ret

Dolphin.getAttribWord :	; returns eax
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
ret

Dolphin.getAttribByte :	; returns eax
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
ret


Dolphin.setAttribDouble :	; attrib val in eax
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
ret


Dolphin.setAttribWord :	; attrib val in ax
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
ret


Dolphin.setAttribByte :	; attrib val in al
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
ret
;																*** NEW



Dolphin.unregisterWindow :	; winNum in bl
pusha
mov ecx, 0x0
and ebx, 0xFF
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
	
call Dolphin.redrawBG
	
popa
ret

Dolphin.moveWindow :	; xchange in eax, y change in ebx
pusha
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

call Dolphin.redrawBG

popa
ret

Dolphin.moveWindowAbsolute :	; x in eax, y in ebx
pusha
mov ecx, ebx

mov bl, [Window.X_POS]
call Dolphin.setAttribWord

mov eax, ecx
mov bl, [Window.Y_POS]
call Dolphin.setAttribWord

call Dolphin.redrawBG

popa
ret

Dolphin.anyActiveWindows :	; eax ret
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
ret
Dolphin.anyActiveWindows.yes :
mov eax, edx
add eax, 1
pop edx
pop ecx
pop ebx
ret

Dolphin.activeWinNum :
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
pusha
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

call Dolphin.redrawBG

popa
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


Dolphin.SCREEN_BUFFER :
dd 0x0
Dolphin.SCREEN_FLIPBUFFER :
dd 0x0

Window.TYPE_TEXT equ 0x0
Window.TYPE_IMAGE equ 0x1

Window.TITLE :
db 0
Window.WIDTH :
db 4
Window.HEIGHT :
db 6
Window.X_POS :
db 8
Window.Y_POS :
db 10
Window.TYPE :
db 12
Window.DEPTH :
db 13
Window.WINDOWBUFFER :
db 14
Window.BUFFER :
db 18
Window.BUFFERSIZE :
db 22
Window.OLDBUFFER :
db 26

Dolphin_WAIT_FLAG :
db 0x0

Dolphin.currentWindow :
dd 0x0
bstor :
dd 0x0
bposstor :
dd 0x0
dstor :
dd 0x0
dstor2 :
dd 0x0
atwstor :
dw 0x0
atwstor2 :
dw 0x0
atwstorX :
dw 0x0
atwstor2X :
dw 0x0
Dolphin.xbufsize :
dd 0x0
Dolphin.xbuf1pos :
dd 0x0
Dolphin.xbuf2pos :
dd 0x0
Dolphin.xbuf3pos :
dd 0x0
Dolphin.dcount :
db 0x0

Dolphin.colorOverride :
db 0x0
Dolphin.tuskip :
dd 0x2
Dolphin.TextHandler.charposStor :
dw 0x0
Dolphin.bsizstor :
dd 0x0
Dolphin.activeWindow :	; winNum for the window that currently has focus (must be switched by Dolphin!)
db 0x0
bglocstor :
dd 0x0
Dolphin.windowStructs :
times 20 dd 0

Dolphin.UNDolphin.REG_MSG :
db "A window has been unregistered!", 0
Dolphin.REG_MSG :
db "A window has been registered!", 0
