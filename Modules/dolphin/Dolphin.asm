[bits 32]
CHANGE_MASK equ 0x80000000

Dolphin.init :
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

; Dolphin.updateScreen :
; pusha
	; cmp byte [Dolphin_WAIT_FLAG], 0xFF
		; je Dolphin.updateScreen.ret
	; push word [Dolphin.currentWindow]
			; ; 	If an exception occurs, blame Dolphin.	;
	; mov bl, Manager.CONTROL_DOLPHIN
	; mov [os.mlloc], bl
			; ; has active window changed? if so, every window with a lower depth than its previous depth should have their depth incremented by 1, the new active window should have its depthset to 0.

; ;	Draw windows in here!
	; mov ebx, 0x0
	; mov ecx, 0x0
	; Dolphin.updateScreen.checkWindow :
						; ; loop through each window, find the one with the highest depth, then highest depth lower than that depth, etc. (run through all of the windows in order of decreasing depth)
		; cmp ebx, 0x3C	; num of windows * 4 bytes per windowStruct location
			; jge Dolphin.doneDrawingWindows
			
		; call Dolphin.windowExists
		; add ebx, 4
		; cmp eax, 0x0
			; je Dolphin.updateScreen.checkWindow
			
		; push ebx
		; sub ebx, 4
		
		; mov [Dolphin.currentWindow], ebx
		; add ebx, Dolphin.windowStructs
		; mov edx, [ebx]
		; push edx
		
		; mov [atwstorX], ax
		
		; mov [atwstor2X], ax
		
		; mov eax, [edx+14]	; windowbuffer
		
		; xor ecx, ecx
		; mov cx, [edx+4]	; width
		; mov dx, [edx+6]	; height
		; and edx, 0xFFFF

		; mov ebx, eax
		; call Dolphin.drawBorder
		; call Dolphin.drawTitle

		; mov ebx, [Graphics.SCREEN_MEMPOS]
		
		; pop edx
		; push eax
		; xor eax, eax
		; mov ax, [edx+10]	; ypos
		; imul eax, [Graphics.SCREEN_WIDTH]
			
		; add ebx, eax	; add ypos
		; xor eax, eax
		; mov ax, [edx+8]
		; add ebx, eax	; add xpos
		; pop eax
		; mov dx, [edx+6]	; height back

		; call Image.copy
		
		; pop ebx
		; jmp Dolphin.updateScreen.checkWindow
		
	; Dolphin.doneDrawingWindows :
	; pop word [Dolphin.currentWindow]
	
; Dolphin.updateScreen.ret :
; popa
; ret

; *** NEW SCREEN UPDATE CODE ***

Dolphin.updateScreenNew :
pusha
;
; for each window
; 	does it need rects drawn?
;		yes:
;			window is on top:
;				updateRects
;			window is not on top:
;				figure out occlusion somehow...
;	window has been moved/resized:
;		updateAll = true
;
; if updateAll
;	redraw background
;	for each window
;		redraw winBuffer to screen
;
popa
ret

Dolphin.updateScreenNew.updateRects :
pusha
mov [espStor], esp	; store current stack
mov [ebpStor], ebp

pusha			; store window's position
	xor eax, eax
	mov bl, [Window.Y_POS]
	call Dolphin.getAttribWord
	mov ecx, eax
	mov bl, [Window.WIDTH]
	call Dolphin.getAttribWord
	imul ecx, eax
	mov bl, [Window.X_POS]
	call Dolphin.getAttribWord
	add ecx, eax
	mov [cWinPos], ecx
popa

mov ebp, [uRectsBase]	; load rects stack
mov esp, [uRectsEnd]

Dolphin.updateNew.cRectsLoop :	; update rects
pop eax	; eg 0= ul of win in winB
mov ebx, [Graphics.SCREEN_MEMPOS]	; ul of screen
add ebx, [cWinPos]	; ul of win
add ebx, eax	; where to be in win
mov cx, 5
mov dx, 7
call Image.copy
cmp ebp, esp
	jne Dolphin.updateNew.cRectsLoop

mov ebp, [ebpStor]	; load old stack
mov esp, [espStor]
popa
ret

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
	call Dolphin.drawTextNew
	Dolphin.uUpdate.notText :
popa
ret


Dolphin.SCREEN_BUFFER :
dd 0x0
Dolphin.SCREEN_FLIPBUFFER :
dd 0x0



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

Dolphin.UNDolphin.REG_MSG :
db "A window has been unregistered!", 0
Dolphin.REG_MSG :
db "A window has been registered!", 0
