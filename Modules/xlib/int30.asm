_HANDLEFUNC1 :
push eax
xor eax, eax
mov ax, [System.function]
imul eax, 4
add eax, _funcList
mov eax, [eax]
mov [_function], eax
pop eax
pusha
call [_function]
popa
iret

_funcList :
dd 0, Dolphin.moveWindow, Dolphin.sizeWindow, Dolphin.unregisterWindow, Image.copy, 0, os.seq, 0, Image.clear, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Minnow.byName, 0, Manager.lock, console.print, console.println, console.clearScreen, console.newline, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Catfish.notify, Keyboard.getKey, 0, 0, RTC.getSecond, RTC.getMinute, RTC.getHour, 0, RTC.getDay, RTC.getMonth, RTC.getYear, Guppy.malloc, 0, 0, 0
_function :
dd 0
System.function :
dw 0