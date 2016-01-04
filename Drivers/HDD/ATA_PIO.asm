ATA_PIO0_DATA		equ 0x1F0
ATA_PIO0_CTRL1		equ 0x1F1
ATA_PIO0_SC			equ 0x1F2
ATA_PIO0_LBAlow		equ 0x1F3
ATA_PIO0_LBAmid		equ 0x1F4
ATA_PIO0_LBAhigh	equ 0x1F5
ATA_PIO0_DRVSEL		equ 0x1F6
ATA_PIO0_CMD		equ 0x1F7
ATA_PIO0_CTRL8		equ 0x1F8

ATA_PIO1_CTRL0	equ 0x170
ATA_PIO1_CTRL1	equ 0x171
ATA_PIO1_CTRL2	equ 0x172
ATA_PIO1_CTRL3	equ 0x173
ATA_PIO1_CTRL4	equ 0x174
ATA_PIO1_CTRL5	equ 0x175
ATA_PIO1_CTRL6	equ 0x176
ATA_PIO1_CTRL7	equ 0x177
ATA_PIO1_CTRL8	equ 0x178

ATA_PIO0_STAT	equ 0x3F6
ATA_PIO1_STAT	equ 0x376

ATA_PIO_DRIVE0	equ 0xA0
ATA_PIO_DRIVE1	equ 0xB0

ATA_COMMAND_IDENTIFY	equ 0xEC


ATAPIO.init :
	pusha
		call ATAPIO.checkFloat
		call ATAPIO.doIdentify
	popa
	ret

ATAPIO.delay :
	pusha
		mov dx, ATA_PIO1_STAT
		in al, dx
		in al, dx
		in al, dx
		in al, dx
		in al, dx
	popa
	ret

	
ATAPIO.checkFloat :
	pusha
		mov dx, ATA_PIO0_STAT
		in al, dx
		cmp al, 0xFF
			je kernel.halt	; ATA DEV MASTER MISSING
	popa
	ret

	
ATAPIO.doIdentify :
	pusha
	
		mov al, ATA_PIO_DRIVE0
		mov dx, ATA_PIO0_DRVSEL
		out dx, al
		call ATAPIO.delay
		
		mov al, 0
		mov dx, ATA_PIO0_SC
		out dx, al
		mov dx, ATA_PIO0_LBAlow
		out dx, al
		mov dx, ATA_PIO0_LBAmid
		out dx, al
		mov dx, ATA_PIO0_LBAhigh
		out dx, al
		
		mov al, ATA_COMMAND_IDENTIFY
		mov dx, ATA_PIO0_CMD
		out dx, al
		
		mov dx, ATA_PIO0_STAT
		in al, dx
		cmp al, 0x0
			je kernel.halt	; ATA DEV MASTER MISSING
		test al, 0x1
			jnz ATAPIO.doIdentifyOther	; ATA DEV MASTER IS SATA OR ATAPI
		
		mov dx, ATA_PIO0_STAT
		ATAPIO.doIdentify.loop0 :
			in al, dx
			test al, 0x80
				jnz ATAPIO.doIdentify.loop0
		
		mov dx, ATA_PIO0_LBAhigh
		in al, dx
		mov bl, al
		mov dx, ATA_PIO0_LBAmid
		in al, dx
		or al, bl
		cmp al, 0x0
			jne kernel.halt	; DEV IS NOT ATA
		
		mov dx, ATA_PIO0_STAT
		ATAPIO.doIdentify.loop1 :
			in al, dx
			test al, 0x8
				jz ATAPIO.doIdentify.loop1
		
		test al, 0x1
			jnz kernel.halt	; ATA DEV ERROR
		
		mov eax, 0x5	; hard disk drivers ID
		mov ebx, 1
		call Guppy.malloc
		mov [ATA_PIO0.IDENTIFY_RESPONSE], ebx
		
		xor ecx, ecx
		mov dx, ATA_PIO0_DATA
		ATAPIO.doIdentify.loop2 :
		in ax, dx
		mov [ebx], ax
		add ebx, 2
		add ecx, 1
		cmp ecx, 255
			jl ATAPIO.doIdentify.loop2
		
	mov ebx, ATAPIO.STR_FOUNDATA
	call ATAPIO.showMessage

ATAPIO.doIdentifyOther :
	
		mov dx, ATA_PIO0_LBAmid
		in al, dx
		mov ah, al
		mov dx, ATA_PIO0_LBAhigh
		in al, dx
		
		mov ebx, ATAPIO.STR_FOUNDATAPI
		cmp ax, 0x14EB
			je ATAPIO.showMessage
		
		mov ebx, ATAPIO.STR_FOUNDSATA
		cmp ax, 0x3CC3
			je ATAPIO.showMessage
		
	jmp kernel.halt	; ATA DEV UNKNOWN

ATAPIO.showMessage :
	mov eax, SysHaltScreen.WARN
	mov ecx, 5
	call SysHaltScreen.show
	popa
	ret

ATAPIO.STR_FOUNDATAPI :
	db "ATA Found an ATAPI Device", 0
ATAPIO.STR_FOUNDSATA :
	db "ATA Found a SATA Device", 0
ATAPIO.STR_FOUNDATA :
	db "ATA Found and ATA Device", 0
	
ATA_PIO0.IDENTIFY_RESPONSE :
	dd 0x0