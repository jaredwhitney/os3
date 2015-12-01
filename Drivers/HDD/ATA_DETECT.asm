ATA_DETECT :
pusha
	xor ecx, ecx
	ATA_DETECT.loop :
	push ecx
	mov edx, ecx
	imul edx, 3
	add edx, ATA_DAT
	mov al, [edx]
	mov ah, [edx+1]
	mov bl, [edx+2]
	call PCI.getDeviceByDescription
	cmp dh, 0xFF
		je ATA_DETECT.nof0
	; print some infos
	mov ah, dl	; devnum
	mov al, dh	; bus
	mov bl, [fnc]	; func
	mov bh, 0x0	; reg
	push ebx
	push eax
	call PCI.read
	mov ebx, eax
	call console.numOut
	call console.newline
		mov al, 0x1
		mov ebx, 1
		call Guppy.malloc	; alloc ram to store the ahci data in
		mov ecx, ebx
	pop eax
	pop ebx
	mov bh, 0x24;	set ahci memory location ; p.571 http://www.intel.com/content/www/us/en/chipsets/5-chipset-3400-chipset-datasheet.html
	call PCI.write
	mov [AHCI_MEMLOC], ecx
	;
	;	should wait until it is actually updated?
	;
	add ecx, 0xC
	mov ebx, [ecx]
	call console.numOut
	call console.newline
	;add ebx, 0x10	; version
	;mov ebx, [ebx]
	;call console.numOut
	;call console.newline
	; show halt screen
	mov eax, SysHaltScreen.WARN
	mov ebx, ATA_STR
	imul ecx, 4
	add ebx, ecx
	mov ebx, [ebx]
	mov ecx, 5
	call SysHaltScreen.show
	ATA_DETECT.nof0 :
	pop ecx
	add ecx, 1
	cmp ecx, 6
		jl ATA_DETECT.loop
popa
ret

ATA_STR :
dd ATA_STR0, ATA_STR1, ATA_STR2, ATA_STR3, ATA_STR4, ATA_STR5
ATA_STR0 :
db "Found IDE Controller.", 0
ATA_STR1 :
db "Found RAID Controller.", 0
ATA_STR2 :
db "Found ATA Controller (Single DMA).", 0
ATA_STR3 :
db "Found ATA Controller (Chained DMA).", 0
ATA_STR4 :
db "Found SATA Controller (Vendor Specific).", 0
ATA_STR5 :
db "Found SATA Controller (AHCI 1.0).", 0

ATA_DAT :
db 1, 1, 0x00
db 1, 4, 0x00
db 1, 5, 0x20
db 1, 5, 0x30
db 1, 6, 0x00
db 1, 6, 0x01

AHCI_MEMLOC :
	dd 0x0