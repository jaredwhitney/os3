Minnow.dtree :	; deprecated.
	pusha
	popa
	ret
	call Minnow.navToFirst; at filesize
	
	Minnow.dtree.scr1done :
	
	mov edx, [ebx]
	cmp edx, 0x0
	;cmp ah, 2
	je Minnow.dtree.ret
	
	push ebx
	push ebx
	mov ebx, Minnow.stag
	call debug.print
	pop ebx
	;mov ebx, edx	; uncommented = size, commented = loc
	add ebx, 0x10	; comment for size, uncomment for loc
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
	call debug.newl

	add ebx, 8	; at start of file
	
	add ebx, edx	; at header for next file
	;add ebx, 0x858
	
	jmp Minnow.dtree.scr1done
	
	Minnow.dtree.ret :
	call debug.update
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
	
Minnow.ctree :
	pusha
	call Minnow.navToFirst; at filesize
	Minnow.ctree.scr1done :
	mov edx, [ebx]
	cmp edx, 0x0
	push edx
	je Minnow.ctree.ret
	push ebx
	push ebx
	mov ebx, Minnow.stag
	call console.print
	pop ebx
	;mov ebx, edx	; uncommented = size, commented = loc
	add ebx, 0x10	; comment for size, uncomment for loc
	call console.numOut
	pop ebx
	mov al, "]"
	call console.cprint
	add ebx, 4	; at filetype
	mov ecx, 4
	call console.print
	push ebx
	mov ebx, Minnow.sep
	call console.print
	pop ebx
	call String.getLength
	add ebx, edx	; at filename
	mov ecx, 8
	call console.print
	call console.newline
	call String.getLength
	add ebx, edx	; at start of file
	pop edx
	add ebx, edx	; at header for next file
	jmp Minnow.ctree.scr1done
	Minnow.ctree.ret :
	;call console.update
	pop edx
	popa
	ret
Minnow.ctree.nprint :
	pusha
	mov edx, 0x0
	Minnow.ctree.lnam :
		mov al, [ebx]
		cmp al, "_"
		je Minnow.ctree.nprint.noprint
			call console.cprint
		Minnow.ctree.nprint.noprint :
		add ebx, 1
		add edx, 1
		cmp edx, ecx
		je Minnow.ctree.lnam.done
		jmp Minnow.ctree.lnam
	Minnow.ctree.lnam.done :
	popa
	ret

Minnow.navToFirst :
	mov ebx, MINNOW_START
	Minnow.navToFirst.scr1 :
		mov al, [ebx]
		cmp al, 0x0
		jne Minnow.navToFirst.scr1done
		add ebx, 1
		jmp Minnow.navToFirst.scr1
	Minnow.navToFirst.scr1done :
	ret

Minnow.byName :	; pointer to name in ebx, returns file location in ebx
	mov ecx, ebx
	call Minnow.navToFirst	; at filesize
	
	Minnow.byName.loop1 :
	mov eax, [ebx]
		push ecx
		mov ecx, eax
		cmp ecx, 0x0
		pop ecx
		je Minnow.byName.fileNotFound
	add ebx, 4	; at filetype
		call String.getLength
		add ebx, edx
	;add ebx, 4	; at filename
	mov edx, [ebx]
	mov [Minnow.cstor], edx
	add ebx, 4
	mov edx, [ebx]
	push ebx
	mov ebx, Minnow.cstor
	add ebx, 4
	mov [ebx], edx
	pop ebx
	
	mov edx, eax
	push ebx
	mov ebx, Minnow.cstor
	mov eax, ecx
		push ebx
		push ecx
		push edx
	call os.seq
		pop edx
		pop ecx
		pop ebx
	pop ebx
	add ebx, 4
	cmp al, 1
		je Minnow.byName.kret
	add ebx, edx
	jmp Minnow.byName.loop1
	
	Minnow.byName.kret :
	ret
	
Minnow.byName.fileNotFound :
	mov eax, Minnow.FILE_NOT_FOUND
	call Catfish.notify
	mov ebx, 0x0
	ret
	
Minnow.getType :	; file location in ebx, returns pointer to type in ebx
	push ecx
	push eax
	sub ebx, 12
	mov eax, Minnow.ftypestor
	mov ch, 0x0
	Minnow.getType.loop1 :
	mov cl, [ebx]
	mov [eax], cl
	add ebx, 1
	add eax, 1
	add ch, 1
	cmp ch, 4
	jl Minnow.getType.loop1
	mov ebx, Minnow.ftypestor
	pop eax
	pop ecx
	ret

Minnow.getSize :	; fileName in ebx, returns fileSize in ebx NOT FULLY IMPLEMENTED!
call Minnow.navToFirst

	
Minnow.getAttribute :	; file location in ebx, attribute number in ecx; returns attribute(s) in cx, dx
	push eax
	push ebx
	add ebx, ecx
	mov cx, [ebx]
	add ebx, 2	; next word
	mov dx, [ebx]
	pop ebx
	pop eax
	ret
	
Minnow.FILE_NOT_FOUND :
db "The specified file does not exist.", 0x0
Minnow.ftypestor :
db "____", 0x0
Minnow.IMAGE :
db "IMAG", 0x0
Minnow.ANIMATION :
db "ANIM", 0x0
Minnow.TEXT :
db "TEXT", 0x0
Minnow.image.DIM :
dd 0x0
Minnow.attr.SIZE :
dd 0xFFFFFFF6; -10
Minnow.sep :
db ": ", 0
Minnow.stag :
db "[0x", 0
Minnow.cstor :
db 0, 0, 0, 0, 0, 0, 0, 0, 0