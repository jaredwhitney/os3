ps2.init :
pusha
	; Disable all ps2 devices
	mov al, 0xAD
	out 0x64, al	; first controller
	mov al, 0xA7
	out 0x64, al	; second controller (if exists)
	
	call ps2.discardAllData
	
	
	
	
popa
ret

ps2.discardAllData :
	in al, 0x64
	test al, 0b1
		jz ps2.discardAllData.ret
	in al, 0x60
	jmp ps2.discardAllData
ps2.discardAllData.ret :
ret