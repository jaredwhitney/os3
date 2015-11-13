[bits 32]

dd iConsole.$FILE_END - iConsole.$FILE_START
db "OrcaHLL Class", 0
db "iConsole", 0
iConsole.$FILE_START :

iConsole.$global.window :
	dd 0x0
iConsole.$global.win :
	dd 0x0
iConsole.$global.command :
	dd 0x0
iConsole._init: 
pop dword [iConsole._init.returnVal]
push eax
push ebx
push edx
mov ax, 0x0106
int 0x30
mov [iConsole.$global.window], ecx
mov ecx, 80
push ecx
mov ax, 0x0502
int 0x30
mov [iConsole.$global.command], ecx
mov ecx, [iConsole._init.string_0]
push ecx
mov ax, 0x0100
int 0x30
pop edx
pop ebx
pop eax
push dword [iConsole._init.returnVal]
ret
	;Vars:
iConsole._init.string_0 :
	dd iConsole._init.string_0_data
iConsole._init.string_0_data :
	db "Console: ", 0
iConsole._init.returnVal:
	dd 0x0


iConsole._loop: 
pop dword [iConsole._loop.returnVal]
push eax
push ebx
push edx
mov ecx, [iConsole.$global.window]
push ecx
mov ax, 0x0404
int 0x30
cmp cl, 0xFF
	jne iConsole.$loop_if.0_close
mov ecx, [iConsole.$global.window]
push ecx
mov ax, 0x0405
int 0x30
mov [iConsole.$loop_if.0.$local.ch], cl
push edx
xor ecx, ecx
mov cl, [iConsole.$loop_if.0.$local.ch]
mov edx, ecx
xor ecx, ecx
mov cl, [Key.$global.ENTER]
cmp edx, ecx
pop edx
jne iConsole.$comp_14.true
mov cl, 0x0
jmp iConsole.$comp_14.done
iConsole.$comp_14.true :
mov cl, 0xFF
iConsole.$comp_14.done :

cmp cl, 0xFF
	jne iConsole.$loop_if.1_close
push edx
xor ecx, ecx
mov cl, [iConsole.$loop_if.0.$local.ch]
mov edx, ecx
xor ecx, ecx
mov cl, [Key.$global.KEY_SHIFT]
cmp edx, ecx
pop edx
jne iConsole.$comp_15.true
mov cl, 0x0
jmp iConsole.$comp_15.done
iConsole.$comp_15.true :
mov cl, 0xFF
iConsole.$comp_15.done :

cmp cl, 0xFF
	jne iConsole.$loop_if.2_close
push ebx
mov ebx, iConsole.$global.command
xor ecx, ecx
mov cl, [iConsole.$loop_if.0.$local.ch]
push ecx
call String.AppendChar
pop ebx
xor ecx, ecx
mov cl, [iConsole.$loop_if.0.$local.ch]
push ecx
mov ax, 0x0105
int 0x30
iConsole.$loop_if.2_close :

iConsole.$loop_if.1_close :

push edx
xor ecx, ecx
mov cl, [iConsole.$loop_if.0.$local.ch]
mov edx, ecx
xor ecx, ecx
mov cl, [Key.$global.ENTER]
cmp edx, ecx
pop edx
je iConsole.$comp_19.true
mov cl, 0x0
jmp iConsole.$comp_19.done
iConsole.$comp_19.true :
mov cl, 0xFF
iConsole.$comp_19.done :

cmp cl, 0xFF
	jne iConsole.$loop_if.3_close
mov ax, 0x0103
int 0x30
push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.4.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.4_close
mov ecx, [iConsole.$loop_if.4.string_1]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.4.string_2]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.4.string_3]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.4.string_4]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.4.string_5]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.4.string_6]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.4.string_7]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.4.string_8]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.4.string_9]
push ecx
mov ax, 0x0101
int 0x30
iConsole.$loop_if.4_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.5.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.5_close
mov ax, 0x0104
int 0x30
iConsole.$loop_if.5_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.6.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.6_close
mov ecx, [iConsole.$global.window]
push ecx
mov ax, 0x0201
int 0x30
iConsole.$loop_if.6_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.7.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.7_close
mov ecx, 0
push edx	; Begin getting subvar
mov edx, [iConsole.$global.window]
add dl, Window.xPos
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, 8
push edx	; Begin getting subvar
mov edx, [iConsole.$global.window]
add dl, Window.yPos
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, 0x1	; System Constant
push ecx
mov ax, 0x0001
int 0x30
push edx	; Begin getting subvar
mov edx, [iConsole.$global.window]
add dl, Window.width
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, 0x2	; System Constant
push ecx
mov ax, 0x0001
int 0x30
push edx	; Begin getting subvar
mov edx, [iConsole.$global.window]
add dl, Window.height
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
iConsole.$loop_if.7_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.8.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.8_close
call Manager.lock	; INLINE ASSEMBLY
iConsole.$loop_if.8_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.9.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.9_close
mov ecx, [iConsole.$loop_if.9.string_1]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, 0x5	; System Constant
push ecx
mov ax, 0x0001
int 0x30
push ecx
mov ax, 0x0102
int 0x30
mov ecx, [iConsole.$loop_if.9.string_2]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, 0x4	; System Constant
push ecx
mov ax, 0x0001
int 0x30
push ecx
mov ax, 0x0102
int 0x30
mov ax, 0x0103
int 0x30
iConsole.$loop_if.9_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.10.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.10_close
mov ecx, [iConsole.$global.window]
push ecx
mov ax, 0x0102
int 0x30
mov ax, 0x0103
int 0x30
mov ecx, [iConsole.$global.window]
mov ecx, [ecx]	; ptr
push ecx
mov ax, 0x0102
int 0x30
mov ax, 0x0103
int 0x30
iConsole.$loop_if.10_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.11.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.11_close
mov ecx, 0x0B
push ecx
mov ax, 0x0108
int 0x30
mov ax, 0x0703
int 0x30
push ecx
mov ax, 0x0102
int 0x30
mov ecx, [iConsole.$loop_if.11.string_1]
push ecx
mov ax, 0x0100
int 0x30
mov ax, 0x0702
int 0x30
push ecx
mov ax, 0x0102
int 0x30
mov ecx, [iConsole.$loop_if.11.string_2]
push ecx
mov ax, 0x0100
int 0x30
mov ax, 0x0701
int 0x30
push ecx
mov ax, 0x0102
int 0x30
mov ecx, [iConsole.$loop_if.11.string_3]
push ecx
mov ax, 0x0100
int 0x30
mov ax, 0x0705
int 0x30
push ecx
mov ax, 0x0102
int 0x30
mov ecx, [iConsole.$loop_if.11.string_4]
push ecx
mov ax, 0x0100
int 0x30
mov ax, 0x0706
int 0x30
push ecx
mov ax, 0x0102
int 0x30
mov ecx, [iConsole.$loop_if.11.string_5]
push ecx
mov ax, 0x0100
int 0x30
mov ax, 0x0704
int 0x30
push ecx
mov ax, 0x0102
int 0x30
mov ax, 0x0103
int 0x30
iConsole.$loop_if.11_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.12.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.12_close
call Minnow.ctree	; INLINE ASSEMBLY
iConsole.$loop_if.12_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.13.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.13_close
mov eax, SysHaltScreen.RESET	; INLINE ASSEMBLY
mov ecx, [iConsole.$loop_if.13.string_1]
mov ebx, ecx	; INLINE ASSEMBLY
mov ecx, 5	; INLINE ASSEMBLY
call SysHaltScreen.show	; INLINE ASSEMBLY
iConsole.$loop_if.13_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.14.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.14_close
call Library._init	; INLINE ASSEMBLY
iConsole.$loop_if.14_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.15.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.15_close
call VideoInfo._init	; INLINE ASSEMBLY
iConsole.$loop_if.15_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.16.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.16_close
call TestProgram._init	; INLINE ASSEMBLY
iConsole.$loop_if.16_close :

mov ecx, [iConsole.$loop_if.3.string_0]
push ecx
mov ax, 0x0100
int 0x30
push ebx
mov ebx, iConsole.$global.command
mov ecx, 0
push ecx
xor ecx, ecx
mov cl, [Char.$global.NUL]
push ecx
call String.SetChar
pop ebx
iConsole.$loop_if.3_close :

iConsole.$loop_if.0_close :

pop edx
pop ebx
pop eax
push dword [iConsole._loop.returnVal]
ret
	;Vars:
iConsole.$loop_if.11.string_3 :
	dd iConsole.$loop_if.11.string_3_data
iConsole.$loop_if.7.string_0_data :
	db "fullscreen", 0
iConsole.$loop_if.4.string_2 :
	dd iConsole.$loop_if.4.string_2_data
iConsole.$loop_if.13.string_1_data :
	db "Restarting the computer.", 0
iConsole.$loop_if.11.string_1 :
	dd iConsole.$loop_if.11.string_1_data
iConsole.$loop_if.11.string_3_data :
	db " ", 0
iConsole.$loop_if.4.string_9 :
	dd iConsole.$loop_if.4.string_9_data
iConsole.$loop_if.4.string_3 :
	dd iConsole.$loop_if.4.string_3_data
iConsole.$loop_if.11.string_0 :
	dd iConsole.$loop_if.11.string_0_data
iConsole.$loop_if.4.string_5_data :
	db "lock: Locks the computer.", 0
iConsole.$loop_if.4.string_6_data :
	db "memstat: Prints out the percentage of RAM in use.", 0
iConsole.$loop_if.4.string_8 :
	dd iConsole.$loop_if.4.string_8_data
iConsole.$loop_if.4.string_1_data :
	db "clear: Clears the screen.", 0
iConsole.$loop_if.14.string_0 :
	dd iConsole.$loop_if.14.string_0_data
iConsole.$loop_if.15.string_0_data :
	db "OHLL videoinfo", 0
iConsole.$loop_if.16.string_0 :
	dd iConsole.$loop_if.16.string_0_data
iConsole.$loop_if.12.string_0_data :
	db "tree", 0
iConsole.$loop_if.12.string_0 :
	dd iConsole.$loop_if.12.string_0_data
iConsole.$loop_if.11.string_2_data :
	db ":", 0
iConsole.$loop_if.7.string_0 :
	dd iConsole.$loop_if.7.string_0_data
iConsole.$loop_if.9.string_2 :
	dd iConsole.$loop_if.9.string_2_data
iConsole.$loop_if.3.string_0_data :
	db "Console: ", 0
iConsole.$loop_if.9.string_1 :
	dd iConsole.$loop_if.9.string_1_data
iConsole.$loop_if.6.string_0_data :
	db "exit", 0
iConsole.$loop_if.16.string_0_data :
	db "OHLL test", 0
iConsole.$loop_if.3.string_0 :
	dd iConsole.$loop_if.3.string_0_data
iConsole.$loop_if.10.string_0_data :
	db "test", 0
iConsole.$loop_if.13.string_0_data :
	db "restart", 0
iConsole.$loop_if.4.string_0 :
	dd iConsole.$loop_if.4.string_0_data
iConsole.$loop_if.11.string_4 :
	dd iConsole.$loop_if.11.string_4_data
iConsole.$loop_if.11.string_5_data :
	db "-", 0
iConsole.$loop_if.9.string_0_data :
	db "memstat", 0
iConsole.$loop_if.4.string_2_data :
	db "exit: Exits the console.", 0
iConsole.$loop_if.13.string_0 :
	dd iConsole.$loop_if.13.string_0_data
iConsole.$loop_if.4.string_9_data :
	db "tree: Displays all mounted files.", 0
iConsole.$loop_if.4.string_1 :
	dd iConsole.$loop_if.4.string_1_data
iConsole.$loop_if.4.string_3_data :
	db "fullscreen: Toggles fullscreen mode.", 0
iConsole.$loop_if.4.string_8_data :
	db "time: Prints out the current time.", 0
iConsole.$loop_if.11.string_5 :
	dd iConsole.$loop_if.11.string_5_data
iConsole.$loop_if.9.string_1_data :
	db "Usage: ", 0
iConsole.$loop_if.4.string_6 :
	dd iConsole.$loop_if.4.string_6_data
iConsole.$loop_if.6.string_0 :
	dd iConsole.$loop_if.6.string_0_data
iConsole.$loop_if.9.string_0 :
	dd iConsole.$loop_if.9.string_0_data
iConsole.$loop_if.10.string_0 :
	dd iConsole.$loop_if.10.string_0_data
iConsole.$loop_if.11.string_1_data :
	db ":", 0
iConsole.$loop_if.8.string_0_data :
	db "lock", 0
iConsole.$loop_if.8.string_0 :
	dd iConsole.$loop_if.8.string_0_data
iConsole.$loop_if.5.string_0_data :
	db "clear", 0
iConsole.$loop_if.5.string_0 :
	dd iConsole.$loop_if.5.string_0_data
iConsole.$loop_if.13.string_1 :
	dd iConsole.$loop_if.13.string_1_data
iConsole.$loop_if.0.$local.ch :
	db 0x0
iConsole.$loop_if.4.string_4_data :
	db "help: Displays this prompt.", 0
iConsole.$loop_if.4.string_7_data :
	db "restart: Restarts the computer.", 0
iConsole.$loop_if.11.string_2 :
	dd iConsole.$loop_if.11.string_2_data
iConsole.$loop_if.4.string_4 :
	dd iConsole.$loop_if.4.string_4_data
iConsole.$loop_if.11.string_4_data :
	db "-", 0
iConsole.$loop_if.9.string_2_data :
	db " / ", 0
iConsole.$loop_if.11.string_0_data :
	db "time", 0
iConsole.$loop_if.4.string_0_data :
	db "help", 0
iConsole.$loop_if.4.string_7 :
	dd iConsole.$loop_if.4.string_7_data
iConsole.$loop_if.14.string_0_data :
	db "OHLL lib", 0
iConsole.$loop_if.15.string_0 :
	dd iConsole.$loop_if.15.string_0_data
iConsole.$loop_if.4.string_5 :
	dd iConsole.$loop_if.4.string_5_data
iConsole._loop.returnVal:
	dd 0x0


iConsole.$FILE_END :
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

Window.$global.TYPE_IMAGE :
	db 0x0
Window.$global.TYPE_TEXT :
	db 0x0
Window.Create: 
pop dword [Window.Create.returnVal]
pop ecx
mov [Window.Create.$local.type], cl
pop ecx
mov [Window.Create.$local.title], ecx
push eax
push ebx
push edx
mov ecx, 39
push ecx
mov ax, 0x0502
int 0x30
mov [Window.Create.$local.ret], ecx
mov ecx, [Window.Create.$local.title]
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.title
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
xor ecx, ecx
mov cl, [Window.Create.$local.type]
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.type
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, 40
mov [Window.Create.$local.wk], cx
xor ecx, ecx
mov cx, [Window.Create.$local.wk]
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.width
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
xor ecx, ecx
mov cx, [Window.Create.$local.wk]
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.height
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, 0x1	; System Constant
push ecx
mov ax, 0x0001
int 0x30
mov [Window.Create.$local.size], ecx
push edx	; Math start
mov ecx, 0x2	; System Constant
push ecx
mov ax, 0x0001
int 0x30
mov edx, ecx
mov ecx, [Window.Create.$local.size]
imul ecx, edx
pop edx	; Math end
mov [Window.Create.$local.size], ecx
mov ecx, [Window.Create.$local.size]
push ecx
mov ax, 0x0501
int 0x30
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.windowBuffer
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, [Window.Create.$local.size]
push ecx
mov ax, 0x0502
int 0x30
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.buffer
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, [Window.Create.$local.size]
push ecx
mov ax, 0x0502
int 0x30
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.oldBuffer
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, [Window.Create.$local.ret]
pop edx
pop ebx
pop eax
push dword [Window.Create.returnVal]
ret
	;Vars:
Window.Create.$local.ret :
	dd 0x0
Window.Create.$local.wk :
	dw 0x0
Window.Create.$local.size :
	dd 0x0
Window.Create.$local.title :
	dd 0x0
Window.Create.$local.type :
	db 0x0
Window.Create.returnVal:
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
pop ecx
mov [String.Append.$local.s], ecx
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
xor ecx, ecx
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
mov ecx, [ebx]
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
mov ecx, [ebx]
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
pop ecx
mov [String.GetChar.$local.pos], ecx
push eax
push ebx
push edx
mov ecx, [ebx]
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
pop ecx
mov [String.SetChar.$local.ch], cl
pop ecx
mov [String.SetChar.$local.pos], ecx
push eax
push ebx
push edx
mov ecx, [ebx]
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
	db 0x0
String.SetChar.returnVal:
	dd 0x0


String.AppendChar: 
pop dword [String.AppendChar.returnVal]
pop ecx
mov [String.AppendChar.$local.ch], cl
push eax
push ebx
push edx
push ebx
mov ebx, ebx
call String.GetLength
pop ebx
mov [String.AppendChar.$local.length], ecx
mov ecx, 0
mov [String.AppendChar.$local.blank], cl
push ebx
mov ebx, ebx
mov ecx, [String.AppendChar.$local.length]
push ecx
xor ecx, ecx
mov cl, [String.AppendChar.$local.ch]
push ecx
call String.SetChar
pop ebx
push ebx
mov ebx, ebx
push edx	; Math start
mov ecx, 1
mov edx, ecx
mov ecx, [String.AppendChar.$local.length]
add ecx, edx
pop edx	; Math end
push ecx
xor ecx, ecx
mov cl, [String.AppendChar.$local.blank]
push ecx
call String.SetChar
pop ebx
pop edx
pop ebx
pop eax
push dword [String.AppendChar.returnVal]
ret
	;Vars:
String.AppendChar.$local.blank :
	db 0x0
String.AppendChar.$local.ch :
	db 0x0
String.AppendChar.$local.length :
	dd 0x0
String.AppendChar.returnVal:
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
mov ecx, [String.$loop_for.0.$local.z]
push ecx
call String.GetChar
pop ebx
mov [String.$loop_for.0.$local.ch], cl
push ebx
mov ebx, String.RawToWhite.$local.ret
mov ecx, [String.$loop_for.0.$local.offs]
push ecx
xor ecx, ecx
mov cl, [String.$loop_for.0.$local.ch]
push ecx
call String.SetChar
pop ebx
push ebx
mov ebx, String.RawToWhite.$local.ret
push edx	; Math start
mov ecx, 1
mov edx, ecx
mov ecx, [String.$loop_for.0.$local.offs]
add ecx, edx
pop edx	; Math end
push ecx
xor ecx, ecx
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
jl String.$comp_45.true
mov cl, 0x0
jmp String.$comp_45.done
String.$comp_45.true :
mov cl, 0xFF
String.$comp_45.done :

cmp cl, 0xFF
	je String.$loop_for.0_open

mov ecx, [String.RawToWhite.$local.ret]
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
xor ecx, ecx
mov cl, [String.GetLength.$local.ch]
mov edx, ecx
mov ecx, 0
cmp edx, ecx
pop edx
jne String.$comp_50.true
mov cl, 0x0
jmp String.$comp_50.done
String.$comp_50.true :
mov cl, 0xFF
String.$comp_50.done :

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
mov ecx, [String.GetLength.$local.ret]
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


String.Equals: 
pop dword [String.Equals.returnVal]
pop ecx
mov [String.Equals.$local.str], ecx
push eax
push ebx
push edx
push ebx
mov ebx, ebx
call String.GetLength
pop ebx
mov [String.Equals.$local.finish], ecx
push edx
mov ecx, [String.Equals.$local.finish]
mov edx, ecx
push ebx
mov ebx, String.Equals.$local.str
call String.GetLength
pop ebx
cmp edx, ecx
pop edx
jne String.$comp_57.true
mov cl, 0x0
jmp String.$comp_57.done
String.$comp_57.true :
mov cl, 0xFF
String.$comp_57.done :

cmp cl, 0xFF
	jne String.$loop_if.0_close
mov ecx, 0x00
pop edx
pop ebx
pop eax
push dword [String.Equals.returnVal]
ret
String.$loop_if.0_close :

mov ecx, 0
mov [String.$loop_for.1.$local.pos], ecx
String.$loop_for.1_open :
push edx
push ebx
mov ebx, ebx
mov ecx, [String.$loop_for.1.$local.pos]
push ecx
call String.GetChar
pop ebx
mov edx, ecx
push ebx
mov ebx, String.Equals.$local.str
mov ecx, [String.$loop_for.1.$local.pos]
push ecx
call String.GetChar
pop ebx
cmp edx, ecx
pop edx
jne String.$comp_60.true
mov cl, 0x0
jmp String.$comp_60.done
String.$comp_60.true :
mov cl, 0xFF
String.$comp_60.done :

cmp cl, 0xFF
	jne String.$loop_if.1_close
mov ecx, 0x00
pop edx
pop ebx
pop eax
push dword [String.Equals.returnVal]
ret
String.$loop_if.1_close :

push edx	; Math start
mov ecx, 1
mov edx, ecx
mov ecx, [String.$loop_for.1.$local.pos]
add ecx, edx
pop edx	; Math end
mov [String.$loop_for.1.$local.pos], ecx
push edx
mov ecx, [String.$loop_for.1.$local.pos]
mov edx, ecx
mov ecx, [String.Equals.$local.finish]
cmp edx, ecx
pop edx
jl String.$comp_62.true
mov cl, 0x0
jmp String.$comp_62.done
String.$comp_62.true :
mov cl, 0xFF
String.$comp_62.done :

cmp cl, 0xFF
	je String.$loop_for.1_open

mov ecx, 0xFF
pop edx
pop ebx
pop eax
push dword [String.Equals.returnVal]
ret
	;Vars:
String.Equals.$local.str :
	dd 0x0
String.Equals.$local.finish :
	dd 0x0
String.$loop_for.1.$local.pos :
	dd 0x0
String.Equals.returnVal:
	dd 0x0


String.$FILE_END :


; *** LIB IMPORT 'KeyCodes' ***
[bits 32]
dd Key.$FILE_END - Key.$FILE_START
db "OrcaHLL Class", 0
db "Key", 0
Key.$FILE_START :

Key.$global.KEY_DOWN :
	db 0x50
Key.$global.KEY_LEFT :
	db 0x4B
Key.$global.TAB :
	db 0x3A
Key.$global.ESC :
	db 0x01
Key.$global.KEY_RIGHT :
	db 0x4D
Key.$global.ENTER :
	db 0xFE
Key.$global.KEY_UP :
	db 0x48
Key.$global.KEY_SHIFT :
	db 0x2A
Key.$global.BACKSPACE :
	db 0xFF
Key.$FILE_END :


; *** LIB IMPORT 'CharCodes' ***
[bits 32]
dd Char.$FILE_END - Char.$FILE_START
db "OrcaHLL Class", 0
db "Char", 0
Char.$FILE_START :

Char.$global.NUL :
	db 0x00
Char.$global.NEWLINE :
	db 0x0A
Char.$FILE_END :



