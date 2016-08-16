TextMode.println :	; ebx is String
pusha
call TextMode.print
call TextMode.newline
popa
ret
TextMode.print :	; ebx is String
pusha
	mov ah, 0x0F
	mov ecx, [TextMode.charpos]
	TextMode.println.loop :
	mov al, [ebx]
	cmp al, 0x0
		je TextMode.println.ret
	mov [ecx], ax
	add ecx, 2
	add ebx, 1
	jmp TextMode.println.loop
	TextMode.println.ret :
	mov [TextMode.charpos], ecx
	call TextMode.scroll
popa
ret

TextMode.cprint :
pusha
mov ecx, [TextMode.charpos]
mov [ecx], ax
add ecx, 2
mov [TextMode.charpos], ecx
popa
ret

TextMode.newline :
pusha
	mov eax, [TextMode.charpos]
	sub eax, 0xb8000
	xor ebx, ebx
	xor edx, edx
	mov ecx, 160
	idiv ecx
	add eax, 1
	imul eax, 160
	add eax, 0xb8000
	mov [TextMode.charpos], eax
	call TextMode.scroll
popa
ret

TextMode.clearScreen :
pusha
	mov eax, 0xb8000
	mov [TextMode.charpos], eax
	TextMode.clearScreen.loop :
	cmp eax, 0xb9000
		je TextMode.clearScreen.ret
	mov dword [eax], 0x0
	add eax, 4
	jmp TextMode.clearScreen.loop
TextMode.clearScreen.ret :
popa
ret

DebugLogEAX :
pusha
	mov ecx, DebugStringStor
	mov dword [ecx], 0x0
	add ecx, 4
	mov dword [ecx], 0x0
	mov ebx, eax
	mov eax, DebugStringStor
	call String.fromHex
	;mov ebx, eax
	;call String.copyColorToRaw
	;call TextMode.clearScreen
	call TextMode.print
popa
ret

TextMode.scroll :
pusha
	mov ecx, [TextMode.charpos]
	cmp ecx, 0xb8ec0	; should be less than b9000!
		jle TextMode.scroll.ret
;	call TextMode.clearScreen
	;mov esi, 0xb9000
	;mov edx, 0xb8000
	;mov ecx, 0x1000
	;rep movsb
	sub ecx, 0xA0
	mov [TextMode.charpos], ecx
	mov eax, 0xb80A0
	mov ebx, 0xb8000
	mov ecx, 0x1000
	mov edx, 1
	call Image.copyLinear
TextMode.scroll.ret :
popa
ret

TextMode.charpos :
	dd 0xb8000
DebugStringStor :
	dd 0x0, 0x0, 0x0, 0x0, 0x0