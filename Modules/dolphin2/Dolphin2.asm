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
	
Dolphin2.registerWindow :	; String title, int x, int y, int w, int h
		call WindowGrouping.Create
		push eax
		push ebx
			mov eax, ecx
			mov ebx, [Dolphin2.compositorGrouping]
			call Grouping.Add
		pop ebx
		pop eax
	ret

Dolphin2.compositorGrouping :
	dd 0x0
