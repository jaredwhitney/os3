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

	call Dolphin.redrawBG

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
	mov byte [Dolphin_WAIT_FLAG], 0x0
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
		
		mov eax, [edx+22]	; windowbuffer
		
		xor ecx, ecx
		mov cx, [edx+4]	; width
		mov dx, [edx+8]	; height
		and edx, 0xFFFF

		mov ebx, eax
		call Dolphin.drawBorder
		call Dolphin.drawTitle

		mov ebx, [Graphics.SCREEN_MEMPOS]
		
		pop edx
		push eax
		xor eax, eax
		mov ax, [edx+16]	; ypos
		imul eax, [Graphics.SCREEN_WIDTH]
			
		add ebx, eax	; add ypos
		xor eax, eax
		mov ax, [edx+12]
		add ebx, eax	; add xpos
		pop eax
		mov dx, [edx+8]	; height back

		call Image.copy

ret

; *** NEW SCREEN UPDATE CODE ***

; Dolphin.updateScreenNew :
; pusha
; cmp byte [Dolphin_WAIT_FLAG], 0x0
	; je Dolphin.uSN.cont
; popa
; ret
; Dolphin.uSN.cont :
; mov byte [Dolphin_WAIT_FLAG], 0xFF

;for each window
;	does it need rects drawn?
;		yes:
;			window is on top:
;				updateRects
;			window is not on top:
;				figure out occlusion somehow...
;	window has been moved/resized:
;		updateAll = true

;if updateAll
;	redraw background
;	for each window
;		redraw winBuffer to screen

	
	; mov ebx, Dolphin.windowStructs
	; mov [Dolphin.uSN.endval], ebx
	; add dword [Dolphin.uSN.endval], 0xF*0x4
	; Dolphin.updateScreenNew.loop1_start :
		; cmp ebx, [Dolphin.uSN.endval]
			; jg Dolphin.updateScreenNew.loop1_end	
			
			; push ebx
			; mov eax, [ebx]
			; cmp eax, 0x0
				; je Dolphin.updateScreenNew.loop1_innerdone
				; mov eax, ebx
				; sub eax, Dolphin.windowStructs
			; mov [Dolphin.currentWindow], eax
			
			; mov bl, [Window.DEPTH]
			; call Dolphin.getAttribByte
			; cmp al, 0x0
				; jne Dolphin.uSN.loop1.notOnTop
					; mov bl, [Window.NEEDS_RECT_UPDATE]
					; call Dolphin.getAttribByte
						; cmp al, 0x0
							; je Dolphin.updateScreenNew.loop1_innerdone
						; mov bl, [Window.RECTL_BASE]
						; call Dolphin.getAttribDouble
						; sub eax, 4
						; mov [uRectsBase], eax
						; mov bl, [Window.RECTL_TOP]
						; call Dolphin.getAttribDouble
						; mov [uRectsEnd], eax
						; mov bl, [Window.WINDOWBUFFER]
						; call Dolphin.getAttribDouble
						; mov [cWinBuf], eax
						; call Dolphin.updateScreenNew.updateRects
			; Dolphin.uSN.loop1.notOnTop :
;				figure out occlusion somehow...
		; Dolphin.updateScreenNew.loop1_innerdone :
		; pop ebx
		; add ebx, 4
		; jmp Dolphin.updateScreenNew.loop1_start
	; Dolphin.updateScreenNew.loop1_end :
	; mov byte [Dolphin_WAIT_FLAG], 0x00
; popa
; ret
; Dolphin.uSN.endval :
	; dd 0x0
; cWinPos :
	; dd 0x0
; cWinBuf :
	; dd 0x0

; Dolphin.updateScreenNew.updateRects :
; pusha


; pusha			; store window's position
	; xor eax, eax
	; mov bl, [Window.Y_POS]
	; call Dolphin.getAttribWord
	; mov ecx, eax
	; mov eax, [Graphics.SCREEN_WIDTH]
	; imul ecx, eax
	; mov bl, [Window.X_POS]
	; call Dolphin.getAttribWord
	; add ecx, eax
	; mov [cWinPos], ecx
; popa


; Dolphin.updateNew.cRectsLoop :	; update rects
;pop eax	; eg 0= ul of win in winB
; mov eax, [uRectsEnd]
; push eax
; mov eax, [eax]

; add dword [uRectsEnd], 4
; mov ebx, [Graphics.SCREEN_MEMPOS]	; ul of screen
; add ebx, [cWinPos]	; ul of win
; add ebx, eax	; where to be in win
; add eax, [cWinBuf]
; mov cx, 7	; SHOULD BE 5 BY 7
; mov dx, 9

; call Image.copyFromWinSource

; pop eax
; cmp eax, [uRectsBase]
	; jle Dolphin.updateNew.cRectsLoop

	; mov al, 0x0
	; mov bl, [Window.NEEDS_RECT_UPDATE]
	; call Dolphin.setAttribByte
	
; popa
; ret

; uRectsBase :
	; dd 0x0
; uRectsEnd :
	; dd 0x0
; ebpStor :
	; dd 0x0
; espStor :
	; dd 0x0

; *** END NEW SCREEN UPDATE CODE ***

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
	call Dolphin.drawTextNew2
	Dolphin.uUpdate.notText :
popa
ret

Dolphin.updateWindows :
pusha
Dolphin.updateWindows.wait :
;cmp byte [Dolphin_WAIT_FLAG], 0xFF
;	je Dolphin.updateWindows.wait
;mov byte [Dolphin_WAIT_FLAG], 0xFF
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
	;cmp ecx, 20*4
	;	jle Dolphin.updateWindows.loop
;	mov byte [Dolphin_WAIT_FLAG], 0x0
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
