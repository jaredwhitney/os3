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
	popa
	ret
	EHCI.noDeviceFound :
		mov eax, SysHaltScreen.KILL
		mov ebx, EHCI.DEV_NOT_FOUND_STR
		mov ecx, 5
		call SysHaltScreen.show
	popa
	ret

EHCI.printPortCount :
	pusha
		mov ecx, [EHCI.PCI_Device]
		mov bh, 0x10	; BAR 2 ? (USBBASE)
		call PCI.readFromObject

		add ecx, 0x4
		mov eax, [ecx]
		and eax, 0xFF

		mov ebx, eax
		call console.numOut
		call console.newline
	popa
	ret

EHCI.PCI_Device :
	dd 0x0
EHCI.DEV_FOUND_STR :
	db "Found an EHCI Controller!", 0x0
EHCI.DEV_NOT_FOUND_STR :
	db "No compatible EHCI Controller found.", 0x0
