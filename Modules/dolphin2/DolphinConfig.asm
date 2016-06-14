DolphinConfig.proccessFile :
	pusha
		mov eax, DolphinConfig.STR_FILE_NAME
		call Minnow4.getFilePointer
		cmp ebx, Minnow4.SUCCESS
			jne .ret
		call Minnow4.readFileBlock
		mov ebx, ecx
		.loop :
		mov eax, DolphinConfig.PREFIX_DESKTOP_COLOR
		call DolphinConfig.wordEquals
		cmp eax, true
			jne .notDesktopColor
		call DolphinConfig.skipWhitespace
		call DolphinConfig.colorFromString	; returns color in edx
		mov eax, [Dolphin2.compositorGrouping]
		mov dword [eax+Grouping_backingColor], edx
		jmp .advance
		.notDesktopColor :
		mov eax, DolphinConfig.PREFIX_TITLEBAR_COLOR
		call DolphinConfig.wordEquals
		cmp eax, true
			jne .notTitlebarColor
		call DolphinConfig.skipWhitespace
		call DolphinConfig.colorFromString
		mov [Dolphin2.titleBarColor], edx
		jmp .advance
		.notTitlebarColor :
		mov eax, DolphinConfig.PREFIX_LOGIN_PASSWORD
		call DolphinConfig.wordEquals
		cmp eax, true
			jne .notLoginPassword
		; things here
		jmp .advance
		.notLoginPassword :
		mov eax, DolphinConfig.PREFIX_WINDOWTRIM_COLOR
		call DolphinConfig.wordEquals
		cmp eax, true
			jne .notWindowtrimColor	; no idea, just forget about it
		call DolphinConfig.skipWhitespace
		call DolphinConfig.colorFromString
		mov [Dolphin2.windowTrimColor], edx
		jmp .advance
		.notWindowtrimColor :
		mov eax, DolphinConfig.PREFIX_TITLEBAR_ACTIVE_COLOR
		call DolphinConfig.wordEquals
		cmp eax, true
			jne .advance
		call DolphinConfig.skipWhitespace
		call DolphinConfig.colorFromString
		mov [Dolphin2.titleBarActiveColor], edx
		.advance :
		cmp byte [ebx], 0xFE	; newline
			je .advanceDone
		inc ebx
		jmp .advance
		.advanceDone :
		inc ebx
		cmp byte [ebx], 0x0
			jne .loop
		; should deal with it maybe being multiple blocks long here!!
	.ret :
	popa
	ret
DolphinConfig.STR_FILE_NAME :
	db "D2CFG.rawtext", 0x0
DolphinConfig.PREFIX_DESKTOP_COLOR :
	db "DESKTOP_COLOR", 0
DolphinConfig.PREFIX_TITLEBAR_COLOR :
	db "TITLEBAR_COLOR", 0
DolphinConfig.PREFIX_TITLEBAR_ACTIVE_COLOR :
	db "TITLEBAR_ACTIVE_COLOR", 0
DolphinConfig.PREFIX_LOGIN_PASSWORD :
	db "LOGIN_PASSWORD", 0
DolphinConfig.PREFIX_WINDOWTRIM_COLOR :
	db "WINDOW_TRIM_COLOR", 0

DolphinConfig.skipWhitespace :
	cmp byte [ebx], ' '
		jne .ret
	inc ebx
	jmp DolphinConfig.skipWhitespace
	.ret :
	ret

DolphinConfig.wordEquals :
	push ebx
	push ecx
	
		.loop :
		mov cl, [ebx]
		cmp cl, ' '
			je .rettrue
		cmp [eax], cl
			jne .retfalse
		inc eax
		inc ebx
		jmp .loop
	.rettrue :
	mov eax, TRUE
	pop ecx
	pop ebx
	ret
	.retfalse :
	mov eax, FALSE
	pop ecx
	pop ebx
	ret
	
DolphinConfig.colorFromString :
	push eax
	push ebx
	push ecx
		mov eax, 3
		.loop :
		call Integer.decimalFromString
		shl dword [.color], 8
		or [.color], ecx
			.inloop :
			cmp byte [ebx], ','
				je .loopDone
			inc ebx
			jmp .inloop
			.loopDone :
			inc ebx
			call DolphinConfig.skipWhitespace
		dec eax
		cmp eax, 0x0
			jg .loop
		mov eax, [Dolphin2.compositorGrouping]
		mov edx, [.color]
		or edx, 0xFF000000
	pop ecx
	pop ebx
	pop eax
	ret
.color :
	dd 0x0