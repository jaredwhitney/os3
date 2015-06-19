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
	pusha
	mov ebx, Graphics.VESA_SUPPORTED_MSG
	call debug.print
	xor ebx, ebx
	mov bx, [Graphics.VESA_SUPPORTED]
	call debug.num
	call debug.newl
	cmp bx, 0xff
	jne ccacont
							;jmp ccacont	; if left uncommented (ALONG WITH THE OTHER LINE), disable VESA mode.
	mov ebx, 0x500*0x4
	mov [Graphics.SCREEN_WIDTH], ebx
	mov ebx, 0x400;*0x4
	mov [Graphics.SCREEN_HEIGHT], ebx
	mov ebx, 0x140000*0x4
	mov [Graphics.SCREEN_SIZE], ebx
	mov ebx, [0x80000+40]
	mov [Graphics.SCREEN_MEMPOS], ebx
	mov bl, 1
	mov [Graphics.VESA_MODE], bl
	mov ebx, 0x4
	mov [Graphics.bytesPerPixel], ebx
	popa
	ret
	ccacont :
		call Graphics.setGrayscalePalette
		call Graphics.setVGApalette
	popa
	ret

Graphics.PALETTE_NODEFAULT :
db "Applying patch to palette...", 0
	
Graphics.VESA_SUPPORTED_MSG :
db "VESA Support: ", 0x0

Graphics.VESA_SUPPORTED :
dw 0x4d

Graphics.VESA_MODE :
db 0x0

Graphics.tColor :
dd 0x0, 0x0, 0x0, 0x0

Graphics.SCREEN_MEMPOS :
dd 0xa0000

Graphics.SCREEN_WIDTH :
dd 0x140

Graphics.SCREEN_HEIGHT :
dd 0xc0

Graphics.SCREEN_SIZE :
dd 0xf800

