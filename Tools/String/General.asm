String.getLength :	; String in ebx, length out in edx
xor edx, edx
push ebx
push ax
String.getLength.loop :
add ebx, 1
add edx, 1
mov al, [ebx]
cmp al, 0x0
jne String.getLength.loop
pop ax
pop ebx
add edx, 1
ret

String.fromHex :	; eax = buffer to store string in, ebx = hex number
pusha
	mov [String._buffer], eax
	xor eax, eax
	mov [String._bufferOffs], eax
	mov cl, 28
	mov ch, 0x0
	
	; num out
	String.fromHex.start :
		cmp ebx, 0x0
		jne String.fromHex.cont
		mov al, '0'
		call String.fromHex.cprint
		popa
		ret
		String.fromHex.cont :
	mov edx, ebx
	shr edx, cl
	and edx, 0xF
	
	cmp dx, 0x0
	je String.fromHex.checkZ
	mov ch, 0x1
	String.fromHex.dontcare :
	push ebx
	mov eax, edx
	
	cmp dx, 0x9
	jg String.fromHex.g10
	add eax, 0x30
	jmp String.fromHex.goPrint
	String.fromHex.g10 :
	add eax, 0x37
	String.fromHex.goPrint :
	push ax
	call String.fromHex.cprint
	pop ax
	pop ebx
	String.fromHex.goCont :
	cmp cl, 0
	jle String.fromHex.end
	sub cl, 4
	jmp String.fromHex.start
	String.fromHex.end :
popa
ret
String.fromHex.checkZ :
	cmp ch, 0x0
		je String.fromHex.goCont
	jmp String.fromHex.dontcare

String.fromHex.cprint :
pusha
	mov ah, 0xFF
	mov ebx, [String._buffer]
	add ebx, [String._bufferOffs]
	mov [ebx], ax
	mov ebx, [String._bufferOffs]
	add ebx, 0x2
	mov [String._bufferOffs], ebx
popa
ret

String.copy :	; eax = String to copy, ebx = new location to copy it to
pusha
	String.copy.loop :
		mov cl, [eax]
		cmp cl, 0x0
			je String.copy.ret
		mov [ebx], cl
		add eax, 1
		add ebx, 1
		jmp String.copy.loop
String.copy.ret :
mov byte [ebx], 0x0
popa
ret


String._buffer :
dd 0x0

String._bufferOffs :
dd 0x0
