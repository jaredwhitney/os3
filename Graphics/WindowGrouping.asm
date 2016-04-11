WindowGrouping_x			equ 8
WindowGrouping_y			equ 12
WindowGrouping_w			equ 16
WindowGrouping_h			equ 20
WindowGrouping_mainGrouping	equ 48
WindowGrouping_titleBar		equ 52
WindowGrouping_nameString	equ 56
WindowGrouping_sizeButton	equ 60
WindowGrouping_closeButton	equ 64

WindowGrouping.Create :	; String title, int x, int y, int w, int h
	pop dword [WindowGrouping.Create.retval]
	pop dword [WindowGrouping.Create.h]
	pop dword [WindowGrouping.Create.w]
	pop dword [WindowGrouping.Create.y]
	pop dword [WindowGrouping.Create.x]
	pop dword [WindowGrouping.Create.title]
	push eax
	push ebx
	push edx

		mov eax, 0x7
		mov ebx, 68
		call ProgramManager.reserveMemory
		mov edx, ebx
			
			pusha
			mov eax, edx
			mov edx, 64
			mov ebx, 0x00000000
			call Image.clear
			popa
			
			; THIS SHOULD ALL BE IN THE WindowGrouping main NOT ITS OWN GROUPING
			mov eax, [WindowGrouping.Create.x]
			mov [edx+Grouping_x], eax
			mov eax, [WindowGrouping.Create.y]
			mov [edx+Grouping_y], eax
			mov eax, [WindowGrouping.Create.w]	; should allocate a screen-sized buffer
			add eax, 8*4
			mov [edx+Grouping_w], eax
			mov eax, [WindowGrouping.Create.h]
			add eax, 20+4+4
			mov [edx+Grouping_h], eax
			mov eax, [Graphics.SCREEN_WIDTH]
			imul eax, [Graphics.SCREEN_HEIGHT]
			sub eax, 1
				push edx
				xor edx, edx
				mov ecx, 0x1000
				idiv ecx
				pop edx
			mov ebx, eax
			add ebx, 1
			mov al, 0x7
			call Guppy.malloc
			mov [edx+Grouping_image], ebx
		
		push dword 4*4
		push dword 2
		push dword [Graphics.SCREEN_WIDTH]	; buffer should be SCREEN_WIDTH wide
		push dword 20
		call Grouping.Create
		mov [edx+WindowGrouping_titleBar], ecx
		mov dword [ecx+Grouping_backingColor], 0xFF201080
		mov ebx, edx
		mov eax, ecx
		call Grouping.Add
		mov eax, [WindowGrouping.Create.w]
		mov [ecx+Grouping_w], eax
		
		push dword WindowGrouping.upArrowStr
		push dword console.checkColor_ret	; really? please don't use this in the future!
		mov eax, [WindowGrouping.Create.w]
		sub eax, 22*4
		push eax
		push dword 5
		push dword 10*4
		push dword 10
		call Button.Create
		mov eax, ecx
		mov ebx, [edx+WindowGrouping_titleBar]
		call Grouping.Add
		mov dword [ecx+Button_backingColor], 0xFF180878
		
		push dword WindowGrouping.closeStr
		push dword WindowGrouping.closeCallback
		mov eax, [WindowGrouping.Create.w]
		sub eax, 10*4
		push eax
		push dword 5
		push dword 10*4
		push dword 10
		call Button.Create
		mov eax, ecx
		mov ebx, [edx+WindowGrouping_titleBar]
		call Grouping.Add
		mov dword [ecx+Button_backingColor], 0xFFE00000
		
		push dword [WindowGrouping.Create.title]
		push dword 0
		push dword 20/2-FONTHEIGHT/2
		mov eax, [WindowGrouping.Create.w]
		sub eax, 22*4+2*4	; dont let it overlap the buttons
		push eax
		push dword 20
		call TextLine.Create
		mov eax, ecx
		mov ebx, [edx+WindowGrouping_titleBar]
		call Grouping.Add
		
		push dword 4*4
		push dword 20+2+2
		push dword [Graphics.SCREEN_WIDTH]	; should allocate a screen-sized buffer!
		push dword [Graphics.SCREEN_HEIGHT]
		call Grouping.Create
		mov eax, ecx
		mov ebx, edx
		call Grouping.Add
		mov eax, [WindowGrouping.Create.w]
		mov [ecx+Grouping_w], eax
		mov eax, [WindowGrouping.Create.h]
		mov [ecx+Grouping_h], eax
		mov [edx+WindowGrouping_mainGrouping], ecx
		mov dword [ecx+Grouping_backingColor], 0xFFB02020
		
		mov dword [edx+Component_type], Component.TYPE_WINDOW
		mov dword [edx+Grouping_backingColor], 0xFFFFFFFF
		
		mov ecx, edx
		
	pop edx
	pop ebx
	pop eax
	push dword [WindowGrouping.Create.retval]
	ret
	
WindowGrouping.closeCallback :	; Button in ebx
	pusha
		mov eax, ebx
		WindowGrouping.closeCallback.findWindowLoop :
		mov eax, [ebx+Component_upperRenderFlag]
		sub eax, Grouping_renderFlag
		cmp dword [eax+Component_type], Component.TYPE_WINDOW
			je WindowGrouping.closeCallback.foundWindow
		mov ebx, eax
		jmp WindowGrouping.closeCallback.findWindowLoop
		WindowGrouping.closeCallback.foundWindow :
		mov ebx, [Dolphin2.compositorGrouping]
		call Grouping.Remove
	popa
	ret

WindowGrouping.passthroughMouseEvent :
	cmp dword [Component.mouseEventType], MOUSE_NOBTN
		je .goon
	pusha
		mov eax, ebx
		mov ebx, [Dolphin2.compositorGrouping]
		call Grouping.BringToFront
	popa
	.goon :
	call Grouping.passthroughMouseEvent
	ret
	
WindowGrouping.moveWindow :	; x pos in eax, y pos in ebx
	pusha
		mov edx, eax
		mov ecx, ebx
		mov ebx, [Dolphin2.focusedComponent]
		WindowGrouping.moveWindow.findWindowLoop :
		mov eax, [ebx+Component_upperRenderFlag]
		cmp eax, 0x0
			jne WindowGrouping.moveWindow.cont
		mov eax, [WindowGrouping.lastWin]
		cmp eax, 0x0
			je WindowGrouping.moveWindow.ret
		jmp WindowGrouping.moveWindow.foundWindow
		WindowGrouping.moveWindow.cont :
		sub eax, Grouping_renderFlag
		cmp dword [eax+Component_type], Component.TYPE_WINDOW
			je WindowGrouping.moveWindow.foundWindow
		mov ebx, eax
		jmp WindowGrouping.moveWindow.findWindowLoop
		WindowGrouping.moveWindow.foundWindow :
		mov [WindowGrouping.lastWin], eax
		mov [eax+Component_x], edx
		mov [eax+Component_y], ecx
	WindowGrouping.moveWindow.ret :
	popa
	ret
WindowGrouping.lastWin :
	dd 0x0
WindowGrouping.Create.retval :
	dd 0x0
WindowGrouping.Create.h :
	dd 0x0
WindowGrouping.Create.w :
	dd 0x0
WindowGrouping.Create.x :
	dd 0x0
WindowGrouping.Create.y :
	dd 0x0
WindowGrouping.Create.title :
	dd 0x0
	
WindowGrouping.upArrowStr :
	db "M", 0
WindowGrouping.closeStr :
	db "X", 0

