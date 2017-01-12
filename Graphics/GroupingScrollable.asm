GroupingScrollable_image			equ 4
GroupingScrollable_x				equ 8
GroupingScrollable_y				equ 12
GroupingScrollable_w				equ 16
GroupingScrollable_h				equ 20
GroupingScrollable_renderFlag		equ 32	; compliance with Grouping
GroupingScrollable_subComponent		equ 36
GroupingScrollable_backingColor		equ 40
GroupingScrollable_xoffs			equ 44
GroupingScrollable_yoffs			equ 48

GroupingScrollable.Create :	; int x, int y, int w, int h
	methodTraceEnter
	pop dword [GroupingScrollable.Create.retval]
	pop dword [GroupingScrollable.Create.h]
	pop dword [GroupingScrollable.Create.w]
	pop dword [GroupingScrollable.Create.y]
	pop dword [GroupingScrollable.Create.x]
	push eax
	push ebx
	push edx
		
		mov eax, 0x7
		mov ebx, 52
		call ProgramManager.reserveMemory
		mov edx, ebx
		
		mov eax, [GroupingScrollable.Create.x]
		mov [edx+GroupingScrollable_x], eax
		mov eax, [GroupingScrollable.Create.y]
		mov [edx+GroupingScrollable_y], eax
		mov eax, [GroupingScrollable.Create.w]
		mov [edx+GroupingScrollable_w], eax
		mov eax, [GroupingScrollable.Create.h]
		mov [edx+GroupingScrollable_h], eax
		
		pusha
			mov eax, [ebx+GroupingScrollable_w]
			imul eax, [ebx+GroupingScrollable_h]
			mov ebx, eax
			call ProgramManager.reserveMemory
			mov [edx+GroupingScrollable_image], ebx
		popa
		mov ecx, ebx
	pop edx
	pop ebx
	pop eax
	push dword [GroupingScrollable.Create.retval]
	methodTraceLeave
	ret
GroupingScrollable.Create.retval :
	dd 0x0
GroupingScrollable.Create.h :
	dd 0x0
GroupingScrollable.Create.w :
	dd 0x0
GroupingScrollable.Create.x :
	dd 0x0
GroupingScrollable.Create.y :
	dd 0x0

GroupingScrollable.Add :
	call Grouping.Add
	ret
GroupingScrollable.Remove :
	call Grouping.Remove
	ret
GroupingScrollable.Render :	; GroupingScrollable in ebx, basically Grouping.Render with a few added lines
	methodTraceEnter
		mov edx, ebx
		cmp dword [edx+GroupingScrollable_renderFlag], FALSE
			je GroupingScrollable.Render.ret
			
			test dword [edx+GroupingScrollable_backingColor], 0xFF000000
				jz GroupingScrollable.Render.noLayerColor
			pusha
			mov eax, [edx+Component_image]
			mov ecx, [edx+Component_w]
			imul ecx, [edx+Component_h]
			mov ebx, [edx+GroupingScrollable_backingColor]
			mov edx, ecx
			call Image.clear
			popa
			GroupingScrollable.Render.noLayerColor :
		
		mov ebx, [ebx+Grouping_subcomponent]
		
		GroupingScrollable.Render.loop :
			cmp ebx, 0x0
				je GroupingScrollable.Render.ret
			call Component.Render
			
			; need to deal with x and y when they are <0...
			mov eax, [ebx+Component_y]
			add eax, [edx+GroupingScrollable_yoffs]
			imul eax, [edx+Component_w]
			add eax, [ebx+Component_x]
			add eax, [edx+GroupingScrollable_xoffs]
			add eax, [edx+Component_image]
			mov [Image.copyRegionWithTransparency.nbuf], eax
			
			mov eax, [ebx+Component_image]
			mov [Image.copyRegionWithTransparency.obuf], eax
			
			mov eax, [edx+Component_w]
			sub eax, [ebx+Component_x]
				cmp eax, [ebx+Component_w]
					jle GroupingScrollable.Render.nos0
				mov eax, [ebx+Component_w]
				GroupingScrollable.Render.nos0 :
			mov [Image.copyRegionWithTransparency.w], eax
			
			mov eax, [edx+Component_h]
			sub eax, [ebx+Component_y]
				cmp eax, [ebx+Component_h]
					jle GroupingScrollable.Render.nos1
				mov eax, [ebx+Component_h]
				GroupingScrollable.Render.nos1 :
			mov [Image.copyRegionWithTransparency], eax
			
		; if x is negative one of these will change?
			mov eax, [ebx+Component_w]
			mov [Image.copyRegionWithTransparency.ow], eax
			
			mov eax, [edx+Component_w]
			mov [Image.copyRegionWithTransparency.nw], eax
			
			call Image.copyRegionWithTransparency
			
			mov ebx, [ebx+Component_nextLinked]
			jmp GroupingScrollable.Render.loop
		mov dword [edx+GroupingScrollable_renderFlag], FALSE
	GroupingScrollable.Render.ret :
	popa
	methodTraceLeave
	ret
GroupingScrollable.doScrollLeft :
	ret
GroupingScrollable.doScrollRight :
	ret
GroupingScrollable.doScrollUp :
	ret
GroupingScrollable.doScrollDown :
	ret
GroupingScrollable.passthroughMouseEvent :	; GroupingScrollable in ebx
	methodTraceEnter
	pusha
		GroupingScrollable.passthroughMouseEvent.nomatch :
		mov ebx, [ebx+Component_nextLinked]
		cmp ebx, 0x0
			je GroupingScrollable.passthroughMouseEvent.ret
		mov ecx, [Component.mouseEventX]
		mov edx, [Component.mouseEventY]
		; ... finish this!
	GroupingScrollable.passthroughMouseEvent.ret :
	popa
	methodTraceLeave
	ret

