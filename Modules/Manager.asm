Manager.handleLock :
push ebx
mov bl, [Manager.locked]
cmp bl, 0x0
jne Manager.doLock
pop ebx
ret

Manager.lock :
push ebx
	mov [Manager.astor], eax
	mov [Manager.bstor], ebx
	mov [Manager.cstor], ecx
	mov [Manager.dstor], edx
	mov bl, [os.mlloc]
	mov [Manager.faultloc], bl
mov bl, 0xFF
mov [Manager.locked], bl
mov [Manager.reason], bl
pop ebx
ret

Manager.freezePanic :
push ebx
call Manager.lock
mov bl, 0x1
mov [Manager.reason], bl
pop ebx
ret

Manager.doLock :
pusha

mov edx, SCREEN_WIDTH*SCREEN_HEIGHT
mov eax, 0xa0000
mov bl, 0x0
call Dolphin.clearImage
mov eax, 0xa0000+SCREEN_WIDTH/2+((SCREEN_HEIGHT/4)-4)*SCREEN_WIDTH-3*37
mov ebx, Manager.lockMsg
mov cl, WHITE
call drawStringDirect
mov cl, 0xD0
add eax, SCREEN_WIDTH*16
mov ebx, Manager.EAX
call drawStringDirect
add eax, 24
; print contents of eax
	mov ebx, [Manager.astor]
	call Manager.direct.num
add eax, SCREEN_WIDTH*8-24
mov ebx, Manager.EBX
call drawStringDirect
add eax, 24
; print contents of ebx
	mov ebx, [Manager.bstor]
	call Manager.direct.num
add eax, SCREEN_WIDTH*8-24
mov ebx, Manager.ECX
call drawStringDirect
add eax, 24
; print contents of ecx
	mov ebx, [Manager.cstor]
	call Manager.direct.num
add eax, SCREEN_WIDTH*8-24
mov ebx, Manager.EDX
call drawStringDirect
add eax, 24
; print contents of edx
	mov ebx, [Manager.dstor]
	call Manager.direct.num
add eax, SCREEN_WIDTH*8-24
mov ebx, Manager.LOC
call drawStringDirect
mov bl, [Manager.faultloc]
cmp bl, 0x0
jne Manager.doLock.cl1
mov ebx, Manager.OS
jmp Manager.doLock.cl3
Manager.doLock.cl1 :
cmp bl, 0x1
jne Manager.doLock.cl2
mov ebx, Manager.PROGRAM
jmp Manager.doLock.cl3
Manager.doLock.cl2 :
cmp bl, 0x2
jne Manager.doLock.cl3
mov ebx, Manager.DOLPHIN
Manager.doLock.cl3 :
add eax, 16*6
call drawStringDirect

mov ebx, Manager.LOCK_PREMESSAGE
call debug.print
mov bl, [Manager.reason]
cmp bl, 0xFF
jne Manager.doLock.notNormal
	mov ebx, Manager.NORMAL_LOCK_MESSAGE
	mov cl, 0x8
	jmp Manager.doLock.cont
Manager.doLock.notNormal :
cmp bl, 0x01
jne Manager.doLock.notFP
	mov ebx, Manager.FREEZEPANIC_LOCK_MESSAGE
	mov cl, 0x3
	jmp Manager.doLock.cont
Manager.doLock.notFP :
mov ebx, Manager.UNKNOWN_LOCK_MESSAGE
mov cl, 0x3
Manager.doLock.cont :
call debug.println
mov eax, 0xa0000
call drawStringDirect

	mov ah, [Dolphin.activeWindow]
	mov [currentWindow], ah
	LockLoop :
		call os.pollKeyboard
		call os.getKey
		cmp bl, 0xfe
		jne LockLoop
	mov bl, 0x0
	mov [Manager.locked], bl
		mov bl, [Manager.reason]
		cmp bl, 0x01
			jne Manager.doLock.post.notFP
		call console.createWindow
	Manager.doLock.post.notFP :
popa
pop ebx
ret

drawStringDirect :
pusha
mov [charpos], eax
drawStringDirect.loop :
mov al, [ebx]
cmp al, 0x0
je drawStringDirect.ret
mov ah, cl
call graphics.drawChar
			push ecx
			mov ecx, [charpos]
			push ebx
			mov ebx, SCREEN_WIDTH*2
			add ecx, ebx
			mov [charpos], ecx
			pop ebx
			pop ecx
add ebx, 1
jmp drawStringDirect.loop
drawStringDirect.ret :
popa
ret

Manager.direct.num :		; num in ebx
		pusha
		mov [colorS], cl
		mov cl, 28
		mov ch, 0x0
		mov [charpos], eax
		Manager.direct.num.start :
			cmp ebx, 0x0
			jne Manager.direct.num.cont
			mov ah, [colorS]
			mov al, '0'
			call graphics.drawChar
					push ecx
					mov ecx, [charpos]
					push ebx
					mov ebx, SCREEN_WIDTH*2
					add ecx, ebx
					mov [charpos], ecx
					pop ebx
					pop ecx
			popa
			ret
			Manager.direct.num.cont :
		mov edx, ebx
		shr edx, cl
		and edx, 0xF
		cmp dx, 0x0
		je Manager.direct.num.checkZ
		mov ch, 0x1
		Manager.direct.num.dontcare :
		push ebx
		mov eax, edx
		cmp dx, 0x9
		jg Manager.direct.num.g10
		add eax, 0x30
		jmp Manager.direct.num.goPrint
		Manager.direct.num.g10 :
		add eax, 0x37
		Manager.direct.num.goPrint :
		mov ah, [colorS]
		call graphics.drawChar
			push ecx
			mov ecx, [charpos]
			push ebx
			mov ebx, SCREEN_WIDTH*2
			add ecx, ebx
			mov [charpos], ecx
			pop ebx
			pop ecx
		pop ebx
		Manager.direct.num.goCont :
		cmp cl, 0
		jle Manager.direct.num.end
		sub cl, 4
		jmp Manager.direct.num.start
		Manager.direct.num.checkZ :
		cmp ch, 0x0
		je Manager.direct.num.goCont
		jmp Manager.direct.num.dontcare
		Manager.direct.num.end :
		popa
		ret

Manager.locked :
	db 0x0
Manager.reason :
	db 0x0
Manager.astor :
	dd 0x0
Manager.bstor :
	dd 0x0
Manager.cstor :
	dd 0x0
Manager.dstor :
	dd 0x0
Manager.faultloc :
	db 0x0
Manager.lockMsg :
	db "Press [enter] to unlock the computer.", 0x0
Manager.LOCK_PREMESSAGE :
	db "Computer locked: ", 0x0
Manager.NORMAL_LOCK_MESSAGE :
	db "NORMAL", 0x0
Manager.FREEZEPANIC_LOCK_MESSAGE :
	db "FREEZE PANIC", 0x0
Manager.UNKNOWN_LOCK_MESSAGE :
	db "UNKNOWN", 0x0
Manager.EAX :
	db "EAX: ", 0
Manager.EBX :
	db "EBX: ", 0
Manager.ECX :
	db "ECX: ", 0
Manager.EDX :
	db "EDX: ", 0
Manager.LOC :
	db "Fault raised by ", 0
Manager.PROGRAM :
	db "a program", 0
Manager.OS :
	db "the kernel", 0
Manager.DOLPHIN :
	db "Dolphin (window manager)", 0