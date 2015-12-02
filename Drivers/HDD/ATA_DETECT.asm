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
	call PCI.getObjectFromSearch
	mov [ATA_DEVICE], ecx
	; print some infos
	mov ecx, [ATA_DEVICE]
	mov bh, 0x0	; reg
	call PCI.readFromObject
	mov ebx, ecx
	call console.numOut
	call console.newline
		mov al, 0x1
		mov ebx, 1
		call Guppy.malloc	; alloc ram to store the ahci data in
		mov eax, ebx
	mov ecx, [ATA_DEVICE]
	mov bh, 0x24;	set ahci memory location ; p.571 http://www.intel.com/content/www/us/en/chipsets/5-chipset-3400-chipset-datasheet.html
	call PCI.readFromObject
	mov [AHCI_MEMLOC], ecx
	;
	;	should wait until it is actually updated?
	;
	mov eax, 2000
	call System.sleep
	;
	;add ecx, 0xC
	mov ebx, ecx;[ecx]
	call console.numOut
	call console.newline
	;add ebx, 0x10	; version
	;mov ebx, [ebx]
	;call console.numOut
	;call console.newline
	; show halt screen
	mov eax, SysHaltScreen.WARN
	mov ecx, 1	; not right
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

ATA_DEVICE :
	dd 0x0

AHCI_MEMLOC :
	dd 0x0