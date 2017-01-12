MOUSE_DEV_ENABLE_REPORTING	equ 0xF4
MOUSE_DEV_RESET	equ 0xFF

MOUSE_LBTN_FLAG	equ 0b00000001
MOUSE_RBTN_FLAG	equ 0b00000010

mouse.init :
methodTraceEnter
pusha
	mov al, MOUSE_DEV_RESET
	call ps2.commandPort2
	call ps2.waitForData
	mov al, MOUSE_DEV_ENABLE_REPORTING
	call ps2.commandPort2
	
	in al, PS2_DATA_PORT
	cmp al, 0xFA
		jne .noResetAck
	in al, PS2_DATA_PORT
	cmp al, 0xAA
		je .gotSecondAck
	jmp .fixNoAA
	.noResetAck :
	call SysHaltScreen.show
	.fixNoAA :
	inc byte [Mouse.datpart] ; got 1 too many already, need to make sure the mouse packet part counter is intact
	.gotSecondAck :
	.gotAck :
	
	.doneloop :
	mov dword [Mouse.inited], true
popa
methodTraceLeave
ret

Mouse.loop :
methodTraceEnter
cmp dword [Mouse.inited], true
	jne .rret
pusha
	in al, PS2_DATA_PORT
	mov bl, [Mouse.datpart]
	cmp bl, 0x2
		jne Mouse.loop.handleMotion
	call Mouse.storeSubs
	mov ebx, MOUSE_NOBTN
	test al, MOUSE_LBTN_FLAG
		jz Mouse.loop.notleft
	mov ebx, MOUSE_LBTN
	jmp Mouse.loop.go
	Mouse.loop.notleft :
	test al, MOUSE_RBTN_FLAG
		jz Mouse.loop.go
	mov ebx, MOUSE_RBTN
	Mouse.loop.go :
	;mov [Mouse.PRESS.type], ebx
	;mov eax, [Mouse.x]
	;mov [Mouse.PRESS.x], eax
	;mov eax, [Mouse.y]
	;mov [Mouse.PRESS.y], eax
	;push dword null
	call WinMan.HandleMouseEvent;Dolphin2.handleMouseEvent
Mouse.loop.ret :
mov bl, [Mouse.datpart]
cmp bl, 0x01
	jne Mouse.loop.ret.noup
call Mouse.sanityCheckAndUpdate
Mouse.loop.ret.noup :
call Mouse.incpart
popa
Mouse.loop.rret :
methodTraceLeave
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
methodTraceEnter
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
methodTraceLeave
ret

Mouse.incpart :
methodTraceEnter
	mov bl, [Mouse.datpart]
	add bl, 1
	cmp bl, 3
		jl Mouse.loop.ret.nofix
	mov bl, 0x0
	Mouse.loop.ret.nofix :
	mov [Mouse.datpart], bl
methodTraceLeave
ret

Mouse.sanityCheckAndUpdate :
methodTraceEnter
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
methodTraceLeave
ret

Mouse.drawOnScreen :
methodTraceEnter
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
methodTraceLeave
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
Mouse.inited :
	dd false

MOUSE_NOBTN :
	dd 0
MOUSE_LBTN :
	dd 1
MOUSE_RBTN :
	dd 2
Mouse.PRESS.type :
	dd 0x0
Mouse.PRESS.x :
	dd 0x0
Mouse.PRESS.y :
	dd 0x0
