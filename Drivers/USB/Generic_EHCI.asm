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
	mov ebx, USB.STRING_mmioLoc
	call console.print
	mov ebx, eax
	call console.numOut
	call console.newline
	
popa
ret

USB.STRING_mmioLoc :
db "USB MMIO: 0x", 0x0