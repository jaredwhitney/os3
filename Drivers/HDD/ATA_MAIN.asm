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
	mov ah, 1
	mov al, 6
	call PCI.getDeviceByClassCodes
	cmp dh, 0xFF
		je ATA0.nodevFound
	jmp ATA0.unknownType
popa
ret

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
	
	