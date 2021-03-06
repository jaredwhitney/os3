String.getLength :	; String in ebx, length out in edx
xor edx, edx
push ebx
push ax
	mov al, [ebx]
	cmp al, 0x0
		je String.getLength.kret
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
String.getLength.kret :
pop ax
pop ebx
mov edx, 1
ret

String.getEffectiveLength :	; charwidth in eax, String in ebx, length out in edx FINISH WRITING THIS
	pusha
		mov bl, [ebx]
		cmp bl, 0x0A
			jne String.getEffectiveLength.noadd
		xor edx, edx
		mov ecx, eax
		String.getEffectiveLength.noadd :
	popa
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
	mov al, 0x0
	call String.fromHex.cprint
popa
ret
String.fromHex.checkZ :
	cmp ch, 0x0
		je String.fromHex.goCont
	jmp String.fromHex.dontcare

String.fromHex.cprint :
pusha
	;mov ah, 0xFF
	mov ebx, [String._buffer]
	add ebx, [String._bufferOffs]
	mov [ebx], al
	mov ebx, [String._bufferOffs]
	add ebx, 0x1
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

String.copyRawToWhite :	; eax = String to copy, ebx = location to copy it to
pusha
	mov ch, 0xFF
	String.copyRawToWhite.loop :
		mov cl, [eax]
		cmp cl, 0x0
			je String.copyRawToWhite.ret
		mov [ebx], cx
		add eax, 1
		add ebx, 2
		jmp String.copyRawToWhite.loop
String.copyRawToWhite.ret :
mov word [ebx], 0x0	; i think word is right...
popa
ret

String.copyRawToWhite_auto :	; ebx = String to copy, returns ecx = new String
push eax
push ebx
push edx
		mov eax, ebx
		call String.getLength
		imul edx, 2
		mov ebx, edx
		call ProgramManager.reserveMemory
				;mov ebx, 0x4000	; TESTING
		mov ecx, ebx
		push ecx
	mov ch, 0xFF
				;mov eax, HelloWorld.welcomeMessage
	String.copyRawToWhite_auto.loop :
		mov cl, [eax]
		cmp cl, 0x0
			je String.copyRawToWhite_auto.ret
		mov [ebx], cx
		add eax, 1
		add ebx, 2
		jmp String.copyRawToWhite_auto.loop
String.copyRawToWhite_auto.ret :
mov word [ebx], 0x0	; i think word is right...
pop ecx
pop edx
pop ebx
pop eax
ret

String.copyColorToRaw : ; eax = String to copy, ebx = location to copy it to
pusha
	String.copyColorToRaw.loop :
		mov cx, [eax]
		cmp cl, 0x0
			je String.copyColorToRaw.ret
		mov [ebx], cl
		add eax, 2
		add ebx, 1
		jmp String.copyColorToRaw.loop
String.copyColorToRaw.ret :
mov byte [ebx], 0x0
popa
ret

String.copyUntilBothZeroed :	; eax = String to copy, ebx = new location to copy it to
pusha
	mov edx, [Graphics.SCREEN_MEMPOS]
	mov ecx, [Clock.tics]
	and ecx, 0xFF
	add edx, ecx
	mov dword [edx], 0xFF
	String.copyUntilBothZeroed.loop :
		mov cx, [eax]
		cmp cx, 0x0
			jne String.copyUntilBothZeroed.cont
		cmp word [ebx], 0x0
			je String.copyUntilBothZeroed.ret
		String.copyUntilBothZeroed.cont :
		mov [ebx], cx
		add eax, 2
		add ebx, 2
		jmp String.copyUntilBothZeroed.loop
String.copyUntilBothZeroed.ret :
mov byte [ebx], 0x0
popa
ret

String.append :	; eax = main String, ebx = text to append
pusha
	push ebx
	mov ebx, eax
	call String.getLength
	sub edx, 1
	add eax, edx
	pop ebx
	xchg eax, ebx
	call String.copy
popa
ret

String._buffer :
dd 0x0

String._bufferOffs :
dd 0x0
