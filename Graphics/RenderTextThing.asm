Component_type				equ 0
Component_image				equ 4
Component_x					equ 8
Component_y					equ 12
Component_w					equ 16
Component_h					equ 20
Component_nextLinked		equ 24
Component_upperRenderFlag	equ 28
Component_transparent		equ 32
Component_renderFunc		equ 36
Component_mouseHandlerFunc	equ 40
Component_keyHandlerFunc	equ 44
Component_needsRedraw		equ 48
Component_freeFunc		equ 52
Component_CLASS_SIZE		equ 56

Component.Render :	; Component in ebx
	methodTraceEnter
	pusha
		cmp dword [ebx+Component_renderFunc], 0
			je Component.killfunc
		call [ebx+Component_renderFunc]
	popa
	methodTraceLeave
	ret
Component.killfunc :
	methodTraceEnter
	mov eax, SysHaltScreen.KILL
	mov ebx, Component.INVALID_COMPONENT_MESSAGE
	mov ecx, 5
	call SysHaltScreen.show
	methodTraceLeave
	jmp $
Component.INVALID_COMPONENT_MESSAGE :
	db "[Dolphin] An attempt was made to access an invalid Component.", 0
Component.DEBUG_ALL :
	dd TRUE
Component.Render.layerColor :
	dd 0x400000

;Component.functionPointers :
;	dd Component.killfunc, TextLine.Render, TextArea.Render, Image.Render, ImageScalable.Render, Grouping.Render, Button.Render, GroupingScrollable.Render, SelectionPanel.Render, Grouping.Render
Component.TYPE_TEXTLINE				equ 0x1
Component.TYPE_TEXTAREA				equ 0x2
Component.TYPE_IMAGE				equ 0x3
Component.TYPE_IMAGE_SCALABLE		equ 0x4
Component.TYPE_GROUPING				equ 0x5
Component.TYPE_BUTTON				equ 0x6
Component.TYPE_SCROLLPANEL			equ 0x7
Component.TYPE_SELECTPANEL			equ 0x8
Component.TYPE_WINDOW				equ 0x9

Component.RequestUpdate :	; Component in ebx
methodTraceEnter
;pusha
	;mov ecx, [ebx+Component_upperRenderFlag]
	;mov dword [ecx], TRUE
	mov dword [ebx+Component_needsRedraw], true
;popa
methodTraceLeave
ret

Component.HandleMouseEvent :	; Component in ebx
methodTraceEnter
pusha
	; Make the coordinates relative to the component
	mov eax, [Component.mouseEventX]
	sub eax, [ebx+Component_x]
	mov [Component.mouseEventX], eax
	mov eax, [Component.mouseEventY]
	sub eax, [ebx+Component_y]
	mov [Component.mouseEventY], eax
	; Call the proper function
	cmp dword [ebx+Component_mouseHandlerFunc], 0x0
		jne .callfunc
	methodTraceLeave
	jmp Component.discardMouseEvent
	.callfunc :
	call [ebx+Component_mouseHandlerFunc]
popa
methodTraceLeave
ret
Component.discardKeyboardEvent :
Component.discardMouseEvent :
	; discard the event
popa
ret
Component.mouseHandlerPointers :
	dd Component.killfunc, Component.discardMouseEvent, Component.discardMouseEvent, Component.discardMouseEvent, Component.discardMouseEvent, Grouping.passthroughMouseEvent, Button.onMouseEvent, GroupingScrollable.passthroughMouseEvent, SelectionPanel.HandleMouseEvent, WindowGrouping.passthroughMouseEvent
Component.mouseEventX :
	dd 0x0
Component.mouseEventY :
	dd 0x0
Component.mouseEventType :
	dd 0x0
Component.HandleKeyboardEvent :	; Component in ebx
methodTraceEnter
pusha
	cmp byte [Component.keyChar], 0x0
		je Component.HandleKeyboardEvent.ret
	cmp dword [ebx+Component_keyHandlerFunc], 0x0
		je Component.discardKeyboardEvent
	call [ebx+Component_keyHandlerFunc]
Component.HandleKeyboardEvent.ret :
popa
methodTraceLeave
ret
Component.keyHandlerPointers :
	dd Component.killfunc, Component.discardKeyboardEvent, TextArea.onKeyboardEvent, Component.discardKeyboardEvent, Component.discardKeyboardEvent, Component.discardKeyboardEvent, Component.discardKeyboardEvent, Component.discardKeyboardEvent, Component.discardKeyboardEvent, Component.discardKeyboardEvent
Component.keyChar :
	db 0x0
Component.Free :	; Component in ebx
methodTraceEnter
pusha
	cmp dword [ebx+Component_freeFunc], null
		je Component.defaultFreeFunc
	call [ebx+Component_freeFunc]
popa
methodTraceLeave
ret
Component.defaultFreeFunc :
methodTraceEnter
	; free self image
	mov edx, ebx
	mov ebx, [edx+Component_image]
	call Guppy2.free
	; free self
	mov ebx, edx
	call Guppy2.free
popa
methodTraceLeave
ret

Component.initToDefaults :
methodTraceEnter
	mov dword [ebx+Component_keyHandlerFunc], null
	mov dword [ebx+Component_mouseHandlerFunc], null
	mov dword [ebx+Component_renderFunc], null
	mov dword [ebx+Component_nextLinked], null
	mov dword [ebx+Component_transparent], false
	mov dword [ebx+Component_needsRedraw], true
	mov dword [ebx+Component_freeFunc], null
methodTraceLeave
ret
	
Textline_type	equ 0
Textline_image	equ 4
Textline_x		equ 8
Textline_y		equ 12
Textline_w		equ 16
Textline_h		equ 20
Textline_text	equ Component_CLASS_SIZE

TextLine.Create :	; String str, int x, int y, int w, int h
	methodTraceEnter
	pop dword [TextLine.Create.retval]
	pop dword [TextLine.Create.h]
	pop dword [TextLine.Create.w]
	pop dword [TextLine.Create.y]
	pop dword [TextLine.Create.x]
	pop dword [TextLine.Create.str]
	push eax
	push ebx
		mov ebx, Component_CLASS_SIZE+4
		call ProgramManager.reserveMemory
		call Component.initToDefaults
		mov eax, [TextLine.Create.str]
		mov [ebx+Textline_text], eax
		mov eax, [TextLine.Create.x]
		mov [ebx+Textline_x], eax
		mov eax, [TextLine.Create.y]
		mov [ebx+Textline_y], eax
		mov eax, [TextLine.Create.w]
		mov [ebx+Textline_w], eax
		mov eax, [TextLine.Create.h]
		mov [ebx+Textline_h], eax
		mov eax, Component.TYPE_TEXTLINE
		mov [ebx+Textline_type], eax
		mov dword [ebx+Component_transparent], TRUE
		mov dword [ebx+Component_renderFunc], TextLine.Render
		pusha
			mov edx, ebx
			mov eax, [ebx+Textline_w]
			imul eax, [ebx+Textline_h]
			mov ebx, eax
			call ProgramManager.reserveMemory
			mov [edx+Textline_image], ebx
		popa
		mov ecx, ebx
	pop ebx
	pop eax
	push dword [TextLine.Create.retval]
	methodTraceLeave
	ret
TextLine.Create.retval :
	dd 0x0
TextLine.Create.str :
	dd 0x0
TextLine.Create.x :
	dd 0x0
TextLine.Create.y :
	dd 0x0
TextLine.Create.w :
	dd 0x0
TextLine.Create.h :
	dd 0x0

TextLine.Render :	; textline in ebx
	methodTraceEnter
	pusha
			push ebx
				mov edx, ebx
				mov eax, [edx+Component_image]
				mov ecx, [edx+Component_w]
				imul ecx, [edx+Component_h]
				mov ebx, 0x00000000
				mov edx, ecx
				call Image.clear
			pop ebx
		push ebx
			mov ebx, [ebx+Textline_text]
			call String.getLength
			sub edx, 1
			mov ecx, edx
		pop ebx
				push ecx
				push ebx
					mov eax, [ebx+Textline_w]
					xor edx, edx
					mov ecx, FONTWIDTH*4
					idiv ecx
				pop ebx
				pop ecx
					cmp ecx, eax
						jle TextLine.Render.dontcutshort
					mov ecx, eax
					TextLine.Render.dontcutshort :
		xor edx, edx
		TextLine.Render.loop :
		pusha
		mov eax, [ebx+Textline_text]
		add eax, edx
		mov al, [eax]
		mov ecx, [ebx+Textline_image]
		imul edx, 0x4*FONTWIDTH
		add ecx, edx
		mov edx, [ebx+Textline_w]
		mov ebx, 0xFFFFFFFF
		call RenderText
		popa
		add edx, 1
		sub ecx, 1
		cmp ecx, 0
			jg TextLine.Render.loop
		
	popa
	methodTraceLeave
	ret

TextLine.RenderTest :
methodTraceEnter
pusha
	; create the component
;	mov byte [INTERRUPT_DISABLE], 0xFF

;	push dword TextLine.RenderTest.text
;	push dword TextLine.RenderTest.isClicked
;	push dword 20*4
;	push dword 20
;	push dword 100*4
;	push dword 50
;	call Button.Create
;	mov [TextLine.RenderTest.button], ecx
	
	; create a grouping
;	push dword 0;500*4
;	push dword 0;500
;	push dword 0;1000*4
;	push dword 0;500
;	call Grouping.Create
;	mov ebx, ecx
;	mov eax, [TextLine.RenderTest.button]
;	call Grouping.Add
;		mov al, [console.winNum]
;		and eax, 0xFF
;		add eax, Dolphin.windowStructs
;		mov eax, [eax]
;	mov [eax+Window_linkedComponent], ebx
	; copy the rendered image to the screen
	;mov ebx, [TextLine.RenderTest.textarea]
;	mov eax, [ebx+Component_image]
;	mov ecx, [ebx+Component_w]
;	mov edx, [ebx+Component_h]
;	mov ebx, [Graphics.SCREEN_MEMPOS]
;	call Image.copy
;	mov byte [INTERRUPT_DISABLE], 0x00
popa
methodTraceLeave
ret
TextLine.RenderTest.button :
	dd 0x0
TextLine.RenderTest.isClicked :
methodTraceEnter
pusha
	mov ecx, TextLine.RenderTest.text
	mov dl, [TextLine.RenderTest.flip]
	cmp dl, 0xFF
		jne TextLine.RenderTest.cont
	mov ecx, TextLine.RenderTest.text2
	TextLine.RenderTest.cont :
	mov eax, ecx
	call Button.SetText
	xor dl, 0xFF
	mov [TextLine.RenderTest.flip], dl
popa
methodTraceLeave
ret
TextLine.RenderTest.flip :
	db 0xFF
TextLine.RenderTest.text :
	db "Test Button!", 0
TextLine.RenderTest.text2 :
	db "Hellow.", 0

RenderText :	; char in al, color in ebx, image in ecx, image width in edx
	methodTraceEnter
	cmp al, 0x0D
		je RenderText.ret
	pusha
		mov [RenderText.imwidth], edx
		push ebx
		push ecx
		call TextHandler.getCharBitmap
		mov eax, ebx
		pop ecx
		pop ebx
		mov [RenderText.bitmapPos], eax
		mov edx, FONTHEIGHT
		RenderText.mainloop :
		push ecx
		push eax
		mov al, [eax]	; eax now contains row data
		and eax, 0xFF
		add ecx, FONTWIDTH*4
		RenderText.widthLoop :
		test eax, 0b1	; if the bit is not set, dont draw the pixel
			jz RenderText.noDraw
		mov [ecx], ebx	; otherwise copy the color over
		RenderText.noDraw :
		sub ecx, 4	; advance to the next pixel on screen
		shr eax, 1	; advance to the next bit in the bitmap
		test eax, 0b11111	; if there is anything left to draw in the bitmap
			jnz RenderText.widthLoop	; go ahead and draw it
		pop eax
		pop ecx
		add eax, 1
		add ecx, [RenderText.imwidth]
		sub edx, 1
		cmp edx, 0
			jg RenderText.mainloop	; repeat mainloop FONTHEIGHT times
	popa
	RenderText.ret :
	methodTraceLeave
	ret
RenderText.imwidth :
	dd 0x0
RenderText.bitmapPos :
	dd 0x0
FONTWIDTH equ 5
FONTHEIGHT equ 7
