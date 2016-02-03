MOUSE_DEV_ENABLE_REPORTING	equ 0xF4
MOUSE_DEV_RESET	equ 0xFF

MOUSE_LBTN_FLAG	equ 0b00000001
MOUSE_RBTN_FLAG	equ 0b00000010

mouse.init :
pusha
	mov al, MOUSE_DEV_RESET
	call ps2.commandPort2
	mov al, MOUSE_DEV_ENABLE_REPORTING
	call ps2.commandPort2
popa
ret

Mouse.loop :
pusha
	in al, PS2_DATA_PORT
	mov bl, [Mouse.datpart]
	cmp bl, 0x2	; I blame an uncaught ACK or something!
		jne Mouse.loop.handleMotion
	call Mouse.storeSubs
	test al, MOUSE_LBTN_FLAG
		jz Mouse.loop.notleft
	mov ebx, MOUSE_LBTN
	jmp Mouse.loop.go
	Mouse.loop.notleft :
	test al, MOUSE_RBTN_FLAG
		jz Mouse.loop.ret
	mov ebx, MOUSE_RBTN
	Mouse.loop.go :
	;mov [Mouse.PRESS.type], ebx
	;mov eax, [Mouse.x]
	;mov [Mouse.PRESS.x], eax
	;mov eax, [Mouse.y]
	;mov [Mouse.PRESS.y], eax
	call Dolphin.handleMouseClick
Mouse.loop.ret :
mov bl, [Mouse.datpart]
cmp bl, 0x01
	jne Mouse.loop.ret.noup
call Mouse.sanityCheckAndUpdate
Mouse.loop.ret.noup :
call Mouse.incpart
popa
ret

Mouse.loop.handleMotion:
mov ecx, Mouse_ysum
and ebx, 0xFF
cmp bl, 1
	je Mouse.loop.handleMotion.ymotion
mov ecx, Mouse_xsum
Mouse.loop.handleMotion.ymotion :
and eax, 0xFF
mov edx, Mouse.xsub
add edx, ebx	; because ebx is 0 for x and 1 for y and its a 1 byte value...
mov bl, [edx]
cmp bl, 0xFF
	je Mouse.loop.handleMotion.subs
add [ecx], eax
jmp Mouse.loop.ret

Mouse.loop.handleMotion.subs :
neg al
sub [ecx], eax
jmp Mouse.loop.ret

Mouse.datpart :
db 0x0

Mouse.storeSubs :
pusha
	mov cl, 0x00
	test al, 0b10000
		jz Mouse.storeSubs.noxn
	mov cl, 0xFF
	Mouse.storeSubs.noxn :
	mov ch, 0x00
	test al, 0b100000
		jz Mouse.storeSubs.noyn
	mov ch, 0xFF
	Mouse.storeSubs.noyn :
	mov [Mouse.xsub], cl
	mov [Mouse.ysub], ch
popa
ret

Mouse.incpart :
	mov bl, [Mouse.datpart]
	add bl, 1
	cmp bl, 3
		jl Mouse.loop.ret.nofix
	mov bl, 0x0
	Mouse.loop.ret.nofix :
	mov [Mouse.datpart], bl
ret

Mouse.sanityCheckAndUpdate :
pusha
	mov eax, [Mouse_xsum]
	test eax, 0xF0000000
		jz Mouse.sCAU.nxfix1
	mov eax, 0
	mov [Mouse_xsum], eax
	Mouse.sCAU.nxfix1 :
	cmp eax, [Graphics.SCREEN_REALWIDTH]
		jl Mouse.sCAU.nxfix2
	mov eax, [Graphics.SCREEN_REALWIDTH]
	mov [Mouse_xsum], eax
	Mouse.sCAU.nxfix2 :
	mov [Mouse.x], eax
	
	mov eax, [Mouse_ysum]
	test eax, 0xF0000000
		jz Mouse.sCAU.nyfix1
	mov eax, 0
	mov [Mouse_ysum], eax
	Mouse.sCAU.nyfix1 :
	cmp eax, [Graphics.SCREEN_HEIGHT]
		jl Mouse.sCAU.nyfix2
	mov eax, [Graphics.SCREEN_HEIGHT]
	mov [Mouse_ysum], eax
	Mouse.sCAU.nyfix2 :
	mov [Mouse.y], eax
popa
ret

Mouse.drawOnScreen :
pusha
	mov eax, [Graphics.SCREEN_MEMPOS]
	mov ebx, [Graphics.SCREEN_HEIGHT]
		pusha
		sub ebx, [Mouse.lasty]
		imul ebx, [Graphics.SCREEN_WIDTH]
		add eax, ebx
		mov ecx, [Mouse.lastx]
		imul ecx, 4
		add eax, ecx
				mov ebx, 1
				mov ecx, 1
				call Dolphin.redrawBackgroundRegion
		popa
	sub ebx, [Mouse.y]
	imul ebx, [Graphics.SCREEN_WIDTH]
	add eax, ebx
	mov ecx, [Mouse.x]
	imul ecx, 4
	add eax, ecx
	mov dword [eax], 0xFFFFFF
	
								mov ecx, [Mouse.x]
								mov edx, [Mouse.y]
								mov [Mouse.lastx], ecx
								mov [Mouse.lasty], edx
popa
ret

Mouse.xsub :
	db 0x0
Mouse.ysub :
	db 0x0
Mouse_xsum :
	dd 0x0
Mouse_ysum :
	dd 0x0
Mouse.x :
	dd 0x0
Mouse.y :
	dd 0x0
Mouse.lastx :
	dd 0x0
Mouse.lasty :
	dd 0x0

MOUSE_LBTN :
	dd "L_CK"
MOUSE_RBTN :
	dd "R_CK"
Mouse.PRESS.type :
	dd 0x0
Mouse.PRESS.x :
	dd 0x0
Mouse.PRESS.y :
	dd 0x0
