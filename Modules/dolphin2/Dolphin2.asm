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
		
		mov dword [ecx+Grouping_backingColor], 0x0;0xFF000040
		
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
		
		mov dword [FPS_NUM_STR], 0
		mov dword [FPS_NUM_STR+4], 0
		mov eax, FPS_NUM_STR
		mov ebx, [Clock.tics]
		sub ebx, [Dolphin2.lastFrameTime]
		shl ebx, 2
			push eax
			mov eax, ebx
			mov ecx, 10
			xor edx, edx
			idiv ecx
			mov ebx, eax
			pop eax
		call String.fromHex
		mov eax, [Clock.tics]
		mov [Dolphin2.lastFrameTime], eax
		
		mov eax, HEX_PREF_STR
		mov ecx, [Dolphin2.flipBuffer]
		call d2_easyteletype
		mov eax, FPS_NUM_STR
		call d2_easyteletype
		mov eax, FPS_STR
		call d2_easyteletype
		
		mov eax, [Dolphin2.flipBuffer]
		mov ebx, [Graphics.SCREEN_MEMPOS]
		mov ecx, [Graphics.SCREEN_WIDTH]
		mov edx, [Graphics.SCREEN_HEIGHT]
		call Video.imagecopy
		
	popa
	ret
HEX_PREF_STR :
	db "0x", 0
FPS_NUM_STR :
	dq 0
	db 0
FPS_STR :
	db " ms/frame", 0
Dolphin2.lastFrameTime :
	dd 0x0
d2_easyteletype :
		mov edx, [Graphics.SCREEN_WIDTH]
		mov ebx, 0xFFFFFFFF
		
		reasr4 :
		push eax
		mov al, [eax]
		cmp al, 0x0
			je qweasdasd
		call RenderText
		pop eax
		add eax, 1
		add ecx, 0x4*FONTWIDTH
		jmp reasr4
		qweasdasd :
		pop eax	
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
		push dword 200*4
		push dword 80
		push dword (1024-200-200)*4
		push dword 200
		call Grouping.Create
		mov dword [ecx+Grouping_backingColor], 0xFFC01010
		mov eax, ecx
		call Grouping.Add
		mov ebx, ecx
		call Component.RequestUpdate	; test
		push dword Dolphin2.STR_LOGIN
		push dword 512*4-(9/2*FONTWIDTH*4)-200*4
		push dword 100-80
		push dword 9*FONTWIDTH*4
		push dword FONTHEIGHT
		call TextLine.Create
		mov eax, ecx
		call Grouping.Add
		
		push dword Dolphin2.STR_PASSWORD
		push dword 512*4-(5*FONTWIDTH*4)-10*FONTWIDTH*4-200*4
		push dword 100+FONTHEIGHT+5-80
		push dword FONTWIDTH*4*10
		push dword FONTHEIGHT
		call TextLine.Create
		mov eax, ecx
		call Grouping.Add
		
		push dword 20
		push dword 512*4+(5*FONTWIDTH*4)-10*FONTWIDTH*4-200*4
		push dword 100+FONTHEIGHT+5-80
		push dword 20*FONTWIDTH*4
		push dword FONTHEIGHT
		push dword FALSE
		call TextArea.Create
		mov eax, ecx
		call Grouping.Add
	;;;	mov dword [ecx+Textarea_customKeyHandler], SysHaltScreen.show
		mov [Dolphin2.passEntryBox], ecx
		
		push dword Dolphin2.STR_GOBUTTON
		push dword Dolphin2.checkPass
		push dword 512*4-20*4/2-200*4
		push dword 100+FONTHEIGHT*2+10-80
		push dword 20*4
		push dword 10
		call Button.Create
		mov eax, ecx
		call Grouping.Add
		
	popa
	ret
Dolphin2.STR_PASSWORD :
	db "Password: ", 0
Dolphin2.STR_LOGIN :
	db "Os3 Login", 0
Dolphin2.STR_GOBUTTON :
	db "Go", 0
Dolphin2.STR_PASS :
	db "password", 0
Dolphin2.passEntryBox :
	dd 0x0
Dolphin2.checkPass :
	pusha
		mov eax, [Dolphin2.passEntryBox]
		mov ebx, [eax+Textarea_text]
		mov eax, Dolphin2.STR_PASS
		call os.seq
		cmp al, FALSE
			je Dolphin2.checkPass.ret
		mov ebx, [Dolphin2.passEntryBox]
		call WindowGrouping.closeCallback
		Dolphin2.checkPass.ret :
	popa
	ret
	
Dolphin2.SystemMenu.Show :
	pusha
		
		push dword 0
		push dword 0
		push dword [Graphics.SCREEN_WIDTH]
		push dword [Graphics.SCREEN_HEIGHT]
		call Grouping.Create
		mov dword [ecx+Component_transparent], FALSE
		mov dword [ecx+Grouping_backingColor], 0x80000000
		mov eax, ecx
		mov ebx, [Dolphin2.compositorGrouping]
		;call Grouping.Add
		;mov ebx, ecx
		mov eax, [Graphics.SCREEN_WIDTH]
		shr eax, 1
		sub eax, 500*4/2
		push eax
		mov eax, [Graphics.SCREEN_HEIGHT]
		shr eax, 1
		sub eax, 300/2
		push eax
		push dword 500*4
		push dword 300
		call Grouping.Create
		mov dword [ecx+Component_transparent], FALSE
		mov dword [ecx+Grouping_backingColor], 0xFF00FF00
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
