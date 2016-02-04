_HANDLEFUNC1 :
pop dword [_HF1_s0]
pop dword [_HF1_s1]
pop dword [_HF1_s2]

cmp ax, 0x0001
	jne _HANDLEFUNC1.nexts
		pop dword [_arg0]
		; push eax
		; push ebx
		; push edx
		mov ebx, [_arg0]
		call System.getValue
		; pop edx
		; pop ebx
		; pop eax
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nexts :
	
cmp ax, 0x0100
	jne _HANDLEFUNC1.next0
		pop dword [_arg0]
		pusha
		mov ebx, [_arg0]
		call console.print
				pusha
				mov eax, ebx
				mov ebx, [TextLine.RenderTest.textarea]
				cmp ebx, 0
					je _HANDLEFUNC1.0_nop
					call TextArea.AppendText
				_HANDLEFUNC1.0_nop :
				popa
		popa
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.next0 :

cmp ax, 0x0101
	jne _HANDLEFUNC1.next1
		pop dword [_arg0]
		pusha
		mov ebx, [_arg0]
		call console.println
				pusha
				mov eax, ebx
				mov ebx, [TextLine.RenderTest.textarea]
				cmp ebx, 0
					je _HANDLEFUNC1.1_nop
					call TextArea.AppendText
					mov al, 0x0A
					call TextArea.AppendChar
				_HANDLEFUNC1.1_nop :
				popa
		popa
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.next1 :

cmp ax, 0x0102
	jne _HANDLEFUNC1.next2
		pop dword [_arg0]
		pusha
		mov ebx, [_arg0]
		call console.numOut
		popa
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.next2 :
		
cmp ax, 0x0103
	jne _HANDLEFUNC1.next3
		call console.newline
				pusha
				mov ebx, [TextLine.RenderTest.textarea]
				cmp ebx, 0
					je _HANDLEFUNC1.3_nop
					mov al, 0x0A
					call TextArea.AppendChar
				_HANDLEFUNC1.3_nop :
				popa
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.next3 :
	
cmp ax, 0x0104
	jne _HANDLEFUNC1.next4
		call console.clearScreen
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.next4 :

cmp ax, 0x0105
	jne _HANDLEFUNC1.nextc5
		pop dword [_arg0]
		push ax
		mov ah, 0xFF
		mov al, [_arg0]
		call console.cprint
				pusha
				mov ebx, [TextLine.RenderTest.textarea]
				cmp ebx, 0
					je _HANDLEFUNC1.c5_nop
					call TextArea.AppendChar
					call Component.RequestUpdate
				_HANDLEFUNC1.c5_nop :
				popa
		pop ax
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextc5 :

cmp ax, 0x0106
	jne _HANDLEFUNC1.nextc6
		mov ecx, [console.windowStructLoc]
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextc6 :
	
cmp ax, 0x0107
	jne _HANDLEFUNC1.nextc7
		pop dword ecx
		mov dword [console.color], ecx
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextc7 :
	
cmp ax, 0x0108
	jne _HANDLEFUNC1.nextc8
		pop dword ecx
		mov byte [console.vgacolor], cl
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextc8 :
	
cmp ax, 0x0200
	jne _HANDLEFUNC1.nextd0
		pop dword [_arg0]
		push ebx
		push eax
		mov eax, [_arg0]
		call Dolphin.registerWindow
		xor ecx, ecx
		mov cl, bl
		pop eax
		pop ebx
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextd0 :
	
cmp ax, 0x0201
	jne _HANDLEFUNC1.nextd1
		pop dword [_arg0]
		push ebx
		push eax
		mov eax, [_arg0]
		mov [Dolphin.currentWindow], eax
		mov bl, [Window.WIN_NUM]
		call Dolphin.getAttribByte
		xor ebx, ebx
		mov bl, al
		call Dolphin.unregisterWindow
		pop eax
		pop ebx
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextd1 :

cmp ax, 0x0202
	jne _HANDLEFUNC1.nextd2
		pop dword [_arg1]
		pop dword [_arg0]
		push eax
		push ebx
		push edx
		push dword [_arg0]
		push word [_arg1]
		call Window.create
		pop edx
		pop ebx
		pop eax
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextd2 :
	
cmp ax, 0x0501
	jne _HANDLEFUNC1.next5
		pop dword [_arg0]
		push ebx
		mov ebx, [_arg0]
		call ProgramManager.reserveMemory
		mov ecx, ebx
		pop ebx
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.next5 :
	
cmp ax, 0x0502
	jne _HANDLEFUNC1.next6
		pop dword [_arg0]
		push eax
		push ebx
		push edx
		mov ebx, [_arg0]
		push ebx
		call ProgramManager.reserveMemory
		mov eax, ebx
		pop ebx
		call Buffer.clear
		mov ecx, eax
		pop edx
		pop ebx
		pop eax
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.next6 :
	
cmp ax, 0x0404
	jne _HANDLEFUNC1.next7
		pop dword [_arg0]
		push ebx
		mov ebx, [_arg0]
		mov [Dolphin.currentWindow], ebx
		call KeyManager.hasEvent
		pop ebx
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.next7 :

cmp ax, 0x0405
	jne _HANDLEFUNC1.next8
		pop dword [_arg0]
		push ebx
		mov ebx, [_arg0]
		mov [Dolphin.currentWindow], ebx
		call Keyboard.getKey
		mov cl, bl
		pop ebx
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.next8 :
	
cmp ax, 0x0701
	jne _HANDLEFUNC1.nextt1
		push ebx
		call RTC.getSecond
		mov ecx, ebx
		pop ebx
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextt1 :

cmp ax, 0x0702
	jne _HANDLEFUNC1.nextt2
		push ebx
		call RTC.getMinute
		mov ecx, ebx
		pop ebx
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextt2 :

cmp ax, 0x0703
	jne _HANDLEFUNC1.nextt3
		push ebx
		call RTC.getHour
		mov ecx, ebx
		pop ebx
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextt3 :
	
cmp ax, 0x0704
	jne _HANDLEFUNC1.nextt4
		push ebx
		call RTC.getYear
		mov ecx, ebx
		pop ebx
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextt4 :
	
cmp ax, 0x0705
	jne _HANDLEFUNC1.nextt5
		push ebx
		call RTC.getMonth
		mov ecx, ebx
		pop ebx
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextt5 :
	
cmp ax, 0x0706
	jne _HANDLEFUNC1.nextt6
		push ebx
		call RTC.getDay
		mov ecx, ebx
		pop ebx
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextt6 :
	
call kernel.halt
_HANDLEFUNC1.ret :
push dword [_HF1_s2]
push dword [_HF1_s1]
push dword [_HF1_s0]
iret


_arg0 :
dd 0
_arg1 :
dd 0
_HF1_s0 :
dd 0
_HF1_s1 :
dd 0
_HF1_s2 :
dd 0