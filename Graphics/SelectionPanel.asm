SelectionPanel_renderFlag			equ Component_CLASS_SIZE
SelectionPanel_subcomponent			equ Component_CLASS_SIZE+4
SelectionPanel_backingColor			equ Component_CLASS_SIZE+8
SelectionPanel_selectColor			equ Component_CLASS_SIZE+12
SelectionPanel_selectedComponent	equ Component_CLASS_SIZE+16

SelectionPanel.Create :	; int x, int y, int w, int h
	methodTraceEnter
	pop dword [SelectionPanel.Create.retval]
	pop dword [SelectionPanel.Create.h]
	pop dword [SelectionPanel.Create.w]
	pop dword [SelectionPanel.Create.y]
	pop dword [SelectionPanel.Create.x]
	push eax
	push ebx
	push edx
		
		mov eax, 0x7
		mov ebx, Component_CLASS_SIZE+20
		call ProgramManager.reserveMemory
		call Component.initToDefaults
		mov edx, ebx
		
		mov eax, [SelectionPanel.Create.x]
		mov [edx+Component_x], eax
		mov eax, [SelectionPanel.Create.y]
		mov [edx+Component_y], eax
		mov eax, [SelectionPanel.Create.w]
		mov [edx+Component_w], eax
		mov eax, [SelectionPanel.Create.h]
		mov [edx+Component_h], eax
		mov dword [edx+Component_type], Component.TYPE_SELECTPANEL
		mov dword [edx+Component_renderFunc], SelectionPanel.Render
		mov dword [edx+Component_mouseHandlerFunc], SelectionPanel.HandleMouseEvent
		mov dword [edx+Component_freeFunc], SelectionPanel.Free
		pusha
			mov eax, [ebx+Component_w]
			imul eax, [ebx+Component_h]
			mov ebx, eax
			call ProgramManager.reserveMemory
			mov [edx+Component_image], ebx
		popa
		call Component.RequestUpdate
		mov ecx, ebx
		
	pop edx
	pop ebx
	pop eax
	push dword [SelectionPanel.Create.retval]
	methodTraceLeave
	ret
SelectionPanel.Create.x :
	dd 0x0
SelectionPanel.Create.y :
	dd 0x0
SelectionPanel.Create.w :
	dd 0x0
SelectionPanel.Create.h :
	dd 0x0
SelectionPanel.Create.retval :
	dd 0x0

SelectionPanel.Free :
	ret

SelectionPanel.Add :
	methodTraceEnter
	call Grouping.Add
	methodTraceLeave
	ret

SelectionPanel.Remove :
	methodTraceEnter
	call Grouping.Remove
	methodTraceLeave
	ret
	
SelectionPanel.Render :
	methodTraceEnter
	pusha
		
		mov edx, ebx
		
		;cmp dword [edx+SelectionPanel_renderFlag], FALSE
		;	je SelectionPanel.Render.ret
		
		test dword [edx+SelectionPanel_backingColor], 0xFF000000
			jz SelectionPanel.Render.noLayerColor
		pusha
		mov eax, [edx+Component_image]
		mov ecx, [edx+Component_w]
		imul ecx, [edx+Component_h]
		mov ebx, [edx+SelectionPanel_backingColor]
		mov edx, ecx
		call Image.clear
		popa
		SelectionPanel.Render.noLayerColor :
		
		mov ebx, [ebx+SelectionPanel_subcomponent]
		xor eax, eax
		
		SelectionPanel.Render.loop :
		
			cmp ebx, 0x0
				je SelectionPanel.Render.doRender
			
			push ebx
			add eax, 1
			
			mov ebx, [ebx+Component_nextLinked]
			jmp SelectionPanel.Render.loop
			
			SelectionPanel.Render.doRender :
			cmp eax, 0x0
				jle SelectionPanel.Render.ret
			pop ebx
			call SelectionPanel.RenderSub
			sub eax, 1
			jmp SelectionPanel.Render.doRender
			
		mov dword [edx+SelectionPanel_renderFlag], FALSE
	SelectionPanel.Render.ret :
	popa
	methodTraceLeave
	ret
SelectionPanel.RenderSub :
	methodTraceEnter
	pusha
		call Component.Render
			
		mov eax, [ebx+Component_y]
		imul eax, [edx+Component_w]
		add eax, [ebx+Component_x]
		add eax, [edx+Component_image]
		mov [Image.copyRegionWithTransparency.nbuf], eax
		
		mov eax, [ebx+Component_image]
		mov [Image.copyRegionWithTransparency.obuf], eax
		
		mov eax, [edx+Component_w]
		sub eax, [ebx+Component_x]
			cmp eax, [ebx+Component_w]
				jle SelectionPanel.Render.nos0
			mov eax, [ebx+Component_w]
			SelectionPanel.Render.nos0 :
		mov [Image.copyRegionWithTransparency.w], eax
		
		mov eax, [edx+Component_h]
		sub eax, [ebx+Component_y]
			cmp eax, [ebx+Component_h]
				jle SelectionPanel.Render.nos1
			mov eax, [ebx+Component_h]
			SelectionPanel.Render.nos1 :
		mov [Image.copyRegionWithTransparency.h], eax
		
		mov eax, [ebx+Component_w]
		mov [Image.copyRegionWithTransparency.ow], eax
		mov eax, [edx+Component_w]
		mov [Image.copyRegionWithTransparency.nw], eax
		
		call Image.copyRegionWithTransparency
		
		;; Outline the currently selected Component
		cmp ebx, [edx+SelectionPanel_selectedComponent]
			jne SelectionPanel.Render.nos2
		pusha
		push ebx
		mov ebx, edx
		call L3gxImage.FakeFromComponent
		pop ebx
		push ecx	; Image
		mov ecx, [ebx+Component_x]
		shr ecx, 2	; div by 4
		add ecx, 1
		push ecx	; x
		mov ecx, [ebx+Component_y]
		add ecx, 1
		push dword ecx	; y
		mov ecx, [ebx+Component_w]
		shr ecx, 2	; div by 4
		sub ecx, 2
		push ecx	; w
		mov ecx, [ebx+Component_h]
		sub ecx, 2
		push dword ecx	; h
		push dword 0xFF00FF00	; Color (GREEN)
		call L3gx.lineRect
		popa
		SelectionPanel.Render.nos2 :
		;;
	popa
	methodTraceLeave
	ret
	
SelectionPanel.HandleMouseEvent :	; SelectionPanel in ebx
	methodTraceEnter
	pusha
		; Check to see if any subcomponent exists where x<=mousex<=x+width && y<=mousey<=y+width, if one is found set it as the selected Component
		push ebx
		mov ebx, [ebx+Grouping_subcomponent]
		jmp SelectionPanel.HandleMouseEvent.beginLoop
		SelectionPanel.HandleMouseEvent.nomatch :
		mov ebx, [ebx+Component_nextLinked]
		SelectionPanel.HandleMouseEvent.beginLoop :
		cmp ebx, 0x0
			je SelectionPanel.HandleMouseEvent.ret
		mov ecx, [Component.mouseEventX]
		mov edx, [Component.mouseEventY]
		cmp ecx, [ebx+Component_x]
			jl SelectionPanel.HandleMouseEvent.nomatch
		mov eax, [ebx+Component_x]
		add eax, [ebx+Component_w]
		cmp ecx, eax
			jg SelectionPanel.HandleMouseEvent.nomatch
		cmp edx, [ebx+Component_y]
			jl SelectionPanel.HandleMouseEvent.nomatch
		mov eax, [ebx+Component_y]
		add eax, [ebx+Component_h]
		cmp edx, eax
			jg SelectionPanel.HandleMouseEvent.nomatch
		pop ecx
		cmp dword [Component.mouseEventType], MOUSE_NOBTN
			je .dontfocus
		mov [ecx+SelectionPanel_selectedComponent], ebx
		mov [Dolphin2.focusedComponent], ebx
		.dontfocus :
		mov ebx, ecx
		call Component.RequestUpdate
		popa
		methodTraceLeave
		ret
	SelectionPanel.HandleMouseEvent.ret :
	pop ecx
	popa
	methodTraceLeave
	ret
