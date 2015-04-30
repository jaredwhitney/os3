;	INITIALIZE THE PS2 CONTROLLER TO RETURN MOUSE UPDATES	;
Mouse.init :
	push ax
	;	ENABLE AUXILLARY INPUT
	mov al, 0xA8
	out 0x64, al
	;	TELL MOUSE TO LISTEN FOR A COMMAND	;
	mov al, 0xD4
	out 0x64, al
	;	COMMAND MOUSE TO SEND PACKETS	;
	mov al, 0xF4
	out 0x60, al
	
	pop ax
	ret