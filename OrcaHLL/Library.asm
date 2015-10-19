[bits 32]

dd Library.$FILE_END - Library.$FILE_START
db "OrcaHLL Class", 0
db "Library", 0
Library.$FILE_START :

Library._init: 
pop dword [Library._init.returnVal]
push eax
push ebx
push edx
mov ecx, [Library._init.string_0]
push ecx
call Book.Create
mov [Library._init.$local.one], ecx
mov ecx, [Library._init.string_1]
push ecx
call Book.Create
mov [Library._init.$local.two], ecx
mov ax, 0x0103
int 0x30
mov ecx, [Library._init.string_2]
push ecx
mov ax, 0x0100
int 0x30
push edx	; Begin getting subvar
mov edx, [Library._init.$local.one]
add dl, Book.title
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov ecx, [eax]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [Library._init.string_3]
push edx	; Begin getting subvar
mov edx, [Library._init.$local.one]
add dl, Book.title
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, [Library._init.string_4]
push ecx
mov ax, 0x0100
int 0x30
push edx	; Begin getting subvar
mov edx, [Library._init.$local.one]
add dl, Book.title
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov ecx, [eax]
push ecx
mov ax, 0x0101
int 0x30
mov ecx, [Library._init.string_5]
push ecx
mov ax, 0x0100
int 0x30
push edx	; Begin getting subvar
mov edx, [Library._init.$local.one]
add dl, Book.pages
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov ecx, [eax]
push ecx
mov ax, 0x0102
int 0x30
mov ax, 0x0101
int 0x30
mov ecx, 0x57
push edx	; Begin getting subvar
mov edx, [Library._init.$local.two]
add dl, Book.pages
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, [Library._init.string_6]
push ecx
mov ax, 0x0100
int 0x30
push edx	; Begin getting subvar
mov edx, [Library._init.$local.two]
add dl, Book.pages
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov ecx, [eax]
push ecx
mov ax, 0x0102
int 0x30
mov ax, 0x0101
int 0x30
pop edx
pop ebx
pop eax
push dword [Library._init.returnVal]
ret
	;Vars:
Library._init.string_5 :
	dd Library._init.string_5_data
Library._init.string_3_data :
	db "Othello", 0
Library._init.string_2_data :
	db "Book one's title is: ", 0
Library._init.$local.one :
	dd 0x0
Library._init.string_1 :
	dd Library._init.string_1_data
Library._init.$local.two :
	dd 0x0
Library._init.string_4_data :
	db "Book one's new title is: ", 0
Library._init.string_4 :
	dd Library._init.string_4_data
Library._init.string_5_data :
	db "Pages in book one: ", 0
Library._init.string_0_data :
	db "A Midsummer Night's Dream", 0
Library._init.string_6 :
	dd Library._init.string_6_data
Library._init.string_2 :
	dd Library._init.string_2_data
Library._init.string_3 :
	dd Library._init.string_3_data
Library._init.string_6_data :
	db "Pages in book two: ", 0
Library._init.string_1_data :
	db "Beowulf", 0
Library._init.string_0 :
	dd Library._init.string_0_data
Library._init.returnVal:
	dd 0x0


Library.$FILE_END :
; *** LIB IMPORT 'Book' ***
[bits 32]
dd Book.$FILE_END - Book.$FILE_START
db "OrcaHLL Class", 0
db "Book", 0
Book.$FILE_START :

Book.pages equ 4
Book.title equ 0

Book.Create: 
pop dword [Book.Create.returnVal]
pop dword [Book.Create.$local.title]
push eax
push ebx
push edx
mov ecx, 8
push ecx
mov ax, 0x0501
int 0x30
mov [Book.Create.$local.ret], ecx
mov ecx, 0x10
push edx	; Begin getting subvar
mov edx, [Book.Create.$local.ret]
add dl, Book.pages
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, [Book.Create.$local.title]
push edx	; Begin getting subvar
mov edx, [Book.Create.$local.ret]
add dl, Book.title
mov eax, edx
mov edx, [edx]
pop edx	; End getting subvar
mov [eax], ecx
mov ecx, [Book.Create.$local.ret]
pop edx
pop ebx
pop eax
push dword [Book.Create.returnVal]
ret
	;Vars:
Book.Create.$local.ret :
	dd 0x0
Book.Create.$local.title :
	dd 0x0
Book.Create.returnVal:
	dd 0x0


Book.$FILE_END :



