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
	
cmp ax, 0x0501
	jne _HANDLEFUNC1.next5
		pop dword [_arg0]
		mov ebx, [_arg0]
		call ProgramManager.reserveMemory
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
	
call kernel.halt
_HANDLEFUNC1.ret :
push dword [_HF1_s2]
push dword [_HF1_s1]
push dword [_HF1_s0]
iret

;_funcList :
;dd 0, Dolphin.moveWindow, Dolphin.sizeWindow, Dolphin.unregisterWindow, Image.copy, 0, os.seq, 0, Image.clear, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Minnow.byName, 0, Manager.lock, console.print, console.println, console.clearScreen, console.newline, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Catfish.notify, Keyboard.getKey, 0, 0, RTC.getSecond, RTC.getMinute, RTC.getHour, 0, RTC.getDay, RTC.getMonth, RTC.getYear, Guppy.malloc, 0, 0, 0
_arg0 :
dd 0
_HF1_s0 :
dd 0
_HF1_s1 :
dd 0
_HF1_s2 :
dd 0