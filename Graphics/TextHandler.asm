[bits 32]

;clearScreenG :
;pusha
;mov dx, 0x0
;mov ebx, [Dolphin.SCREEN_BUFFER]
;mov edx, ebx
;add edx, [Graphics.SCREEN_SIZE]
;csgloop :
;mov [ebx], dx
;add ebx, 0x2
;cmp ebx, edx
;jl csgloop
;mov ecx, [TextHandler.charpos]
;mov ecx, [Dolphin.SCREEN_BUFFER]
;mov [TextHandler.charpos], ecx
;popa
;ret

TextHandler.drawCharFromBitmap :	; ebx contains char to draw
pusha
mov [TextHandler.selectedColor], ah
mov dx, 0x0
TextHandler.drawCharloop :
; ah contains the current row of the char
mov ah, [ebx]
	push ecx
	mov ecx, [TextHandler.textSizeMultiplier]
	TextHandler.drawCharLoop.FinishHeight :
call TextHandler.drawRow
	sub ecx, 1
	cmp ecx, 0x0
	jg TextHandler.drawCharLoop.FinishHeight
	pop ecx
add ebx, 0x1
add dx, 0x1
cmp dx, 0x7
jl TextHandler.drawCharloop
call TextHandler.drawSolidBacking
mov ecx, [TextHandler.charpos]
	push eax
	xor eax, eax
	mov ax, [TextHandler.textWidth]
	push ebx
	mov ebx, 7
	imul ebx, [TextHandler.textSizeMultiplier]
	add ebx, 2
	imul eax, ebx	; 1=9, 2=16, 3=23
	pop ebx
		;imul eax, [TextHandler.textSizeMultiplier]
	sub ecx, eax
	pop eax
	push edx
	push ecx
	push eax
	mov edx, [Graphics.bytesPerPixel]
	imul edx, 6
		imul edx, [TextHandler.textSizeMultiplier]
	pop eax
	pop ecx
	add ecx, edx
	pop edx
mov [TextHandler.charpos], ecx
popa
ret

TextHandler.drawSolidBacking :
pusha
mov dl, [TextHandler.solidChar]
cmp dl, 0x0
je TextHandler.drawSolidBacking.ret
mov ah, 0x0
call TextHandler.drawRow
call TextHandler.drawRow
TextHandler.drawSolidBacking.ret :
popa
ret

TextHandler.drawRow :	; ah contains row
	pusha
	mov ebx, [TextHandler.charpos]
		;sub ebx, [bstor]
		;add ebx, [Dolphin.cbuffer]
	mov cl, 6
	TextHandler.drawRowloop :
		mov ch, ah
		sub cl, 0x1
		shr ch, cl
		and ch, 0b1
		cmp ch, 0b0
			je TextHandler.drawRownd
				mov dl, [Graphics.VESA_MODE]
				cmp dl, 0x0
					jne TextHandler.drawRowVESA
				mov dl, [TextHandler.selectedColor]
					push ecx
					mov ecx, [TextHandler.textSizeMultiplier]
				TextHandler.drawRowloop.FinishWidth :
				mov [ebx], dl
					add ebx, 1
					sub ecx, 1
					cmp ecx, 0x0
						jg TextHandler.drawRowloop.FinishWidth
					pop ecx
				
				jmp TextHandler.drawRownddone
				TextHandler.drawRowVESA :
				mov edx, [TextHandler.selectedColor]
								or edx, CHANGE_MASK
					push ecx
					mov ecx, [TextHandler.textSizeMultiplier]
					TextHandler.drawRowloop.FinishWidthVESA :
				mov [ebx], edx
					add ebx, 4
					sub ecx, 1
					cmp ecx, 0x0
						jg TextHandler.drawRowloop.FinishWidthVESA
					pop ecx
		jmp TextHandler.drawRownddone
	TextHandler.drawRownd :
		push dx
		mov dl, [TextHandler.solidChar]
		cmp dl, 0x0
			je TextHandler.drawRownd.nodrawnodr
		mov dl, 0x0
		mov [ebx], dl
		TextHandler.drawRownd.nodrawnodr :
			push ecx	; advance to next char slot
			mov ecx, [TextHandler.textSizeMultiplier]
			imul ecx, [Graphics.bytesPerPixel]
		add ebx, ecx
			pop ecx
	TextHandler.drawRownd.nodr :
		pop dx
	TextHandler.drawRownddone :
		cmp cl, 0x0
			jg TextHandler.drawRowloop
			
	mov ecx, [TextHandler.charpos]
	push eax
	xor eax, eax
	mov ax, [TextHandler.textWidth]
		;push edx
		;push ecx
		;mov dl, [Graphics.VESA_MODE]
		;cmp dl, 0x0
		;je TextHandler.drawRownnddoneNOVESA
		;imul eax, 0x2
		;TextHandler.drawRownnddoneNOVESA :
		;pop ecx
		;pop edx
	add ecx, eax
	pop eax
	mov [TextHandler.charpos], ecx
	popa
ret

TextHandler.newline :
;mov eax, [TextHandler.charpos]
;mov bx, 0x0
;mov [eax], bx
mov eax, [TextHandler.charpos]
mov ecx, 0x0
add eax, 0x2
gnldloop :
sub eax, 0xA00
add ecx, 0x1
cmp eax, [Dolphin.SCREEN_BUFFER]
jg gnldloop
mov eax, ecx
mov ebx, 0xA00
mul ebx
add eax, [Dolphin.SCREEN_BUFFER]
mov [TextHandler.charpos], eax

ret

TextHandler.drawChar :		; char in ax
pusha
call TextHandler.getCharBitmap
call TextHandler.drawCharFromBitmap
popa
ret


TextHandler.getCharBitmap :
mov ebx, Font.bitmaps
mov edx, Font.order
graphicsgetposloop :
mov cl, [edx]
cmp al, cl
je graphicsgetposret
add ebx, 7
add edx, 1
mov cl, [edx]
cmp cl, '*'
je graphicsgetposret
jmp graphicsgetposloop

graphicsgetposret :
ret

		
TextHandler.charpos :
dd 0x0

Graphics.bytesPerPixel :
dd 0x1

TextHandler.selectedColor :
dd 0xFFFFFF

TextHandler.solidChar :
db 0x0

TextHandler.textWidth :
dd 0x0

TextHandler.charposStor :
dd 0x0

TextHandler.textSizeMultiplier :
dd 0x1

