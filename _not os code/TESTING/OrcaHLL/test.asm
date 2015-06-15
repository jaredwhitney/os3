[bits 32]
dd $TestProgram_END - $TestProgram_START
db "OrcaHLLex", 0
db "Orca HLL Test", 0
$TestProgram_START :

dd TestProgram._init	; pointer to the _init function

TestProgram.$PRE_RUN :

	; Pre-alloc
	mov ebx, 200
	mov word [System.function], Meta.Guppy.Malloc
	int 0x30
	mov [TestProgram.$memLoc], ecx

	; Permission
	mov eax, Meta.Permission.KEYBOARD_LOCAL_RECIEVE
	mov word [System.function], Meta.Manager.Request
	int 0x30

	; Permission
	mov eax, Meta.Permission.DOLPHIN_CREATE_WINDOWS
	mov word [System.function], Meta.Manager.Request
	int 0x30

ret

TestProgram._init :

	push dword TestProgram.$final.String_0
	push dword [Meta.Window.TYPE_TEXT]

	mov ebx [TestProgram.$memLoc]
	add ebx [TestProgram.$obj_createOffs]

	push word [System.function], Meta.Window.Create
	int 0x30

	sub ecx, [TestProgram.$memLoc]
	mov [TestProgram.$global.window], ecx

	mov ebx, [TestProgram.$memLoc]
	add ebx, [TestProgram.$global.window]
	add ebx, [Meta.Window.offs.buffer]

	push dword TestProgram.$final.String_1
	mov word [System.function], Meta.String.Copy
	int 0x30

	push dword 0
	push dword 0

	mov ebx, [TestProgram.$memLoc]
	add ebx, [TestProgram.$global.window]
	push word [System.function], Meta.Window.SetPosition
	int 0x30


	mov ebx, [TestProgram.$memLoc]
	add ebx, [TestProgram.$global.window]
	push word [System.function], Meta.Window.GetPreferredWidth
	int 0x30
	push dword ecx

	mov ebx, [TestProgram.$memLoc]
	add ebx, [TestProgram.$global.window]
	push word [System.function], Meta.Window.GetPreferredHeight
	int 0x30
	push dword ecx

	mov ebx, [TestProgram.$memLoc]
	add ebx, [TestProgram.$global.window]
	push word [System.function], Meta.Window.SetSize
	int 0x30


	mov ebx, [TestProgram.$memLoc]
	add ebx, [TestProgram.$global.window]
	push word [System.function], Meta.Window.ShowWindow
	int 0x30

	push dword TestProgram.handleKeys
	push dword [Meta.KeyManager.MODE_DEBOUNCED]

	push word [System.function], Meta.KeyManager.RecieveKeyPresses
	int 0x30

ret

TestProgram.handleKeys :

	pop ebx
	mov [TestProgram.$local.handleKeys.c], ebx
	mov ebx, [TestProgram.$memLoc]
	add ebx, [TestProgram.$global.window]
	add ebx, [Meta.Window.offs.buffer]

	push dword ebx
	push dword [TestProgram.$local.handleKeys.c]

	push word [System.function], Meta.String.Append
	int 0x30

ret

TestProgram.$final.String_0 :
	db "Test", 0
TestProgram.$obj_createOffs :
	dd 0x0
TestProgram.$final.String_1 :
	db "This window is a test!", 0xA, ":)", 0
TestProgram.$memLoc :
	dd 0x0
TestProgram.$global.window :
	dd 0x0
TestProgram.$local.handleKeys.c :
	db 0x0


$TestProgram_END :

