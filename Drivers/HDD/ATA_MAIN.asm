ATA0_DATAPORT equ 0x1F0
ATA0_CTRLPORT equ 0x1F7
ATA0_STATPORT equ 0x1F7
ATA0_DRIVESELECT equ 0x1F6
ATA0_DEV_CTRL equ 0x3E6

ATA1_DATAPORT equ 0x170
ATA1_CTRLPORT equ 0x177
ATA1_STATPORT equ 0x177
ATA1_DRIVESELECT equ 0x176
ATA1_DEV_CTRL equ 0x366

ATA0.init :
pusha
;	 ugh try #3?
;	mov dx, 
;	out dx, al
;popa
;ret


;
;	mov ah, 0x01
;	mov al, 0x05
;	mov bl, 0x20
;	call PCI.getDeviceByDescription
;	cmp dh, 0xFF
;		je ATA0.nodevFound
;	jmp ATA0.unknownType
;popa
;ret

	mov dx, ATA1_STATPORT
	in al, dx
	cmp al, 0xFF
		je ATA0.nodevFound
	
	mov dx, ATA0_DEV_CTRL	; force reset
	mov al, 0b100
	out dx, al
	
	mov eax, 50000
	call System.sleep
	
	mov dx, ATA0_DEV_CTRL	; end reset
	mov al, 0b0
	out dx, al

	mov eax, 50000
	call System.sleep
	
	mov al, 0xA0
	mov dx, ATA0_DRIVESELECT
	out dx, al
	
	mov dx, ATA0_DATAPORT	; delay ~400ns
	in al, dx
	in al, dx
	in al, dx
	in al, dx
	
	mov dx, 0x1F4
	in al, dx
	mov ah, al
	mov dx, 0x1F5
	in al, dx
	mov [ATA_DEVNUM], ax
	cmp ax, 0xC33C
		je ATA0.foundSATA
	cmp ax, 0x9669
		je ATA0.foundSATAPI
	cmp ax, 0x0000
		je ATA0.foundATA
	cmp ax, 0xEB14
		je ATA0.foundATAPI
	jmp ATA0.unknownType

ATA0.nodevFound :
	mov eax, SysHaltScreen.WARN
	mov ebx, ATA_DEVMISSINGSTR
	mov ecx, 2
	call SysHaltScreen.show
	popa
	ret
	
ATA0.unknownType :
	mov eax, SysHaltScreen.WARN
	mov ebx, ATA_DEVUNKNOWNSTR
	mov ecx, 5
	call SysHaltScreen.show
	popa
	ret

ATA0.foundSATA :
	mov eax, SysHaltScreen.WARN
	mov ebx, ATA_DEV_SATA_FOUNDSTR
	mov ecx, 3
	call SysHaltScreen.show
	popa
	ret

ATA0.foundSATAPI :
	mov eax, SysHaltScreen.WARN
	mov ebx, ATA_DEV_SATAPI_FOUNDSTR
	mov ecx, 3
	call SysHaltScreen.show
	popa
	ret
	
ATA0.foundATA :
	mov eax, SysHaltScreen.WARN
	mov ebx, ATA_DEV_ATA_FOUNDSTR
	mov ecx, 3
	call SysHaltScreen.show
	popa
	ret
	
ATA0.foundATAPI :
	mov eax, SysHaltScreen.WARN
	mov ebx, ATA_DEV_ATAPI_FOUNDSTR
	mov ecx, 3
	call SysHaltScreen.show
	popa
	ret

ATA_STOR :
	dd 0x0
ATA_DEVNUM :
	dw 0x0
	

ATA_DEV_SATA_FOUNDSTR :
	db "Found a SATA Device.", 0
ATA_DEV_SATAPI_FOUNDSTR :
	db "Found a SATAPI Device.", 0
ATA_DEV_ATA_FOUNDSTR :
	db "Found an ATA Device.", 0
ATA_DEV_ATAPI_FOUNDSTR :
	db "Found an ATAPI Device.", 0
ATA_DEVUNKNOWNSTR :
	db "Unable to determine ATA device type.", 0
ATA_DEVMISSINGSTR :
	db "No ATA device found.", 0
	
	
Disk.infoDebug :
pusha
	mov ah, 0x01
	mov al, 0x02
	mov bl, 0x00
	call PCI.getDeviceByDescription
	cmp dh, 0xFF
		je Disk.iD.c0
	mov ebx, DISK_FDC
	call console.println
	Disk.iD.c0 :
	mov ah, 0x01
	mov al, 0x04
	mov bl, 0x00
	call PCI.getDeviceByDescription
	cmp dh, 0xFF
		je Disk.iD.c1
	mov ebx, DISK_RAIDCT
	call console.println
	Disk.iD.c1 :
	mov ah, 0x01
	mov al, 0x05
	mov bl, 0x20
	call PCI.getDeviceByDescription
	cmp dh, 0xFF
		je Disk.iD.c2
	mov ebx, DISK_ATASIN
	call console.println
	Disk.iD.c2 :
	mov ah, 0x01
	mov al, 0x05
	mov bl, 0x30
	call PCI.getDeviceByDescription
	cmp dh, 0xFF
		je Disk.iD.c3
	mov ebx, DISK_ATACHN
	call console.println
	Disk.iD.c3 :
	mov ah, 0x01
	mov al, 0x06
	mov bl, 0x00
	call PCI.getDeviceByDescription
	cmp dh, 0xFF
		je Disk.iD.c4
	mov ebx, DISK_SATAVN
	call console.println
	Disk.iD.c4 :
	mov ah, 0x01
	mov al, 0x06
	mov bl, 0x01
	call PCI.getDeviceByDescription
	cmp dh, 0xFF
		je Disk.iD.c5
	mov ebx, DISK_SATAV1
	call console.println
	Disk.iD.c5 :
	mov ah, 0x0C
	mov al, 0x03
	mov bl, 0x20
	call PCI.getDeviceByDescription
	cmp dh, 0xFF
		je kernel.halt
popa
ret

DISK_FDC :
	db "Found 'Floppy disk controller'", 0
DISK_RAIDCT :
	db "Found 'RAID controller'", 0
DISK_ATASIN :
	db "Found 'ATA controller (single DMA)'", 0
DISK_ATACHN :
	db "Found 'ATA controller (chain DMA)'", 0
DISK_SATAVN :
	db "Found 'SATA controller (Vendor Spec)'", 0
DISK_SATAV1 :
	db "Found 'SATA controller (AHCI 1.0)'", 0
	