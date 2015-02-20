[bits 32]
Dolphin.init :
	; whatever needs to be done here

Dolphin.create :	; bl contains PNUM
push ax
mov al, bl
mov ah, 0x2	; right now only doing text-based windows
call Guppy.malloc
pop ax
ret	; returns buffer location in ebx


Dolphin.textUpdate :	; eax contains text buffer location, ebx contains pos, cx contains width, dx contains height
pusha
add ebx, 0xa0000
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
call graphics.drawChar
Dolphin.update.noDraw :
pop eax
sub cx, 0x1
add eax, 0x2
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
call debug.update	; ensuring that debug information stays 'on top'
popa
ret

Dolphin.drawBorder :
pusha
mov eax, 0xC0C0C0C
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
mov al, 0x11
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

Dolphin.makeBG :	; ebx contains location of data
pusha
mov eax, 0xa0000
Dolphin.makeBG.loop1 :
mov cl, [ebx]
mov [eax], cl
add ebx, 1
add eax, 1
cmp eax, 0xaf000
jl Dolphin.makeBG.loop1
popa
ret

Dolphin.setVGApalette :
pusha
mov dx, 0x3c8
mov al, 0x0
out dx, al	; we are starting with index 0

mov dx, 0x0	; red
mov cx, 0x0	; blue
mov bx, 0x0	; green
mov ax, 0x0

Dolphin.setVGApalette.loop1 :
mov ax, dx
push dx
mov dx, 0x3c9
out dx, ax	; red
mov ax, bx
out dx, ax	; green
mov ax, cx
out dx, ax	; blue
pop dx
add cx, 42
cmp cx, 216
jle Dolphin.setVGApalette.cont
mov cx, 0x0
add bx, 42
cmp bx, 216
jle Dolphin.setVGApalette.cont
mov bx, 0x0
add dx, 42
Dolphin.setVGApalette.cont :
cmp dx, 216
jle Dolphin.setVGApalette.loop1
popa
ret

Dolphin.charposStor :
dw 0x0