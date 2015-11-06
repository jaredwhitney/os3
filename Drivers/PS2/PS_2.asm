ps2.init :
pusha
	; Disable all ps2 devices
	mov al, 0xAD
	out 0x64, al	; first controller
	mov al, 0xA7
	out 0x64, al	; second controller (if exists)
	
	call ps2.discardAllData
	
	; Disable translation and ints in controller config byte
	call ps2.readConfigByte
	mov bl, 0b01000011
	not bl
	or al, bl
	mov cl, al
	call ps2.waitForWrite
	mov al, 0x60
	out 0x64, al
	call ps2.waitForWrite
	mov al, cl
	out 0x60, al
	
	; Perform self-test
	call ps2.waitForWrite
	mov al, 0xAA
	out 0x64, al
	;call ps2.waitForData
		ps2st.discardjunk :	; should not be needed...
		in al, 0x60
		cmp al, 0x67
			je ps2st.discardjunk
			mov [ps2firstrep], al
	cmp al, 0x55
		jne kernel.halt	; should handle this more gracefully...
	
	; Check for second ps2 port
	call ps2.waitForWrite
	mov al, 0xA8
	out 0x64, al
	call ps2.readConfigByte
	test al, 0b100000
		jnz kernel.halt	; should be handled... (single port ps2) 
	call ps2.waitForWrite
	mov al, 0xA7
	out 0x64, al
	
	; P
	
popa
ret

ps2firstrep :
db 0x0

ps2.discardAllData :
	in al, 0x64
	test al, 0b1
		jz ps2.discardAllData.ret
	in al, 0x60
	jmp ps2.discardAllData
ps2.discardAllData.ret :
ret

ps2.readConfigByte :
	call ps2.waitForWrite
	mov al, 0x20
	out 0x64, al
	call ps2.waitForData
	in al, 0x60
ret

ps2.waitForData :
in al, 0x64
test al, 0b1
	jnz ps2.waitForData
ret

ps2.waitForWrite :
in al, 0x64
test al, 0b10
	jnz ps2.waitForWrite
ret

ps2.waitForResponse :
mov bl, al
ps2.waitForResponse.loop :
in al, 0x60
cmp al, bl
	jne ps2.waitForResponse.loop
ret