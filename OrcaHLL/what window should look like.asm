Window.create :
pop dword [Window.retstor]
pop byte [Window.create.$local.type]
pop dword [Window.create.$local.title]

push eax
push ebx
push edx

mov ax, 0x0501
mov ecx, <<CLASS_SIZE>>
push ecx
int 0x30
mov [Window.create.$local.ret], ecx

; init things that I'm really too lazy to do out only for an example (subvarstuffs)

mov ax, 0x0001
mov ecx, 1
push ecx
int 0x30
mov ebx, ecx
mov ax, 0x0001
mov ecx, 2
push ecx
int 0x30
imul ecx, ebx
mov [Window.create.$local.size], ecx

mov ax, 0x0502
mov ecx, [Window.create.$local.size]
push ecx
int 0x30
; set the subvarthing
mov ax, 0x0502
mov ecx, [Window.create.$local.size]
push ecx
int 0x30
; set the subvarthing
mov ax, 0x0502
mov ecx, [Window.create.$local.size]
push ecx
int 0x30
; set the subvarthing

mov ecx, [Window.create.$local.ret]

pop edx
pop ebx
pop eax

ret