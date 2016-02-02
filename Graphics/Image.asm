Image_type	equ 0
Image_image	equ 4
Image_x		equ 8
Image_y		equ 12
Image_w		equ 16
Image_h		equ 20
Image_source	equ 28
Image_sw	equ 32
Image_sh	equ 36

Image.Create :	; Image source, int sw, int sh, int x, int y, int w, int h
	pop dword [Image.Create.retval]
	pop dword [Image.Create.h]
	pop dword [Image.Create.w]
	pop dword [Image.Create.y]
	pop dword [Image.Create.x]
	pop dword [Image.Create.sh]
	pop dword [Image.Create.sw]
	pop dword [Image.Create.source]
	push eax
	push ebx
		mov ebx, 32
		call ProgramManager.reserveMemory
		mov eax, [Image.Create.source]
		mov [ebx+Image_source], eax
		mov eax, [Image.Create.sw]
		mov [ebx+Image_sw], eax
		mov eax, [Image.Create.sh]
		mov [ebx+Image_sh], eax
		mov eax, [Image.Create.x]
		mov [ebx+Image_x], eax
		mov eax, [Image.Create.y]
		mov [ebx+Image_y], eax
		mov eax, [Image.Create.w]
		mov [ebx+Image_w], eax
		mov eax, [Image.Create.h]
		mov [ebx+Image_h], eax
		mov eax, Component.TYPE_IMAGE
		mov [ebx+Image_type], eax
		pusha
			mov edx, ebx
			mov eax, [ebx+Image_w]
			imul eax, [ebx+Image_h]
			mov ebx, eax
			call ProgramManager.reserveMemory
			mov [edx+Image_image], ebx
		popa
		mov ecx, ebx
	pop ebx
	pop eax
	push dword [Image.Create.retval]
	ret
Image.Render :	; Image in ebx
	pusha
		mov eax, [ebx+Image_w]	; take min(Image_w, Image_sw)
			cmp eax, [ebx+Image_sw]	
				jle Image.Render.nos0
			mov eax, [ebx+Image_sw]
			Image.Render.nos0 :
		mov [Image.copyRegion.w], eax
		mov eax, [ebx+Image_w]
		mov [Image.copyRegion.nw], eax
		mov eax, [ebx+Image_sw]
		mov [Image.copyRegion.ow], eax
		mov eax, [ebx+Image_h]	; take min(Image_h, Image_sh)
			cmp eax, [ebx+Image_sh]
				jle Image.Render.nos1
			mov eax, [ebx+Image_sh]
			Image.Render.nos1 :
		mov [Image.copyRegion.h], eax
		mov eax, [ebx+Image_source]
		mov [Image.copyRegion.obuf], eax
		mov eax, [ebx+Image_image]
		mov [Image.copyRegion.nbuf], eax
		call Image.copyLinear
	popa
	ret

Imagescalable_type	equ 0
Imagescalable_image	equ 4
Imagescalable_x		equ 8
Imagescalable_y		equ 12
Imagescalable_w		equ 16
Imagescalable_h		equ 20
Imagescalable_source	equ 28
Imagescalable_sw	equ 32
Imagescalable_sh	equ 36

ImageScalable.Create :	; Image source, int sw, int sh, int x, int y, int w, int h
	pop dword [ImageScalable.Create.retval]
	pop dword [ImageScalable.Create.h]
	pop dword [ImageScalable.Create.w]
	pop dword [ImageScalable.Create.y]
	pop dword [ImageScalable.Create.x]
	pop dword [ImageScalable.Create.sh]
	pop dword [ImageScalable.Create.sw]
	pop dword [ImageScalable.Create.source]
	push eax
	push ebx
		mov ebx, 40
		call ProgramManager.reserveMemory
		mov eax, [ImageScalable.Create.source]
		mov [ebx+Imagescalable_source], eax
		mov eax, [ImageScalable.Create.sw]
		mov [ebx+Imagescalable_sw], eax
		mov eax, [ImageScalable.Create.sh]
		mov [ebx+Imagescalable_sh], eax
		mov eax, [ImageScalable.Create.x]
		mov [ebx+Imagescalable_x], eax
		mov eax, [ImageScalable.Create.y]
		mov [ebx+Imagescalable_y], eax
		mov eax, [ImageScalable.Create.w]
		mov [ebx+Imagescalable_w], eax
		mov eax, [ImageScalable.Create.h]
		mov [ebx+Imagescalable_h], eax
		mov eax, Component.TYPE_IMAGE_SCALABLE
		mov [ebx+Imagescalable_type], eax
		pusha
			mov edx, ebx
			mov eax, [ebx+Image_w]
			imul eax, [ebx+Image_h]
			mov ebx, eax
			call ProgramManager.reserveMemory
			mov [edx+Image_image], ebx
		popa
		mov ecx, ebx
	pop ebx
	pop eax
	push dword [ImageScalable.Create.retval]
	ret

ImageScalable.Render :	; ImageScalable in ebx
	pusha
		; Figure out how to nicely scale images!
	popa
	ret

; Image, ImageScalable [s:w,h], ImageScrollable[mscrolls]
