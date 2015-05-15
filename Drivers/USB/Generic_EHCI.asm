USB_PrintControllerInfo :
pusha
	mov ah, 0x0C	; EHCI controller info
	mov al, 0x03
	mov bl, 0x20
	call PCI.getDeviceByDescription
	mov al, dh
	mov ah, dl
	mov bl, [fnc]
	mov bh, 0x10
	call PCI.read
	mov [USB_BASE], eax
	mov ebx, USB.STRING_mmioLoc
	call console.print
	mov ebx, eax
	call console.numOut
	call console.newline
	
	mov eax, [USB_BASE+0x4]	; structural params
	mov ebx, [eax]
	and ebx, 0b111	; number of ports
	mov [USB.numPorts], ebx
	mov ebx, USB.STRING_numPorts
	call console.print
	mov ebx, [USB.numPorts]
	call console.numOut
	call console.newline
	
popa
ret

USB_PrintActivePorts :
pusha
	xor ecx, ecx
	mov eax, [USB_BASE+0x4]	; structural params
	mov ebx, [eax]
	and ebx, 0b111	; number of ports
	mov [USB.numPorts], ebx
	USB_PrintActivePorts.loop :
	mov eax, [USB_BASE]
	xor ebx, ebx
	mov bl, [eax]
	add eax, ebx	; operational base -> eax
	
	add eax, 0x44	; eax -> port stat and control data
		push ecx
		imul ecx, 4
		add eax, ecx	; get to the proper port number
		pop ecx
	
	mov ebx, [eax]	; load data for the first port
	and ebx, 0b1
	cmp ebx, 0
		je USB.nonActive
	push ebx
	mov ebx, USB.STRING_activePort
	call console.print
	mov ebx, ecx
	and ebx, 0xFF	; cl is port counter
	call console.numOut
	call console.newline
	pop ebx
	USB.nonActive :
	add ecx, 1
	cmp ecx, [USB.numPorts]
		jle USB_PrintActivePorts.loop
popa
ret

USB.STRING_mmioLoc :
	db "USB MMIO: 0x", 0x0
USB.STRING_activePort :
	db "Port is active: 0x", 0x0
USB.STRING_numPorts :
	db "USB Port Count: 0x", 0x0
USB.numPorts :
	dd 0x0
USB_BASE :
	dd 0x0