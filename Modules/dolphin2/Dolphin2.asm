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
		
	popa
	ret

Dolphin2.renderScreen :
	pusha
	
		mov ebx, [Dolphin2.compositorGrouping]
		;call Component.Render
		call L3gxImage.FakeFromComponent
		
		push ecx
		push 0xFF000000
		call L3gx.clearImage
		
		push ecx
		push 100
		push 100
		push 50
		push 50
		push 0xFFFF00FF
		call L3gx.lineRect
		
		push ecx
		push 100
		push 200
		push 50
		push 100
		push 0xFF00FF00
		call L3gx.fillRect
		
		mov ebx, [ebx+Grouping_subcomponent]
		mov ecx, [Mouse.x]
		imul ecx, 4
		mov [ebx+Component_x], ecx
		mov ecx, [Graphics.SCREEN_HEIGHT]
		sub ecx, [Mouse.y]
		mov [ebx+Component_y], ecx
		
		mov eax, [Dolphin2.flipBuffer]
		mov ebx, [Graphics.SCREEN_MEMPOS]
		mov ecx, [Graphics.SCREEN_WIDTH]
		mov edx, [Graphics.SCREEN_HEIGHT]
		call Video.imagecopy
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

Dolphin2.compositorGrouping :
	dd 0x0
Dolphin2.makeWindow.ret :
	dd 0x0
Dolphin2.flipBuffer :
	dd 0x0
