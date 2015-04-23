[bits 32]
[org 0x0]
PRINTSTRING equ 0x1000
entry :
	push ebx
	mov al, [msg]
	mov cl, [msg]
	mov dl, [msg]
	mov bl, [msg]
	mov ah, [msg]
	mov ch, [msg]
	mov dh, [msg]
	mov bh, [msg]
	mov ax, [msg]
	mov cx, [msg]
	mov dx, [msg]
	mov bx, [msg]
	mov eax, [msg]
	mov ecx, [msg]
	mov edx, [msg]
	mov ebx, [msg]
	call [PRINTSTRING]
	pop ebx
	ret
	;dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
msg :
	db "Hello from an external program!", 0x0