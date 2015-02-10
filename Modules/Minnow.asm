Minnow.dtree :
	pusha
	mov ebx, MINNOW_START
	mov ah, 0x0
	Minnow.dtree.scr1 :
		mov al, [ebx]
		cmp al, 0x0
		jne Minnow.dtree.scr1done
		add ebx, 1
		jmp Minnow.dtree.scr1
	Minnow.dtree.scr1done :	; at filesize
	mov edx, [ebx]
	cmp edx, 0x0
	;cmp ah, 2
	je Minnow.dtree.ret
	
	push ebx
	mov ebx, Minnow.stag
	call debug.print
	mov ebx, edx
	call debug.num
	pop ebx
	mov al, "]"
	call debug.cprint
	
	add ebx, 4	; at filetype
	mov ecx, 4
	call Minnow.dtree.nprint
	
	push ebx
	mov ebx, Minnow.sep
	call debug.print
	pop ebx
	
	add ebx, 4	; at filename
	mov ecx, 8
	call Minnow.dtree.nprint
	
	;add ebx, 8
	add ah, 1
	call debug.newl

	add ebx, 8	; at start of file
	
	add ebx, edx	; at header for next file
	;add ebx, 0x858
	
	jmp Minnow.dtree.scr1done
	
	Minnow.dtree.ret :
	popa
	ret
	
Minnow.dtree.nprint :
	pusha
	mov edx, 0x0
	Minnow.dtree.lnam :
		mov al, [ebx]
		cmp al, "_"
		je Minnow.dtree.nprint.noprint
			call debug.cprint
		Minnow.dtree.nprint.noprint :
		add ebx, 1
		add edx, 1
		cmp edx, ecx
		je Minnow.dtree.lnam.done
		jmp Minnow.dtree.lnam
	Minnow.dtree.lnam.done :
	popa
	ret

Minnow.sep :
db ": ", 0
Minnow.stag :
db "[0x", 0