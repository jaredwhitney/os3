USB.init :
	pusha
		;call USB_InitController
		;call USB_EnablePlugAndPlay
	popa
	ret

USB_PrintControllerInfo :
pusha
	call USB_CheckExists
	
	mov ebx, USB.STRING_mmioLoc
	call console.print
	mov ebx, [USB_BASE]
	call console.numOut
	call console.newline
	
	mov ebx, USB.STRING_numPorts
	call console.print
	mov ebx, [USB.numPorts]
	call console.numOut
	call console.newline
	
popa
ret

USB_PrintActivePorts :
pusha

	call USB_CheckExists
	
	xor ecx, ecx
	USB_PrintActivePorts.loop :
	mov eax, [USB_OPBASE]
	
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
		jl USB_PrintActivePorts.loop
popa
ret

USB_InitController :
pusha
	call USB_GrabControllerInfo
	; actually init the controller here!
	mov ebx, [USB_OPBASE]
	add ebx, 0x40
	mov eax, 0x1
	mov [ebx], eax	; take control of the USB ports!
popa
ret

USB_RunAsyncTasks :
pusha
	mov ebx, [USB_OPBASE]	; o+0x0 = USBCMD reg
	mov eax, [ebx]
	or eax, 0b100000
	mov [ebx], eax
popa
ret

USB_LoadQueueHead :	; queue head address in ebx
pusha
	mov eax, [USB_OPBASE]
	add eax, 0x18	; ASYNCLISTADDR
	mov eax, ebx
popa
ret

USB_GrabControllerInfo :	; so broken D:
	pusha
	mov ah, 0x0C	; EHCI controller info
	mov al, 0x03
	mov bl, 0x20
	call PCI.getDeviceByDescription
	mov al, dh
	mov ah, dl
	mov [USB_PCIMAJOR], ax
	mov bl, [fnc]
	mov [USB_PCIMINOR], bl
	mov bh, 0x10
	call PCI.read
	mov [USB_BASE], eax
	
	xor ebx, ebx
	mov bl, [eax]
	add eax, ebx	; operational base -> eax
	mov [USB_OPBASE], eax
	;call console.numOut
	mov ebx, eax
	;call console.numOut

	mov eax, [USB_BASE]	; structural params
	add eax, 0x4
	mov ebx, [eax]
	and ebx, 0xF	; number of ports
	mov [USB.numPorts], ebx
	
	popa
	ret
USB_NotSupported :
	mov ebx, USB.STRING_CONTROLLERNOTFOUND
	mov ah, 0xFF
	call console.println
	popa
	ret

USB_CheckExists :
	pusha
	mov dx, [USB_PCIMAJOR]
	cmp dx, 0xFFFF
		je USB_NotSupported
	popa
	ret
	
USB_EnablePlugAndPlay :
pusha
	mov ebx, [USB_OPBASE]
	add ebx, 0x8
	mov eax, [ebx]
	or eax, (0b1 << 2)
	mov [ebx], eax
	
	mov ax, [USB_PCIMAJOR]
	mov bl, [USB_PCIMINOR]
	mov bh, 0x4
	push eax
	call PCI.read
	mov ecx, eax
	pop eax
	or ecx, 0b1 << 10
	call PCI.write
popa
ret


USB.STRING_mmioLoc :
	db "USB MMIO: 0x", 0x0
USB.STRING_activePort :
	db "Port is active: 0x", 0x0
USB.STRING_numPorts :
	db "USB Port Count: 0x", 0x0
USB.STRING_CONTROLLERNOTFOUND :
	db "[Error] No EHCI Controller found!", 0x0
USB.numPorts :
	dd 0x0
USB_BASE :
	dd 0x0
USB_OPBASE :
	dd 0x0
USB_PCIMAJOR :
	dw 0x0
USB_PCIMINOR :
	db 0x0
	
align 32	; no idea if any of these structures are actually valid (will test later)
USB_QUEUEHEADEX :
	dd (0x7e00+USB_QUEUEHEADEX-$$) | 0b11
	dd 0x0 | (0x400 << 16) | (0b1 << 15) | (0b0 << 14) | (0b00 << 12) | (0x7 << 8) | (0b0 << 7) | (0b0)	; so much is probably wrong here...
	dd (0b01 << 30) | 0x00
	dd USB_QTDEX	; current qTD
	dd (0x7e00+USB_QTDEX-$$) | 0b1	; next qTD | T bit
	dd (0x7e00+USB_QTDEX-$$) | 0b1	; alternate qTD | T bit
	dw (0b0 << 15) | (0x0 & 0b11111)	; data toggle off, 0 bytes to transfer
	dw (0b0 << 15) | (0b000 << 12) | (0b00 << 10) | (0b10 <<  8) | (0x00)	; 0b10 << 8 = SETUP PID
	dd 0x0	; this should be an actual buffer!
	dd 0x0	; this should be an actual buffer!
	dd 0x0	; this should be an actual buffer!
	dd 0x0	; this should be an actual buffer!
	dd 0x0	; this should be an actual buffer!
	
USB_QTDEX :
	dd 0x0 | 0b1
	dd 0x0 | 0b1
	dw (0b0 << 15) | (0x0 & 0b11111)
	dw (0b0 << 15) | (0b000 << 12) | (0b00 << 10) | (0b10 << 8) | (0x00)
	dd 0x0	; this should be an actual buffer!
	dd 0x0	; this should be an actual buffer!
	dd 0x0	; this should be an actual buffer!
	dd 0x0	; this should be an actual buffer!
	dd 0x0	; this should be an actual buffer!