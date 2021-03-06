PMGDT :
	dw GDTEND-GDTSTART-1
	dd GDTSTART
PMIDT :
	dw IDTEND-IDTSTART-1
	dd IDTSTART

GDTSTART :
dd 0x0
dd 0x0
GDTCODE :
dw 0xFFFF
dw 0x0
db 0x0
db 0b10011010
db 0b11001111
db 0x0
GDTDATA :
dw 0xFFFF
dw 0x0
db 0x0
db 0b10010010
db 0b11001111
db 0x0
GDTEND :
codeOffs equ GDTCODE-GDTSTART
dataOffs equ GDTDATA-GDTSTART

IDTSTART :
		dw (KERNEL_LOADER_LOC+CLOCK_CALL-$$) & 0xFFFF	; INT 0
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+CLOCK_CALL-$$) >> 16

		dw (KERNEL_LOADER_LOC+KEYBOARD_CALL-$$) & 0xFFFF	; INT 1
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+KEYBOARD_CALL-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 2
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 3
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 4
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 5
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 6
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 7
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+EXCEPTION8HANDLER-$$) & 0xFFFF	; INT 8
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+EXCEPTION8HANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 9
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16

		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT A
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT B
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT C
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT D
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT E
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT F
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 10
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 11
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 12
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 13
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 14
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 15
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 16
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 17
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 18
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 19
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 1A
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 1B
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 1C
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 1D
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 1E
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 1F
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 20
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 21
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 22
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 23
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+MOUSE_CALL-$$) & 0xFFFF	; INT 24
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+MOUSE_CALL-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 25
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 26
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 27
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 28
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 29
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 2A
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 2B
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 2C
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 2D
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 2E
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 2F
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 30
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 31
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 32
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 33
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 34
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 35
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 36
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 37
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 38
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 39
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 3A
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 3B
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 3C
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 3D
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 3E
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 3F
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 40
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 41
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16
		
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) & 0xFFFF	; INT 42
		dw 0x8
		db 0x0
		db 0b10001110
		dw (KERNEL_LOADER_LOC+IDTHANDLER-$$) >> 16

IDTEND :
IDTHANDLER :
	pusha
		mov al, 0x20
		out 0xA0, al
		mov al, 0x20
		out 0x20, al
	popa
	iret

EXCEPTION8HANDLER :
	pushad
	popad
	iret
	
CLOCK_CALL :
	pusha
		inc dword [Clock.tics]
		mov al, 0x20
		out 0xA0, al
		mov al, 0x20
		out 0x20, al
	popa
	iret

KEYBOARD_CALL :
	pusha
	mov byte [IN_INT_CALL], true
		call Keyboard.poll
	mov byte [IN_INT_CALL], false
		mov al, 0x20
		out 0xA0, al
		mov al, 0x20
		out 0x20, al
	popa
	iret

MOUSE_CALL :
	pusha
	mov byte [IN_INT_CALL], true
		call Mouse.loop
	mov byte [IN_INT_CALL], false
		mov al, 0x20
		out 0xA0, al
		mov al, 0x20
		out 0x20, al
	popa
	iret

align 16
RMGDTSTART :
dq 0x0
RMGDTCODE :
dw 0xFFFF
dw 0x0
db 0x0
db 0b10011010
db 0b00001111
db 0x0
RMGDTDATA :
dw 0xFFFF
dw 0x0
db 0x0
db 0b10010010
db 0b00001111
db 0x0
RMGDT32 :
dw 0xFFFF
dw 0x0
db 0x0
db 0b10011010
db 0b11001111
db 0x0
RMGDTEND :

RMGDT :
dw RMGDTEND-RMGDTSTART-1
dd RMGDTSTART

IN_INT_CALL :
	db FALSE

rmCodeOffs equ RMGDTCODE-RMGDTSTART
rmDataOffs equ RMGDTDATA-RMGDTSTART
rm32Offs equ RMGDT32-RMGDTSTART
