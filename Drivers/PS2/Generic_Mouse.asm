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
		jne Mouse.loop.ret
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
call Mouse.incpart
popa
ret

Mouse.datpart :
db 0x0

Mouse.incpart :
	mov bl, [Mouse.datpart]
	add bl, 1
	cmp bl, 3
		jl Mouse.loop.ret.nofix
	mov bl, 0x0
	Mouse.loop.ret.nofix :
	mov [Mouse.datpart], bl
ret

MOUSE_LBTN_STR :
	db "[LEFT MOUSE]", 0x0
MOUSE_RBTN_STR :
	db "[RIGHT MOUSE]", 0x0

	
	
	
	
	
; Mouse.setCompaqByte :
	; call Mouse.waitForReady
	; mov al, 0x20
	; out MOUSE_COMMANDPORT, al
	; in al, MOUSE_DATAPORT
	; or al, 0b10
	; mov bl, 0b100000
	; not bl
	; or al, bl
	; call Mouse.waitForReady
	; push ax
	; mov al, 0x60
	; out MOUSE_COMMANDPORT, al
	; pop ax
	; call Mouse.waitForReady
	; out MOUSE_DATAPORT, al
; ret

; Mouse.waitForResponse :
; mov bl, al
; Mouse.waitForResponse.loop :
; in al, 0x60
; cmp al, bl
	; jne Mouse.waitForResponse.loop
; ret

; Mouse.waitForReady :
; in al, 0x64
; test al, 0b10
	; jnz Mouse.waitForReady
; ret

; MOUSE_FOUND_DEV_STR :
	; db "Found an input device.", 0x0

; MOUSE_COMMANDPORT equ 0x64
; MOUSE_DATAPORT equ 0x60
