Graphics.setVGApalette :
pusha
	mov dx, 0x3c6	; setting palette mask, unneeded on bochs
	mov al, 0xff
	out dx, al
	mov dx, 0x3c8
	out dx, al

mov dx, 0x3c8
mov al, 0x0
out dx, al	; we are starting with index 0


Graphics.setVGApalette.loop1 :
mov dx, 0x3c9
mov ebx, Graphics.tColor
mov ax, [ebx]
out dx, al	; red
add ebx, 2
mov ax, [ebx]
out dx, al	; green
add ebx, 2
mov ax, [ebx]
out dx, al	; blue
add ebx, 2

mov ebx, Graphics.tColor
mov cx, [ebx]	; r
add cx, 21
mov [ebx], cx
cmp cx, 64
jle Graphics.setVGApalette.cont
mov cx, 0x0
mov [ebx], cx
add ebx, 2
mov cx, [ebx]	; g
add cx, 21
mov [ebx], cx
cmp cx, 64
jle Graphics.setVGApalette.cont
mov cx, 0x0
mov [ebx], cx
add ebx, 2
mov cx, [ebx]	; b
add cx, 21
mov [ebx], cx
Graphics.setVGApalette.cont :
cmp cx, 64
jle Graphics.setVGApalette.loop1
popa
ret

Graphics.setGrayscalePalette :
pusha
mov ax, [0x1000]
cmp ax, 0xF
jne Graphics.setGrayscalePalette2
Graphics.setGrayscalePalette.go :
mov dx, 0x3c8
mov al, 0x0
out dx, al	; we are starting with index 0
mov ax, 0x0
mov dx, 0x3c9
Graphics.setGrayscalePalette.loop1 :
out dx, al
out dx, al
out dx, al
add ax, 1
cmp ax, 255
jle Graphics.setGrayscalePalette.loop1
popa
ret

Graphics.setGrayscalePalette2 :	; no longer needed, remove
;mov ah, 0x1f
;call debug.useFallbackColor
mov ebx, Graphics.PALETTE_NODEFAULT
call debug.log.info

	mov dx, 0x3c6	; setting palette mask, unneeded on bochs
	mov al, 0xff
	out dx, al
	mov dx, 0x3c8
	out dx, al
	
	jmp Graphics.setGrayscalePalette.go
popa
ret

Graphics.doVESAtest :
pusha
mov eax, [Graphics.SCREEN_MEMPOS]
mov ebx, 0x000000
xor edx, edx
Graphics.VESAloop :
call Graphics.doVESAtest.sub
add ebx, 0x1
add edx, 0x1
cmp edx, [Graphics.SCREEN_HEIGHT]
jle Graphics.VESAloop
popa
ret
Graphics.doVESAtest.sub :
	xor ecx, ecx
	Graphics.doVESAtest.loop :
	mov [eax], ebx
	add eax, 4
	;cmp ecx, 0x250
	;	jle Graphics.doVESAtest.skip
	;mov ebx, 0xFFFFFF
	;Graphics.doVESAtest.skip :
	add ecx, 1
	cmp ecx, [Graphics.SCREEN_WIDTH]
		jl Graphics.doVESAtest.loop
	ret

Graphics.init :
	;cmp dword [DisplayMode], MODE_TEXT
	;	je Graphics.init.ret
	pusha
	;mov ebx, Graphics.VESA_SUPPORTED_MSG
	;call debug.print
	;xor ebx, ebx
	;mov bx, [Graphics.VESA_SUPPORTED]
	;call debug.num
	;call debug.newl
	;cmp bx, 0xff
	;jne ccacont
							;jmp ccacont	; if left uncommented (ALONG WITH THE OTHER LINE), disable VESA mode.
	xor ebx, ebx
	mov bx, [VESA_CLOSEST_XRES]
	mov [Graphics.SCREEN_REALWIDTH], ebx
	imul ebx, 4	; should not be hardcoded
	mov [Graphics.SCREEN_WIDTH], ebx
	xor ebx, ebx
	mov bx, [VESA_CLOSEST_YRES]
	mov [Graphics.SCREEN_HEIGHT], ebx
	mov ecx, [Graphics.SCREEN_WIDTH]
	imul ebx, ecx
	imul ebx, 4	;bpp, should not be hardcoded >8|
	mov [Graphics.SCREEN_SIZE], ebx
	mov ebx, [VESA_CLOSEST_BUFFERLOC]
	mov [Graphics.SCREEN_MEMPOS], ebx
	mov bl, 1	; this needs to be a word...
	mov [Graphics.VESA_MODE], bl
	mov ebx, 0x4	; and this also should NOT be hardcoded
	mov [Graphics.bytesPerPixel], ebx
	call Graphics.grabCardName
	;popa
	;ret
	ccacont :
		call Graphics.setGrayscalePalette
		call Graphics.setVGApalette
	popa
	Graphics.init.ret :
	ret
	
Graphics.grabCardName :
	pusha
		mov ax, [0x2006]
		mov bx, [0x2008]
		and ebx, 0xFFFF
		and eax, 0xFFFF
		imul ebx, 0x10
		add eax, ebx
		mov ebx, eax
		mov [Graphics.CARDNAME], ebx
	popa
	ret
	
Graphics.printModeInfo :
	pusha
		
		mov eax, [0x2000]
		mov [VESA_TAG], eax
		mov ebx, VESA_TAGMSG
		call console.print
		mov ebx, VESA_TAG
		call console.println
		
		mov ax, [0x2004]
		and eax, 0xFFFF
		mov ebx, VESA_VER
		call console.print
		call DebugLogEAX
		call console.newline
		
		mov ebx, VESA_OEMMSG
		call console.print
		mov ebx, [Graphics.CARDNAME]
		call console.println
		
		mov ax, [0x200E]
		mov bx, [0x2010]
		and ebx, 0xFFFF
		and eax, 0xFFFF
		imul ebx, 0x1000
		add eax, ebx
		Txmlp_0.qo :
		mov bx, [eax]
		add eax, 2
		add ecx, 1
		cmp bx, 0xFFFF
			jne Txmlp_0.qo
		
		mov eax, ecx
		mov ebx, VESA_VMODENUMMSG
		call console.print
		call DebugLogEAX
		call console.newline
		
		mov ebx, VESA_CLOSEST_MATCHMSG
		call console.print
		xor eax, eax
		mov ax, [VESA_CLOSEST_MATCH]
		call DebugLogEAX
		call console.newline
		
		mov ebx, VESA_CLOSEST_RESMSG
		call console.print
		
		xor eax, eax
		mov ax, [VESA_CLOSEST_XRES]
		call DebugLogEAX
		
		mov ebx, VESA_CLOSEST_RESDIV
		call console.print
		
		xor eax, eax
		mov ax, [VESA_CLOSEST_YRES]
		call DebugLogEAX
		
		mov ebx, VESA_CLOSEST_BPPMSG
		call console.print
		
		xor eax, eax
		mov ax, [VESA_CLOSEST_BPP]
		call DebugLogEAX
		call console.newline
		
		mov ebx, VESA_CLOSEST_BUFFERLOCMSG
		call console.print
		mov eax, [VESA_CLOSEST_BUFFERLOC]
		call DebugLogEAX
		call console.newline
	popa
	ret
	

Graphics.PALETTE_NODEFAULT :
db "Applying patch to palette...", 0
	
Graphics.VESA_SUPPORTED_MSG :
db "VESA Support: ", 0x0

VESA_OEMMSG :
	db "OEM String: ", 0x0
	
VESA_VER :
	db "VESA Version: ", 0x0

VESA_TAGMSG :
	db "VESA Signature: ", 0x0

VESA_TAG :
	dd 0x0, 0x0

VESA_VMODENUMMSG :
	db "Modes Available: 0x", 0x0

VESA_CLOSEST_RESMSG :
	db "    Resolution: ", 0x0

VESA_CLOSEST_RESDIV :
	db "x", 0x0

VESA_CLOSEST_MATCHMSG :
	db "Found mode: ", 0x0

VESA_CLOSEST_BPPMSG :
	db ", bpp = ", 0x0

VESA_CLOSEST_BUFFERLOCMSG :
	db "    Buffer position: ", 0x0

Graphics.VESA_VER equ 0x2004	; word

Graphics.VESA_SUPPORTED :
dw 0x4d

Graphics.VESA_MODE :
dd 0x0

Graphics.CARDNAME :
dd 0x0

Graphics.tColor :
dd 0x0, 0x0, 0x0, 0x0

Graphics.SCREEN_MEMPOS :
dd 0xa0000

Graphics.SCREEN_WIDTH :
dd 0x140

Graphics.SCREEN_REALWIDTH :
dd 0x140

Graphics.SCREEN_HEIGHT :
dd 0xc0

Graphics.SCREEN_SIZE :
dd 0xf800

