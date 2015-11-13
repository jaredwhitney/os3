ATA0_PORT0 equ 0x170
ATA0_PORT1 equ 0x171
ATA0_PORT2 equ 0x172
ATA0_PORT3 equ 0x173
ATA0_PORT4 equ 0x174
ATA0_PORT5 equ 0x175
ATA0_PORT6 equ 0x176
ATA0_PORT7 equ 0x177
ATA_DATAPORT equ 0x1F0
ATA_CTRLPORT equ 0x1F7
ATA_STATPORT equ 0x1F7
ATA0_DRIVESELECT equ 0x1F6

ATA.init :
pusha
	mov al, 0xA0
	mov dx, ATA0_DRIVESELECT
	out dx, al
	xor al, al
	mov dx, ATA0_PORT2
	out dx, al
	add dx, 1
	out dx, al
	add dx, 1
	out dx, al
	add dx, 1
	out dx, al
	mov al, 0xEC
	mov dx, ATA_CTRLPORT
	out dx, al
	mov dx, ATA_STATPORT
	in al, dx
	cmp al, 0x0
		je ATA0.nodevFound
	ATA0.waitFor :
	in al, dx
	test al, 0b1001
		jz ATA0.waitFor
	test al, 0b1
		jnz ATA0.testMore
	; it is ready to send its data... get a buffer to put it in
	mov eax, 1
	call Guppy.malloc
	mov [ATA_STOR], ebx
	mov dx, ATA_DATAPORT
	xor cx, cx
	ATA_readloop1 :
	in ax, dx
	mov [ebx], ax
	add ebx, 2
	add cx, 1
	cmp cx, 255
		jl ATA_readloop1
popa
ret

ATA0.testMore :
	mov dx, 0x1F4
	in al, dx
	mov ah, al
	mov dx, 0x1F5
	in al, dx
	cmp ax, 0xEB14
		je ATA0.foundATAPI
	cmp ax, 0xC33C
		je ATA0.foundSATA
	mov eax, SysHaltScreen.WARN
	mov ebx, ATA_DEVUNKNOWNSTR
	mov ecx, 5
	call SysHaltScreen.show
	popa
	ret
ATA0.nodevFound :
	mov eax, SysHaltScreen.WARN
	mov ebx, ATA_DEVNOTFOUNDSTR
	mov ecx, 3
	call SysHaltScreen.show
	popa
	ret

ATA0.foundSATA :
	mov eax, SysHaltScreen.WARN
	mov ebx, ATA_DEVSATAFOUNDSTR
	mov ecx, 3
	call SysHaltScreen.show
	popa
	ret

ATA0.foundATAPI :
	mov eax, SysHaltScreen.WARN
	mov ebx, ATA_DEVATAPIFOUNDSTR
	mov ecx, 3
	call SysHaltScreen.show
	popa
	ret

ATA_STOR :
	dd 0x0
	
ATA_DEVNOTFOUNDSTR :
	db "Could not find any ATA Devices.", 0
ATA_DEVSATAFOUNDSTR :
	db "Found a SATA Device.", 0
ATA_DEVATAPIFOUNDSTR :
	db "Found an ATAPI Device.", 0
ATA_DEVUNKNOWNSTR :
	db "Unable to determine ATA device type.", 0