[bits 32]
SCREEN_BUFFER	equ 0xA20000
SCREEN_WIDTH	equ 0x140
SCREEN_HEIGHT	equ 0xc8
Dolphin.init :
	; whatever needs to be done here

Dolphin.create :	; bl contains PNUM
push eax
mov al, bl
mov ah, 0x7D	; Window buffer
call Guppy.malloc
mov ecx, ebx
mov ah, 0x7D	; text/image buffer
call Guppy.malloc
pop eax
ret	; returns buffer locations in ebx, ecx

Dolphin.copyImage :	; eax = source, ebx = dest, cx = width, dx = height
	pusha
	mov [bstor], ebx
	Dolphin.wupdate.loop0 :
		push cx
		Dolphin.wupdate.loop1 :
			push eax
			mov al, [eax]
			mov [ebx], al
			pop eax
			add ebx, 1
			add eax, 1
			sub cx, 1
			cmp cx, 0
				jg Dolphin.wupdate.loop1
			pop cx
			sub dx, 1

			push eax
			push ecx
			push edx
			mov eax, ebx
			sub eax, [bstor]
			mov ecx, 0x140
			push eax
			mov edx, 0x0
			div ecx
			pop eax
			cmp edx, 0
				je Debug.wupdate.noadd
			mov ecx, 0x140
			sub ecx, edx
			mov edx, ecx
			add eax, edx	; edx = remainder
		Debug.wupdate.noadd :
			add eax, [bstor]
			mov ebx, eax
			pop edx
			pop ecx
			pop eax
			cmp dx, 0
				jg Dolphin.wupdate.loop0
	popa
	ret
	
Dolphin.copyImageLinear :	; eax = source, ebx = dest, ecx = width, edx = height
	pusha
	imul ecx, edx
	Dolphin.copyImageLinear_loop :
	mov dl, [eax]
	mov [ebx], dl
	add eax, 1
	add ebx, 1
	sub ecx, 1
	cmp ecx, 0x0
	jge Dolphin.copyImageLinear_loop
	popa
	ret
	
Dolphin.clearImage :	; eax = source, ecx = width, edx = height, bl = color
	pusha
	and ecx, 0xFFFF
	and edx, 0xFFFF
	imul ecx, edx
	sub ecx, 1
	mov edx, 0x0
	Dolphin.clearImage_loop :
	mov [eax], bl
	add eax, 1
	add edx, 1
	cmp edx, ecx
	jle Dolphin.clearImage_loop
	popa
	ret

Dolphin.drawText :	; eax = text buffer, ebx = dest, cx = width, edx = bufferSize
	pusha
	mov [os.textwidth], cx
		pusha
		mov eax, ebx
		call Dolphin.clearImage
		popa
	mov ecx, [charpos]
	mov [bstor], ebx
	mov [debug.charpos.stor], ecx
	mov ecx, ebx	; dest buffer
	call Dolphin.checkCharLine
	mov [charpos], ecx
	mov ebx, eax	; src buffer
	mov ah, 255
	mov [Dolphin.bsizstor], edx
	mov edx, 0x0
	Dolphin.drawText_loop :
		mov ax, [ebx]
		push ebx
		mov ebx, [Dolphin.bsizstor]
		;call debug.num
		cmp edx, 0x4000	; size of buffer
		pop ebx
			jg Dolphin.drawText_ret
		add edx, 1
		cmp al, 0x0
			je Dolphin.drawText.nodraw
		cmp al, 0xA0
			je Dolphin.drawText.newl
			push bx
			mov bl, [Dolphin.colorOverride]
			cmp bl, 0
			je Dolphin.drawText_noOverride1
			mov ah, bl
			Dolphin.drawText_noOverride1 :
			pop bx
		call graphics.drawChar
		mov ecx, [charpos]
			push ebx
			xor ebx, ebx
			mov bx, [os.textwidth]
			imul ebx, 2
			add ecx, ebx
			;add ecx, 0xa0*2
			pop ebx
		Dolphin.drawText.doCheck :
		call Dolphin.checkCharLine	; EXPERIMENTAL!!!
		mov [charpos], ecx
		jmp Dolphin.drawText.cont1
		Dolphin.drawText.nodraw :
			push ecx
			mov ecx, [charpos]
			add ecx, 6
			mov [charpos], ecx
			pop ecx
		Dolphin.drawText.cont1 :
			add ebx, 0x1
				push ax
				mov al, [Dolphin.colorOverride]
				cmp al, 0
				jne Dolphin.drawText_noOverride2
				add ebx, 0x1
				Dolphin.drawText_noOverride2 :
				pop ax
			jmp Dolphin.drawText_loop
	Dolphin.drawText_ret :
	mov ecx, [debug.charpos.stor]
	mov [charpos], ecx
	popa
	ret
	
	Dolphin.drawText.newl :	; move one space down, checkCharLine will move to the next line
	push edx
	mov ecx, [charpos]
	mov edx, SCREEN_WIDTH
	add ecx, edx
	mov [charpos], ecx
	pop edx
	jmp Dolphin.drawText.doCheck
	
	Dolphin.checkCharLine :	; charpos in ecx, width in os.textwidth, buffer loc in bstor
	push eax
	push ebx
	push edx
		mov eax, [bstor]
		sub ecx, eax
		push eax
		push ecx
		add ecx, 6
		mov eax, ecx
		xor ebx, ebx
		mov bx, [os.textwidth]
		xor edx, edx
		div ebx	; eax now contains the line number
		
		mov ecx, 9
		xor edx, edx
		idiv ecx
		
		cmp edx, 0x0
		je Dolphin.checkCharLine.kret
		; if the line is invalid :
		mov ecx, edx	; ecx now contains the remainder, if non 0 the line is invalid
		add eax, 1	; eax contains last valid line
		xor edx, edx
		imul eax, 9	; should be 8
		
		xor ecx, ecx
		mov cx, [os.textwidth]
		xor edx, edx
		imul eax, ecx
			mov ebx, eax
		pop ecx
		pop eax
			mov ecx, ebx
			add ecx, eax
		;sub ecx, 6
		;push ecx
		;	mov eax, ecx
			;xor ecx, ecx
			;mov cx, [os.textwidth]
			;idiv ecx
			;cmp edx, 0x8
			;pop ecx
			;jge noreadd
			;add ecx, 6
		noreadd :
		jmp Dolphin.checkCharLine.ret
		
		Dolphin.checkCharLine.kret :
		pop ecx
		pop eax
		add ecx, eax
	Dolphin.checkCharLine.ret :
	pop edx
	pop ebx
	pop eax
	ret
	
	

Dolphin.drawBorder :	; ebx = image buffer, cx = width, dx = height
pusha
and ecx, 0xFFFF
push ecx
mov al, 0x03	; red
	push ebx
	mov bl, [Dolphin.activeWindow]
	mov bh, [currentWindow]
	cmp bl, bh
	jne Dolphin.drawBorder.nonactive
	mov al, 0x3d	; light blue
	Dolphin.drawBorder.nonactive :
	pop ebx
push ebx
Dolphin.drawBorder.loop1 :
mov [ebx], al
add ebx, 0x1
sub cx, 0x1
cmp cx, 0x0
jg Dolphin.drawBorder.loop1
mov [ebx], al
pop ebx
pop ecx
Dolphin.drawBorder.loop2 :
mov [ebx], al
add ebx, ecx
sub dx, 0x1
cmp dx, 0x0
jg Dolphin.drawBorder.loop2
mov [ebx], al

popa
ret

Dolphin.clear :
pusha
imul ecx, 8
imul edx, 8
mov al, 0x4A	; dark gray
Dolphin.clear.loop0 :
push ecx
Dolphin.clear.loop1 :
mov [ebx], al
add ebx, 1
sub ecx, 1
cmp ecx, 0x0
jg Dolphin.clear.loop1
pop ecx
sub ebx, ecx
add ebx, 0x140
sub edx, 1
cmp edx, 0
jg Dolphin.clear.loop0
popa
ret

Dolphin.redrawBG :
push ebx
mov ebx, [bglocstor]
call Dolphin.makeBG
pop ebx
ret

Dolphin.makeBG :	; ebx contains location of data
pusha
mov [bglocstor], ebx
cmp ebx, 0x0
je Dolphin.solidBG
mov eax, ebx
mov ebx, SCREEN_BUFFER
mov ecx, SCREEN_WIDTH
mov edx, SCREEN_HEIGHT
call Dolphin.copyImage
Dolphin.makeBG.ret :
popa
ret

Dolphin.solidBG :
mov eax, SCREEN_BUFFER
mov ecx, SCREEN_WIDTH
mov edx, SCREEN_HEIGHT
mov bl, 0x10
call Dolphin.clearImage
popa
ret

Dolphin.setVGApalette :
pusha
	mov dx, 0x3c6	; setting palette mask, unneeded on bochs
	mov al, 0xff
	out dx, al
	mov dx, 0x3c8
	out dx, al

;mov ax, [0x1000]
;cmp ax, 0xF
;jne Dolphin.setGrayscalePalette2
mov dx, 0x3c8
mov al, 0x0
out dx, al	; we are starting with index 0

;mov dx, 0x0	; red
;mov cx, 0x0	; blue
;mov bx, 0x0	; green
;mov ax, 0x0


Dolphin.setVGApalette.loop1 :
;mov ax, dx
;push dx	; pushing dx breaks things!
mov dx, 0x3c9
mov ebx, Dolphin.tColor
mov ax, [ebx]
out dx, al	; red
add ebx, 2
mov ax, [ebx]
out dx, al	; green
add ebx, 2
mov ax, [ebx]
out dx, al	; blue
add ebx, 2

mov ebx, Dolphin.tColor
mov cx, [ebx]	; r
add cx, 21
mov [ebx], cx
cmp cx, 64
jle Dolphin.setVGApalette.cont
mov cx, 0x0
mov [ebx], cx
add ebx, 2
mov cx, [ebx]	; g
add cx, 21
mov [ebx], cx
cmp cx, 64
jle Dolphin.setVGApalette.cont
mov cx, 0x0
mov [ebx], cx
add ebx, 2
mov cx, [ebx]	; b
add cx, 21
mov [ebx], cx
Dolphin.setVGApalette.cont :
cmp cx, 64
jle Dolphin.setVGApalette.loop1
popa
ret

Dolphin.setGrayscalePalette :
pusha
mov ax, [0x1000]
cmp ax, 0xF
jne Dolphin.setGrayscalePalette2	; should be jne, swapped for testing
Dolphin.setGrayscalePalette.go :
mov dx, 0x3c8
mov al, 0x0
out dx, al	; we are starting with index 0
mov ax, 0x0
mov dx, 0x3c9
Dolphin.setGrayscalePalette.loop1 :
out dx, al
out dx, al
out dx, al
add ax, 1
cmp ax, 255
jle Dolphin.setGrayscalePalette.loop1
popa
ret

Dolphin.setGrayscalePalette2 :
;mov ah, 0x1f
;call debug.useFallbackColor
mov ebx, PALETTE_NODEFAULT
call debug.log.info

	mov dx, 0x3c6	; setting palette mask, unneeded on bochs
	mov al, 0xff
	out dx, al
	mov dx, 0x3c8
	out dx, al
	
	jmp Dolphin.setGrayscalePalette.go
	; some alternate code should go here!
	
	
popa
ret

Dolphin.updateScreen :
pusha
call Dolphin.redrawBG
;
;	Draw windows in here!
		mov ebx, 0x0
		Dolphin.updateScreen.checkWindow :
			call Dolphin.windowExists
			cmp ebx, 0xF*4	; num of windows * 4 bytes per windowStruct location
			je Dolphin.doneDrawingWindows
			cmp eax, 0x0
			add ebx, 4
				je Dolphin.updateScreen.checkWindow
		push ebx
		sub ebx, 4
		
		mov [currentWindow], ebx
	
		mov bl, [Dolphin.WIDTH]
		call Dolphin.getAttribute
		mov [atwstor], ax
		
		mov bl, [Dolphin.HEIGHT]
		call Dolphin.getAttribute
		mov [atwstor2], ax
		
		call Dolphin.getWindowBuffer	; mov eax, windowBuffer
		mov ecx, [atwstor]
		mov edx, [atwstor2]
			pusha
			mov ebx, eax
			call Dolphin.drawBorder
			popa
		mov ebx, SCREEN_BUFFER
		
		push eax
		xor eax, eax
		push bx
		mov bl, [Dolphin.Y_POS]
		call Dolphin.getAttribute
		pop bx
		imul eax, SCREEN_WIDTH
		add ebx, eax	; add ypos
		push bx
		mov bl, [Dolphin.X_POS]
		call Dolphin.getAttribute
		pop bx
		add ebx, eax
		pop eax
		
		call Dolphin.copyImage
		
		pop ebx
		jmp Dolphin.updateScreen.checkWindow
Dolphin.doneDrawingWindows :
;
call debug.update	; ensuring that debug information stays updated and 'on top'
mov eax, SCREEN_BUFFER
mov ebx, 0xa0000
mov ecx, SCREEN_WIDTH
mov edx, SCREEN_HEIGHT
call Dolphin.copyImage
popa
ret

Dolphin.windowExists :	; windowNum in ebx, returns either 0x0 or 0xF (F|T) in eax
push ebx
add ebx, Dolphin.windowStructs
mov eax, [ebx]
pop ebx
cmp eax, 0x0
je Dolphin.windowExists.false
mov eax, 0xF
ret
Dolphin.windowExists.false :
mov eax, 0x0
ret

Dolphin.activateNext :	; activates the next window in the list
pusha
xor ebx, ebx
mov bl, [Dolphin.activeWindow]
	Dolphin.activeNext.loop :
	add bl, 1
	cmp bl, 0x10
		jl Dolphin.activateNext.cont_1
	mov bl, 0x0
	Dolphin.activateNext.cont_1 :
	call Dolphin.windowExists
	cmp eax, 0x0
	je Dolphin.activeNext.loop
	mov [Dolphin.activeWindow], bl
popa
ret

Dolphin.toggleColored :
pusha
mov eax, [Dolphin.tuskip]
cmp eax, 0x2
je Dolphin.toggleColored.toNonColored
mov eax, 0x2
mov [Dolphin.tuskip], eax
mov al, 0x0
mov [Dolphin.colorOverride], al
jmp Dolphin.toggleColored.ret
Dolphin.toggleColored.toNonColored :
mov eax, 0x1
mov [Dolphin.tuskip], eax
mov al, 0xFF
mov [Dolphin.colorOverride], al
Dolphin.toggleColored.ret :
popa
ret

Dolphin.registerWindow :	; bl = pnum, eax = pointer to windowStruct; returns bl contains windowNum
push ecx
push edx
mov edx, Dolphin.windowStructs
Dolphin.registerWindow.loop1 :
mov ecx, [edx]
add edx, 4
cmp ecx, 0x0
jne Dolphin.registerWindow.loop1
sub edx, 4
mov [edx], eax
sub edx, Dolphin.windowStructs
mov ebx, edx
and ebx, 0xFF
mov [Dolphin.activeWindow], bl
pop edx
pop ecx
ret

Dolphin.getWindowBuffer :	; returns eax = buffer location
push edx
push ecx
push ebx
mov eax, [currentWindow]
add eax, Dolphin.windowStructs
mov eax, [eax]
add eax, 26
mov eax, [eax]
pop ebx
pop ecx
pop edx
ret

Dolphin.getAttribute :	; attribute num in bl, returns attribute data in eax
push ecx
push ebx
xor eax, eax
mov ecx, [currentWindow]
add ecx, Dolphin.windowStructs
mov ecx, [ecx]
and ebx, 0xFF
add ecx, ebx
cmp bl, 16
jl Dolphin.getAttribute.load2xDouble
cmp bl, 24
jl Dolphin.getAttribute.loadWord
mov al, [ecx]
jmp Dolphin.getAttribute.done
Dolphin.getAttribute.loadWord :
mov ax, [ecx]
jmp Dolphin.getAttribute.done
Dolphin.getAttribute.load2xDouble :
mov eax, ecx
Dolphin.getAttribute.done :
pop ebx
pop ecx
ret

Dolphin.setAttribute :	; attribute num in bl, attribute data in eax
	pusha
	mov ecx, [currentWindow]
	add ecx, Dolphin.windowStructs
	mov ecx, [ecx]
	and ebx, 0xFF
	add ecx, ebx
	cmp bl, 16
	jl Dolphin.setAttribute.read2xDouble
	cmp bl, 24
	jl Dolphin.setAttribute.readWord
	cmp bl, 26
	jge Dolphin.setAttribute.readDouble
	mov [ecx], al
	jmp Dolphin.setAttribute.done
	Dolphin.setAttribute.readWord :
	mov [ecx], ax
	jmp Dolphin.setAttribute.done
	Dolphin.setAttribute.readDouble :
	mov [ecx], eax
	jmp Dolphin.setAttribute.done
	Dolphin.setAttribute.read2xDouble :
	;mov eax, ecx	; currently unimplemented.
	Dolphin.setAttribute.done :
	popa
	ret

Dolphin.unregisterWindow :	; winNum in bl
pusha
mov ecx, 0x0
and ebx, 0xFF
mov eax, Dolphin.windowStructs
add eax, ebx
mov [eax], ecx
mov ebx, UNREG_MSG
call debug.log.system
call Dolphin.activateNext
popa
ret

Dolphin.moveWindow :	; xchange in eax, y change in ebx
pusha
mov edx, eax
mov ecx, ebx
mov bh, [Dolphin.activeWindow]
mov [currentWindow], bh

mov bl, [Dolphin.X_POS]
call Dolphin.getAttribute
add eax, edx
call Dolphin.setAttribute

mov bl, [Dolphin.Y_POS]
call Dolphin.getAttribute
add eax, ecx
call Dolphin.setAttribute
popa
ret

Dolphin.moveWindowAbsolutte :	; x in eax, y in ebx
pusha
mov ecx, ebx
mov bh, [Dolphin.activeWindow]
mov [currentWindow], bh

mov bl, [Dolphin.X_POS]
call Dolphin.setAttribute

mov eax, ecx
mov bl, [Dolphin.Y_POS]
call Dolphin.setAttribute

popa
ret

Dolphin.sizeWindow :	; xchange in eax, y change in ebx
pusha
mov edx, eax
mov ecx, ebx
mov bh, [Dolphin.activeWindow]
mov [currentWindow], bh
pusha
mov bl, [Dolphin.WIDTH]
call Dolphin.getAttribute
add eax, edx
call Dolphin.setAttribute
popa
mov bl, [Dolphin.HEIGHT]
call Dolphin.getAttribute
add eax, ecx
call Dolphin.setAttribute
popa
ret

;Dolphin.newWindow :	; windowStruct in eax, pnum in bl, returns winNum
;pusha
;call Dolphin.create
;and bx, 0xFF
;mov [atwstor], bx
;call Dolphin.registerWindow
;push ebx
;mov bl, 26
;mov eax, ecx
;call Dolphin.setAttribute
;pop ebx
;mov eax, ebx
;mov bl, 30
;call Dolphin.setAttribute
;popa
;mov bx, [atwstor]
;ret

Dolphin.TITLE :
db 0
Dolphin.WIDTH :
db 16
Dolphin.HEIGHT :
db 18
Dolphin.X_POS :
db 20
Dolphin.Y_POS :
db 22
Dolphin.TYPE :
db 24
DOLPHIN.DEPTH :
db 25

currentWindow :
dd 0x0
bstor :
dd 0x0
atwstor :
dw 0x0
atwstor2 :
dw 0x0
Dolphin.colorOverride :
db 0x0
Dolphin.tuskip :
dd 0x2
Dolphin.charposStor :
dw 0x0
Dolphin.tColor :
dd 0x0, 0x0, 0x0, 0x0
Dolphin.bsizstor :
dd 0x0
Dolphin.activeWindow :	; winNum for the window that currently has focus (must be switched by Dolphin!)
db 0x0
bglocstor :
dd 0x0
Dolphin.windowStructs :
dd 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
Dolphin.cbuffer :
dd SCREEN_BUFFER
PALETTE_NODEFAULT :
db "Applying patch to palette...", 0
UNREG_MSG :
db "A window has been unregistered!", 0