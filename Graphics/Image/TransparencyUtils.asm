Image.copyRegionWithTransparency :
	pusha
		mov eax, [Image.copyRegionWithTransparency.ow]
		sub eax, [Image.copyRegionWithTransparency.w]
		;sub eax, 4
		mov [Image.copyRegionWithTransparency.owa], eax
		mov eax, [Image.copyRegionWithTransparency.nw]
		sub eax, [Image.copyRegionWithTransparency.w]
		;sub eax, 4
		mov [Image.copyRegionWithTransparency.nwa], eax

		mov edx, [Image.copyRegionWithTransparency.h]
		mov eax, [Image.copyRegionWithTransparency.obuf]
		mov ebx, [Image.copyRegionWithTransparency.nbuf]
		Image.copyRegionWithTransparency.loop1 :
			push edx
			mov edx, [Image.copyRegionWithTransparency.w]
			Image.copyRegionWithTransparency.loop2 :
				mov ecx, [eax]
					push edx
						mov edx, [ebx]
						call Color.fuse
					pop edx
				mov [ebx], ecx
				add eax, 4
				add ebx, 4
				sub edx, 4
				cmp edx, 0x0
					jg Image.copyRegionWithTransparency.loop2
			pop edx
			add ebx, [Image.copyRegionWithTransparency.nwa]
			add eax, [Image.copyRegionWithTransparency.owa]
			sub edx, 1
			cmp edx, 0x0
				jg Image.copyRegionWithTransparency.loop1
	popa
	ret
Image.copyRegionWithTransparency.w :
	dd 0x0
Image.copyRegionWithTransparency.ow :
	dd 0x0
Image.copyRegionWithTransparency.nw :
	dd 0x0
Image.copyRegionWithTransparency.h :
	dd 0x0
Image.copyRegionWithTransparency.obuf :
	dd 0x0
Image.copyRegionWithTransparency.nbuf :
	dd 0x0
Image.copyRegionWithTransparency.owa :
	dd 0x0
Image.copyRegionWithTransparency.nwa :
	dd 0x0
Color.fuse :	; overlapping color in ecx, color being written over in edx... returns color in ecx
	pusha
		mov [Color.fuse.old], edx
		mov [Color.fuse.new], ecx
		
		cmp byte [Color.fuse.newalpha], 0xFF
		mov [Color.fuse.ret], ecx
			je Color.fuse.goret
		cmp byte [Color.fuse.newalpha], 0x00
		mov [Color.fuse.ret], edx
			je Color.fuse.goret
			
		; mov al, [Color.fuse.newalpha]
		; add al, 0xFF
		; add al, 1
		; mov [Color.fuse.newalpha], al
		
		mov eax, ecx
		shr eax, 24
		and eax, 0xFF	; eax contains transparency (0-255)
		imul eax, 100
		xor edx, edx
		mov ecx, 255
		idiv ecx	; eax contains transparency as a percent
		
		; Get new blue color 
		xor ebx, ebx
		xor ecx, ecx
		mov bl, [Color.fuse.oldblue]
		mov cl, [Color.fuse.newblue]
		sub ecx, ebx
		imul ecx, eax
		xor edx, edx
		push eax
		mov eax, ecx
		mov ecx, 100
		idiv ecx
		add edx, eax
		pop eax
		mov [Color.fuse.retblue], dl
		
		; Get new green color 
		xor ebx, ebx
		xor ecx, ecx
		mov bl, [Color.fuse.oldgreen]
		mov cl, [Color.fuse.newgreen]
		sub ecx, ebx
		imul ecx, eax
		xor edx, edx
		push eax
		mov eax, ecx
		mov ecx, 100
		idiv ecx
		add edx, eax
		pop eax
		mov [Color.fuse.retgreen], dl
		
		; Get new red color 
		xor ebx, ebx
		xor ecx, ecx
		mov bl, [Color.fuse.oldred]
		mov cl, [Color.fuse.newred]
		sub ecx, ebx
		imul ecx, eax
		xor edx, edx
		push eax
		mov eax, ecx
		mov ecx, 100
		idiv ecx
		add edx, eax
		pop eax
		mov [Color.fuse.retred], dl
		
		mov al, [Color.fuse.oldalpha]
		mov [Color.fuse.retalpha], al
		
	Color.fuse.goret :
	popa
	mov ecx, [Color.fuse.ret]
	ret
Color.fuse.VARDATA :
dd Color.fuse.VARDATA_END-Color.fuse.VARDATA
	Color.fuse.old :
	Color.fuse.oldblue :
		db 0x0
	Color.fuse.oldgreen :
		db 0x0
	Color.fuse.oldred :
		db 0x0
	Color.fuse.oldalpha :
		db 0x0
	Color.fuse.new :
	Color.fuse.newblue :
		db 0x0
	Color.fuse.newgreen :
		db 0x0
	Color.fuse.newred :
		db 0x0
	Color.fuse.newalpha :
		db 0x0
	Color.fuse.ret :
	Color.fuse.retblue :
		db 0x0
	Color.fuse.retgreen :
		db 0x0
	Color.fuse.retred :
		db 0x0
	Color.fuse.retalpha :
		db 0x0
Color.fuse.VARDATA_END :
