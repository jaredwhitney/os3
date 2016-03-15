SelectionPanel_renderFlag			equ 32
SelectionPanel_subcomponent			equ 36
SelectionPanel_backingColor			equ 40
SelectionPanel_selectColor			equ 44
SelectionPanel_selectedComponent	equ 48

SelectionPanel.Create :	; int x, int y, int w, int h
	pop dword [SelectionPanel.Create.retval]
	pop dword [SelectionPanel.Create.h]
	pop dword [SelectionPanel.Create.w]
	pop dword [SelectionPanel.Create.y]
	pop dword [SelectionPanel.Create.x]
	push eax
	push ebx
	push edx
		
		mov eax, 0x7
		mov ebx, 52
		call ProgramManager.reserveMemory
		mov edx, ebx
		
		mov eax, [SelectionPanel.Create.x]
		mov [edx+Component_x], eax
		mov eax, [SelectionPanel.Create.y]
		mov [edx+Component_y], eax
		mov eax, [SelectionPanel.Create.w]
		mov [edx+Component_w], eax
		mov eax, [SelectionPanel.Create.h]
		mov [edx+Component_h], eax
		
		pusha
			mov eax, [ebx+Component_w]
			imul eax, [ebx+Component_h]
			mov ebx, eax
			call ProgramManager.reserveMemory
			mov [edx+GroupingScrollable_image], ebx
		popa
		mov ecx, ebx
		
	pop edx
	pop ebx
	pop eax
	push dword [SelectionPanel.Create.retval]
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

SelectionPanel.Add :
	call Grouping.Add
	ret

SelectionPanel.Remove :
	call Grouping.Remove
	ret
	
SelectionPanel.Render :
	pusha
		
		mov edx, ebx
		
		cmp dword [edx+SelectionPanel_renderFlag], FALSE
			je SelectionPanel.Render.ret
		
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
		
		SelectionPanel.Render.loop :
		
			cmp ebx, 0x0
				je SelectionPanel.Render.ret
			
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
			push dword [ebx+Component_x]	; x
			push dword [ebx+Component_y]	; y
			mov ecx, [ebx+Component_w]
			shr ecx, 2	; div by 4
			push ecx	; w
			push dword [ebx+Component_h]	; h
			push dword 0xFF00FF00	; Color (GREEN)
			call L3gx.lineRect
			popa
			SelectionPanel.Render.nos2 :
			;;
			
			mov ebx, [ebx+Component_nextLinked]
			jmp SelectionPanel.Render.loop
		mov dword [edx+SelectionPanel_renderFlag], FALSE
	SelectionPanel.Render.ret :
	popa
	ret
	
SelectionPanel.HandleMouseEvent :
	pusha
	
	popa
	ret
