PS2_COMMAND_PORT	equ 0x64
PS2_STATUS_PORT		equ 0x64
PS2_DATA_PORT		equ 0x60

PS2_READ_CONFIG		equ 0x20
PS2_WRITE_CONFIG	equ 0x60
PS2_TEST_CONTROLLER	equ 0xAA
PS2_ENABLE_PORT1	equ 0xAE
PS2_DISABLE_PORT1	equ 0xAD
PS2_TEST_PORT1		equ 0xAB
PS2_SEND_PORT1		equ 0xD1	; is this right?
PS2_FAKEAS_PORT1	equ 0xD2
PS2_ENABLE_PORT2	equ 0xA8
PS2_DISABLE_PORT2	equ 0xA7
PS2_TEST_PORT2		equ 0xA9
PS2_SEND_PORT2		equ 0xD4
PS2_FAKEAS_PORT2	equ 0xD3
PS2_RESET_CPU		equ 0xFE

PS2_SELFTEST_SUCCESS	equ 0x55
PS2_ACK					equ 0xFA

PS2_OUTB_FULL_FLAG	equ 0b00000001
PS2_INPB_FULL_FLAG	equ 0b00000010
PS2_TRANSLATE_FLAG	equ 0b01000000
PS2_PORT1_INT_FLAG	equ 0b00000001
PS2_PORT2_INT_FLAG	equ 0b00000010
PS2_P2CLKDSBL_FLAG	equ 0b00100000

ps2.init :
methodTraceEnter
pusha

	; Disable all ps2 devices
	call ps2.waitForWrite
	mov al, PS2_DISABLE_PORT1
	out PS2_COMMAND_PORT, al	; first controller
	call ps2.waitForWrite
	mov al, PS2_DISABLE_PORT2
	out PS2_COMMAND_PORT, al	; second controller (if exists)
	
	; Discard any residual data
	call ps2.discardAllData
	
	; Disable translation and ints in controller config byte
	call ps2.readConfigByte
	mov bl, (PS2_TRANSLATE_FLAG | PS2_PORT1_INT_FLAG | PS2_PORT2_INT_FLAG)
	not bl
	or al, bl
	mov cl, al
	call ps2.waitForWrite
	mov al, PS2_WRITE_CONFIG
	out PS2_COMMAND_PORT, al
	call ps2.waitForWrite
	mov al, cl
	out PS2_DATA_PORT, al
	
	; Perform self-test
	call ps2.waitForWrite
	mov al, PS2_TEST_CONTROLLER
	out PS2_COMMAND_PORT, al
	call ps2.waitForData
	in al, PS2_DATA_PORT
	cmp al, PS2_SELFTEST_SUCCESS
		jne ps2.sw_selftestFail
	
	; Check for second ps2 port
	call ps2.waitForWrite
	mov al, PS2_ENABLE_PORT2
	out PS2_COMMAND_PORT, al
	call ps2.readConfigByte
	test al, PS2_P2CLKDSBL_FLAG
		jnz ps2.sw_singlePortController
	call ps2.waitForWrite
	mov al, PS2_DISABLE_PORT2
	out PS2_COMMAND_PORT, al
	
	; Test both ports
	call ps2.waitForWrite
	mov al, PS2_TEST_PORT1
	out PS2_COMMAND_PORT, al
	call ps2.waitForData
	in al, PS2_DATA_PORT
	cmp al, 0x0
		jne ps2.sw_test1fail
		
	call ps2.waitForWrite
	mov al, PS2_TEST_PORT2
	out PS2_COMMAND_PORT, al
	call ps2.waitForData
	in al, PS2_DATA_PORT
	cmp al, 0x0
		jne ps2.sw_test2fail
		
	; Enable ps2 devices
	call ps2.waitForWrite
	mov al, PS2_ENABLE_PORT1
	out PS2_COMMAND_PORT, al
	
	call ps2.waitForWrite
	mov al, PS2_ENABLE_PORT2
	out PS2_COMMAND_PORT, al
	
	; Enable ints on all devices (should probably check to see what kind of devices they are before blindly enabling them...)
	call ps2.readConfigByte
	or al, (PS2_PORT1_INT_FLAG | PS2_PORT2_INT_FLAG)
	mov cl, al
	call ps2.waitForWrite
	mov al, PS2_WRITE_CONFIG
	out PS2_COMMAND_PORT, al
	call ps2.waitForWrite
	mov al, cl
	out PS2_DATA_PORT, al
	
	call mouse.init	; should not be done here...
	
popa
methodTraceLeave
ret

ps2firstrep :
db 0x0

ps2.discardAllData :
methodTraceEnter
	in al, PS2_STATUS_PORT
	test al, PS2_OUTB_FULL_FLAG
		jz ps2.discardAllData.ret
	in al, PS2_DATA_PORT
	jmp ps2.discardAllData
ps2.discardAllData.ret :
methodTraceLeave
ret

ps2.readConfigByte :
methodTraceEnter
	call ps2.waitForWrite
	mov al, PS2_READ_CONFIG
	out PS2_COMMAND_PORT, al
	call ps2.waitForData
	in al, PS2_DATA_PORT
methodTraceLeave
ret

ps2.waitForData :
methodTraceEnter
	ps2.waitForDataLoop :
	in al, PS2_STATUS_PORT
	test al, PS2_OUTB_FULL_FLAG
		jz ps2.waitForDataLoop
methodTraceLeave
ret

ps2.waitForWrite :
methodTraceEnter
	ps2.waitForWriteLoop :
	in al, PS2_STATUS_PORT
	test al, PS2_INPB_FULL_FLAG
		jnz ps2.waitForWriteLoop
methodTraceLeave
ret

ps2.waitForACK :
methodTraceEnter
	mov al, PS2_ACK
	call ps2.waitForResponse
methodTraceLeave
ret

ps2.waitForResponse :
methodTraceEnter
	mov bl, al
	ps2.waitForResponse.loop :
	in al, PS2_DATA_PORT
	cmp al, bl
		jne ps2.waitForResponse.loop
methodTraceLeave
ret

ps2.commandPort1 :	; is this right?
methodTraceEnter
push ax
	call ps2.waitForWrite
	out PS2_DATA_PORT, al
pop ax
methodTraceLeave
ret

ps2.commandPort2 :
methodTraceEnter
push ax
	mov ah, al
	call ps2.waitForWrite
	mov al, PS2_SEND_PORT2
	out PS2_COMMAND_PORT, al
	call ps2.waitForWrite
	mov al, ah
	out PS2_DATA_PORT, al
pop ax
methodTraceLeave
ret

ps2.sw_selftestFail :
		mov eax, SysHaltScreen.RESET
		mov ebx, PS2.SELFTEST_FAILMSG
		mov ecx, 5
		call SysHaltScreen.show
methodTraceLeave
popa
ret

ps2.sw_singlePortController :
		mov eax, SysHaltScreen.WARN
		mov ebx, PS2.SINGLEPORT_MSG
		mov ecx, 3
		call SysHaltScreen.show
methodTraceLeave
popa
ret

ps2.sw_test1fail :
		mov eax, SysHaltScreen.RESET
		mov ebx, PS2.PORT1_FAILMSG
		mov ecx, 5
		call SysHaltScreen.show
methodTraceLeave
popa
ret

ps2.sw_test2fail :
		mov eax, SysHaltScreen.WARN
		mov ebx, PS2.PORT2_FAILMSG
		mov ecx, 3
		call SysHaltScreen.show
methodTraceLeave
popa
ret

ps2.sw_timeout :
		mov eax, SysHaltScreen.RESET
		mov ebx, PS2.TIMEOUT_MSG
		mov ecx, 5
		call SysHaltScreen.show
methodTraceLeave
popa
ret

ps2.resetCPU :
methodTraceEnter
call ps2.waitForWrite
mov al, PS2_RESET_CPU
out PS2_COMMAND_PORT, al
mov eax, SysHaltScreen.WARN
mov ebx, PS2.RESET_FAILMSG
mov ecx, 10
call SysHaltScreen.show
methodTraceLeave
ret

PS2.RESET_FAILMSG :
	db "Could not reset the CPU.", 0
PS2.SELFTEST_FAILMSG :
	db "PS/2 Controller test fail. Restarting the computer...", 0
PS2.SINGLEPORT_MSG :
	db "PS/2 Controller does not have a second port.", 0
PS2.PORT1_FAILMSG :
	db "PS/2 Port 1 test fail. Restarting the computer...", 0
PS2.PORT2_FAILMSG :
	db "PS/2 Port 2 test fail.", 0
PS2.TIMEOUT_MSG :
	db "PS/2 Controller not responding. Restarting the computer...", 0