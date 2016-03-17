L3gxImage_data	equ 0x0
L3gxImage_w		equ 0x4
L3gxImage_h		equ 0x8

L3gxImage_$CLASSSIZE	equ 0xC

L3gxImage.Create :	; int width, int height
	pop dword [L3gxImage.Create.retval]
	pop dword [L3gxImage.Create.width]
	pop dword [L3gxImage.Create.height]
	push eax
	push ebx
		mov al, 7
		mov ebx, [L3gxImage.Create.width]
		imul ebx, [L3gxImage.Create.height]
		call ProgramManager.reserveMemory
		mov eax, ebx
		mov ebx, [L3gxImage.Create.width]
		mov ecx, [L3gxImage.Create.height]
		call L3gxImage.FromBuffer
	pop ebx
	pop eax
	push dword [L3gxImage.Create.retval]
	ret
L3gxImage.Create.retval :
	dd 0x0
L3gxImage.Create.width :
	dd 0x0
L3gxImage.Create.height :
	dd 0x0

L3gxImage.FromBuffer :	; eax = data, ebx = width, ecx = height
	push edx
	push eax
		mov edx, eax
		push ebx
		mov al, 7
		mov ebx, L3gxImage_$CLASSSIZE
		call ProgramManager.reserveMemory
		mov eax, ebx
		pop ebx
		mov [eax+L3gxImage_data], edx
		mov [eax+L3gxImage_w], ebx
		mov [eax+L3gxImage_h], ecx
	mov ecx, eax
	pop eax
	pop edx
	ret
	
L3gxImage.FakeFromComponent :	; ebx = component
		mov ecx, [ebx+Component_image]
		mov [L3gxImage.fakedImageData+L3gxImage_data], ecx
		mov ecx, [ebx+Component_w]
		shr ecx, 2	; div by 4 so its in pixels and not bytes
		mov [L3gxImage.fakedImageData+L3gxImage_w], ecx
		mov ecx, [ebx+Component_h]
		mov [L3gxImage.fakedImageData+L3gxImage_h], ecx
		mov ecx, L3gxImage.fakedImageData
	ret
L3gxImage.fakedImageData :
	times 3 dd 0x0