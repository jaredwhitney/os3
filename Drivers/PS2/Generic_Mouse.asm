;	INITIALIZE THE PS2 CONTROLLER TO RETURN MOUSE UPDATES	;
mouse.init :
pusha
	; reset
	mov al, 0xFF
	out MOUSE_COMMANDPORT, al
	; self-test
	mov al, 0xAA
	out MOUSE_COMMANDPORT, al
	mov al, 0x55
	call Mouse.waitForResponse
	; set the compaq status byte
	call kernel.halt
popa
ret
	
Mouse.loop :
pusha
	in al, 0x64
	test al, 0b1
		jz Mouse.loop.ret
	mov bl, al
	in al, 0x60
	;test bl, 0b100000
	;	jz Mouse.loop.ret
	mov ebx, MOUSE_FOUND_DAT_STR
	call console.println
Mouse.loop.ret :
popa
ret

Mouse.waitForResponse :
mov bl, al
Mouse.waitForResponse.loop :
in al, 0x60
cmp al, bl
	jne Mouse.waitForResponse.loop
ret

Mouse.waitForReady :
in al, 0x64
test al, 0b10
	jnz Mouse.waitForReady
ret

MOUSE_FOUND_DEV_STR :
	db "Found an input device.", 0x0

MOUSE_FOUND_DAT_STR :
	db "Recieved some data?", 0x0

MOUSE_COMMANDPORT equ 0x64
MOUSE_DATAPORT equ 0x60