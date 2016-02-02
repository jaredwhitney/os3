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
	popa
	ret
