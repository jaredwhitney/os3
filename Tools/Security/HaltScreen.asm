SysHaltScreen.WARN	equ 0x1
SysHaltScreen.KILL	equ 0x2
SysHaltScreen.RESET	equ 0x3

SysHaltScreen.show :	; warn type in eax, message in ebx, timeout in ecx (if applicable)
pusha
mov byte [INTERRUPT_DISABLE], 0xFF

	;
	;pusha
	;mov ah, 0xFF
	;call console.println
	;popa
	;
	
	mov [SHS.wtyp], eax
	mov [SHS.ss], ebx
	mov [SHS.tout], ecx
	
	mov ecx, [Graphics.SCREEN_MEMPOS]	; only actually needed on the first run
	mov [SHS.rl], ecx
	
		mov eax, [Graphics.SCREEN_MEMPOS]
		mov edx, [Graphics.SCREEN_SIZE]
		mov ebx, 0xFF0000
		call Image.clear
	
	mov ecx, 0x0
	SysHaltScreen.timeout_loop :
		call SysHaltScreen.printCountdown
		call SysHaltScreen.printMainMessage
		mov eax, 5000
		call System.sleep
		add ecx, 1
		cmp ecx, [SHS.tout]
			jl SysHaltScreen.timeout_loop
	cmp dword [SHS.wtyp], SysHaltScreen.WARN	; if warn
		je SysHaltScreen.show.ret
	cmp dword [SHS.wtyp], SysHaltScreen.RESET	; if reset
		je ps2.resetCPU
	cli	; if kill (or unspecified)
	hlt
SysHaltScreen.show.ret :
mov byte [INTERRUPT_DISABLE], 0x00
popa
ret

SysHaltScreen.printMainMessage :
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
	mov cl, WHITE
	call drawStringDirect
	mov dword [TextHandler.textSizeMultiplier], 1
popa
	ret

SysHaltScreen.printCountdown :
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
ret

SysHaltScreen.saveRegionDimensions :
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
ret

SHS.ss :
	dd 0x0
SHS.tout :
	dd 0x0
SHS.wtyp :
	dd 0x0
SHS.cdown :
	dq 0x0
SHS.rl :
	dd 0x0
SHS.rw :
	dd 0x1
SHS.rh :
	dd 0x1
