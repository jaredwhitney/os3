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
mov ax, 0x0102
int 0x30
mov ax, 0x0103
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
mov ecx, 20
push edx	; Begin getting subvar
mov edx, [HelloWorldWindowProgram.DisplayWindow.$local.w]
add dl, Window.xPos
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
call HelloWorldWindowProgram.PrintBufferInfo
mov ecx, [HelloWorldWindowProgram.DisplayWindow.$local.text]
push edx	; Begin getting subvar
mov edx, [HelloWorldWindowProgram.DisplayWindow.$local.w]
add dl, Window.buffer
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
call HelloWorldWindowProgram.PrintBufferInfo
pop edx
pop ebx
pop eax
push dword [HelloWorldWindowProgram.DisplayWindow.returnVal]
ret
	;Vars:
HelloWorldWindowProgram.DisplayWindow.string_0_data :
	db "Test Window", 0
HelloWorldWindowProgram.DisplayWindow.string_1_data :
	db "Txhxixsx xixsx xax xtxexsxtx.x", 0
HelloWorldWindowProgram.DisplayWindow.$local.w :
	dd 0x0
HelloWorldWindowProgram.DisplayWindow.string_1 :
	dd HelloWorldWindowProgram.DisplayWindow.string_1_data
HelloWorldWindowProgram.DisplayWindow.$local.text :
	dd 0x0
HelloWorldWindowProgram.DisplayWindow.string_0 :
	dd HelloWorldWindowProgram.DisplayWindow.string_0_data
HelloWorldWindowProgram.DisplayWindow.returnVal:
	dd 0x0


HelloWorldWindowProgram.PrintBufferInfo: 
pop dword [HelloWorldWindowProgram.PrintBufferInfo.returnVal]
pop dword [HelloWorldWindowProgram.PrintBufferInfo.$local.w]
push eax
push ebx
push edx
mov ecx, [HelloWorldWindowProgram.PrintBufferInfo.string_0]
push ecx
mov ax, 0x0100
int 0x30
push edx	; Begin getting subvar
mov edx, [HelloWorldWindowProgram.PrintBufferInfo.$local.w]
add dl, Window.buffer
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov ecx, [eax]
push ecx
mov ax, 0x0102
int 0x30
mov ax, 0x0103
int 0x30
mov ecx, [HelloWorldWindowProgram.PrintBufferInfo.string_1]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, [ecx]	; INLINE ASSEMBLY
push ecx	; INLINE ASSEMBLY
mov ax, 0x0102
int 0x30
mov ax, 0x0103
int 0x30
pop edx
pop ebx
pop eax
push dword [HelloWorldWindowProgram.PrintBufferInfo.returnVal]
ret
	;Vars:
HelloWorldWindowProgram.PrintBufferInfo.string_0 :
	dd HelloWorldWindowProgram.PrintBufferInfo.string_0_data
HelloWorldWindowProgram.PrintBufferInfo.$local.w :
	dd 0x0
HelloWorldWindowProgram.PrintBufferInfo.string_0_data :
	db "w.buffer: ", 0
HelloWorldWindowProgram.PrintBufferInfo.string_1 :
	dd HelloWorldWindowProgram.PrintBufferInfo.string_1_data
HelloWorldWindowProgram.PrintBufferInfo.string_1_data :
	db "[w.buffer]: ", 0
HelloWorldWindowProgram.PrintBufferInfo.returnVal:
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
jg HelloWorldWindowProgram.$comp_48.true
mov cl, 0x0
jmp HelloWorldWindowProgram.$comp_48.done
HelloWorldWindowProgram.$comp_48.true :
mov cl, 0xFF
HelloWorldWindowProgram.$comp_48.done :

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
jle HelloWorldWindowProgram.$comp_50.true
mov cl, 0x0
jmp HelloWorldWindowProgram.$comp_50.done
HelloWorldWindowProgram.$comp_50.true :
mov cl, 0xFF
HelloWorldWindowProgram.$comp_50.done :

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


; *** LIB IMPORT 'String' ***
[bits 32]
dd String.$FILE_END - String.$FILE_START
db "OrcaHLL Class", 0
db "String", 0
String.$FILE_START :

String.Append: 
pop dword [String.Append.returnVal]
pop dword [String.Append.$local.s]
push eax
push ebx
push edx
mov ecx, 0
mov [String.Append.$local.q], ecx
push ebx
mov ebx, ebx
mov ecx, [String.Append.$local.q]
push ecx
call String.GetChar
pop ebx
mov [String.Append.$local.ch], cl
String.$loop_while.0_open :
push edx
mov cl, [String.Append.$local.ch]
mov edx, ecx
mov ecx, 0
cmp edx, ecx
pop edx
jne String.$comp_4.true
mov cl, 0x0
jmp String.$comp_4.done
String.$comp_4.true :
mov cl, 0xFF
String.$comp_4.done :

cmp cl, 0xFF
	jne String.$loop_while.0_end
mov ecx, [ebx]	; INLINE ASSEMBLY
add ecx, [String.Append.$local.q]	; INLINE ASSEMBLY
sub ecx, 1	; INLINE ASSEMBLY
mov dl, [String.Append.$local.ch]	; INLINE ASSEMBLY
mov [ecx], dl	; INLINE ASSEMBLY
push edx	; Math start
mov ecx, 1
mov edx, ecx
mov ecx, [String.Append.$local.q]
add ecx, edx
pop edx	; Math end
mov [String.Append.$local.q], ecx
push ebx
mov ebx, ebx
mov ecx, [String.Append.$local.q]
push ecx
call String.GetChar
pop ebx
mov [String.Append.$local.ch], cl
	jmp String.$loop_while.0_open
String.$loop_while.0_end :
mov ecx, [ebx]	; INLINE ASSEMBLY
mov ecx, [String.Append.$local.q]	; INLINE ASSEMBLY
sub ecx, 1	; INLINE ASSEMBLY
mov byte [ecx], 0x0	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [String.Append.returnVal]
ret
	;Vars:
String.Append.$local.q :
	dd 0x0
String.Append.$local.s :
	dd 0x0
String.Append.$local.ch :
	db 0x0
String.Append.returnVal:
	dd 0x0


String.GetChar: 
pop dword [String.GetChar.returnVal]
pop dword [String.GetChar.$local.pos]
push eax
push ebx
push edx
mov ecx, [ebx]	; INLINE ASSEMBLY
add ecx, [String.GetChar.$local.pos]	; INLINE ASSEMBLY
mov cl, [ecx]	; INLINE ASSEMBLY
and ecx, 0xFF	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [String.GetChar.returnVal]
ret
	;Vars:
String.GetChar.$local.pos :
	dd 0x0
String.GetChar.returnVal:
	dd 0x0


String.SetChar: 
pop dword [String.SetChar.returnVal]
pop dword [String.SetChar.$local.pos]
pop dword [String.SetChar.$local.ch]
push eax
push ebx
push edx
mov ecx, [ebx]	; INLINE ASSEMBLY
add ecx, [String.SetChar.$local.pos]	; INLINE ASSEMBLY
mov al, [String.SetChar.$local.ch]	; INLINE ASSEMBLY
mov byte [ecx], al	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [String.SetChar.returnVal]
ret
	;Vars:
String.SetChar.$local.pos :
	dd 0x0
String.SetChar.$local.ch :
	dd 0x0
String.SetChar.returnVal:
	dd 0x0


String.RawToWhite: 
pop dword [String.RawToWhite.returnVal]
push eax
push ebx
push edx
push ebx
mov ebx, ebx
call String.GetLength
pop ebx
push ecx
mov ax, 0x0501
int 0x30
mov [String.RawToWhite.$local.ret], ecx
push ebx
mov ebx, ebx
call String.GetLength
pop ebx
mov [String.RawToWhite.$local.length], ecx
mov ecx, 0xFF
mov [String.RawToWhite.$local.white], cl
mov ecx, 0
mov [String.$loop_for.0.$local.z], ecx
String.$loop_for.0_open :
push edx	; Math start
mov ecx, 2
mov edx, ecx
mov ecx, [String.$loop_for.0.$local.z]
imul ecx, edx
pop edx	; Math end
mov [String.$loop_for.0.$local.offs], ecx
;			k.	; INLINE ASSEMBLY
push ebx
mov ebx, ebx
push edx	; Math start
mov ecx, 2
mov edx, ecx
mov ecx, [String.$loop_for.0.$local.z]
imul ecx, edx
pop edx	; Math end
push ecx
call String.GetChar
pop ebx
mov [String.$loop_for.0.$local.ch], cl
push ebx
mov ebx, String.RawToWhite.$local.ret
push edx	; Math start
mov ecx, 2
mov edx, ecx
mov ecx, [String.$loop_for.0.$local.z]
imul ecx, edx
pop edx	; Math end
push ecx
mov cl, [String.$loop_for.0.$local.ch]
push ecx
call String.SetChar
pop ebx
push ebx
mov ebx, String.RawToWhite.$local.ret
push edx	; Math start
push edx	; Math start
mov ecx, 1
mov edx, ecx
mov ecx, 2
add ecx, edx
pop edx	; Math end
mov edx, ecx
mov ecx, [String.$loop_for.0.$local.z]
add ecx, edx
pop edx	; Math end
push ecx
mov cl, [String.RawToWhite.$local.white]
push ecx
call String.SetChar
pop ebx
push edx	; Math start
mov ecx, 1
mov edx, ecx
mov ecx, [String.$loop_for.0.$local.z]
add ecx, edx
pop edx	; Math end
mov [String.$loop_for.0.$local.z], ecx
push edx
mov ecx, [String.$loop_for.0.$local.z]
mov edx, ecx
mov ecx, [String.RawToWhite.$local.length]
cmp edx, ecx
pop edx
jl String.$comp_40.true
mov cl, 0x0
jmp String.$comp_40.done
String.$comp_40.true :
mov cl, 0xFF
String.$comp_40.done :

cmp cl, 0xFF
	je String.$loop_for.0_open

pop edx
pop ebx
pop eax
push dword [String.RawToWhite.returnVal]
ret
	;Vars:
String.RawToWhite.$local.ret :
	dd 0x0
String.RawToWhite.$local.white :
	db 0x0
String.RawToWhite.$local.length :
	dd 0x0
String.$loop_for.0.$local.offs :
	dd 0x0
String.$loop_for.0.$local.ch :
	db 0x0
String.$loop_for.0.$local.z :
	dd 0x0
String.RawToWhite.returnVal:
	dd 0x0


String.GetLength: 
pop dword [String.GetLength.returnVal]
push eax
push ebx
push edx
mov ecx, 0
mov [String.GetLength.$local.ret], ecx
push ebx
mov ebx, ebx
mov ecx, [String.GetLength.$local.ret]
push ecx
call String.GetChar
pop ebx
mov [String.GetLength.$local.ch], cl
String.$loop_while.1_open :
push edx
mov cl, [String.GetLength.$local.ch]
mov edx, ecx
mov ecx, 0
cmp edx, ecx
pop edx
jne String.$comp_43.true
mov cl, 0x0
jmp String.$comp_43.done
String.$comp_43.true :
mov cl, 0xFF
String.$comp_43.done :

cmp cl, 0xFF
	jne String.$loop_while.1_end
push edx	; Math start
mov ecx, 1
mov edx, ecx
mov ecx, [String.GetLength.$local.ret]
add ecx, edx
pop edx	; Math end
mov [String.GetLength.$local.ret], ecx
push ebx
mov ebx, ebx
mov ecx, [String.GetLength.$local.ret]
push ecx
call String.GetChar
pop ebx
mov [String.GetLength.$local.ch], cl
	jmp String.$loop_while.1_open
String.$loop_while.1_end :
push edx	; Math start
mov ecx, 1
mov edx, ecx
mov ecx, [String.GetLength.$local.ret]
add ecx, edx
pop edx	; Math end
pop edx
pop ebx
pop eax
push dword [String.GetLength.returnVal]
ret
	;Vars:
String.GetLength.$local.ret :
	dd 0x0
String.GetLength.$local.ch :
	db 0x0
String.GetLength.returnVal:
	dd 0x0


String.$FILE_END :



