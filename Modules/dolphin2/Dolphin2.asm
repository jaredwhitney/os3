Dolphin2.createCompositorGrouping :
	pusha
		; Create the Grouping
		push dword 0
		push dword 0
		push dword 0
		push dword 0
		call Grouping.Create
		
		; Manually match the Grouping to the screen
		mov eax, [Graphics.SCREEN_WIDTH]
		mov [ecx+Component_w], eax
		mov eax, [Graphics.SCREEN_HEIGHT]
		mov [ecx+Component_h], eax
		
		push ecx
		mov eax, [Graphics.SCREEN_SIZE]
		sub eax, 1
		xor edx, edx
		mov ecx, 0x1000
		idiv ecx
		add eax, 1
		mov ebx, eax
		mov al, 8
		call Guppy.malloc
		mov [Dolphin2.flipBuffer], ebx
		pop ecx
		mov [ecx+Component_image], ebx
		
		mov dword [ecx+Grouping_backingColor], 0xFF000040
		
		; Save the Grouping for later use
		mov [Dolphin2.compositorGrouping], ecx
		
		mov dword [Dolphin2.started], 0xFF
		
	popa
	ret

Dolphin2.renderScreen :
	pusha
	
		mov ebx, [Dolphin2.compositorGrouping]
		call Component.Render
		
	;	mov ebx, [ebx+Grouping_subcomponent]
	;	mov ecx, [Mouse.x]
	;	imul ecx, 4
	;	mov [ebx+Component_x], ecx
	;	mov ecx, [Graphics.SCREEN_HEIGHT]
	;	sub ecx, [Mouse.y]
	;	mov [ebx+Component_y], ecx
		
		mov eax, [Dolphin2.flipBuffer]
		mov ebx, [Graphics.SCREEN_MEMPOS]
		mov ecx, [Graphics.SCREEN_WIDTH]
		mov edx, [Graphics.SCREEN_HEIGHT]
		call Video.imagecopy
		
	popa
	ret
	
Dolphin2.drawMouse :
	pusha
		mov eax, [Graphics.SCREEN_MEMPOS]
		mov ebx, [Graphics.SCREEN_HEIGHT]
		pusha
		sub ebx, [Mouse.lasty]
		imul ebx, [Graphics.SCREEN_WIDTH]
		add eax, ebx
		mov ecx, [Mouse.lastx]
		imul ecx, 4
		add eax, ecx
		mov ebx, 1
		mov ecx, 1
		call Dolphin.redrawBackgroundRegion
		popa
		sub ebx, [Mouse.y]
		imul ebx, [Graphics.SCREEN_WIDTH]
		add eax, ebx
		mov ecx, [Mouse.x]
		imul ecx, 4
		add eax, ecx
		mov dword [eax], 0xFFFFFF

		mov ecx, [Mouse.x]
		mov edx, [Mouse.y]
		mov [Mouse.lastx], ecx
		mov [Mouse.lasty], edx
	popa
	ret

Dolphin2.HandleKeyboardEvent :
	pusha
		mov ebx, [Dolphin2.focusedComponent]
		call Component.HandleKeyboardEvent
	popa
	ret
	
Dolphin2.makeWindow :	; String title, int x, int y, int w, int h; returns WindowGrouping in ecx
		pop dword [Dolphin2.makeWindow.ret]
		call WindowGrouping.Create
	;		pop dword [0x1000]
	;		pop dword [0x1000]
	;		pop dword [0x1000]
	;		pop dword [0x1000]
	;		pop dword [0x1000]
		push eax
		push ebx
			mov eax, ecx
			mov ebx, [Dolphin2.compositorGrouping]
			call Grouping.Add
		pop ebx
		pop eax
		mov ecx, [ecx+WindowGrouping_mainGrouping]
		push dword [Dolphin2.makeWindow.ret]
	ret

Dolphin2.handleMouseClick :
	pusha
			mov eax, [Mouse.x]
			imul eax, 4
			mov [Component.mouseEventX], eax
			mov eax, [Graphics.SCREEN_HEIGHT]
			sub eax, [Mouse.y]
			mov [Component.mouseEventY], eax
		mov ebx, [Dolphin2.compositorGrouping]
		call Component.HandleMouseEvent
	popa
	ret
	
Dolphin2.showLoginScreen :
	pusha
		push dword Dolphin2.STR_LOGIN_SCREEN
		push dword 0
		push dword 0
		push dword [Graphics.SCREEN_WIDTH]
		push dword [Graphics.SCREEN_HEIGHT]
		call Dolphin2.makeWindow
		mov ebx, ecx
		push dword [Dolphin2.bgimg]
		push dword 1024*4
		push dword 768
		push dword 0
		push dword 0
		push dword [Graphics.SCREEN_WIDTH]
		push dword [Graphics.SCREEN_HEIGHT]
		call Image.Create
		mov eax, ecx
		call Grouping.Add
	popa
	ret
	
Dolphin2.compositorGrouping :
	dd 0x0
Dolphin2.makeWindow.ret :
	dd 0x0
Dolphin2.flipBuffer :
	dd 0x0
Dolphin2.bgimg :
	dd 0x0
Dolphin2.focusedComponent :
	dd 0x0
Dolphin2.started :
	dd 0x0
Dolphin2.STR_LOGIN_SCREEN :
	db "Os3 Login", 0
