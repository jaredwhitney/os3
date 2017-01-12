Button_type			equ 0
Button_image		equ 4
Button_x			equ 8
Button_y			equ 12
Button_w			equ 16
Button_h			equ 20
Button_text			equ Component_CLASS_SIZE
Button_onClick		equ Component_CLASS_SIZE+4
Button_backingColor	equ Component_CLASS_SIZE+8

Button.Create :	; String str, Func onclick, int x, int y, int w, int h
	methodTraceEnter
	pop dword [Button.Create.retval]
	pop dword [Button.Create.h]
	pop dword [Button.Create.w]
	pop dword [Button.Create.y]
	pop dword [Button.Create.x]
	pop dword [Button.Create.onClick]
	pop dword [Button.Create.text]
	push eax
	push ebx
		mov ebx, Component_CLASS_SIZE+12
		call ProgramManager.reserveMemory
		call Component.initToDefaults
		mov eax, [Button.Create.text]
		mov [ebx+Button_text], eax
		mov eax, [Button.Create.onClick]
		mov [ebx+Button_onClick], eax
		mov eax, [Button.Create.x]
		mov [ebx+Button_x], eax
		mov eax, [Button.Create.y]
		mov [ebx+Button_y], eax
		mov eax, [Button.Create.w]
		mov [ebx+Button_w], eax
		mov eax, [Button.Create.h]
		mov [ebx+Button_h], eax
		mov eax, Component.TYPE_BUTTON
		mov [ebx+Button_type], eax
		mov dword [ebx+Component_transparent], TRUE
		mov dword [ebx+Component_renderFunc], Button.Render
		mov dword [ebx+Component_mouseHandlerFunc], Button.onMouseEvent
		pusha
			mov edx, ebx
			mov eax, [ebx+Button_w]
			imul eax, [ebx+Button_h]
			mov ebx, eax
			call ProgramManager.reserveMemory
			mov [edx+Button_image], ebx
		popa
		mov ecx, ebx
	pop ebx
	pop eax
	push dword [Button.Create.retval]
	methodTraceLeave
	ret
Button.Create.retval :
	dd 0x0
Button.Create.x :
	dd 0x0
Button.Create.y :
	dd 0x0
Button.Create.w :
	dd 0x0
Button.Create.h :
	dd 0x0
Button.Create.onClick :
	dd 0x0
Button.Create.text :
	dd 0x0
	
Button.SetText : 	; Text in eax, Button in ebx
	methodTraceEnter
	pusha
		mov [ebx+Button_text], eax
		call Component.RequestUpdate
	popa
	methodTraceLeave
	ret
	
Button.Render :	; Button in ebx
	methodTraceEnter
	pusha
	
			mov edx, ebx
			test dword [edx+Button_backingColor], 0xFF000000
				jz Button.Render.noLayerColor
			pusha
			mov eax, [edx+Component_image]
			mov ecx, [edx+Component_w]
			imul ecx, [edx+Component_h]
			mov ebx, [edx+Button_backingColor]
			mov edx, ecx
			call Image.clear
			popa
			Button.Render.noLayerColor :
	
		push ebx
			mov ebx, [ebx+Button_text]
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
					jle Button.Render.dontcutshort
				mov ecx, eax
				Button.Render.dontcutshort :
							pusha
								push ebx
									mov eax, ecx
									imul eax, FONTWIDTH
									shr eax, 1
									mov ebx, [Graphics.bytesPerPixel]
									imul eax, ebx
								pop ebx
								mov ecx, [ebx+Button_w]
								shr ecx, 1
								sub ecx, eax
								add ecx, [ebx+Button_image]
								mov eax, [ebx+Button_h]
								shr eax, 1
								sub eax, FONTHEIGHT/2
								imul eax, [ebx+Button_w]
								add ecx, eax
								mov [Button.Render.startpos], ecx
							popa
		xor edx, edx
		Button.Render.loop :
		pusha
		mov eax, [ebx+Button_text]
		add eax, edx
		mov al, [eax]
		mov ecx, [Button.Render.startpos]
		imul edx, 0x4*FONTWIDTH
		add ecx, edx
		mov edx, [ebx+Button_w]
		mov ebx, 0xFFFFFFFF
		call RenderText
		popa
		add edx, 1
		sub ecx, 1
		cmp ecx, 0
			jg Button.Render.loop
	popa
	methodTraceLeave
	ret
Button.Render.startpos :
	dd 0x0
Button.onMouseEvent :
	methodTraceEnter
	cmp dword [Component.mouseEventType], MOUSE_NOBTN
		je .ret
	pusha
		mov eax, [ebx+Button_onClick]
		call eax
	popa
	.ret :
	methodTraceLeave
	ret
