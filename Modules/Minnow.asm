Minnow.dtree :
	pusha

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

Minnow.navToFirst :
	mov ebx, MINNOW_START
	mov ah, 0x0
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
	add ebx, 4	; at filetype
	add ebx, 4	; at filename
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

Minnow.sep :
db ": ", 0
Minnow.stag :
db "[0x", 0
Minnow.cstor :
db 0, 0, 0, 0, 0, 0, 0, 0, 0