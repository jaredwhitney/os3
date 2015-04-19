debug.init :
mov al, 1
mov ah, 3
;call Guppy.malloc
mov ebx, 0xA02000
mov [debug.buffer], ebx
call debug.flush
call clearScreenG
mov ebx, DEBUG_INIT_MSG
call debug.log.system
;jmp $
mov ax, [0x1000]
cmp ax, 0xF
jne debug.init.op1
mov ebx, DEBUG_INIT_EMUBOOT
call debug.log.info
ret
debug.init.op1 :
mov ebx, DEBUG_INIT_REALBOOT
call debug.log.info
ret

debug.println :
	call debug.print
	call debug.newl
	call debug.update
	ret
	
debug.log.system :
	pusha
	mov ah, 0xFF
	call debug.setColor
	push ebx
	mov ebx, DEBUG_SYSTEM_TAG
	call debug.print
	pop ebx
	call debug.println
	call debug.restoreColor
	popa
	ret
	
debug.log.info :
	pusha
	mov ah, 0xE9
	call debug.setColor
	push ebx
	mov ebx, DEBUG_INFO_TAG
	call debug.print
	pop ebx
	call debug.println
	call debug.restoreColor
	popa
	ret
	
debug.log.error :
	pusha
	mov ah, 0x3
	call debug.setColor
	push ebx
	mov ebx, DEBUG_ERROR_TAG
	call debug.print
	pop ebx
	call debug.println
	call debug.restoreColor
	popa
	ret

debug.print :	; string loc in ebx
	pusha
	mov ah, [debug.color]
	mov ecx, [debug.buffer]
	mov edx, [debug.bufferpos]
	add ecx, edx
	debug.print.loop :
		mov al, [ebx]
		cmp al, 0x0
		je debug.print.ret
		mov [ecx], ax
		add ebx, 0x1
		add ecx, 0x2
		jmp debug.print.loop
		debug.print.ret :
	mov edx, [debug.buffer]
	sub ecx, edx
	mov [debug.bufferpos], ecx
	popa
	ret
	
debug.update :
	pusha
	mov cx, SCREEN_WIDTH
	mov [os.textwidth], cx
		mov bl, [debug.nogo]
		cmp bl, 0xFF
		je debug.update.rret
	mov bl, 0xF
	mov [char.solid], bl
	mov ecx, [charpos]
	mov [debug.charpos.stor], ecx
	mov ecx, [debug.charpos]
	mov [charpos], ecx
	mov ebx, [debug.buffer]
	mov ah, 255
	mov edx, 0x0
	debug.update_loop :
		mov ax, [ebx]
		call debug.internal.fallcheck
		cmp edx, 0x2A00
			jg debug.update_ret
		add edx, 1
		cmp al, 0x0
			je debug.update.nodraw
			call graphics.drawChar
		jmp debug.update.cont1
		debug.update.nodraw :
			push ecx
			mov ecx, [charpos]
			add ecx, 6
			mov [charpos], ecx
			pop ecx
		debug.update.cont1 :
		add ebx, 0x2
		jmp debug.update_loop
	debug.update_ret :
	mov ecx, [debug.charpos.stor]
	mov [charpos], ecx
	mov bl, 0x0
	mov [char.solid], bl
	debug.update.rret :
	popa
	ret

debug.clear :
pusha
mov ebx, [debug.buffer]
mov eax, [debug.bufferpos]
add eax, ebx
mov cx, 0x0
debug.clear.loop :
mov [ebx], cx
add ebx, 2
cmp ebx, eax
jg debug.clear.ret
jmp debug.clear.loop
debug.clear.ret :
mov ecx, 0x0
mov [debug.bufferpos], ecx
mov [debug.nlcor], ecx
mov cl, 0x1
mov [debug.nlcnow], cl
popa
ret

debug.flush :
pusha
mov eax, [debug.buffer]
add eax, 0xf800
mov [debug.bufferpos], eax
call debug.clear
popa
ret

debug.num :		; num in ebx
		pusha
		mov cl, 28
		mov ch, 0x0
		debug.num.start :
			cmp ebx, 0x0
			jne debug.num.cont
			mov ah, [console.cstor]
			mov al, '0'
			call debug.cprint
			popa
			ret
			debug.num.cont :
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
	mov ah, [debug.color]
	mov [ecx], ax
	add ecx, 2	; there are now two bytes: char and color
	sub ecx, ebx
	mov [debug.bufferpos], ecx
	popa
	ret
LINE_SEQ equ 0x3c0; 0x140 * 3 = 0x3c0
debug.newl :
	pusha
	mov ebx, [debug.bufferpos]
	mov edx, 0x0
	mov eax, ebx
	mov ecx, LINE_SEQ
	div ecx
	mov ebx, eax
	imul ebx, LINE_SEQ
	add ebx, LINE_SEQ
	
		pusha
		;mov ebx, [debug.bufferpos]
		cmp ebx, 0x17*0x3c0
		jl debug.newl.noshift
		mov ebx, [debug.buffer]
		add ebx, 0x3c0	; not the correct number!
		mov [debug.buffer], ebx
		;call debug.clear
		popa
		sub ebx, LINE_SEQ
		jmp debug.newl.shiftdone
		debug.newl.noshift :
		popa
	debug.newl.shiftdone :
		
	mov [debug.bufferpos], ebx
	popa
	ret
debug.setColor :
	push ax
	mov ah, [debug.color]
	mov [debug.cstor], ah
	pop ax
	mov [debug.color], ah
	ret
debug.restoreColor :
	push ax
	mov ah, [debug.cstor]
	mov [debug.color], ah
	pop ax
	ret
debug.useFallbackColor :
	mov [debug.color.fallback], ah
	push ax
	mov ah, 0x1
	mov [char.solid], ah
	pop ax
	ret
debug.internal.fallcheck :
	push bx
	mov bl, [debug.color.fallback]
	cmp bl, 0x0
	je debug.internal.fallcheck.ret
	mov ah, bl
	debug.internal.fallcheck.ret :
	pop bx
	ret
debug.toggleView :
	push bx
	mov bl, [debug.nogo]
	xor bl, 0xFF
	mov [debug.nogo], bl
	call Dolphin.updateScreen
	pop bx
	ret
debug.charpos :
dd SCREEN_BUFFER
debug.charpos.stor :
dd 0x0
debug.buffer :
dd 0x0
debug.bufferpos :
dd 0x0
debug.nlcor :
dd 0x0
debug.nlcnow :
db 0x1
debug.color :
db 0xDA
debug.cstor :
db 0xDA
debug.color.fallback :
db 0x0
debug.nogo :
db 0x0
DEBUG_INFO_TAG :
db "[ info ] ", 0
DEBUG_SYSTEM_TAG :
db "[system] ", 0
DEBUG_ERROR_TAG :
db "[error ] ", 0
DEBUG_INIT_MSG :
db "Debugger online.", 0
DEBUG_INIT_REALBOOT :
db "Running on a real computer.", 0
DEBUG_INIT_EMUBOOT :
db "Running on an emulator.", 0