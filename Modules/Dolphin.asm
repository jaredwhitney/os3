[bits 32]
SCREEN_BUFFER equ 0xA20000
Dolphin.init :
	; whatever needs to be done here

Dolphin.create :	; bl contains PNUM
push ax
mov al, bl
mov ah, 0x2	; right now only doing text-based windows
call Guppy.malloc
pop ax
ret	; returns buffer location in ebx

Dolphin.windowUpdate :	; eax contains buffer location, ebx contains pos, cx contains width, dx contains height
pusha
add ebx, SCREEN_BUFFER
;call Dolphin.drawBorder	; both are expecting size in chars >_<
;call Dolphin.clear
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
;sub ebx, 1
;add ebx, 0x140
push eax
push ecx
push edx
mov eax, ebx
sub eax, SCREEN_BUFFER
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
add eax, SCREEN_BUFFER
mov ebx, eax
pop edx
pop ecx
pop eax
cmp dx, 0
jg Dolphin.wupdate.loop0
popa
ret

Dolphin.textUpdate :	; eax contains text buffer location, ebx contains pos, cx contains width, dx contains height
pusha
call Dolphin.redrawBG	; ensuring that the background stays 'on bottom'
add ebx, SCREEN_BUFFER
call Dolphin.clear
call Dolphin.drawBorder
push eax
mov eax, [charpos]
mov [Dolphin.charposStor], eax
pop eax
push cx

Dolphin.update.loop1 :
mov [charpos], ebx
push eax
mov ax, [eax]
cmp al, 0x0
je Dolphin.update.noDraw
push bx
mov bl, [Dolphin.colorOverride]
cmp bl, 0x0
pop bx
je Dolphin.update.goDraw
mov ah, [Dolphin.colorOverride]
Dolphin.update.goDraw :
call graphics.drawChar
Dolphin.update.noDraw :
pop eax
sub cx, 0x1
add eax, [Dolphin.tuskip]
add ebx, 0x8	; usually 0x8, want it to be 0x6
cmp cx, 0
jg Dolphin.update.loop1
add ebx, 0xA00
pop cx

sub ebx, ecx
sub ebx, ecx
sub ebx, ecx
sub ebx, ecx
sub ebx, ecx
sub ebx, ecx
sub ebx, ecx
sub ebx, ecx

sub dx, 1
push cx
cmp dx, 0
jg Dolphin.update.loop1
pop cx
mov eax, [Dolphin.charposStor]
mov [charpos], eax
popa
ret

Dolphin.drawBorder :
pusha
mov eax, 0x03030303	; red
sub ebx, 0x140
add cx, cx
push ebx
Dolphin.drawBorder.loop1 :
mov [ebx], eax
add ebx, 0x4
sub cx, 0x1
cmp cx, 0x0
jg Dolphin.drawBorder.loop1
mov [ebx], al
pop ebx

imul dx, 0x8
Dolphin.drawBorder.loop2 :
mov [ebx], al
add ebx, 0x140
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
je Dolphin.makeBG.ret
add ebx, 4
mov eax, SCREEN_BUFFER
mov edx, eax
add edx, 0xf000
Dolphin.makeBG.loop1 :
mov cl, [ebx]
mov [eax], cl
add ebx, 1
add eax, 1
cmp eax, edx
jl Dolphin.makeBG.loop1
Dolphin.makeBG.ret :
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
call debug.update	; ensuring that debug information stays updated and 'on top'
mov ebx, SCREEN_BUFFER
mov eax, 0xa0000
mov ecx, 0xaf800
Dolphin.updateScreen.loop1 :
mov edx, [ebx]
mov [eax], edx
add eax, 4
add ebx, 4
cmp eax, ecx
jle Dolphin.updateScreen.loop1
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

Dolphin.colorOverride :
db 0x0
Dolphin.tuskip :
dd 0x2
Dolphin.charposStor :
dw 0x0
Dolphin.tColor :
dd 0x0, 0x0, 0x0, 0x0
bglocstor :
dd 0x0
PALETTE_NODEFAULT :
db "Applying patch to palette...", 0