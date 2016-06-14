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
		mov eax, [Graphics.SCREEN_WIDTH]
		imul eax, [Graphics.SCREEN_HEIGHT]
		add eax, 8	; space for the width and height
		mov ebx, eax
		call ProgramManager.reserveMemory;Guppy.malloc
		add ebx, 8
		mov [Dolphin2.flipBuffer], ebx
		pop ecx
		mov [ecx+Component_image], ebx
		
		mov eax, [Graphics.SCREEN_WIDTH]
		shr eax, 2
		mov [ebx-8], eax
		mov eax, [Graphics.SCREEN_HEIGHT]
		mov [ebx-4], eax
		
		mov dword [ecx+Grouping_backingColor], 0xFF000040
		
		; Save the Grouping for later use
		mov [Dolphin2.compositorGrouping], ecx
		
		mov dword [Dolphin2.started], 0xFF
		
	popa
	ret
	


SystemConfig.getBgColor :
	pusha
		mov eax, SystemConfig.STR_FILE_NAME
		call Minnow4.getFilePointer
		cmp ebx, Minnow4.SUCCESS
			jne .default
		call Minnow4.readFileBlock
		mov ebx, ecx
		mov eax, 3
		.loop :
		call Integer.decimalFromString
		shl dword [.color], 8
		or [.color], ecx
			.inloop :
			cmp byte [ebx], ','
				je .loopDone
			inc ebx
			jmp .inloop
			.loopDone :
			inc ebx
		dec eax
		cmp eax, 0x0
			jg .loop
		mov eax, [Dolphin2.compositorGrouping]
		mov edx, [.color]
		or edx, 0xFF000000
		mov dword [eax+Grouping_backingColor], edx
	popa
	ret
	.default :
		mov eax, [Dolphin2.compositorGrouping]
		mov edx, 0xFF000040
		mov dword [eax+Grouping_backingColor], edx
	popa
	ret
.color :
	dd 0x0
SystemConfig.STR_FILE_NAME :
	db "D2CFG.rawtext", 0x0
Dolphin2.windowTrimColor :
	dd 0xFFFFFFFF
Dolphin2.titleBarColor :
	dd 0xFF808080
Dolphin2.titleBarActiveColor :
	dd 0xFF201080

Dolphin2.renderScreen :
	pusha
	
		mov ebx, [Dolphin2.compositorGrouping]
		call Component.Render
		
		call Dolphin2.drawFPScounter
		
		call Dolphin2.drawMouse
		
		mov eax, [Dolphin2.flipBuffer]
		mov ebx, [Graphics.SCREEN_MEMPOS]
		mov ecx, [Graphics.SCREEN_WIDTH]
		mov edx, [Graphics.SCREEN_HEIGHT]
		call Video.imagecopy
		
	popa
	ret
FPS_NUM_STR :
	dq 0
	db 0
FPS_STR :
	db " fps", 0
Dolphin2.lastFrameTime :
	dd 0x0
Dolphin2.tempvar :
	times 5 dw 0
Dolphin2.1k :
	dd 1000
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

Dolphin2.drawFPScounter :
	pusha
		mov dword [FPS_NUM_STR], 0
		mov dword [FPS_NUM_STR+4], 0
		mov eax, FPS_NUM_STR
		mov ebx, [Clock.tics]
		sub ebx, [Dolphin2.lastFrameTime]
		push eax
		; ebx is in 5000ths of a second per frame
		xor edx, edx
		mov eax, ebx
		mov ecx, 5
		idiv ecx
		mov ebx, eax; ebx is in ms per frame
		mov [Dolphin2.tempvar], ebx
		fld1
		fimul dword [Dolphin2.1k]
		fidiv dword [Dolphin2.tempvar]
		fbstp [Dolphin2.tempvar]
		mov ebx, [Dolphin2.tempvar]
		pop eax
		call String.fromHex
		mov eax, [Clock.tics]
		mov [Dolphin2.lastFrameTime], eax
		
		mov ecx, [Dolphin2.flipBuffer]
		mov eax, FPS_NUM_STR
		call d2_easyteletype
		mov eax, FPS_STR
		call d2_easyteletype
	popa
	ret
	
Dolphin2.drawMouse :
	pusha
		cmp dword [Dolphin2.started], true
			jne .ret
		mov eax, [Dolphin2.flipBuffer]
		mov ebx, [Graphics.SCREEN_HEIGHT]
	;	pusha
	;		sub ebx, [Mouse.lasty]
	;		imul ebx, [Graphics.SCREEN_WIDTH]
	;		add eax, ebx
	;		mov ecx, [Mouse.lastx]
	;		imul ecx, 4
	;		add eax, ecx
	;		mov ebx, 8
	;		mov ecx, 14
	;		call Dolphin.redrawBackgroundRegion
	;	popa
		sub ebx, [Mouse.y]
		imul ebx, [Graphics.SCREEN_WIDTH]
		add eax, ebx
		mov ecx, [Mouse.x]
		imul ecx, 4
		add eax, ecx
		
		push dword [Image.copyRegionWithTransparency.w]
		push dword [Image.copyRegionWithTransparency.ow]
		push dword [Image.copyRegionWithTransparency.nw]
		push dword [Image.copyRegionWithTransparency.h]
		push dword [Image.copyRegionWithTransparency.obuf]
		push dword [Image.copyRegionWithTransparency.nbuf]
		push dword [Image.copyRegionWithTransparency.owa]
		push dword [Image.copyRegionWithTransparency.nwa]
		mov ecx, eax
		;		mov ebx, Color.fuse.VARDATA
		;		call kernel.SaveFunctionState
		push dword [Color.fuse.old]
		push dword [Color.fuse.new]
		push dword [Color.fuse.ret]
			mov dword [Image.copyRegionWithTransparency.w], CURSOR_WIDTH
			mov dword [Image.copyRegionWithTransparency.ow], CURSOR_WIDTH
			mov edx, [Graphics.SCREEN_WIDTH]
			mov [Image.copyRegionWithTransparency.nw], edx
			mov dword [Image.copyRegionWithTransparency.h], CURSOR_HEIGHT
			mov eax, [Mouse.cursor]
			mov dword [Image.copyRegionWithTransparency.obuf], eax
			mov [Image.copyRegionWithTransparency.nbuf], ecx
			call Image.copyRegionWithTransparency
		pop dword [Color.fuse.ret]
		pop dword [Color.fuse.new]
		pop dword [Color.fuse.old]
		;		mov ebx, Color.fuse.VARDATA
		;		call kernel.LoadFunctionState
		pop dword [Image.copyRegionWithTransparency.nwa]
		pop dword [Image.copyRegionWithTransparency.owa]
		pop dword [Image.copyRegionWithTransparency.nbuf]
		pop dword [Image.copyRegionWithTransparency.obuf]
		pop dword [Image.copyRegionWithTransparency.h]
		pop dword [Image.copyRegionWithTransparency.nw]
		pop dword [Image.copyRegionWithTransparency.ow]
		pop dword [Image.copyRegionWithTransparency.w]
		
		mov ecx, [Mouse.x]
		mov edx, [Mouse.y]
		mov [Mouse.lastx], ecx
		mov [Mouse.lasty], edx
	.ret :
	popa
	ret

B equ 0xFF000000
W equ 0xFFFFFFFF
T equ 0x00000000

CURSOR_WIDTH	equ 11*4
CURSOR_HEIGHT	equ 21
Mouse.cursor :
	dd Mouse.CURSOR_DEFAULT
Mouse.CURSOR_DEFAULT :
	dd B, T, T, T, T, T, T, T, T, T, T
	dd B, B, T, T, T, T, T, T, T, T, T
	dd B, W, B, T, T, T, T, T, T, T, T
	dd B, W, W, B, T, T, T, T, T, T, T
	dd B, W, W, W, B, T, T, T, T, T, T
	dd B, W, W, W, W, B, T, T, T, T, T
	dd B, W, W, W, W, W, B, T, T, T, T
	dd B, W, W, W, W, W, W, B, T, T, T
	dd B, W, W, W, W, W, W, W, B, T, T
	dd B, W, W, W, W, W, W, W, W, B, T
	dd B, W, W, W, W, W, W, W, W, W, B
	dd B, W, W, W, W, W, W, W, W, B, B
	dd B, W, W, W, W, W, W, B, B, T, T
	dd B, W, W, W, B, W, W, B, T, T, T
	dd B, W, W, B, T, B, W, B, T, T, T
	dd B, W, B, T, T, B, W, W, B, T, T
	dd B, B, T, T, T, T, B, W, W, B, T
	dd T, T, T, T, T, T, T, B, W, B, T
	dd T, T, T, T, T, T, T, B, W, W, B
	dd T, T, T, T, T, T, T, B, W, B, B
	dd T, T, T, T, T, T, T, T, B, T, T
Mouse.CURSOR_TRANSPARENT :
	times CURSOR_WIDTH*CURSOR_HEIGHT dd T

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

Dolphin2.handleMouseEvent :
	pusha
		mov [Component.mouseEventType], ebx
		mov eax, [Mouse.x]
		imul eax, 4
		mov [Component.mouseEventX], eax
		mov eax, [Graphics.SCREEN_HEIGHT]
		sub eax, [Mouse.y]
		mov [Component.mouseEventY], eax
			cmp dword [Dolphin2.windowMoving], TRUE
				jne .cont
			jmp TitleBar.passthroughMouseEvent.gocheck
			.cont :
		mov ebx, [Dolphin2.compositorGrouping]
		call Component.HandleMouseEvent
	popa
	ret
	
Dolphin2.showLoginScreen :
	pusha
		push dword 0
		push dword 0
		push dword [Graphics.SCREEN_WIDTH]
		push dword [Graphics.SCREEN_HEIGHT]
		call Grouping.Create
		mov ebx, [Dolphin2.compositorGrouping]
		mov eax, ecx
		call Grouping.Add
		mov ebx, ecx
		push dword [Dolphin2.bgimg]	; for some reason breaks 'Image's made later...
		push dword 1024*4
		push dword 768
		push dword 0
		push dword 0
		push dword [Graphics.SCREEN_WIDTH]
		push dword [Graphics.SCREEN_HEIGHT]
		call Image.Create
	;	push dword [Dolphin2.bgimg]	; TESTING!~!!
	;	push dword 1024*4
	;	push dword 768
	;	push dword 0
	;	push dword 0
	;	push dword [Graphics.SCREEN_WIDTH]
	;	push dword [Graphics.SCREEN_HEIGHT]
	;	call Image.Create	; TESTING!~!!
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
		mov dword [ecx+Component_keyHandlerFunc], Dolphin2.showLoginScreen.passwordKeyHandler
		mov [Dolphin2.focusedComponent], ecx
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
		mov ebx, [Dolphin2.compositorGrouping]
		mov eax, [ebx+Grouping_subcomponent]
		call Grouping.Remove
		Dolphin2.checkPass.ret :
	popa
	ret

Dolphin2.showLoginScreen.passwordKeyHandler :
	mov al, [Component.keyChar]
	cmp al, 0xFE
		jne kgo
	call Dolphin2.checkPass
	ret
	kgo :
	call TextArea.onKeyboardEvent.handle
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
Dolphin2.windowMoving :
	dd 0x0
Dolphin2.STR_LOGIN_SCREEN :
	db "Os3 Login", 0
