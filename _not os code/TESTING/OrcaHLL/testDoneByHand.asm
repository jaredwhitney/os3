[bits 32]
dd $END-$START
db "OrcaHLLex", 0
db "Orca HLL Test", 0
$START :

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
	
	mov eax, Meta.Permission.DOLPHIN_CREATE_WINDOWS
	mov word [System.function], Meta.Manager.Request
	int 0x30
	
	; Global
	mov ebx, [TestProgram.$memLoc]
	add ebx, [TestProgram.$obj_createOffs]
	mov [TestProgram.$global.w], ebx
	mov ebx, [TestProgram.$obj_createOffs]
	add ebx, [Meta.Window.SIZE]
	mov [TestProgram.$obj_createOffs], ebx
	
ret

TestProgram._init :
	
	mov ebx, [TestProgram.$memLoc]	; line
	add ebx, [TestProgram.$global.w]
	
	push dword TestProgram.$final.String_0
	push dword [Meta.Window.TYPE_TEXT]
	
	mov word [System.function], Meta.Dolphin.CreateWindow
	int 0x30
	
	mov ebx, [TestProgram.$memLoc]	; line
	add ebx, [TestProgram.$global.w]
	add ebx, [Meta.Window.offs.buffer]
	
	push dword TestProgram.$final.String_1
	
	mov word [System.function], Meta.String.HLLcopy
	int 0x30
	
	mov ebx, [TestProgram.$memLoc]	; line
	add ebx, [TestProgram.$global.w]
	push dword 0
	push dword 0
	mov word [System.function], Meta.Window.SetPosition
	int 0x30
	
	mov ebx, [TestProgram.$memLoc]	; line
	add ebx, [TestProgram.$global.w]
	
	mov word [System.function], Meta.Window.GetPreferredWidth
	int 0x30
	push ecx
	
	mov ebx, [TestProgram.$memLoc]
	add ebx, [TestProgram.$global.w]
	
	mov word [System.function], Meta.Window.GetPreferredHeight
	int 0x30
	push ecx
	
	mov ebx, [TestProgram.$memLoc]
	add ebx, [TestProgram.$global.w]
	
	mov word [System.function], Meta.Window.SetSize
	int 0x30
	
	mov ebx, [TestProgram.$memLoc]	; line
	add ebx, [TestProgram.$global.w]
	mov word [System.function], Meta.Window.ShowWindow
	int 0x30
	
	push dword TestProgram.handleKeys	; line
	push dword [Meta.KeyManager.MODE_DEBOUNCED]
	mov word [System.function], Meta.KeyManager.RecieveKeyPresses
	int 0x30
	
ret	

TestProgram.handleKeys :
	pop bl
	mov [TestProgram.$local._handleKeys.c], bl
	
	mov ebx, [TestProgram.$memLoc]	; line
	add ebx, [TestProgram.$global.w]
	add ebx, [Meta.Window.offs.buffer]
	push ebx
	
	mov bl, [TestProgram.$local._handleKeys.c]
	push ebx
	
	mov word [System.function], Meta.String.Append
	int 0x30
	
ret

TestProgram.$global.w :
	dd 0x0
TestProgram.$final.String_0 :
	db "Test", 0
TestProgram.$final.String_1 :
	db "This window is a test!", 0x0A, ":)", 0
TestProgram.$local._handleKeys.c :
	db 0x0


TestProgram.$obj_createOffs :
	dd 0x0
TestProgram.$memLoc :
	dd 0x0
	
$END :