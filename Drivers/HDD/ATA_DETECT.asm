ATA_DETECT :
pusha
	xor ecx, ecx
	ATA_DETECT.loop :
	push ecx
	mov edx, ecx
	imul edx, 3
	add edx, ATA_DAT
	mov al, [edx+1]
	mov ah, [edx]
	mov bl, [edx+2]
	call PCI.getDeviceByDescription
	cmp dh, 0xFF
		je ATA_DETECT.nof0
	call PCI.getObjectFromSearch
	mov [ATA_DEVICE], ecx
	
		call AHCI_INIT
	
	mov eax, SysHaltScreen.WARN
	mov ecx, 1
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
		AHCI_INIT :
			pusha
			; print some infos
				mov ecx, [ATA_DEVICE]
				mov bh, 0x0	; reg
				call PCI.readFromObject
				mov ebx, ecx
				call console.numOut
				call console.newline
					;mov al, 0x1
					;mov ebx, 1
					;call Guppy.malloc	; alloc ram to store the ahci data in
					;mov eax, ebx
				;mov eax, 0xFA000000
				;mov ecx, [ATA_DEVICE]
				;mov bh, 0x24;	set ahci memory location ; p.571 http://www.intel.com/content/www/us/en/chipsets/5-chipset-3400-chipset-datasheet.html
				;call PCI.writeFromObject
				;
				;	should wait until it is actually updated?
				;
				;mov eax, 2000
				;call System.sleep
				;
				;add ecx, 0xC
				mov ecx, [ATA_DEVICE]
				mov bh, 0x24
				call PCI.readFromObject
				mov [AHCI_MEMLOC], ecx
				
				mov ebx, [AHCI_MEMLOC]
				add ebx, 0xC
				mov ebx, [ebx]
				mov [AHCI_PORTMASK], ebx
				call console.numOut
				call console.newline
				
				mov eax, 0x05
				mov ebx, 10
				call Guppy.malloc
				mov [AHCI_PORTALLOCEDMEM], ebx

				
				
				mov ebx, [AHCI_MEMLOC]
				add ebx, 0x100	; port 0 info pointer at this address
				mov ebx, [ebx]	; port 0 info pointer
				mov ecx, [AHCI_PORTALLOCEDMEM]
				mov [ebx+0], ecx	; write command list address
				mov ecx, [AHCI_PORTALLOCEDMEM]
				add ecx, 0x1000
				mov [ebx+8], ecx	; write FIS address (should NOT be pointing here... is where the FIS that is sent back is placed)
				mov dword [ebx+12], 0x0
				
				; Command Header
				mov ebx, [AHCI_PORTALLOCEDMEM]
				mov byte [ebx+0], (0b010 << 5) | (16)	; 010 or 011 ?
				mov byte [ebx+1], 0b00000000	; is this right?
				mov word [ebx+2], 1	; 1 PRDT
				mov ecx, ebx
				add ecx, 0x1000
				mov dword [ebx+4], ecx	; command table descriptor
				mov dword [ebx+8], 0x0	; upper
				mov dword [ebx+12], 0x0
				mov dword [ebx+16], 0x0
				mov dword [ebx+20], 0x0
				mov dword [ebx+24], 0x0
				
				; Command FIS
				mov ebx, [AHCI_PORTALLOCEDMEM]
				mov byte [ebx+0x1000], 0x27
				mov byte [ebx+0x1000+1], 1
				mov byte [ebx+0x1000+2], 0xEC; command
				mov byte [ebx+0x1000+3], 0 ; feature
				mov byte [ebx+0x1000+4], 0	; lbalow
				mov byte [ebx+0x1000+5], 0	; lbamid
				mov byte [ebx+0x1000+6], 0	; lbahigh
				mov byte [ebx+0x1000+7], 0	; dev
				mov byte [ebx+0x1000+8], 0
				mov byte [ebx+0x1000+9], 0
				mov byte [ebx+0x1000+10], 0
				mov byte [ebx+0x1000+11], 0
				mov byte [ebx+0x1000+12], 0	; countlow
				mov byte [ebx+0x1000+13], 0	; counthigh
				mov byte [ebx+0x1000+14], 0	; isynccompletion
				mov byte [ebx+0x1000+15], 0	; control reg
				mov dword [ebx+0x1000+16], 0	; resv
				
				; PRDTs
					mov al, 0x5
					mov ebx, 1
					call Guppy.malloc
					mov [AHCI_RECVPLACE], ebx
					mov dword [ebx], 0x0
				mov ecx, ebx
				mov ebx, [AHCI_PORTALLOCEDMEM]
				mov dword [ebx+0x1080], ecx
				mov dword [ebx+0x1080+4], 0
				mov dword [ebx+0x1080+8], 0	; resv
				mov dword [ebx+0x1080+12], 255	; 255 bytes?
				
				mov ebx, [AHCI_MEMLOC]
				mov dword [ebx+0x38], 1	; activate command 0
				
				mov eax, 5000
				call System.sleep
				
				test dword [ebx+0x38], 1
					jnz kernel.halt	; if fail, freeze the system
				
				mov ebx, [AHCI_MEMLOC]
				cmp dword [ebx+0x100+0x10], 0x0
					je ATA_NOCHNG
				mov eax, SysHaltScreen.WARN	; so it works... but where the recieved data go??
				mov ebx, AHCI_IDENTIFYSUCCESS
				mov ecx, 4
				call SysHaltScreen.show
				ATA_NOCHNG :
				
			popa
			ret
			AHCI_IDENTIFYSUCCESS :
				db "IDENTIFY command worked!", 0
			AHCI_RECVPLACE :
				dd 0x0

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
	
AHCI_PORTMASK :
	dd 0x0
	
AHCI_PORTALLOCEDMEM :
	dd 0x0
	
;DISK_DEVICELIST :
;	times 255 dq 0, 0, 0, 0	; support up to 255 'PCI_DEVICE's
	
; PCI_DEVICE :
; 	dd Internal Name [String]	; 0x0
; 	dd Hardware Type [String]	; 0x4
;	dd CLASSCODE | SUBCLASS CODE | PROG_IF | 0 (int)	; 0x8
; 	dd Vendor Name [String]	; 0xC
;	dw Vendor ID (int)	; 0x10
; 	dd Device Name [String] <unimplemented>	; 0x12
; 	dw Device ID (int)	; 0x16
; 	dd PCI object (int)	; 0x18
;	dd Status (int) <initialized | in use | disconnected | unresponsive | slept>	; 0x22