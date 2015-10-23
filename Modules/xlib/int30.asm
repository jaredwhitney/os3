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
		popa
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.next0 :

cmp ax, 0x0101
	jne _HANDLEFUNC1.next1
		pop dword [_arg0]
		pusha
		mov ebx, [_arg0]
		call console.println
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
		pop ax
		jmp _HANDLEFUNC1.ret
	_HANDLEFUNC1.nextc5 :
	
cmp ax, 0x0202
	jne _HANDLEFUNC1.nextd1
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
	_HANDLEFUNC1.nextd1 :
	
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
		call KeyManager.hasEvent
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