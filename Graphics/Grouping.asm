Grouping_type	equ 0
Grouping_image	equ 4
Grouping_x		equ 8
Grouping_y		equ 12
Grouping_w		equ 16
Grouping_h		equ 20

Grouping.Create :	; int x, int y, int w, int h
	pop dword [Grouping.Create.retval]
	pop dword [Grouping.Create.h]
	pop dword [Grouping.Create.w]
	pop dword [Grouping.Create.y]
	pop dword [Grouping.Create.x]
	push eax
	push ebx
		mov ebx, 28
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
		mov ecx, [ebx+Component_nextLinked]	; get the head of the list
		mov [eax+Component_nextLinked], ecx	; new component points to the rest of the list
		mov [ebx+Component_nextLinked], eax	; Grouping points to the new component
	popa
	ret
Grouping.Remove :	; Component in eax, Grouping in ebx
	pusha
		Grouping.Remove.loop :
		mov ecx, [ebx+Component_nextLinked]
		cmp ecx, eax
			je Grouping.Remove.foundBefore
		mov ebx, ecx
		jmp Grouping.Remove.loop
		Grouping.Remove.foundBefore :
		; ecx now contains the component before the one to be removed, eax contains the component to be removed
	popa
	ret
Grouping.MoveToDepth :	; Component in eax, Grouping in ebx, depth in ecx
	pusha
	popa
	ret
Grouping.GetDepth :	; Component in eax, Grouping in ebx, returns depth in edx
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
Grouping.Render :	; Grouping in ebx
	pusha
		; use a bunch of Image.copyRegion calls to copy over all of the Component_image's
		mov edx, ebx	; edx always points to Grouping
		
		Grouping.Render.loop :
		
			mov ebx, [ebx+Component_nextLinked]
			cmp ebx, 0x0
				je Grouping.Render.ret
			
			call Component.Render
			
			mov eax, [ebx+Component_y]
			imul eax, [edx+Component_w]
			add eax, [ebx+Component_x]
			add eax, [edx+Component_image]
			mov [Image.copyRegion.nbuf], eax
			
			mov eax, [ebx+Component_image]
			mov [Image.copyRegion.obuf], eax
			
			; min([ebx+Component_w], [edx+Component_w]-[ebx+Component_x]) -> [Image.copyRegion.w]
			mov eax, [edx+Component_w]
			sub eax, [ebx+Component_x]
				cmp eax, [ebx+Component_w]
					jle Grouping.Render.nos0
				mov eax, [ebx+Component_w]
				Grouping.Render.nos0 :
			mov [Image.copyRegion.w], eax
			
			; min([ebx+Component_h], [edx+Component_h]-[ebx+Component_y]) -> [Image.copyRegion.h]
			mov eax, [edx+Component_h]
			sub eax, [ebx+Component_y]
				cmp eax, [ebx+Component_h]
					jle Grouping.Render.nos1
				mov eax, [ebx+Component_h]
				Grouping.Render.nos1 :
			mov [Image.copyRegion.h], eax
			
			mov eax, [ebx+Component_w]
			mov [Image.copyRegion.ow], eax
			mov eax, [edx+Component_w]
			mov [Image.copyRegion.nw], eax
			
			call Image.copyRegion
			
			;jmp Grouping.Render.loop
		
	Grouping.Render.ret :
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
	popa
	ret