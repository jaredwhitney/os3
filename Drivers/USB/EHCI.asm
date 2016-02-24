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
		mov bh, 0x10	; BAR 0 (USBBASE)
		call PCI.readFromObject
		mov [EHCI.USBBASE], ecx
		
		mov bl, [ecx]
		and ebx, 0xFF
		add ecx, ebx
		mov [EHCI.OPBASE], ecx
	
	
		; alloc memory for the periodiclist
		mov al, 0x7
		mov ebx, 1
		call Guppy.malloc	; returns 0x1000 region... should work
		mov [EHCI.periodicBase], ebx
	
		call EHCI.hardReset
		mov eax, 0x5000
		call System.sleep
		call EHCI.doEnable
		
	popa
	ret
	
	EHCI.noDeviceFound :
		mov eax, SysHaltScreen.KILL
		mov ebx, EHCI.DEV_NOT_FOUND_STR
		mov ecx, 5
		call SysHaltScreen.show
	popa
	ret
; see section 4.1 of http://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/ehci-specification-for-usb.pdf for initialization sequence

EHCI.hardReset :
	pusha
		mov ecx, [EHCI.OPBASE]
		mov ebx, [ecx]
		and ebx, ~0b1	; stop the controller
		mov [ecx], ebx
		mov eax, 0x500
		call System.sleep
		or ebx, 0b10	; reset the controller
		mov [ecx], ebx
		
		ehcihardresetloop :	; wait for the reset to complete
			mov ebx, [ecx]
			test ebx, 0b1
				jnz ehcihardresetloop				
	popa
	ret

EHCI.getPortCount :
	push eax
		
		mov ecx, [EHCI.USBBASE]
		add ecx, 0x4
		mov eax, [ecx]
		and eax, 0xFF
		mov ecx, eax
		
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
					push ebx
					mov ebx, [ecx]
					call console.numOut
					call console.newline
					pop ebx
		sub edx, 1
		add ecx, 0x4
		cmp edx, 0x0
			jg EHCI.printConnectedPorts.loop
	popa
	ret
EHCI.printConnectedPorts.CONNECTED_STR :
	db "Device connected on port ", 0b0
	
EHCI.doEnable :
	pusha
		; skip steps 1 and 2 for now
		mov ecx, [EHCI.OPBASE]
		mov ebx, [EHCI.periodicBase]
		mov [ecx+PERIODICLISTBASE], ebx
		
		; set T-bits of everything to 1 (eg none are in use)
		mov eax, [EHCI.periodicBase]
		mov ebx, eax
		or ebx, 1	; will point to itself and has the T-bit set
		mov [eax], ebx
		
		; set Run bit to enable
		mov eax, [EHCI.OPBASE]
		mov ecx, [eax+USBCMD]
		or ecx, 0b1
		mov [eax+USBCMD], ecx
		
		; write 1 to CONFIGFLAG to route all ports to EHCI controller
		mov eax, [EHCI.OPBASE]
		mov dword [eax+CONFIGFLAG], 0b1
		mov ebx, [eax+CONFIGFLAG]
		push ax
		mov ah, 0xFF
		;call console.numOut
		;call console.newline
		pop ax
		
		; take ownership of all ports
		mov eax, [EHCI.OPBASE]
		mov ecx, [eax+PORTSC0]
		and ecx, ~(0b1<<13)
		mov [eax+PORTSC0], ecx
		mov ecx, [eax+PORTSC0+4]
		and ecx, ~(0b1<<13)
		mov [eax+PORTSC0+4], ecx
		mov ecx, [eax+PORTSC0+8]
		and ecx, ~(0b1<<13)
		mov [eax+PORTSC0+8], ecx
		
	popa
	ret

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
EHCI.periodicBase :
	dd 0x0
	
USBCMD equ 0x0
USBSTS equ 0x4
USBINTR equ 0x8
FRINDEX equ 0xC
CTRLDSSEGMENT equ 0x10
PERIODICLISTBASE equ 0x14
ASYNCLISTADDR equ 0x18
CONFIGFLAG equ 0x40
PORTSC0 equ 0x44
