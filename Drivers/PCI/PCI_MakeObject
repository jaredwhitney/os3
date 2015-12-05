PCI_DEVICE.makeFromObject :	; memory location in eax, obj in ecx
push eax
push ebx
push edx
	mov [eax+0x18], ecx
	mov [PCI_DEVICE._obj], ecx
	mov bh, 0x0
	call PCI.readFromObject
	mov [PCI_DEVICE._temp], ecx
	and ecx, 0xFFFF
	mov [eax+0x10], ecx
	call PCI_TABLES.lookupVendorString
	mov [eax+0xC], ecx
	mov ecx, [PCI_DEVICE._temp]
	shr ecx, 16
	mov [eax+0x16], ecx
	mov ecx, [PCI_DEVICE._obj]
	mov bh, 0x08
	call PCI.readFromObject
	and ecx, 0xFFFFFF00
	mov [eax+0x8], ecx
	
pop edx
pop ebx
pop eax
ret

PCI_DEVICE._temp :
	dd 0x0
PCI_DEVICE._obj :
	dd 0x0
	
PCI_DEVICE_COUNTER :
	dd 0x0