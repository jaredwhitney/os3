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
		mov eax, [Graphics.SCREEN_MEMPOS]
		mov [ecx+Component_image], eax
		
		; Save the Grouping for later use
		mov [Dolphin2.compositorGrouping], ecx
		
	popa
	ret

Dolphin2.renderScreen :
	pusha
		mov ebx, [Dolphin2.compositorGrouping]
		call Component.Render
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
		;mov ecx, [ecx+WindowGrouping_mainGrouping]
		push dword [Dolphin2.makeWindow.ret]
	ret

Dolphin2.compositorGrouping :
	dd 0x0
Dolphin2.makeWindow.ret :
	dd 0x0
