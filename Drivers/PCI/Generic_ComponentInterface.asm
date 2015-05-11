PCI.read :	; al = bus, ah = device, bl = function, bh = reg; returns data in eax
	push edx
	push ecx
	push ebx
	
	call PCI.getAddr
			;pusha
			;mov ebx, eax
			;call console.numOut
			;popa
	
	mov dx, 0xcf8
	out dx, eax	; write to PCI address port
	
	mov dx, 0xcfc
	in eax, dx	; read value from PCI data port
	
	pop ebx
	pop ecx
	pop edx
	ret

PCI.write :	; al = bus, ah = device, bl = function, bh = reg, data = ecx
	pusha
	push ecx
	call PCI.getAddr
	pop ecx
	
	mov dx, 0xcf8
	out dx, eax
	
	mov dx, 0xcfc
	mov eax, ecx
	out dx, eax
	popa
	ret

PCI.getAddr :	; only meant for use inside PCI driver!
	xor ecx, ecx
	add ecx, eax
	and ecx, 0xFF	; want al
	shl ecx, 16	; bus into position
	
	mov edx, eax
	mov dl, dh
	and edx, 0b11111
	shl edx, 11
	or ecx, edx	; dev into position
	
	push ebx
	and ebx, 0b111
	shl ebx, 8
	or ecx, ebx	; func into position
	mov eax, ecx
	
	pop ebx
	mov edx, ebx
	mov dl, dh
	and edx, 0b11111100
	or eax, edx
	
	or eax, 0b10000000000000000000000000000000
	
	ret

PCI.getDeviceByDescription :	; al = Subclass code, ah = Class code, bl = Program IF; returns dl = device number, dh = device bus (0xFF if fail)
	push eax
	push ecx
	push edx
	
	and ebx, 0xFF
	shl ebx, 8
	shl eax, 16
	or eax, ebx
	
	push eax
	mov dl, 0x0	; begin with device 0
	mov dh, 0x0	; begin with bus 0
	PCI.getDeviceByDescription.loop :
		mov ah, dl	; device
		mov al, dh	; bus
		mov bl, 0	; func
		mov bh, 0x08	; reg 0x08 is class info
		call PCI.read
				;pusha
				;mov ebx, eax
				;mov ah, 0xFF
				;call console.numOut
				;popa
		mov ecx, eax
		pop eax
		and ecx, 0xFFFFFF00	; don't care about last byte (revision ID)
		cmp eax, ecx
			je PCI.getDeviceByDescription.done
		push eax
		add dl, 1
		cmp dl, 0b11111
			je PCI.getDeviceByDescription.done1
		jmp PCI.getDeviceByDescription.loop
	PCI.getDeviceByDescription.done1 :
	add dh, 1
	cmp dh, 0xFF
		jl PCI.getDeviceByDescription.loop
	pop eax
	PCI.getDeviceByDescription.done :

		;	printing stuff
		mov ebx, edx
		and ebx, 0xFF
		mov ah, 0xFF
		push ebx
		mov ebx, PCI.STRING_gdID
		call console.print
		pop ebx
		call console.numOut
		
		mov ebx, PCI.STRING_gdIDs
		call console.print
		mov ebx, edx
		mov bl, bh
		and ebx, 0xFF
		call console.numOut
		mov ebx, PCI.STRING_gdIDe
		call console.print
		
		call console.newline
	
	pop edx
	pop ecx
	pop eax
	ret

PCI.STRING_gdID :
	db "Device Address: 0x", 0
PCI.STRING_gdIDs :
	db " (Bus: 0x", 0
PCI.STRING_gdIDe :
	db ")", 0