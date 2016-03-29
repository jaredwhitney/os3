Grouping_type	equ 0
Grouping_image	equ 4
Grouping_x		equ 8
Grouping_y		equ 12
Grouping_w		equ 16
Grouping_h		equ 20
Grouping_renderFlag	equ 32
Grouping_subcomponent	equ 36
Grouping_backingColor	equ 40

Grouping.Create :	; int x, int y, int w, int h
	pop dword [Grouping.Create.retval]
	pop dword [Grouping.Create.h]
	pop dword [Grouping.Create.w]
	pop dword [Grouping.Create.y]
	pop dword [Grouping.Create.x]
	push eax
	push ebx
		mov ebx, 44
		call ProgramManager.reserveMemory
		mov eax, [Grouping.Create.x]
		mov [ebx+Grouping_x], eax
		mov eax, [Grouping.Create.y]
		mov [ebx+Grouping_y], eax
		mov eax, [Grouping.Create.w]
		mov [ebx+Grouping_w], eax
		mov eax, [Grouping.Create.h]
		mov [ebx+Grouping_h], eax
		mov eax, Component.TYPE_GROUPING
		mov [ebx+Grouping_type], eax
		pusha
			mov edx, ebx
			mov eax, [ebx+Grouping_w]
			imul eax, [ebx+Grouping_h]
			mov ebx, eax
			call ProgramManager.reserveMemory
			mov [edx+Grouping_image], ebx
		popa
		call Component.RequestUpdate
		mov ecx, ebx
	pop ebx
	pop eax
	push dword [Grouping.Create.retval]
	ret
Grouping.Create.retval :
	dd 0x0
Grouping.Create.x :
	dd 0x0
Grouping.Create.y :
	dd 0x0
Grouping.Create.w :
	dd 0x0
Grouping.Create.h :
	dd 0x0
Grouping.Add :	; Component in eax, Grouping in ebx
	pusha
		mov ecx, [ebx+Grouping_subcomponent]	; get the head of the list
		mov [eax+Component_nextLinked], ecx	; new component points to the rest of the list
		mov [ebx+Grouping_subcomponent], eax	; Grouping points to the new component
		mov ecx, ebx
		add ecx, Grouping_renderFlag
		mov [eax+Component_upperRenderFlag], ecx
		call Grouping.DoUpdate
	popa
	ret
Grouping.Remove :	; Component in eax, Grouping in ebx
	pusha
		mov ecx, [ebx+Grouping_subcomponent]
		cmp ecx, 0x0
			je Grouping.Remove.ret
		cmp ecx, eax
			je Grouping.Remove.foundSub
		mov ebx, ecx
		Grouping.Remove.loop :
		mov ecx, [ebx+Component_nextLinked]
		cmp ecx, 0x0
			je Grouping.Remove.ret
		cmp ecx, eax
			je Grouping.Remove.foundBefore
		mov ebx, ecx
		jmp Grouping.Remove.loop
		Grouping.Remove.foundBefore :
		; ebx now contains the component before the one to be removed, eax contains the component to be removed
		mov eax, [eax+Component_nextLinked]
		mov [ebx+Component_nextLinked], eax
		call Grouping.DoUpdate
		jmp Grouping.Remove.ret
		Grouping.Remove.foundSub :
		; ebx now contains the Grouping, eax contains the component to be removed
		mov eax, [eax+Component_nextLinked]
		mov [ebx+Grouping_subcomponent], eax
		call Grouping.DoUpdate
	Grouping.Remove.ret :
	popa
	ret
Grouping.MoveToDepth :	; Component in eax, Grouping in ebx, depth in ecx
	pusha
	call Grouping.DoUpdate
	popa
	ret
Grouping.GetDepth :	; Component in eax, Grouping in ebx, returns depth in edx [NEEDS TO BE REWORKED TO WORK WITH subcomponent]
	push eax
	push ebx
	push ecx
		xor edx, edx
		Grouping.GetDepth.loop :
		mov ecx, [ebx+Component_nextLinked]
		cmp ecx, eax
			je Grouping.GetDepth.ret
		mov ebx, ecx
		add edx, 1
		cmp ebx, 0
			jne Grouping.GetDepth.loop
		mov edx, 0xFFFFFFFF	; Component does not exist in the Grouping
	Grouping.GetDepth.ret :
	pop ecx
	pop ebx
	pop eax
	ret
Grouping.DoUpdate :	; Grouping in ebx
pusha
	mov dword [ebx+Grouping_renderFlag], TRUE
popa
ret
Grouping.Render :	; Grouping in ebx
	pusha
	
		mov edx, ebx	; edx always points to Grouping
		
		cmp dword [edx+Grouping_renderFlag], FALSE
			je Grouping.Render.ret
			
			test dword [edx+Grouping_backingColor], 0xFF000000
				jz Grouping.Render.noLayerColor
			pusha
			mov eax, [edx+Component_image]
			mov ecx, [edx+Component_w]
			imul ecx, [edx+Component_h]
			mov ebx, [edx+Grouping_backingColor]
			mov edx, ecx
			call Image.clear
			popa
			Grouping.Render.noLayerColor :
		
		mov ebx, [ebx+Grouping_subcomponent]
		xor eax, eax
		
		Grouping.Render.loop :
			
			cmp ebx, 0x0
				je Grouping.Render.doRender
			
			push ebx
			add eax, 1
			
			mov ebx, [ebx+Component_nextLinked]
			jmp Grouping.Render.loop
			
			Grouping.Render.doRender :
			cmp eax, 0x0
				jle Grouping.Render.ret
			pop ebx
			call Grouping.RenderSub
			sub eax, 1
			jmp Grouping.Render.doRender
			
		mov dword [edx+Grouping_renderFlag], FALSE
	Grouping.Render.ret :
	popa
	ret
Grouping.RenderSub :
	pusha
		call Component.Render
			
		mov eax, [ebx+Component_y]
		imul eax, [edx+Component_w]
		add eax, [ebx+Component_x]
		add eax, [edx+Component_image]
		mov [Image.copyRegionWithTransparency.nbuf], eax
		
		mov eax, [ebx+Component_image]
		mov [Image.copyRegionWithTransparency.obuf], eax
		
		; min([ebx+Component_w], [edx+Component_w]-[ebx+Component_x]) -> [Image.copyRegionWithTransparency.w]
		mov eax, [edx+Component_w]
		sub eax, [ebx+Component_x]
			cmp eax, [ebx+Component_w]
				jle Grouping.Render.nos0
			mov eax, [ebx+Component_w]
			Grouping.Render.nos0 :
		mov [Image.copyRegionWithTransparency.w], eax
		
		; min([ebx+Component_h], [edx+Component_h]-[ebx+Component_y]) -> [Image.copyRegionWithTransparency.h]
		mov eax, [edx+Component_h]
		sub eax, [ebx+Component_y]
			cmp eax, [ebx+Component_h]
				jle Grouping.Render.nos1
			mov eax, [ebx+Component_h]
			Grouping.Render.nos1 :
		mov [Image.copyRegionWithTransparency.h], eax
		
		mov eax, [ebx+Component_w]
		mov [Image.copyRegionWithTransparency.ow], eax
		mov eax, [edx+Component_w]
		mov [Image.copyRegionWithTransparency.nw], eax
		
		call Image.copyRegionWithTransparency
	popa
	ret
Grouping.updateFitToHostWindow :	; Window in eax, Grouping in ebx
	pusha
		mov ecx, [eax+Window_windowbuffer]
		mov [ebx+Grouping_image], ecx
		xor ecx, ecx
		mov cx, [eax+Window_width]
		mov [ebx+Grouping_w], ecx
		mov cx, [eax+Window_height]
		mov [ebx+Grouping_h], ecx
		mov cx, [eax+Window_xpos]
		mov [ebx+Grouping_x], ecx
		mov cx, [eax+Window_ypos]
		mov [ebx+Grouping_y], ecx
	popa
	ret
Grouping.passthroughMouseEvent :	; Grouping in ebx
	pusha
	
		;mov dword [ebx+Grouping_backingColor], 0xFF00FF00
		; Check to see if any subcomponent exists where x<=mousex<=x+width && y<=mousey<=y+width, if one is found call Component.HandleMouseEvent on it
		mov ebx, [ebx+Grouping_subcomponent]
		jmp Grouping.passthroughMouseEvent.beginLoop
		Grouping.passthroughMouseEvent.nomatch :
		mov ebx, [ebx+Component_nextLinked]
		Grouping.passthroughMouseEvent.beginLoop :
		cmp ebx, 0x0
			je Grouping.passthroughMouseEvent.ret
		mov ecx, [Component.mouseEventX]
		mov edx, [Component.mouseEventY]
		
		cmp ecx, [ebx+Component_x]
			jl Grouping.passthroughMouseEvent.nomatch
		mov eax, [ebx+Component_x]
		add eax, [ebx+Component_w]
		cmp ecx, eax
			jg Grouping.passthroughMouseEvent.nomatch
		cmp edx, [ebx+Component_y]
			jl Grouping.passthroughMouseEvent.nomatch
		mov eax, [ebx+Component_y]
		add eax, [ebx+Component_h]
		cmp edx, eax
			jg Grouping.passthroughMouseEvent.nomatch
	;	push ebx
	;		mov ah, 0xFF
	;		mov ebx, GROUPING_SUB_CLICKED_STR
	;		call console.println
	;	pop ebx
		call Component.HandleMouseEvent
	Grouping.passthroughMouseEvent.ret :
	popa
	ret
GROUPING_CLICKED_STR :
	db "A grouping was clicked!", 0
GROUPING_SUB_CLICKED_STR :
	db "A subcomponent of a grouping was clicked!", 0
	