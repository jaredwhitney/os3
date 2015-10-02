[bits 32]

dd Window.$FILE_END - Window.$FILE_START
db "OrcaHLL Class", 0
db "Window", 0
Window.$FILE_START :

Window.lastxPos equ 14
Window.winNum equ 47
Window.lastyPos equ 18
Window.yPos equ 16
Window.windowBuffer equ 22
Window.rectlBase equ 39
Window.needsRectUpdate equ 38
Window.xPos equ 12
Window.title equ 0
Window.type equ 20
Window.rectlTop equ 43
Window.depth equ 21
Window.width equ 4
Window.lastWidth equ 6
Window.buffer equ 26
Window.lastHeight equ 10
Window.oldBuffer equ 34
Window.height equ 8
Window.bufferSize equ 30

Window.Create: 
pop dword [Window.Create.returnVal]
pop dword [Window.Create.$local.title]
pop dword [Window.Create.$local.type]
push eax
push ebx
push edx
mov [Window.Create.$local.ret], ecx
mov ecx, [Window.Create.$local.title]
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.title
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, 4
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.width
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, 4
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.height
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, 0
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.xPos
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, 8
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.yPos
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, [Window.Create.$local.type]
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.type
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, 0
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.depth
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ax, null
int 0x30
mov [Window.Create.$local.size], ecx
mov ecx, [Window.Create.$local.size]
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.bufferSize
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.windowBuffer
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.buffer
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.oldBuffer
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, [Window.Create.$local.ret]
push ecx
mov ax, null
int 0x30
push edx	; Begin getting subvar
mov edx, [Window.Create.$local.ret]
add dl, Window.winNum
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
Window.Create.$local.size :
	dd 0x0
Window.Create.$local.title :
	dd 0x0
Window.Create.$local.type :
	dd 0x0
Window.Create.returnVal:
	dd 0x0


Window.GetPreferredHeight: 
pop dword [Window.GetPreferredHeight.returnVal]
push eax
push ebx
push edx
push edx
push edx	; Begin getting subvar
mov edx, [ebx]
add dl, Window.type
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov ecx, [eax]
mov edx, ecx
pop edx	; End getting subvar
mov ecx, [eax]
cmp edx, ecx
pop edx
je Window.$comp_23.true
mov cl, 0x0
jmp Window.$comp_23.done
Window.$comp_23.true :
mov cl, 0xFF
Window.$comp_23.done :

cmp cl, 0xFF
	jne Window.$loop_if.0_close
mov ecx, 12
pop edx
pop ebx
pop eax
push dword [Window.GetPreferredHeight.returnVal]
ret
Window.$loop_if.0_close :

push edx	; Begin getting subvar
mov edx, [ebx]
add dl, Window.buffer
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov ecx, [eax]
mov [Window.GetPreferredHeight.$local.temp], ecx
push ebx
mov ebx, Window.GetPreferredHeight.$local.temp
call Image.GetHeight
pop ebx
pop edx
pop ebx
pop eax
push dword [Window.GetPreferredHeight.returnVal]
ret
	;Vars:
Window.GetPreferredHeight.$local.temp :
	dd 0x0
Window.GetPreferredHeight.returnVal:
	dd 0x0


Window.$FILE_END :

