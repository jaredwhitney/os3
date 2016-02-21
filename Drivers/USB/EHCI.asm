EHCI.findDevice :
	pusha
		mov ah, 0x0C
		mov al, 0x03
		mov bl, 0x20
		call PCI.getDeviceByDescription
		call PCI.getObjectFromSearch
		mov [EHCI.PCI_Device], ecx

		cmp ecx, 0xFFFFFFFF
			je EHCI.noDeviceFound
		mov eax, SysHaltScreen.WARN
		mov ebx, EHCI.DEV_FOUND_STR
		mov ecx, 5
		call SysHaltScreen.show
		
		mov ecx, [EHCI.PCI_Device]
		mov bh, 0x10	; BAR 2 ? (USBBASE)
		call PCI.readFromObject
		mov [EHCI.USBBASE], ecx
		
		add cl, [ecx]
		mov [EHCI.OPBASE], ecx
		
	popa
	ret
	EHCI.noDeviceFound :
		mov eax, SysHaltScreen.KILL
		mov ebx, EHCI.DEV_NOT_FOUND_STR
		mov ecx, 5
		call SysHaltScreen.show
	popa
	ret

EHCI.getPortCount :
	push eax
		
		mov ecx, [EHCI.USBBASE]
		add ecx, 0x4
		mov eax, [ecx]
		and eax, 0xFF
		mov ecx, eax
			pusha
			mov ebx, ecx
			call console.numOut
			popa
		
	pop eax
	ret

EHCI.printConnectedPorts :
	pusha
		call EHCI.getPortCount
		mov edx, ecx
		mov ecx, [EHCI.OPBASE]
		add ecx, 0x44
		EHCI.printConnectedPorts.loop :
		test dword [ecx], 0b1
			jz EHCI.noprint
		mov ebx, EHCI.printConnectedPorts.CONNECTED_STR
		call console.print
		mov ebx, ecx
		sub ebx, 0x44
		sub ebx, [EHCI.OPBASE]
		shr ebx, 2
		add ebx, 1
		call console.numOut
		call console.newline
		EHCI.noprint :
		sub edx, 1
		add ecx, 0x4
		cmp edx, 0x0
			jg EHCI.printConnectedPorts.loop
	popa
	ret
EHCI.printConnectedPorts.CONNECTED_STR :
	db "Device connected on port ", 0b0

EHCI.PCI_Device :
	dd 0x0
EHCI.DEV_FOUND_STR :
	db "Found an EHCI Controller!", 0x0
EHCI.DEV_NOT_FOUND_STR :
	db "No compatible EHCI Controller found.", 0x0
EHCI.USBBASE :
	dd 0x0
EHCI.OPBASE :
	dd 0x0
