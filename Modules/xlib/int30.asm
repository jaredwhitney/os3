_HANDLEFUNC1 :
pop dword [_HF1retval]
cmp ax, 0x2
	jne _HANDLEFUNC1.next1
		pop dword [_arg0]
		pusha
		mov ebx, [_arg0]
		call console.println
		popa
_HANDLEFUNC1.next1 :
push dword [_HF1retval]
iret

;_funcList :
;dd 0, Dolphin.moveWindow, Dolphin.sizeWindow, Dolphin.unregisterWindow, Image.copy, 0, os.seq, 0, Image.clear, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Minnow.byName, 0, Manager.lock, console.print, console.println, console.clearScreen, console.newline, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Catfish.notify, Keyboard.getKey, 0, 0, RTC.getSecond, RTC.getMinute, RTC.getHour, 0, RTC.getDay, RTC.getMonth, RTC.getYear, Guppy.malloc, 0, 0, 0
_arg0 :
dd 0
_HF1retval :
dd 0
;System.function :
;dw 0