; >	ptr++
; <	ptr--
; +	dat[ptr]++
; -	dat[ptr]--
; .	cprint(dat[ptr])
; ,	dat[ptr] = cinp()
; [	if dat[ptr]==0 jmp matching ]
; ]	if dat[ptr]!=0 jmp backmatching [

BFCK.ptr :
	dd 0x0
BFCK.memRegion :
	dd 0x0

BFCK.init :
	pusha
		push dword BFCK.COMMAND_PARSE
		call iConsole2.RegisterCommand
	popa
	ret

BFCK.COMMAND_PARSE :
	dd .parseStr
	dd BFCK.parse
	dd null
	.parseStr :
		db "parse", 0
BFCK.parse :
	enter 0, 0
	pusha
		cmp dword [iConsole2.argNum], 2
			jne .keepGoingPre
		mov eax, [ebp+12]
		mov ebx, .fileFlag
		call os.seq
		cmp al, 0
			je .keepGoingPre
		push dword .warning
		call iConsole2.Echo
			; need to read in the file with its name at [ebp+8]
		mov eax, [ebp+8]
		call Minnow4.getFilePointer
		cmp ebx, Minnow4.FILE_NOT_FOUND
			jne .allGood
		push dword .fileNotFound
		call iConsole2.Echo
		jmp .ret
		.allGood :
		mov ebx, 1000	; only run up to 1000 chars for now
		call Guppy2.malloc
		mov ecx, ebx
		mov edx, 1000
		call Minnow4.readBuffer
			; then set [ebp+8] to point to the file data in memory
		mov [ebp+8], ecx
		.keepGoingPre :
		mov ebx, 1000
		call Guppy2.malloc
		mov [BFCK.memRegion], ebx
		mov dword [.c], 0
		mov dword [BFCK.ptr], 0
		mov eax, [BFCK.memRegion]
		mov ebx, 1000
		call Buffer.clear
		.loop :
		mov ebx, [.c]
		add ebx, [ebp+8]
		cmp byte [ebx], 0
			je .aret
		cmp byte [ebx], '>'
			jne .ngthan
		inc dword [BFCK.ptr]
		jmp .cdone
		.ngthan :
		cmp byte [ebx], '<'
			jne .nlthan
		dec dword [BFCK.ptr]
		jmp .cdone
		.nlthan :
		cmp byte [ebx], '+'
			jne .nplus
		mov edx, [BFCK.memRegion]
		add edx, [BFCK.ptr]
		inc byte [edx]
		jmp .cdone
		.nplus :
		cmp byte [ebx], '-'
			jne .nminus
		mov edx, [BFCK.memRegion]
		add edx, [BFCK.ptr]
		dec byte [edx]
		jmp .cdone
		.nminus :
		cmp byte [ebx], '.'
			jne .ndot
		mov edx, [BFCK.memRegion]
		add edx, [BFCK.ptr]
		push edx
		call iConsole2.EchoChar
		jmp .cdone
		.ndot :
		cmp byte [ebx], ','
			jne .ncomma
		mov dword [iConsole2.keyRedirect], BFCK.keyGetter
				mov [.ebxstor], ebx
				mov ebx, [ebp+8]
				mov [.instr], ebx
				popa
				leave
				jmp iConsole2.returnBlindSilent
		.entryPoint :
				enter 0, 0
				pusha
				mov ebx, [.ebxstor]
		mov edx, [BFCK.memRegion]
		add edx, [BFCK.ptr]
		mov cl, [BFCK.keyGetter.char]
		mov [edx], cl
		jmp .cdone
		.ncomma :
		cmp byte [ebx], '['
			jne .nlbracket
		mov edx, [BFCK.memRegion]
		add edx, [BFCK.ptr]
		cmp byte [edx], 0
			jne .skiplbrak
		.lbracketloop :
		inc dword [.c]
		inc ebx
		cmp byte [ebx], 0
			je .cdone
		cmp byte [ebx], ']'
			jne .lbracketloop
		.skiplbrak :
		jmp .cdone
		.nlbracket :
		cmp byte [ebx], ']'
			jne .nrbracket
		mov edx, [BFCK.memRegion]
		add edx, [BFCK.ptr]
		cmp byte [edx], 0
			je .skiprbrak
		.rbracketloop :
		dec dword [.c]
		dec ebx
		cmp byte [ebx], '['
			je .cdone
		cmp dword [.c], 0
			jne .rbracketloop
		.skiprbrak :
		jmp .cdone
		.nrbracket :
		.cdone :
		inc dword [.c]
		jmp .loop
		.aret :
		mov edx, [BFCK.memRegion]
		call Guppy2.free
		mov dword [iConsole2.keyRedirect], null
	.ret :
	popa
	leave
	call iConsole2.returnBlind
	.c :
		dd 0x0
	.ebxstor :
		dd 0x0
	.instr :
		dd 0x0
	.fileFlag :
		db "-F", 0
	.warning :
		db "[WARN] Executing files is currently in development.", newline, 0
	.fileNotFound :
		db "[ERROR] File not found.", newline, 0

BFCK.keyGetter :
	pusha
	mov [0x1000], esp
		call iConsole2.HandleKeyEventNoMod
		mov bl, [Component.keyChar]
		cmp bl, 0xFE
			jne .notEnter
		mov bl, 0x0
		.notEnter :
		mov [.char], bl
	;	mov dword [iConsole2.keyRedirect], null
	push dword [BFCK.parse.instr]
	call BFCK.parse.entryPoint
	ret
.char :
	db 0x0

