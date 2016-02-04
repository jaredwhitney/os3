[bits 32]

CHANGE_MASK equ 0x80000000

Dolphin.init :
	pusha
		
		;mov bl, [Graphics.VESA_MODE]
		;cmp bl, 0x0
		;	je Dolphin.NONVESAinit
		mov al, 0x1
			mov eax, [Graphics.SCREEN_SIZE]
			mov ecx, 0x1000
			xor edx, edx
			idiv ecx
		mov ebx, eax
		call Guppy.malloc
		mov [Dolphin.SCREEN_BUFFER], ebx
		;mov ebx, 0x2800
		;call Guppy.malloc
		;mov [Dolphin.SCREEN_FLIPBUFFER], ebx
		
		;call Dolphin.redrawBG
	
	popa
	ret


; Dolphin.NONVESAinit :

		; mov al, 0x1
		; mov ebx, 0x7D
		; call Guppy.malloc
		; mov [Dolphin.SCREEN_BUFFER], ebx
		; mov ebx, 0x7D
		; call Guppy.malloc
		; mov [Dolphin.SCREEN_FLIPBUFFER], ebx
	
		; call Dolphin.redrawBG
	
	; popa
	; ret


Dolphin.redrawBG :
	push ebx
		mov byte [Dolphin_WAIT_FLAG], 0xFF
		mov ebx, [bglocstor]
		call Dolphin.makeBG
		mov byte [Dolphin_WAIT_FLAG], 0x00
	pop ebx
	ret


Dolphin.makeBG :	; ebx contains location of data
	pusha
		mov [bglocstor], ebx
		cmp ebx, 0x0
			je Dolphin.solidBG
		mov eax, ebx	; should also be smarter than this...
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
		call Dolphin.getSolidBGColor
		call Image.clear
	popa
	ret


Dolphin.getSolidBGColor :
	push cx
		mov ebx, 0x10101010
		mov cl, [Graphics.VESA_MODE]
		cmp cl, 0x0
			je Dolphin.solidBGNOVESA
		mov ebx, 0x0000C7
	Dolphin.solidBGNOVESA :
	pop cx
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
		
		mov eax, [Clock.tics]
		sub eax, [Dolphin.lastTic]
		;imul eax, 10
		mov [Dolphin.frameTime], eax
		mov eax, [Clock.tics]
		mov [Dolphin.lastTic], eax
		
		mov eax, [tnums]
		and eax, 0xFF
		add eax, 0xa0000
		mov dword [eax], 0xFF
		mov eax, [tnums]
		add eax, 1
		mov [tnums], eax
			
		call Dolphin.anyActiveWindows
		cmp eax, 0x0
			jne Dolphin.updateScreen.cont
		call Manager.freezePanic
		Dolphin.updateScreen.cont :
	
	;	Draw windows in here!
		mov ebx, 0x0
		mov ecx, 0x0
		Dolphin.updateScreen.checkWindow :
			; loop through each window, find the one with the highest depth, then highest depth lower than that depth, etc. (run through all of the windows in order of decreasing depth)
			cmp ebx, 0x3C	; num of windows * 4 bytes per windowStruct location
				jge Dolphin.doneDrawingWindows
			
			call Dolphin.windowExists
			add ebx, 4
			cmp eax, 0x0
				je Dolphin.updateScreen.checkWindow
			
			push ebx
			sub ebx, 4
			
			call Dolphin.compositeWindow
			
			pop ebx
			jmp Dolphin.updateScreen.checkWindow
		
		Dolphin.doneDrawingWindows :
		pop word [Dolphin.currentWindow]
		
		call Mouse.drawOnScreen
		
	Dolphin.updateScreen.ret :
	popa
	ret


Dolphin.compositeWindow :

		mov [Dolphin.currentWindow], ebx
		add ebx, Dolphin.windowStructs
		mov edx, [ebx]
		push edx
		
		mov [atwstorX], ax
		
		mov [atwstor2X], ax
		
		mov eax, [edx+Window_windowbuffer]	; windowbuffer
		
		xor ecx, ecx
		mov cx, [edx+Window_width]	; width
		mov dx, [edx+Window_height]	; height
		and edx, 0xFFFF

		mov ebx, eax
		call Dolphin.drawBorder
		call Dolphin.drawTitle

		mov ebx, [Graphics.SCREEN_MEMPOS]
		
		pop edx
		push eax
		xor eax, eax
		mov ax, [edx+Window_ypos]	; ypos
		imul eax, [Graphics.SCREEN_WIDTH]
			
		add ebx, eax	; add ypos
		xor eax, eax
		mov ax, [edx+Window_xpos]
		add ebx, eax	; add xpos
		pop eax
		mov dx, [edx+Window_height]	; height back

		call Image.copy

	ret


Dolphin.uUpdate :	; currentWindow is the window
	pusha
		;mov bl, [Window.TYPE]
		;call Dolphin.getAttribByte
		;cmp al, 0x0
		;	jne Dolphin.uUpdate.notText
		;mov bl, [Window.WIDTH]
		;call Dolphin.getAttribWord
		;mov cx, ax
		;mov bl, [Window.OLDBUFFER]
		;call Dolphin.getAttribDouble
		;mov edx, eax
		;mov bl, [Window.WINDOWBUFFER]
		;call Dolphin.getAttribDouble
		;mov ebx, eax
		;push ebx
		;mov bl, [Window.BUFFER]
		;call Dolphin.getAttribDouble
		;pop ebx
		;call Dolphin.drawTextNew2
		;Dolphin.uUpdate.notText :
		mov eax, [Dolphin.currentWindow]
		add eax, Dolphin.windowStructs
		mov eax, [eax]
		cmp dword [eax+Window_linkedComponent], 0x0
			je Dolphin.uUpdate.noComponents
		mov ebx, [eax+Window_linkedComponent]
		call Grouping.updateFitToHostWindow	; sync Grouping with Window (see below)
		call Component.Render	; Window_linkedComponent will be a Grouping whose size is always kept in sync with the host Window and whose image is the same as the host Window, so no further calls should be needed
		Dolphin.uUpdate.noComponents :
	popa
	ret

Dolphin.updateWindows :
	pusha
	
		xor ecx, ecx
		mov ebx, Dolphin.windowStructs
		
		Dolphin.updateWindows.loop :
			mov edx, [ebx]
			cmp edx, 0x0
				je Dolphin.updateWindows.nope
			mov [Dolphin.currentWindow], ecx
			call Dolphin.uUpdate
			Dolphin.updateWindows.nope :
			add ebx, 4
			add ecx, 4
			; should check and if needed jump back to the start of the loop
			
	popa
	ret

Dolphin.redrawBackgroundRegion :
	pusha
		cmp dword [bglocstor], 0x0
			jne Dolphin.redrawBackgroundRegion.redrawImage
		push ebx
		call Dolphin.getSolidBGColor
		mov edx, ebx
		pop ebx
		call Image.clearRegion
	popa
	ret
Dolphin.redrawBackgroundRegion.redrawImage :	; ebx:w, eax:nbuf, ecx:h
		mov [Image.copyRegion.w], ebx
		mov edx, [Graphics.SCREEN_WIDTH]
		mov [Image.copyRegion.nw], edx
		mov [Image.copyRegion.ow], edx	; should be set to the image's width
		mov [Image.copyRegion.h], ecx
		mov [Image.copyRegion.nbuf], eax
		sub eax, [Graphics.SCREEN_MEMPOS]
		add eax, [bglocstor]	; should be smarter than this... map x,y to x,y etx
		mov [Image.copyRegion.obuf], eax
		call Image.copyRegion
	popa
	ret

Dolphin.handleMouseClick :
	pusha
		mov ecx, [Dolphin.currentWindow]
		add ecx, Dolphin.windowStructs
		mov ecx, [ecx]
		mov eax, [Mouse.x]
		imul eax, 4
		mov ebx, [Graphics.SCREEN_HEIGHT]
		sub ebx, [Mouse.y]
		add ebx, 8
		cmp eax, [ecx+Window_xpos]
			jl Dolphin.handleMouseClick.goMove
		mov edx, [ecx+Window_xpos]
		add edx, [ecx+Window_width]
		cmp eax, edx
			jg Dolphin.handleMouseClick.goMove
		;cmp ebx, [ecx+Window_ypos]
		;	jl Dolphin.handleMouseClick.goMove
		;mov edx, [ecx+Window_ypos]
		;add edx, [ecx+Window_height]
		;cmp ebx, edx
		;	jg Dolphin.handleMouseClick.goMove
		mov ebx, Dolphin.MOUSE_MSG
		call console.println
		jmp Dolphin.handleMouseClick.ret
		Dolphin.handleMouseClick.goMove :
		mov [ecx+Window_xpos], eax
		mov [ecx+Window_ypos], ebx
		;call Window.makeGlassSmart ; is broken atm
	Dolphin.handleMouseClick.ret :
	popa
	ret

Dolphin.SCREEN_BUFFER :
	dd 0x0
;Dolphin.SCREEN_FLIPBUFFER :
	;dd 0x0

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
	dd 0x0

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

Dolphin.lastTic :
	dd 0x0
Dolphin.frameTime :
	dd 0x0
tnums :
	dd 0x0

Dolphin.UNDolphin.REG_MSG :
	db "A window has been unregistered!", 0
Dolphin.REG_MSG :
	db "A window has been registered!", 0
Dolphin.MOUSE_MSG :
	db "Window was clicked!", 0
