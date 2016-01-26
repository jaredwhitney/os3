Component_type	equ 0
Component_image	equ 4
Component_x		equ 8
Component_y		equ 12
Component_w		equ 16
Component_h		equ 20
Component_RESV	equ 24

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
		xor edx, edx
		TextLine.Render.loop :
		pusha
		mov eax, [ebx+Textline_text]
		add eax, edx
		mov al, [eax]
		mov ecx, [Graphics.SCREEN_MEMPOS]
		imul edx, 0x4*FONTWIDTH
		add ecx, edx
		add ecx, [ebx+Textline_x]
		mov edx, [ebx+Textline_y]
		imul edx, [Graphics.SCREEN_WIDTH]
		add ecx, edx
		mov edx, [Graphics.SCREEN_WIDTH]
		mov ebx, 0xFFFFFF
		call RenderText	; instead of using TextHandler need to write own method to do this!
		popa
		add edx, 1
		sub ecx, 1
		cmp ecx, 0
			jg TextLine.Render.loop
		
	popa
	ret

TextLine.RenderTest :
pusha
	mov byte [INTERRUPT_DISABLE], 0xFF
	push dword TextLine.RenderTest.text
	push dword 20*4
	push dword 80
	push dword 50
	push dword 10
	call TextLine.Create
	mov ebx, ecx
	call TextLine.Render
;	mov al, 'H'
;	mov ebx, 0xFFFFFF
;	mov ecx, [Graphics.SCREEN_MEMPOS]
;	add ecx, 0x88
;	mov edx, [Graphics.SCREEN_WIDTH]
;	call RenderText
;	mov al, 'e'
;	add ecx, FONTWIDTH*4
;	call RenderText
;	mov al, 'l'
;	add ecx, FONTWIDTH*4
;	call RenderText
;	mov al, 'l'
;	add ecx, FONTWIDTH*4
;	call RenderText
;	mov al, 'o'
;	add ecx, FONTWIDTH*4
;	call RenderText
	jmp $
popa
ret
TextLine.RenderTest.text :
	db "This is a test.", 0

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
		mov eax, [eax]	; eax now contains row data
		RenderText.widthLoop :
		test eax, 0b1<<FONTWIDTH	; if the bit is not set, dont draw the pixel
			jz RenderText.noDraw
		mov [ecx], ebx	; otherwise copy the color over
		RenderText.noDraw :
		add ecx, 4	; advance to the next pixel on screen
		shl eax, 1	; advance to the next bit in the bitmap
		test eax, 0b11111000	; if there is anything left to draw in the bitmap
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
