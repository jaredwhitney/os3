[bits 32]

dd iConsole.$FILE_END - iConsole.$FILE_START
db "OrcaHLL Class", 0
db "iConsole", 0
iConsole.$FILE_START :

iConsole.$global.sub :
	db 0x0
iConsole.$global.window :
	dd 0x0
iConsole.$global.win :
	dd 0x0
iConsole.$global.command :
	dd 0x0
iConsole.$global.fstorstr :
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
mov ecx, 80
push ecx
mov ax, 0x0502
int 0x30
mov [iConsole.$global.fstorstr], ecx
mov ecx, [iConsole._init.string_0]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, 0x0
mov [iConsole.$global.sub], cl
call MinnowTest._init
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
jne iConsole.$comp_20.true
mov cl, 0x0
jmp iConsole.$comp_20.done
iConsole.$comp_20.true :
mov cl, 0xFF
iConsole.$comp_20.done :

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
jne iConsole.$comp_21.true
mov cl, 0x0
jmp iConsole.$comp_21.done
iConsole.$comp_21.true :
mov cl, 0xFF
iConsole.$comp_21.done :

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
je iConsole.$comp_25.true
mov cl, 0x0
jmp iConsole.$comp_25.done
iConsole.$comp_25.true :
mov cl, 0xFF
iConsole.$comp_25.done :

cmp cl, 0xFF
	jne iConsole.$loop_if.3_close
mov ax, 0x0103
int 0x30
push edx
xor ecx, ecx
mov cl, [iConsole.$global.sub]
mov edx, ecx
mov ecx, 0x2
cmp edx, ecx
pop edx
je iConsole.$comp_28.true
mov cl, 0x0
jmp iConsole.$comp_28.done
iConsole.$comp_28.true :
mov cl, 0xFF
iConsole.$comp_28.done :

cmp cl, 0xFF
	jne iConsole.$loop_if.4_close
mov ecx, [iConsole.$global.fstorstr]
mov eax, ecx	; INLINE ASSEMBLY
mov ecx, [iConsole.$global.command]
mov ebx, ecx	; INLINE ASSEMBLY
call Minnow.nameAndTypeToPointer	; INLINE ASSEMBLY
mov eax, ecx	; INLINE ASSEMBLY
call Minnow.getBuffer	; INLINE ASSEMBLY
call Minnow.skipHeader	; INLINE ASSEMBLY
mov ebx, ecx	; INLINE ASSEMBLY
call console.println	; INLINE ASSEMBLY
mov ecx, 0x0
mov [iConsole.$global.sub], cl
iConsole.$loop_if.4_close :

push edx
xor ecx, ecx
mov cl, [iConsole.$global.sub]
mov edx, ecx
mov ecx, 0x1
cmp edx, ecx
pop edx
je iConsole.$comp_41.true
mov cl, 0x0
jmp iConsole.$comp_41.done
iConsole.$comp_41.true :
mov cl, 0xFF
iConsole.$comp_41.done :

cmp cl, 0xFF
	jne iConsole.$loop_if.5_close
push ebx
mov ebx, iConsole.$global.fstorstr
mov ecx, 0
push ecx
xor ecx, ecx
mov cl, [Char.$global.NUL]
push ecx
call String.SetChar
pop ebx
push ebx
mov ebx, iConsole.$global.fstorstr
mov ecx, [iConsole.$global.command]
push ecx
call String.Append
pop ebx
mov ecx, [iConsole.$loop_if.5.string_0]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, 0x2
mov [iConsole.$global.sub], cl
iConsole.$loop_if.5_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.6.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.6_close
mov ecx, [iConsole.$loop_if.6.string_1]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.6.string_2]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.6.string_3]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.6.string_4]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.6.string_5]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.6.string_6]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.6.string_7]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.6.string_8]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.6.string_9]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.6.string_10]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.6.string_11]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [iConsole.$loop_if.6.string_12]
push ecx
mov ax, 0x0101
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
mov ax, 0x0104
int 0x30
iConsole.$loop_if.7_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.8.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.8_close
mov ecx, [iConsole.$global.window]
push ecx
mov ax, 0x0201
int 0x30
iConsole.$loop_if.8_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.9.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.9_close
call JASM.console.safeFullscreen	; INLINE ASSEMBLY
iConsole.$loop_if.9_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.10.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.10_close
call Manager.lock	; INLINE ASSEMBLY
iConsole.$loop_if.10_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.11.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.11_close
mov ecx, [iConsole.$loop_if.11.string_1]
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
mov ecx, [iConsole.$loop_if.11.string_2]
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
iConsole.$loop_if.11_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.12.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.12_close
call console.test	; INLINE ASSEMBLY
iConsole.$loop_if.12_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.13.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.13_close
mov ecx, 0x0B
push ecx
mov ax, 0x0108
int 0x30
mov ax, 0x0703
int 0x30
push ecx
mov ax, 0x0102
int 0x30
mov ecx, [iConsole.$loop_if.13.string_1]
push ecx
mov ax, 0x0100
int 0x30
mov ax, 0x0702
int 0x30
push ecx
mov ax, 0x0102
int 0x30
mov ecx, [iConsole.$loop_if.13.string_2]
push ecx
mov ax, 0x0100
int 0x30
mov ax, 0x0701
int 0x30
push ecx
mov ax, 0x0102
int 0x30
mov ecx, [iConsole.$loop_if.13.string_3]
push ecx
mov ax, 0x0100
int 0x30
mov ax, 0x0705
int 0x30
push ecx
mov ax, 0x0102
int 0x30
mov ecx, [iConsole.$loop_if.13.string_4]
push ecx
mov ax, 0x0100
int 0x30
mov ax, 0x0706
int 0x30
push ecx
mov ax, 0x0102
int 0x30
mov ecx, [iConsole.$loop_if.13.string_5]
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
iConsole.$loop_if.13_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.14.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.14_close
call Minnow.ctree	; INLINE ASSEMBLY
iConsole.$loop_if.14_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.15.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.15_close
mov eax, SysHaltScreen.RESET	; INLINE ASSEMBLY
mov ecx, [iConsole.$loop_if.15.string_1]
mov ebx, ecx	; INLINE ASSEMBLY
mov ecx, 5	; INLINE ASSEMBLY
call SysHaltScreen.show	; INLINE ASSEMBLY
iConsole.$loop_if.15_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.16.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.16_close
call AHCI.printPartitionInfo	; INLINE ASSEMBLY
iConsole.$loop_if.16_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.17.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.17_close
mov ecx, [iConsole.$loop_if.17.string_1]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, 0x1
mov [iConsole.$global.sub], cl
iConsole.$loop_if.17_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.18.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.18_close
call Minnow3.doFormatPartition	; INLINE ASSEMBLY
iConsole.$loop_if.18_close :

push ebx
mov ebx, iConsole.$global.command
mov ecx, [iConsole.$loop_if.19.string_0]
push ecx
call String.Equals
pop ebx
cmp cl, 0xFF
	jne iConsole.$loop_if.19_close
call MinnowTools.ValidateFS
iConsole.$loop_if.19_close :

push edx
xor ecx, ecx
mov cl, [iConsole.$global.sub]
mov edx, ecx
mov ecx, 0x0
cmp edx, ecx
pop edx
je iConsole.$comp_121.true
mov cl, 0x0
jmp iConsole.$comp_121.done
iConsole.$comp_121.true :
mov cl, 0xFF
iConsole.$comp_121.done :

cmp cl, 0xFF
	jne iConsole.$loop_if.20_close
mov ecx, [iConsole.$loop_if.20.string_0]
push ecx
mov ax, 0x0100
int 0x30
iConsole.$loop_if.20_close :

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
iConsole.$loop_if.6.string_11 :
	dd iConsole.$loop_if.6.string_11_data
iConsole.$loop_if.6.string_10_data :
	db "partition: Detects and displays partition info.", 0
iConsole.$loop_if.7.string_0_data :
	db "clear", 0
iConsole.$loop_if.6.string_12 :
	dd iConsole.$loop_if.6.string_12_data
iConsole.$loop_if.13.string_1_data :
	db ":", 0
iConsole.$loop_if.17.string_1 :
	dd iConsole.$loop_if.17.string_1_data
iConsole.$loop_if.6.string_9_data :
	db "tree: Displays all mounted files.", 0
iConsole.$loop_if.6.string_5 :
	dd iConsole.$loop_if.6.string_5_data
iConsole.$loop_if.6.string_8_data :
	db "time: Prints out the current time.", 0
iConsole.$loop_if.15.string_0_data :
	db "restart", 0
iConsole.$loop_if.6.string_1 :
	dd iConsole.$loop_if.6.string_1_data
iConsole.$loop_if.6.string_4 :
	dd iConsole.$loop_if.6.string_4_data
iConsole.$loop_if.13.string_2_data :
	db ":", 0
iConsole.$loop_if.18.string_0_data :
	db "format", 0
iConsole.$loop_if.12.string_0_data :
	db "test", 0
iConsole.$loop_if.6.string_7 :
	dd iConsole.$loop_if.6.string_7_data
iConsole.$loop_if.6.string_4_data :
	db "help: Displays this prompt.", 0
iConsole.$loop_if.20.string_0_data :
	db "Console: ", 0
iConsole.$loop_if.13.string_0 :
	dd iConsole.$loop_if.13.string_0_data
iConsole.$loop_if.9.string_0 :
	dd iConsole.$loop_if.9.string_0_data
iConsole.$loop_if.11.string_2_data :
	db " / ", 0
iConsole.$loop_if.15.string_1 :
	dd iConsole.$loop_if.15.string_1_data
iConsole.$loop_if.13.string_3 :
	dd iConsole.$loop_if.13.string_3_data
iConsole.$loop_if.20.string_0 :
	dd iConsole.$loop_if.20.string_0_data
iConsole.$loop_if.11.string_1 :
	dd iConsole.$loop_if.11.string_1_data
iConsole.$loop_if.6.string_0_data :
	db "help", 0
iConsole.$loop_if.12.string_0 :
	dd iConsole.$loop_if.12.string_0_data
iConsole.$loop_if.16.string_0_data :
	db "partition", 0
iConsole.$loop_if.6.string_7_data :
	db "restart: Restarts the computer.", 0
iConsole.$loop_if.10.string_0_data :
	db "lock", 0
iConsole.$loop_if.13.string_0_data :
	db "time", 0
iConsole.$loop_if.8.string_0 :
	dd iConsole.$loop_if.8.string_0_data
iConsole.$loop_if.10.string_0 :
	dd iConsole.$loop_if.10.string_0_data
iConsole.$loop_if.19.string_0_data :
	db "VERIFY", 0
iConsole.$loop_if.9.string_0_data :
	db "fullscreen", 0
iConsole.$loop_if.6.string_3_data :
	db "fullscreen: Toggles fullscreen mode.", 0
iConsole.$loop_if.15.string_1_data :
	db "Restarting the computer.", 0
iConsole.$loop_if.13.string_3_data :
	db " ", 0
iConsole.$loop_if.7.string_0 :
	dd iConsole.$loop_if.7.string_0_data
iConsole.$loop_if.17.string_0_data :
	db "readfile", 0
iConsole.$loop_if.6.string_1_data :
	db "clear: Clears the screen.", 0
iConsole.$loop_if.6.string_0 :
	dd iConsole.$loop_if.6.string_0_data
iConsole.$loop_if.14.string_0 :
	dd iConsole.$loop_if.14.string_0_data
iConsole.$loop_if.6.string_6_data :
	db "memstat: Prints out the percentage of RAM in use.", 0
iConsole.$loop_if.17.string_0 :
	dd iConsole.$loop_if.17.string_0_data
iConsole.$loop_if.18.string_0 :
	dd iConsole.$loop_if.18.string_0_data
iConsole.$loop_if.15.string_0 :
	dd iConsole.$loop_if.15.string_0_data
iConsole.$loop_if.16.string_0 :
	dd iConsole.$loop_if.16.string_0_data
iConsole.$loop_if.13.string_4 :
	dd iConsole.$loop_if.13.string_4_data
iConsole.$loop_if.6.string_12_data :
	db "format: Formats the filesystem.", 0
iConsole.$loop_if.11.string_1_data :
	db "Usage: ", 0
iConsole.$loop_if.8.string_0_data :
	db "exit", 0
iConsole.$loop_if.13.string_2 :
	dd iConsole.$loop_if.13.string_2_data
iConsole.$loop_if.17.string_1_data :
	db "File name: ", 0
iConsole.$loop_if.6.string_9 :
	dd iConsole.$loop_if.6.string_9_data
iConsole.$loop_if.13.string_4_data :
	db "-", 0
iConsole.$loop_if.5.string_0_data :
	db "File type: ", 0
iConsole.$loop_if.6.string_3 :
	dd iConsole.$loop_if.6.string_3_data
iConsole.$loop_if.13.string_1 :
	dd iConsole.$loop_if.13.string_1_data
iConsole.$loop_if.13.string_5 :
	dd iConsole.$loop_if.13.string_5_data
iConsole.$loop_if.0.$local.ch :
	db 0x0
iConsole.$loop_if.6.string_10 :
	dd iConsole.$loop_if.6.string_10_data
iConsole.$loop_if.13.string_5_data :
	db "-", 0
iConsole.$loop_if.6.string_2_data :
	db "exit: Exits the console.", 0
iConsole.$loop_if.11.string_0_data :
	db "memstat", 0
iConsole.$loop_if.6.string_11_data :
	db "readfile: Prints out the contents of a text file.", 0
iConsole.$loop_if.14.string_0_data :
	db "tree", 0
iConsole.$loop_if.5.string_0 :
	dd iConsole.$loop_if.5.string_0_data
iConsole.$loop_if.6.string_6 :
	dd iConsole.$loop_if.6.string_6_data
iConsole.$loop_if.11.string_0 :
	dd iConsole.$loop_if.11.string_0_data
iConsole.$loop_if.11.string_2 :
	dd iConsole.$loop_if.11.string_2_data
iConsole.$loop_if.6.string_5_data :
	db "lock: Locks the computer.", 0
iConsole.$loop_if.6.string_2 :
	dd iConsole.$loop_if.6.string_2_data
iConsole.$loop_if.6.string_8 :
	dd iConsole.$loop_if.6.string_8_data
iConsole.$loop_if.19.string_0 :
	dd iConsole.$loop_if.19.string_0_data
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
mov ebx, String.Append.$local.s
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
mov ebx, String.Append.$local.s
mov ecx, [String.Append.$local.q]
push ecx
call String.GetChar
pop ebx
mov [String.Append.$local.ch], cl
	jmp String.$loop_while.0_open
String.$loop_while.0_end :
mov ecx, [ebx]
add ecx, [String.Append.$local.q]	; INLINE ASSEMBLY
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
jl String.$comp_43.true
mov cl, 0x0
jmp String.$comp_43.done
String.$comp_43.true :
mov cl, 0xFF
String.$comp_43.done :

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
jne String.$comp_48.true
mov cl, 0x0
jmp String.$comp_48.done
String.$comp_48.true :
mov cl, 0xFF
String.$comp_48.done :

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
jne String.$comp_55.true
mov cl, 0x0
jmp String.$comp_55.done
String.$comp_55.true :
mov cl, 0xFF
String.$comp_55.done :

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
jne String.$comp_58.true
mov cl, 0x0
jmp String.$comp_58.done
String.$comp_58.true :
mov cl, 0xFF
String.$comp_58.done :

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
jl String.$comp_60.true
mov cl, 0x0
jmp String.$comp_60.done
String.$comp_60.true :
mov cl, 0xFF
String.$comp_60.done :

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


; *** LIB IMPORT 'MinnowTest' ***
[bits 32]
dd MinnowTest.$FILE_END - MinnowTest.$FILE_START
db "OrcaHLL Class", 0
db "MinnowTest", 0
MinnowTest.$FILE_START :

MinnowTest.$global.nameToDelete :
	dd 0x0
MinnowTest.$global.type :
	dd 0x0
MinnowTest.$global.fileContents :
	dd 0x0
MinnowTest.$global.nameToUse :
	dd 0x0
MinnowTest.$global.name1 :
	dd 0x0
MinnowTest.$global.name0 :
	dd 0x0
MinnowTest.$global.switch :
	db 0x0
MinnowTest._init: 
pop dword [MinnowTest._init.returnVal]
push eax
push ebx
push edx
mov ecx, 20
push ecx
mov ax, 0x0502
int 0x30
mov [MinnowTest.$global.nameToUse], ecx
mov ecx, 20
push ecx
mov ax, 0x0502
int 0x30
mov [MinnowTest.$global.nameToDelete], ecx
mov ecx, [MinnowTest._init.string_0]
mov [MinnowTest.$global.name0], ecx
mov ecx, [MinnowTest._init.string_1]
mov [MinnowTest.$global.name1], ecx
mov ecx, [MinnowTest._init.string_2]
mov [MinnowTest.$global.type], ecx
mov ecx, [MinnowTest._init.string_3]
mov [MinnowTest.$global.fileContents], ecx
pop edx
pop ebx
pop eax
push dword [MinnowTest._init.returnVal]
ret
	;Vars:
MinnowTest._init.string_3 :
	dd MinnowTest._init.string_3_data
MinnowTest._init.string_0_data :
	db "Write Test", 0
MinnowTest._init.string_0 :
	dd MinnowTest._init.string_0_data
MinnowTest._init.string_1_data :
	db "Filesystem Test", 0
MinnowTest._init.string_2_data :
	db "Text", 0
MinnowTest._init.string_3_data :
	db "This is some test text that has been written to the filesystem with the new Minnow.WriteFile() command!", 0
MinnowTest._init.string_1 :
	dd MinnowTest._init.string_1_data
MinnowTest._init.string_2 :
	dd MinnowTest._init.string_2_data
MinnowTest._init.returnVal:
	dd 0x0


MinnowTest.RunTest: 
pop dword [MinnowTest.RunTest.returnVal]
push eax
push ebx
push edx
push ebx
mov ebx, MinnowTest.$global.nameToUse
mov ecx, 0
push ecx
mov ecx, 0
push ecx
call String.SetChar
pop ebx
push ebx
mov ebx, MinnowTest.$global.nameToDelete
mov ecx, 0
push ecx
mov ecx, 0
push ecx
call String.SetChar
pop ebx
mov ecx, [MinnowTest.$global.name1]
push ecx
mov ecx, [MinnowTest.$global.type]
push ecx
call Minnow.CheckExists
cmp cl, 0xFF
	jne MinnowTest.$loop_if.0_close
push ebx
mov ebx, MinnowTest.$global.nameToUse
mov ecx, [MinnowTest.$global.name0]
push ecx
call String.Append
pop ebx
push ebx
mov ebx, MinnowTest.$global.nameToDelete
mov ecx, [MinnowTest.$global.name1]
push ecx
call String.Append
pop ebx
MinnowTest.$loop_if.0_close :

mov ecx, [MinnowTest.$global.name0]
push ecx
mov ecx, [MinnowTest.$global.type]
push ecx
call Minnow.CheckExists
cmp cl, 0xFF
	jne MinnowTest.$loop_if.1_close
push ebx
mov ebx, MinnowTest.$global.nameToUse
mov ecx, [MinnowTest.$global.name1]
push ecx
call String.Append
pop ebx
push ebx
mov ebx, MinnowTest.$global.nameToDelete
mov ecx, [MinnowTest.$global.name0]
push ecx
call String.Append
pop ebx
MinnowTest.$loop_if.1_close :

mov ecx, [MinnowTest.$global.nameToDelete]
push ecx
mov ecx, [MinnowTest.$global.type]
push ecx
call Minnow.DeleteFile
mov ecx, [MinnowTest.$global.nameToUse]
push ecx
mov ecx, [MinnowTest.$global.type]
push ecx
mov ecx, [MinnowTest.$global.fileContents]
push ecx
push ebx
mov ebx, MinnowTest.$global.fileContents
call String.GetLength
pop ebx
push ecx
call Minnow.WriteFile
pop edx
pop ebx
pop eax
push dword [MinnowTest.RunTest.returnVal]
ret
	;Vars:
MinnowTest.RunTest.returnVal:
	dd 0x0


MinnowTest.$FILE_END :


; *** LIB IMPORT 'MinnowTools' ***
[bits 32]
dd MinnowTools.$FILE_END - MinnowTools.$FILE_START
db "OrcaHLL Class", 0
db "MinnowTools", 0
MinnowTools.$FILE_START :

MinnowTools.$global.lastBlocks :
	dd 0x0
MinnowTools.$global.dat :
	dd 0x0
MinnowTools.ValidateFS: 
pop dword [MinnowTools.ValidateFS.returnVal]
push eax
push ebx
push edx
mov ecx, 0
push ecx
call Minnow.ReadBlock
mov [MinnowTools.$global.dat], ecx
push ebx
mov ebx, MinnowTools.$global.dat
mov ecx, 4
push ecx
call Buffer.ReadInt
pop ebx
mov [MinnowTools.$global.lastBlocks], ecx
call MinnowTools.ValidateFS_Loop
pop edx
pop ebx
pop eax
push dword [MinnowTools.ValidateFS.returnVal]
ret
	;Vars:
MinnowTools.ValidateFS.returnVal:
	dd 0x0


MinnowTools.ValidateFS_Loop: 
pop dword [MinnowTools.ValidateFS_Loop.returnVal]
push eax
push ebx
push edx
ValidateFS_Loop.__START :	; INLINE ASSEMBLY
push ebx
mov ebx, MinnowTools.$global.dat
mov ecx, 0
push ecx
call Buffer.ReadInt
pop ebx
mov [MinnowTools.ValidateFS_Loop.$local.ptr], ecx
push ebx
mov ebx, MinnowTools.$global.dat
mov ecx, 4
push ecx
call Buffer.ReadInt
pop ebx
mov [MinnowTools.ValidateFS_Loop.$local.blocks], ecx
push edx
mov ecx, [MinnowTools.$global.lastBlocks]
mov edx, ecx
mov ecx, 0
cmp edx, ecx
pop edx
jne MinnowTools.$comp_11.true
mov cl, 0x0
jmp MinnowTools.$comp_11.done
MinnowTools.$comp_11.true :
mov cl, 0xFF
MinnowTools.$comp_11.done :

cmp cl, 0xFF
	jne MinnowTools.$loop_if.0_close
push edx
mov ecx, [MinnowTools.ValidateFS_Loop.$local.blocks]
mov edx, ecx
mov ecx, [MinnowTools.$global.lastBlocks]
cmp edx, ecx
pop edx
jne MinnowTools.$comp_12.true
mov cl, 0x0
jmp MinnowTools.$comp_12.done
MinnowTools.$comp_12.true :
mov cl, 0xFF
MinnowTools.$comp_12.done :

cmp cl, 0xFF
	jne MinnowTools.$loop_if.1_close
mov ecx, [MinnowTools.$loop_if.1.string_0]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, 0
pop edx
pop ebx
pop eax
push dword [MinnowTools.ValidateFS_Loop.returnVal]
ret
MinnowTools.$loop_if.1_close :

MinnowTools.$loop_if.0_close :

push edx
mov ecx, [MinnowTools.$global.lastBlocks]
mov edx, ecx
mov ecx, 0
cmp edx, ecx
pop edx
je MinnowTools.$comp_15.true
mov cl, 0x0
jmp MinnowTools.$comp_15.done
MinnowTools.$comp_15.true :
mov cl, 0xFF
MinnowTools.$comp_15.done :

cmp cl, 0xFF
	jne MinnowTools.$loop_if.2_close
mov ecx, [MinnowTools.$loop_if.2.string_0]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, [MinnowTools.ValidateFS_Loop.$local.ptr]
push ecx
mov ax, 0x0102
int 0x30
mov ax, 0x0103
int 0x30
mov ecx, [MinnowTools.$loop_if.2.string_1]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, [MinnowTools.ValidateFS_Loop.$local.blocks]
push ecx
mov ax, 0x0102
int 0x30
mov ax, 0x0103
int 0x30
push edx	; Math start
mov ecx, 8
mov edx, ecx
mov ecx, [MinnowTools.$global.dat]
add ecx, edx
pop edx	; Math end
mov [MinnowTools.$loop_if.2.$local.name], ecx
push edx	; Math start
push ebx
mov ebx, MinnowTools.$loop_if.2.$local.name
call String.GetLength
pop ebx
mov edx, ecx
mov ecx, [MinnowTools.$loop_if.2.$local.name]
add ecx, edx
pop edx	; Math end
mov [MinnowTools.$loop_if.2.$local.type], ecx
mov ecx, [MinnowTools.$loop_if.2.string_2]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, [MinnowTools.$loop_if.2.$local.name]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [MinnowTools.$loop_if.2.string_3]
push ecx
mov ax, 0x0100
int 0x30
mov ecx, [MinnowTools.$loop_if.2.$local.type]
push ecx
mov ax, 0x0101
int 0x30
MinnowTools.$loop_if.2_close :

push edx
mov ecx, [MinnowTools.ValidateFS_Loop.$local.ptr]
mov edx, ecx
mov ecx, 0
cmp edx, ecx
pop edx
je MinnowTools.$comp_28.true
mov cl, 0x0
jmp MinnowTools.$comp_28.done
MinnowTools.$comp_28.true :
mov cl, 0xFF
MinnowTools.$comp_28.done :

cmp cl, 0xFF
	jne MinnowTools.$loop_if.3_close
push edx
mov ecx, [MinnowTools.ValidateFS_Loop.$local.blocks]
mov edx, ecx
mov ecx, 0
cmp edx, ecx
pop edx
jne MinnowTools.$comp_29.true
mov cl, 0x0
jmp MinnowTools.$comp_29.done
MinnowTools.$comp_29.true :
mov cl, 0xFF
MinnowTools.$comp_29.done :

cmp cl, 0xFF
	jne MinnowTools.$loop_if.4_close
mov ecx, [MinnowTools.$loop_if.4.string_0]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, 0
pop edx
pop ebx
pop eax
push dword [MinnowTools.ValidateFS_Loop.returnVal]
ret
MinnowTools.$loop_if.4_close :

mov ecx, [MinnowTools.$loop_if.3.string_0]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, 0xFF
pop edx
pop ebx
pop eax
push dword [MinnowTools.ValidateFS_Loop.returnVal]
ret
MinnowTools.$loop_if.3_close :

mov ecx, [MinnowTools.ValidateFS_Loop.$local.blocks]
mov [MinnowTools.$global.lastBlocks], ecx
mov ecx, [MinnowTools.$global.dat]
push ecx
call Minnow.ReadBlock
mov [MinnowTools.$global.dat], ecx
jmp ValidateFS_Loop.__START	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [MinnowTools.ValidateFS_Loop.returnVal]
ret
	;Vars:
MinnowTools.ValidateFS_Loop.$local.blocks :
	dd 0x0
MinnowTools.ValidateFS_Loop.$local.ptr :
	dd 0x0
MinnowTools.$loop_if.3.string_0_data :
	db "[End Filesystem]", 0
MinnowTools.$loop_if.2.string_2_data :
	db "Name: ", 0
MinnowTools.$loop_if.2.string_0_data :
	db "Ptr: ", 0
MinnowTools.$loop_if.2.$local.type :
	dd 0x0
MinnowTools.$loop_if.2.string_1_data :
	db "Blocks: ", 0
MinnowTools.$loop_if.3.string_0 :
	dd MinnowTools.$loop_if.3.string_0_data
MinnowTools.$loop_if.2.string_2 :
	dd MinnowTools.$loop_if.2.string_2_data
MinnowTools.$loop_if.2.string_1 :
	dd MinnowTools.$loop_if.2.string_1_data
MinnowTools.$loop_if.2.string_3_data :
	db "Type: ", 0
MinnowTools.$loop_if.2.string_3 :
	dd MinnowTools.$loop_if.2.string_3_data
MinnowTools.$loop_if.2.string_0 :
	dd MinnowTools.$loop_if.2.string_0_data
MinnowTools.$loop_if.2.$local.name :
	dd 0x0
MinnowTools.$loop_if.1.string_0 :
	dd MinnowTools.$loop_if.1.string_0_data
MinnowTools.$loop_if.4.string_0 :
	dd MinnowTools.$loop_if.4.string_0_data
MinnowTools.$loop_if.4.string_0_data :
	db "Quitting on invalid block!", 0
MinnowTools.$loop_if.1.string_0_data :
	db "Quitting on invalid block!", 0
MinnowTools.ValidateFS_Loop.returnVal:
	dd 0x0


MinnowTools.$FILE_END :
; *** LIB IMPORT 'Buffer' ***
[bits 32]
dd Buffer.$FILE_END - Buffer.$FILE_START
db "OrcaHLL Class", 0
db "Buffer", 0
Buffer.$FILE_START :

Buffer.Create: 
pop dword [Buffer.Create.returnVal]
pop ecx
mov [Buffer.Create.$local.size], ecx
push eax
push ebx
push edx
mov ecx, [Buffer.Create.$local.size]
push ecx
mov ax, 0x0502
int 0x30
mov [Buffer.Create.$local.ret], ecx
mov ecx, [Buffer.Create.$local.ret]
pop edx
pop ebx
pop eax
push dword [Buffer.Create.returnVal]
ret
	;Vars:
Buffer.Create.$local.ret :
	dd 0x0
Buffer.Create.$local.size :
	dd 0x0
Buffer.Create.returnVal:
	dd 0x0


Buffer.ReadByte: 
pop dword [Buffer.ReadByte.returnVal]
pop ecx
mov [Buffer.ReadByte.$local.offs], ecx
push eax
push ebx
push edx
mov ecx, [Buffer.ReadByte.$local.offs]
add ebx, ecx	; INLINE ASSEMBLY
xor ecx, ecx	; INLINE ASSEMBLY
mov cl, [ebx]	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [Buffer.ReadByte.returnVal]
ret
	;Vars:
Buffer.ReadByte.$local.offs :
	dd 0x0
Buffer.ReadByte.returnVal:
	dd 0x0


Buffer.ReadIntSmall: 
pop dword [Buffer.ReadIntSmall.returnVal]
pop ecx
mov [Buffer.ReadIntSmall.$local.offs], ecx
push eax
push ebx
push edx
mov ecx, [Buffer.ReadIntSmall.$local.offs]
add ebx, ecx	; INLINE ASSEMBLY
xor ecx, ecx	; INLINE ASSEMBLY
mov cx, [ebx]	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [Buffer.ReadIntSmall.returnVal]
ret
	;Vars:
Buffer.ReadIntSmall.$local.offs :
	dd 0x0
Buffer.ReadIntSmall.returnVal:
	dd 0x0


Buffer.ReadInt: 
pop dword [Buffer.ReadInt.returnVal]
pop ecx
mov [Buffer.ReadInt.$local.offs], ecx
push eax
push ebx
push edx
mov ecx, [Buffer.ReadInt.$local.offs]
add ebx, ecx	; INLINE ASSEMBLY
mov ecx, [ebx]	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [Buffer.ReadInt.returnVal]
ret
	;Vars:
Buffer.ReadInt.$local.offs :
	dd 0x0
Buffer.ReadInt.returnVal:
	dd 0x0


Buffer.$FILE_END :




; *** LIB IMPORT 'Minnow' ***
[bits 32]
dd Minnow.$FILE_END - Minnow.$FILE_START
db "OrcaHLL Class", 0
db "Minnow", 0
Minnow.$FILE_START :

Minnow.ReadFileBlock: 
pop dword [Minnow.ReadFileBlock.returnVal]
pop ecx
mov [Minnow.ReadFileBlock.$local.block], ecx
pop ecx
mov [Minnow.ReadFileBlock.$local.fileType], ecx
pop ecx
mov [Minnow.ReadFileBlock.$local.fileName], ecx
push eax
push ebx
push edx
mov ecx, [Minnow.ReadFileBlock.$local.fileName]
mov eax, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.ReadFileBlock.$local.fileType]
mov ebx, ecx	; INLINE ASSEMBLY
call Minnow.nameAndTypeToPointer	; INLINE ASSEMBLY
mov eax, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.ReadFileBlock.$local.block]
mov ebx, ecx	; INLINE ASSEMBLY
call Minnow.readFileBlock	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [Minnow.ReadFileBlock.returnVal]
ret
	;Vars:
Minnow.ReadFileBlock.$local.fileName :
	dd 0x0
Minnow.ReadFileBlock.$local.block :
	dd 0x0
Minnow.ReadFileBlock.$local.fileType :
	dd 0x0
Minnow.ReadFileBlock.returnVal:
	dd 0x0


Minnow.WriteFile: 
pop dword [Minnow.WriteFile.returnVal]
pop ecx
mov [Minnow.WriteFile.$local.bufferSize], ecx
pop ecx
mov [Minnow.WriteFile.$local.buffer], ecx
pop ecx
mov [Minnow.WriteFile.$local.fileType], ecx
pop ecx
mov [Minnow.WriteFile.$local.fileName], ecx
push eax
push ebx
push edx
mov ecx, [Minnow.WriteFile.$local.fileName]
mov eax, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.WriteFile.$local.fileType]
mov ebx, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.WriteFile.$local.bufferSize]
mov edx, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.WriteFile.$local.buffer]
call Minnow.writeFile	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [Minnow.WriteFile.returnVal]
ret
	;Vars:
Minnow.WriteFile.$local.fileName :
	dd 0x0
Minnow.WriteFile.$local.buffer :
	dd 0x0
Minnow.WriteFile.$local.fileType :
	dd 0x0
Minnow.WriteFile.$local.bufferSize :
	dd 0x0
Minnow.WriteFile.returnVal:
	dd 0x0


Minnow.CheckExists: 
pop dword [Minnow.CheckExists.returnVal]
pop ecx
mov [Minnow.CheckExists.$local.fileType], ecx
pop ecx
mov [Minnow.CheckExists.$local.fileName], ecx
push eax
push ebx
push edx
mov ecx, [Minnow.CheckExists.$local.fileName]
mov eax, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.CheckExists.$local.fileType]
mov ebx, ecx	; INLINE ASSEMBLY
call Minnow.nameAndTypeToPointer	; INLINE ASSEMBLY
cmp cl, 0xFF
	jne Minnow.$loop_if.0_close
mov ecx, 0x0
pop edx
pop ebx
pop eax
push dword [Minnow.CheckExists.returnVal]
ret
Minnow.$loop_if.0_close :

mov ecx, 0xFF
pop edx
pop ebx
pop eax
push dword [Minnow.CheckExists.returnVal]
ret
	;Vars:
Minnow.CheckExists.$local.fileName :
	dd 0x0
Minnow.CheckExists.$local.fileType :
	dd 0x0
Minnow.CheckExists.returnVal:
	dd 0x0


Minnow.DeleteFile: 
pop dword [Minnow.DeleteFile.returnVal]
pop ecx
mov [Minnow.DeleteFile.$local.fileType], ecx
pop ecx
mov [Minnow.DeleteFile.$local.fileName], ecx
push eax
push ebx
push edx
mov ecx, [Minnow.DeleteFile.$local.fileName]
mov eax, ecx	; INLINE ASSEMBLY
mov ecx, [Minnow.DeleteFile.$local.fileType]
mov ebx, ecx	; INLINE ASSEMBLY
call Minnow.nameAndTypeToPointer	; INLINE ASSEMBLY
mov eax, ecx	; INLINE ASSEMBLY
call Minnow.deleteFile	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [Minnow.DeleteFile.returnVal]
ret
	;Vars:
Minnow.DeleteFile.$local.fileName :
	dd 0x0
Minnow.DeleteFile.$local.fileType :
	dd 0x0
Minnow.DeleteFile.returnVal:
	dd 0x0


Minnow.ReadBlock: 
pop dword [Minnow.ReadBlock.returnVal]
pop ecx
mov [Minnow.ReadBlock.$local.block], ecx
push eax
push ebx
push edx
mov ecx, [Minnow.ReadBlock.$local.block]
mov eax, ecx	; INLINE ASSEMBLY
call Minnow.getBuffer	; INLINE ASSEMBLY
pop edx
pop ebx
pop eax
push dword [Minnow.ReadBlock.returnVal]
ret
	;Vars:
Minnow.ReadBlock.$local.block :
	dd 0x0
Minnow.ReadBlock.returnVal:
	dd 0x0


Minnow.$FILE_END :



