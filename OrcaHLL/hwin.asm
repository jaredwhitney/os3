[bits 32]

dd HelloWorldWindowProgram.$FILE_END - HelloWorldWindowProgram.$FILE_START
db "OrcaHLL Class", 0
db "HelloWorldWindowProgram", 0
HelloWorldWindowProgram.$FILE_START :

HelloWorldWindowProgram.$global.type_text :
	dw 0x0
HelloWorldWindowProgram._init: 
pop dword [HelloWorldWindowProgram._init.returnVal]
push eax
push ebx
push edx
mov ecx, [HelloWorldWindowProgram._init.string_0]
push ecx
mov ax, 0x0101
int 0x30
call HelloWorldWindowProgram.DisplayWindow
mov ecx, 30
mov [HelloWorldWindowProgram._init.$local.ramPercent], ecx
mov ecx, [HelloWorldWindowProgram._init.$local.ramPercent]
push ecx
call HelloWorldWindowProgram.PrintRamInfo
mov ecx, [HelloWorldWindowProgram._init.string_1]
push ecx
mov ax, 0x0100
int 0x30
call HelloWorldWindowProgram.AddOneAndTwo
push ecx
mov ax, 0x0100
int 0x30
pop edx
pop ebx
pop eax
push dword [HelloWorldWindowProgram._init.returnVal]
ret
	;Vars:
HelloWorldWindowProgram._init.string_0_data :
	db "Hello world!", 0
HelloWorldWindowProgram._init.$local.ramPercent :
	dd 0x0
HelloWorldWindowProgram._init.string_0 :
	dd HelloWorldWindowProgram._init.string_0_data
HelloWorldWindowProgram._init.string_1_data :
	db "1 + 2 = ", 0
HelloWorldWindowProgram._init.string_1 :
	dd HelloWorldWindowProgram._init.string_1_data
HelloWorldWindowProgram._init.returnVal:
	dd 0x0


HelloWorldWindowProgram.DisplayWindow: 
pop dword [HelloWorldWindowProgram.DisplayWindow.returnVal]
push eax
push ebx
push edx
mov ecx, [HelloWorldWindowProgram.DisplayWindow.string_0]
push ecx
mov cx, [HelloWorldWindowProgram.$global.type_text]
push ecx
mov ax, 0x0202
int 0x30
mov [HelloWorldWindowProgram.DisplayWindow.$local.w], ecx
mov ecx, [HelloWorldWindowProgram.DisplayWindow.string_1]
mov [HelloWorldWindowProgram.DisplayWindow.$local.text], ecx
mov ecx, [HelloWorldWindowProgram.DisplayWindow.$local.text]
push edx	; Begin getting subvar
mov edx, [HelloWorldWindowProgram.DisplayWindow.$local.w]
add dl, Window.buffer
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
pop edx
pop ebx
pop eax
push dword [HelloWorldWindowProgram.DisplayWindow.returnVal]
ret
	;Vars:
HelloWorldWindowProgram.DisplayWindow.string_0_data :
	db "Test Window", 0
HelloWorldWindowProgram.DisplayWindow.string_1 :
	dd HelloWorldWindowProgram.DisplayWindow.string_1_data
HelloWorldWindowProgram.DisplayWindow.string_1_data :
	db "Hello World", 0
HelloWorldWindowProgram.DisplayWindow.$local.w :
	dd 0x0
HelloWorldWindowProgram.DisplayWindow.$local.text :
	dd 0x0
HelloWorldWindowProgram.DisplayWindow.string_0 :
	dd HelloWorldWindowProgram.DisplayWindow.string_0_data
HelloWorldWindowProgram.DisplayWindow.returnVal:
	dd 0x0


HelloWorldWindowProgram.PrintRamInfo: 
pop dword [HelloWorldWindowProgram.PrintRamInfo.returnVal]
pop dword [HelloWorldWindowProgram.PrintRamInfo.$local.ramPercent]
push eax
push ebx
push edx
push edx
mov ecx, [HelloWorldWindowProgram.PrintRamInfo.$local.ramPercent]
mov edx, ecx
mov ecx, 50
cmp edx, ecx
pop edx
jg HelloWorldWindowProgram.$comp_17.true
mov cl, 0x0
jmp HelloWorldWindowProgram.$comp_17.done
HelloWorldWindowProgram.$comp_17.true :
mov cl, 0xFF
HelloWorldWindowProgram.$comp_17.done :

cmp cl, 0xFF
	jne HelloWorldWindowProgram.$loop_if.0_close
mov ecx, [HelloWorldWindowProgram.$loop_if.0.string_0]
push ecx
mov ax, 0x0101
int 0x30
HelloWorldWindowProgram.$loop_if.0_close :

push edx
mov ecx, [HelloWorldWindowProgram.PrintRamInfo.$local.ramPercent]
mov edx, ecx
mov ecx, 50
cmp edx, ecx
pop edx
jle HelloWorldWindowProgram.$comp_19.true
mov cl, 0x0
jmp HelloWorldWindowProgram.$comp_19.done
HelloWorldWindowProgram.$comp_19.true :
mov cl, 0xFF
HelloWorldWindowProgram.$comp_19.done :

cmp cl, 0xFF
	jne HelloWorldWindowProgram.$loop_if.1_close
mov ecx, [HelloWorldWindowProgram.$loop_if.1.string_0]
push ecx
mov ax, 0x0101
int 0x30
HelloWorldWindowProgram.$loop_if.1_close :

mov ecx, [HelloWorldWindowProgram.PrintRamInfo.string_0]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, [HelloWorldWindowProgram.PrintRamInfo.$local.ramPercent]
push ecx
mov ax, 0x0102
int 0x30
mov ecx, [HelloWorldWindowProgram.PrintRamInfo.string_1]
push ecx
mov ax, 0x0103
int 0x30
pop edx
pop ebx
pop eax
push dword [HelloWorldWindowProgram.PrintRamInfo.returnVal]
ret
	;Vars:
HelloWorldWindowProgram.PrintRamInfo.string_1 :
	dd HelloWorldWindowProgram.PrintRamInfo.string_1_data
HelloWorldWindowProgram.PrintRamInfo.$local.ramPercent :
	dd 0x0
HelloWorldWindowProgram.PrintRamInfo.string_1_data :
	db "", 0
HelloWorldWindowProgram.PrintRamInfo.string_0_data :
	db "Percentage of RAM in use: ", 0
HelloWorldWindowProgram.PrintRamInfo.string_0 :
	dd HelloWorldWindowProgram.PrintRamInfo.string_0_data
HelloWorldWindowProgram.$loop_if.1.string_0 :
	dd HelloWorldWindowProgram.$loop_if.1.string_0_data
HelloWorldWindowProgram.$loop_if.0.string_0 :
	dd HelloWorldWindowProgram.$loop_if.0.string_0_data
HelloWorldWindowProgram.$loop_if.0.string_0_data :
	db "Over half of RAM in use!", 0
HelloWorldWindowProgram.$loop_if.1.string_0_data :
	db "Under half of RAM in use!", 0
HelloWorldWindowProgram.PrintRamInfo.returnVal:
	dd 0x0


HelloWorldWindowProgram.AddOneAndTwo: 
pop dword [HelloWorldWindowProgram.AddOneAndTwo.returnVal]
push eax
push ebx
push edx
push edx	; Math start
mov ecx, 2
mov edx, ecx
mov ecx, 1
add ecx, edx
pop edx	; Math end
pop edx
pop ebx
pop eax
push dword [HelloWorldWindowProgram.AddOneAndTwo.returnVal]
ret
	;Vars:
HelloWorldWindowProgram.AddOneAndTwo.returnVal:
	dd 0x0


HelloWorldWindowProgram.$FILE_END :
; *** LIB IMPORT 'Window' ***
[bits 32]
dd Window.$FILE_END - Window.$FILE_START
db "OrcaHLL Class", 0
db "Window", 0
Window.$FILE_START :

Window.winNum equ 38
Window.yPos equ 16
Window.windowBuffer equ 22
Window.xPos equ 12
Window.title equ 0
Window.type equ 20
Window.depth equ 21
Window.lastYpos equ 18
Window.lastXpos equ 14
Window.width equ 4
Window.lastWidth equ 6
Window.buffer equ 26
Window.lastHeight equ 10
Window.oldBuffer equ 34
Window.height equ 8
Window.bufferSize equ 30

Window.$global.TYPE_TEXT :
	dd 0x0
Window._dummyFunc: 
pop dword [Window._dummyFunc.returnVal]
push eax
push ebx
push edx
mov ecx, 0
mov [Window._dummyFunc.$local.y], ecx
pop edx
pop ebx
pop eax
push dword [Window._dummyFunc.returnVal]
ret
	;Vars:
Window._dummyFunc.$local.y :
	dd 0x0
Window._dummyFunc.returnVal:
	dd 0x0


Window.$FILE_END :



