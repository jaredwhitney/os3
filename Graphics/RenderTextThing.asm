Component_type	equ 0
Component_image	equ 4
Component_x		equ 8
Component_y		equ 12
Component_w		equ 16
Component_h		equ 20
Component_nextLinked	equ 24

Component.Render :	; Component in ebx
	pusha
			cmp byte [Component.DEBUG_ALL], 0xFF
				jne Component.Render.noLayerColor
			push ebx
			mov eax, [ebx+Component_image]
			mov edx, [ebx+Component_w]
			imul edx, [ebx+Component_h]
			mov ebx, [Component.Render.layerColor]
			call Image.clear
			xor dword [Component.Render.layerColor], 0x404000
			pop ebx
			Component.Render.noLayerColor :
		mov eax, [ebx]
		imul eax, 4
		add eax, Component.functionPointers
		call [eax]
	popa
	ret
Component.killfunc :
	mov eax, SysHaltScreen.KILL
	mov ebx, Component.INVALID_COMPONENT_MESSAGE
	mov ecx, 5
	call SysHaltScreen.show
	jmp $
Component.INVALID_COMPONENT_MESSAGE :
	db "[Dolphin] An attempt was made to render an invalid Component.", 0
Component.DEBUG_ALL :
	dd TRUE
Component.Render.layerColor :
	dd 0x400000

Component.functionPointers :
	dd Component.killfunc, TextLine.Render, TextArea.Render, Image.Render, ImageScalable.Render, Grouping.Render
Component.TYPE_TEXTLINE				equ 0x1
Component.TYPE_TEXTAREA				equ 0x2
Component.TYPE_IMAGE				equ 0x3
Component.TYPE_IMAGE_SCALABLE		equ 0x4
Component.TYPE_GROUPING				equ 0x5

Textline_type	equ 0
Textline_image	equ 4
Textline_x		equ 8
Textline_y		equ 12
Textline_w		equ 16
Textline_h		equ 20
Textline_text	equ 28

TextLine.Create :	; String str, int x, int y, int w, int h
	pop dword [TextLine.Create.retval]
	pop dword [TextLine.Create.h]
	pop dword [TextLine.Create.w]
	pop dword [TextLine.Create.y]
	pop dword [TextLine.Create.x]
	pop dword [TextLine.Create.str]
	push eax
	push ebx
		mov ebx, 32
		call ProgramManager.reserveMemory
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
	pusha
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
		mov ebx, 0xFFFFFF
		call RenderText
		popa
		add edx, 1
		sub ecx, 1
		cmp ecx, 0
			jg TextLine.Render.loop
		
	popa
	ret

TextLine.RenderTest :
pusha
	; create the component
	mov byte [INTERRUPT_DISABLE], 0xFF
	push dword 150
	push dword 20*4
	push dword 80
	push dword 700
	push dword 200
	push dword TRUE
	call TextArea.Create
	mov [TextLine.RenderTest.textarea], ecx
	; fill it with the sample text
	mov eax, TextLine.RenderTest.text
	mov ebx, [TextLine.RenderTest.textarea]
	call TextArea.SetText
	call TextArea.AppendText
	; create a grouping
	push dword 0;500*4
	push dword 0;500
	push dword 0;1000*4
	push dword 0;500
	call Grouping.Create
	mov ebx, ecx
	mov eax, [TextLine.RenderTest.textarea]
	call Grouping.Add
		mov al, [console.winNum]
		and eax, 0xFF
		add eax, Dolphin.windowStructs
		mov eax, [eax]
	mov [eax+Window_linkedComponent], ebx
	; copy the rendered image to the screen
	;mov ebx, [TextLine.RenderTest.textarea]
;	mov eax, [ebx+Component_image]
;	mov ecx, [ebx+Component_w]
;	mov edx, [ebx+Component_h]
;	mov ebx, [Graphics.SCREEN_MEMPOS]
;	call Image.copy
	mov byte [INTERRUPT_DISABLE], 0x00
popa
ret
TextLine.RenderTest.text :
	db "This is a test of some text that should be written to a text area with automatic line breaks and stuff.", 0
TextLine.RenderTest.textarea :
	dd 0x0

RenderText :	; char in al, color in ebx, image in ecx, image width in edx
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
	ret
RenderText.imwidth :
	dd 0x0
RenderText.bitmapPos :
	dd 0x0
FONTWIDTH equ 5
FONTHEIGHT equ 7
