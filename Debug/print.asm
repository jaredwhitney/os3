debug.init :
mov al, 1
mov ah, 3
call Guppy.malloc
mov [debug.buffer], ebx
call clearScreenG
ret

debug.println :
	call debug.print
	call debug.newl
	call debug.update
	ret

debug.print :	; string loc in ebx
	pusha
	mov ecx, [debug.buffer]
	mov edx, [debug.bufferpos]
	add ecx, edx
	debug.print.loop :
		mov al, [ebx]
		cmp al, 0x0
		je debug.print.ret
		mov [ecx], al
		add ebx, 0x1
		add ecx, 0x1
		jmp debug.print.loop
		debug.print.ret :
	mov edx, [debug.buffer]
	sub ecx, edx
	mov [debug.bufferpos], ecx
	popa
	ret
	
debug.update :
	pusha
	mov ecx, [charpos]
	mov [debug.charpos.stor], ecx
	mov ecx, [debug.charpos]
	mov [charpos], ecx
	mov ebx, [debug.buffer]
	mov ah, 255
	mov edx, 0x0
	debug.update_loop :
		mov al, [ebx]
		cmp edx, 0x1000
			jg debug.update_ret
		add edx, 1
		cmp al, 0x0
			je debug.update.nodraw
			call graphics.drawChar
		jmp debug.update.cont1
		debug.update.nodraw :
			push ecx
			mov ecx, [charpos]
			add ecx, 8
			mov [charpos], ecx
			pop ecx
		debug.update.cont1 :
		add ebx, 0x1
		jmp debug.update_loop
	debug.update_ret :
	mov ecx, [debug.charpos.stor]
	mov [charpos], ecx
	popa
	ret

debug.clear :
pusha
mov ebx, [debug.buffer]
mov eax, [debug.bufferpos]
add eax, ebx
mov cl, 0x0
debug.clear.loop :
mov [ebx], cl
add ebx, 1
cmp ebx, eax
jg debug.clear.ret
jmp debug.clear.loop
debug.clear.ret :
mov ecx, 0x0
mov [debug.bufferpos], ecx
popa
ret

debug.num :		; num in ebx
		pusha
		mov cl, 28
		mov ch, 0x0
		debug.num.start :
		mov edx, ebx
		shr edx, cl
		and edx, 0xF
		cmp dx, 0x0
		je debug.num.checkZ
		mov ch, 0x1
		debug.num.dontcare :
		push ebx
		mov eax, edx
		cmp dx, 0x9
		jg debug.num.g10
		add eax, 0x30
		jmp debug.num.goPrint
		debug.num.g10 :
		add eax, 0x37
		debug.num.goPrint :
		call debug.cprint
		pop ebx
		debug.num.goCont :
		cmp cl, 0
		jle debug.num.end
		sub cl, 4
		jmp debug.num.start
		debug.num.checkZ :
		cmp ch, 0x0
		je debug.num.goCont
		jmp debug.num.dontcare
		debug.num.end :
		popa
		ret
debug.cprint :	; char in al
	pusha
	mov ecx, [debug.bufferpos]
	mov ebx, [debug.buffer]
	add ecx, ebx
	mov [ecx], al
	add ecx, 1
	sub ecx, ebx
	mov [debug.bufferpos], ecx
	popa
	ret

debug.newl :
	push ebx
	mov ebx, [debug.bufferpos]
	add ebx, 0x168
	mov [debug.bufferpos], ebx
	pop ebx
	ret

debug.charpos :
dd 0xa0000
debug.charpos.stor :
dd 0x0
debug.buffer :
dd 0x0
debug.bufferpos :
dd 0x0