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
	mov ebx, MOUSE_LBTN_STR
	jmp Mouse.loop.go
	Mouse.loop.notleft :
	test al, MOUSE_RBTN_FLAG
		jz Mouse.loop.ret
	mov ebx, MOUSE_RBTN_STR
	Mouse.loop.go :
	call console.println
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
	cmp eax, [Graphics.SCREEN_WIDTH]
		jb Mouse.sCAU.nxfix	; jb because the value is unsigned
	mov eax, [Graphics.SCREEN_WIDTH]
	mov [Mouse_xsum], eax
	Mouse.sCAU.nxfix :
	mov [Mouse.x], eax
	
	mov eax, [Mouse_ysum]
	cmp eax, [Graphics.SCREEN_HEIGHT]
		jb Mouse.sCAU.nyfix
	mov eax, [Graphics.SCREEN_HEIGHT]
	mov [Mouse_ysum], eax
	Mouse.sCAU.nyfix :
	mov [Mouse.y], eax
popa
ret

Mouse.drawOnScreen :
pusha
	mov eax, [Graphics.SCREEN_MEMPOS]
	mov ebx, [Graphics.SCREEN_HEIGHT]
	sub ebx, [Mouse.y]
	imul ebx, [Graphics.SCREEN_WIDTH]
	add eax, ebx
	mov ecx, [Mouse.x]
	imul ecx, 4
	add eax, ecx
	mov dword [eax], 0xFFFFFF
	
								pusha
								mov ecx, [Mouse.x]
								mov eax, [Mouse.lastx]
								mov edx, [Mouse.y]
								mov ebx, [Mouse.lasty]
								cmp eax, ecx
									jne Mouse.drawOnScreen.pchk1
								cmp edx, ebx
									je Mouse.drawOnScreen.nobother
								Mouse.drawOnScreen.pchk1 :
								mov eax, [Mouse.x]
								imul eax, 4
								mov ebx, [Graphics.SCREEN_HEIGHT]
								sub ebx, [Mouse.y]
								call Dolphin.moveWindowAbsolute
								Mouse.drawOnScreen.nobother :
								mov [Mouse.lastx], ecx
								mov [Mouse.lasty], edx
								popa
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

MOUSE_LBTN_STR :
	db "[LEFT MOUSE]", 0x0
MOUSE_RBTN_STR :
	db "[RIGHT MOUSE]", 0x0
