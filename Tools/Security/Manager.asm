
Manager.CONTROL_OS		equ 0x0
Manager.CONTROL_MODULES	equ 0x1
Manager.CONTROL_DOLPHIN	equ 0x2

Manager.handleLock :
push bx
mov bl, [Manager.locked]
cmp bl, 0x0
pop bx
jne Manager.doLock
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

Manager.customLock :
push ebx
call Manager.lock
mov [Manager.reason], bl
pop ebx
ret

Manager.doLock :
pusha

mov edx, [Graphics.SCREEN_SIZE]
mov eax, [Graphics.SCREEN_MEMPOS]
mov ebx, 0x0
call Image.clear
		pusha
		mov eax, [Graphics.SCREEN_MEMPOS]
		mov [Manager.cvalstor], eax		; Graphics.SCREEN_MEMPOS
		
		mov eax, [Graphics.SCREEN_WIDTH]
		mov ecx, 2
		xor edx, edx
		idiv ecx
		mov ecx, [Manager.cvalstor]
		add ecx, eax
		mov [Manager.cvalstor], ecx		; + Graphics.SCREEN_WIDTH/2
		
		mov eax, [Graphics.SCREEN_HEIGHT]
		mov ecx, 3
		xor edx, edx
		idiv ecx
		sub eax, 4
		mov ebx, [Graphics.SCREEN_WIDTH]
		imul eax, ebx
		mov ecx, [Manager.cvalstor]
		add ecx, eax
		mov [Manager.cvalstor], ecx		; + ((Graphics.SCREEN_HEIGHT/4)-4)*Graphics.SCREEN_WIDTH
		
		mov eax, 3	; font width/2
		mov ebx, 37	; string length
		imul eax, ebx
		mov ebx, [Graphics.bytesPerPixel]
		imul eax, ebx
		mov ecx, [Manager.cvalstor]
		sub ecx, eax
		mov [Manager.cvalstor], ecx
		
		popa
mov eax, [Manager.cvalstor] ; Graphics.SCREEN_MEMPOS + Graphics.SCREEN_WIDTH/2 + ((Graphics.SCREEN_HEIGHT/4)-4)*Graphics.SCREEN_WIDTH - 3*37	; FIX THIS!
mov ebx, Manager.lockMsg
mov cl, WHITE
call drawStringDirect
mov cl, 0xD0
	push edx
	mov edx, [Graphics.SCREEN_WIDTH]
	imul edx, 16
	add eax, edx
	pop edx
	;add eax, Graphics.SCREEN_WIDTH*16	[see above code]
mov ebx, Manager.EAX
call drawStringDirect
push ebx
	mov ebx, 6*5	; char width times 5 chars per "E_X: "
	imul ebx, [Graphics.bytesPerPixel]
	mov [Manager.cvalstor], ebx
pop ebx
add eax, [Manager.cvalstor]
; print contents of eax
	mov ebx, [Manager.astor]
	call Manager.direct.num
		push edx
		mov edx, [Graphics.SCREEN_WIDTH]
		imul edx, 8
		sub edx, [Manager.cvalstor]
		add eax, edx
		pop edx
;add eax, Graphics.SCREEN_WIDTH*8-24	 [see above code]
mov ebx, Manager.EBX
call drawStringDirect
add eax, [Manager.cvalstor]
; print contents of ebx
	mov ebx, [Manager.bstor]
	call Manager.direct.num
		push edx
		mov edx, [Graphics.SCREEN_WIDTH]
		imul edx, 8
		sub edx, [Manager.cvalstor]
		add eax, edx
		pop edx
;add eax, Graphics.SCREEN_WIDTH*8-24
mov ebx, Manager.ECX
call drawStringDirect
add eax, [Manager.cvalstor]
; print contents of ecx
	mov ebx, [Manager.cstor]
	call Manager.direct.num
		push edx
		mov edx, [Graphics.SCREEN_WIDTH]
		imul edx, 8
		sub edx, [Manager.cvalstor]
		add eax, edx
		pop edx
;add eax, Graphics.SCREEN_WIDTH*8-24
mov ebx, Manager.EDX
call drawStringDirect
add eax, [Manager.cvalstor]
; print contents of edx
	mov ebx, [Manager.dstor]
	call Manager.direct.num
		push edx
		mov edx, [Graphics.SCREEN_WIDTH]
		imul edx, 8
		sub edx, [Manager.cvalstor]
		add eax, edx
		pop edx
;add eax, Graphics.SCREEN_WIDTH*8-24
mov ebx, Manager.LOC
mov [Manager.cvalstor], eax
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
push ebx
mov ebx, 16*6
imul ebx, [Graphics.bytesPerPixel]
add eax, ebx
pop ebx
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
mov eax, [Graphics.SCREEN_MEMPOS]
call drawStringDirect
; ***************************************************************
		mov eax, [Manager.cvalstor]
		push edx
		mov edx, [Graphics.SCREEN_WIDTH]
		imul edx, 8
		add eax, edx
		pop edx
				mov cl, 0xD0
				mov ebx, Manager.ACTIVE_WINS
				call drawStringDirect
						push edx
						mov edx, 16*6
						imul edx, [Graphics.bytesPerPixel]
						add eax, edx
						pop edx
			push eax
			call Dolphin.activeWinNum
			mov ebx, eax
			pop eax
			mov cl, 0xD0
			call Manager.direct.num
; ***************************************************************
	mov ah, [Dolphin.activeWindow]
	mov [Dolphin.currentWindow], ah
	LockLoop :
		call Keyboard.poll
		call Keyboard.getKey
		cmp bl, 0xfe
		jne LockLoop
	mov bl, 0x0
	mov [Manager.locked], bl
		mov bl, [Manager.reason]
		cmp bl, 0x01
			jne Manager.doLock.post.notFP
		call console.rereg
	Manager.doLock.post.notFP :
	
	mov eax, [Graphics.SCREEN_MEMPOS]	; clear out residual data from the lock screen
	mov edx, [Graphics.SCREEN_SIZE]
	mov ebx, 0x0
	call Image.clear
	;mov eax, [Dolphin.SCREEN_FLIPBUFFER]	; force entire screen to redraw itself on next update
	;mov edx, [Graphics.SCREEN_SIZE]
	;mov ebx, 0x0
	;call Image.clear
	
popa
ret

drawStringDirect :
pusha
push eax
mov eax, [Graphics.SCREEN_WIDTH]
mov [TextHandler.textWidth], eax
pop eax
mov [TextHandler.charpos], eax
drawStringDirect.loop :
mov al, [ebx]
cmp al, 0x0
je drawStringDirect.ret
mov ah, cl
call TextHandler.drawChar
add ebx, 1
jmp drawStringDirect.loop
drawStringDirect.ret :
popa
ret

Manager.direct.num :		; num in ebx
		pusha
		mov [TextHandler.selectedColor], cl
		mov cl, 28
		mov ch, 0x0
		mov [TextHandler.charpos], eax
		Manager.direct.num.start :
			cmp ebx, 0x0
			jne Manager.direct.num.cont
			mov ah, [TextHandler.selectedColor]
			mov al, '0'
			call TextHandler.drawChar
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
		mov ah, [TextHandler.selectedColor]
		call TextHandler.drawChar
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
	db 0x1
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
Manager.cvalstor :
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
Manager.ACTIVE_WINS :
	db "Active windows: ", 0
Manager.PROGRAM :
	db "a program", 0
Manager.OS :
	db "the kernel", 0
Manager.DOLPHIN :
	db "Dolphin (window manager)", 0
