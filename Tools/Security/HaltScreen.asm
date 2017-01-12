SysHaltScreen.WARN	equ 0x1
SysHaltScreen.KILL	equ 0x2
SysHaltScreen.RESET	equ 0x3

SysHaltScreen.show :	; warn type in eax, message in ebx, timeout in ecx (if applicable)
methodTraceEnter
pusha
mov ebp, esp
mov byte [INTERRUPT_DISABLE], 0xFF
	
	mov [SHS.wtyp], eax
	mov [SHS.ss], ebx
	mov [SHS.tout], ecx
	
	mov ecx, [Graphics.SCREEN_MEMPOS]	; only actually needed on the first run
	mov [SHS.rl], ecx
	
		mov eax, [Graphics.SCREEN_MEMPOS]
		mov edx, [Graphics.SCREEN_SIZE]
		mov ebx, 0xFF0000
		cmp dword [SHS.wtyp], SysHaltScreen.KILL
			jne .noModifyBgColor
		mov ebx, 0x600000
		.noModifyBgColor :
		call Image.clear
	
	call SysHaltScreen.printMainMessage
	mov ecx, 0x0
	cmp dword [SHS.wtyp], SysHaltScreen.KILL
		je .noCountDown
	.timeout_loop :
		call SysHaltScreen.printCountdown
		mov eax, 5000
		call System.sleep
		inc ecx
		cmp ecx, [SHS.tout]
			jl .timeout_loop
	.noCountDown :
	cmp dword [SHS.wtyp], SysHaltScreen.WARN	; if warn
		je SysHaltScreen.show.ret
	cmp dword [SHS.wtyp], SysHaltScreen.RESET	; if reset
		je ps2.resetCPU
	
	call SysHaltScreen.printStackTrace
	
	cli	; if kill (or unspecified)
	hlt
SysHaltScreen.show.ret :
mov byte [INTERRUPT_DISABLE], 0x00
popa
methodTraceLeave
ret

SysHaltScreen.printMainMessage :
methodTraceEnter
pusha
	mov dword [TextHandler.textSizeMultiplier], 3
		mov eax, [Graphics.SCREEN_HEIGHT]
		mov ecx, 3
		xor edx, edx
		idiv ecx
		mov ebx, [Graphics.SCREEN_WIDTH]
		imul eax, ebx
		mov ebx, eax
		mov eax, [Graphics.SCREEN_WIDTH]
		mov ecx, 2
		xor edx, edx
		idiv ecx
		add eax, ebx
		mov ebx, [SHS.ss]
		call getCenteredString
		sub eax, ebx
		add eax, [Graphics.SCREEN_MEMPOS]
	mov ebx, [SHS.ss]
	mov dword [TextHandler.selectedColor], 0xFFFFFF
	cmp dword [SHS.wtyp], SysHaltScreen.KILL
		jne .noModifyMessageColor
	mov dword [TextHandler.selectedColor], 0x606060
	.noModifyMessageColor :
	call drawStringDirect
	mov dword [TextHandler.textSizeMultiplier], 1
popa
methodTraceLeave
ret

SysHaltScreen.printCountdown :
methodTraceEnter
pusha
	mov eax, SHS.cdown	; string to store things in
	mov ebx, [SHS.tout]
	sub ebx, ecx	; countdown number
	call Number.hexToBCD
	call String.fromHex
	
	mov eax, [Graphics.SCREEN_WIDTH]
	mov [Image.clearRegion.imagewidth], eax
	mov eax, [SHS.rl]
	mov ebx, [SHS.rw]
	mov ecx, [SHS.rh]
	mov edx, 0xFF0000
	call Image.clearRegion
	
	mov dword [TextHandler.textSizeMultiplier], 4
		mov eax, [Graphics.SCREEN_HEIGHT]
		mov ecx, 3
		xor edx, edx
		idiv ecx
		imul eax, 2	; 2/3 way down the screen
		mov ebx, [Graphics.SCREEN_WIDTH]
		imul eax, ebx
		mov ebx, eax
		mov eax, [Graphics.SCREEN_WIDTH]
		mov ecx, 2
		xor edx, edx
		idiv ecx
		add eax, ebx
		mov ebx, SHS.cdown
		call getCenteredString
		sub eax, ebx
		add eax, [Graphics.SCREEN_MEMPOS]
				mov [SHS.rl], eax
	mov ebx, SHS.cdown
	mov cl, WHITE
	call drawStringDirect
	
	call SysHaltScreen.saveRegionDimensions
	
	mov dword [TextHandler.textSizeMultiplier], 1
popa
methodTraceLeave
ret

SysHaltScreen.saveRegionDimensions :
methodTraceEnter
pusha
	mov ebx, SHS.cdown
	call String.getLength
	mov eax, edx
	imul eax, 5
	imul eax, [TextHandler.textSizeMultiplier]
	imul eax, [Graphics.bytesPerPixel]
	mov [SHS.rw], eax
	
	mov eax, 7
	imul eax, [TextHandler.textSizeMultiplier]
	mov [SHS.rh], eax
popa
methodTraceLeave
ret

SysHaltScreen.printStackTrace :
methodTraceEnter
pusha

	mov ecx, FONTHEIGHT+2
	imul ecx, [Graphics.SCREEN_WIDTH]
	mov edx, [Debug.methodTraceStack]
	mov eax, [Debug.methodTraceStackBase]
	mov [.end], eax
	cmp byte [IN_INT_CALL], false
		je .cont
	mov edx, [Debug.methodTraceStack2]
	mov eax, [Debug.methodTraceStackBase2]
	mov [.end], eax
	.cont :
	sub edx, 4
	mov eax, [Graphics.SCREEN_MEMPOS]
	
	.loop :
	
	push eax
	mov eax, SHS.trace
	mov ebx, [edx]
	mov [.istor], ebx
	call String.fromHex
	pop eax
	
	mov ebx, SHS.trace
	mov dword [TextHandler.selectedColor], 0xFFFFFF
	call drawStringDirect
	
	pusha
	mov ecx, [Graphics.SCREEN_WIDTH]
	shr ecx, 1
	add eax, ecx
	mov ebx, Debug.methodTraceLookupTable
	mov edx, [.istor]
	.lookuploop :
	cmp dword [ebx], edx
		ja .foundMatch
	add ebx, 8
	jmp .lookuploop
	.foundMatch :
	sub ebx, 4
	mov ebx, [ebx]
	mov dword [TextHandler.selectedColor], 0xF0F0F0
	call drawStringDirect
	popa
	
	
	add eax, ecx
	sub edx, 4
	
	cmp edx, [.end]
		jae .loop
	
	cmp byte [IN_INT_CALL], false
		je .cont2
	mov ebx, .ihandlers1
	mov dword [TextHandler.selectedColor], 0xB0F0B0
	call drawStringDirect
	mov ecx, [Graphics.SCREEN_WIDTH]
	shr ecx, 1
	add eax, ecx
	mov ebx, .ihandlers2
	call drawStringDirect
	.cont2 :
popa
methodTraceLeave
ret
.istor :
	dd 0x0
.end :
	dd 0x0
.ihandlers1 :
	db "------", 0
.ihandlers2 :
	db "<System Interrupt>", 0

SHS.ss :
	dd 0x0
SHS.tout :
	dd 0x0
SHS.wtyp :
	dd 0x0
SHS.cdown :
	dq 0x0
SHS.trace :
	times 20 dq 0x0
SHS.rl :
	dd 0x0
SHS.rw :
	dd 0x1
SHS.rh :
	dd 0x1
