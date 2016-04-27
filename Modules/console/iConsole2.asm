iConsole2.Init :
	pusha
		
		push iConsole2.windowTitle
		push dword 0*4
		push dword 0
		push dword 300*4
		push dword 100
		call Dolphin2.makeWindow
		mov [iConsole2.window], ecx
		mov dword [ecx+Grouping_backingColor], 0xFF000000
		
		push dword iConsole2.BUFFER_SIZE
		push dword 0
		push dword 0
		push dword 300*4
		push dword 100
		push dword FALSE
		call TextArea.Create
		mov dword [ecx+Component_keyHandlerFunc], iConsole2.HandleKeyEvent
		mov [iConsole2.text], ecx
		
		mov eax, ecx
		mov ebx, [iConsole2.window]
		call Grouping.Add
		
		mov eax, iConsole2.welcomeText
		mov ebx, [iConsole2.text]
		call TextArea.SetText
		
		call iConsole2.PrintPrompt
		
		push dword iConsole2.COMMAND_ECHO
		call iConsole2.RegisterCommand	
		
		push dword iConsole2.COMMAND_CLEAR
		call iConsole2.RegisterCommand
		
		push dword iConsole2.COMMAND_HELP
		call iConsole2.RegisterCommand
		
	popa
	ret
	
iConsole2.HandleKeyEvent :
	pusha
		mov [0x1000], esp
		mov al, [Component.keyChar]
		cmp al, 0xFE
			jne iConsole2.HandleKeyEvent.notnewl
		
		call TextArea.onKeyboardEvent.handle
		
		push ebx
		mov eax, [iConsole2.commandStart]
		mov ebx, iConsole2.commandStore
		call String.copy
		pop ebx
		
		mov dword [.instr], false
		mov eax, iConsole2.commandStore
		.loop :
		mov bl, [eax]
		add eax, 1
		cmp bl, '"'
			jne .notQuotes
		xor dword [.instr], true
		.notQuotes :
		cmp bl, ' '
			jne .notspace
		cmp dword [.instr], true
			je .notspace
		mov byte [eax-1], 0x0
		push eax
		.notspace :
		cmp bl, endstr
			jne .loop
		
		mov byte [eax-2], null	; get rid of the trailing enter

		mov eax, [iConsole2.commandBase]
		mov ebx, iConsole2.commandStore
		.cloop :		; need to add a quit if it turns out the command was unknown!
		mov ecx, eax
		mov eax, [ecx]
		call os.seq
		cmp al, 0x1	; ugh whyyy
			je .nomloop
		mov eax, [ecx+command_nextLink]
		cmp eax, 0x0
			je uhoh...
		jmp .cloop
		.nomloop :
		
		call [ecx+command_function]
		
		call iConsole2.PrintPrompt
	popa
	ret
	.instr :
		dd false
	uhoh... :	; PANIC!
		push dword iConsole2.INVALID_COMMAND
		call iConsole2.Echo
		mov esp, [0x1000]
		call iConsole2.PrintPrompt
		popa
		ret
iConsole2.QUOTES :
	db '"', 0
iConsole2.INVALID_COMMAND :
	db "Command invalid.", 0
iConsole2.HandleKeyEvent.notnewl :
		cmp al, 0xFF
			je iConsole2.HandleKeyEvent.handleBackspace
		; do some other stuff?
		call TextArea.onKeyboardEvent.handle
	popa
	ret
iConsole2.HandleKeyEvent.handleBackspace :
		push ebx
		mov ebx, [ebx+Textarea_text]
		call String.getLength
		sub edx, 1
		add ebx, edx
		cmp ebx, [iConsole2.commandStart]
			jbe iConsole2.HandleKeyEvent.handleBackspace.ret
		pop ebx
		jmp TextArea.onKeyboardEvent.handleBackspace
	iConsole2.HandleKeyEvent.handleBackspace.ret :
	pop ebx
	popa
	ret
		

iConsole2.PrintPrompt :
	pusha
		mov ebx, [iConsole2.text]
		mov eax, iConsole2.prompt
		call TextArea.AppendText
		mov ebx, [iConsole2.text]
		mov ebx, [ebx+Textarea_text]
		call String.getLength
		sub edx, 1
		add ebx, edx
		mov [iConsole2.commandStart], ebx
	popa
	ret

iConsole2.COMMAND_ECHO :
dd iConsole2.STR_ECHO
dd iConsole2.Echo
dd null
iConsole2.Echo :	; String text
	enter 0, 0
		mov eax, [ebp+8]
		mov ebx, [iConsole2.text]
		call TextArea.AppendText
	leave
	ret 4
iConsole2.STR_ECHO :
	db "echo", 0

iConsole2.COMMAND_CLEAR :
dd iConsole2.STR_CLEAR
dd iConsole2.ClearScreen
dd null
iConsole2.ClearScreen :
	enter 0, 0
		mov ebx, iConsole2.BUFFER_SIZE
		mov eax, [iConsole2.text] 
		mov eax, [eax+Textarea_text]
		call Buffer.clear
	leave
	ret 0
iConsole2.STR_CLEAR :
	db "clear", 0

iConsole2.COMMAND_HELP :
dd iConsole2.STR_HELP
dd iConsole2.DisplayHelp
dd null
iConsole2.DisplayHelp :
	enter 0, 0
		mov ebx, [iConsole2.text]
		mov eax, [iConsole2.commandBase]
		.loop :
		mov ecx, eax
		mov eax, [eax+command_name]
		call TextArea.AppendText
		mov eax, iConsole2.DisplayHelp.STR_SEPERATOR
		call TextArea.AppendText
		mov eax, [ecx+command_nextLink]
		cmp eax, null
			jne .loop
	leave
	ret 0
iConsole2.DisplayHelp.STR_SEPERATOR :
	db ",", newline, null
iConsole2.STR_HELP :
	db "help", 0

iConsole2.RegisterCommand :	; Command command
	enter 0, 0
		mov eax, [ebp+8]
		mov ebx, [iConsole2.commandBase]
		cmp ebx, 0
			je .setbase
		.loop :
		mov ecx, ebx
		mov ebx, [ebx+command_nextLink]
		cmp ebx, null
			jne .loop
		mov [ecx+command_nextLink], eax
	
	leave
	ret 4
	.setbase :
			mov [iConsole2.commandBase], eax
		leave
		ret 4
	
iConsole2.window :
	dd 0x0
iConsole2.text :
	dd 0x0
iConsole2.windowTitle :
	db "Console", 0
iConsole2.welcomeText :
	db "Os3 Internal Development Build", 0x0A, "Built: "
	incbin "../$Emulator/build_time.log"
	db 0
iConsole2.prompt :
	db 0x0A, "> ", 0
iConsole2.commandStart :
	dd 0x0
iConsole2.invalidCommand :
	db "Command invalid: ", 0
iConsole2.commandStore :
	times 512 db 0
iConsole2.commandBase :
	dd 0x0
	
command_name		equ 0x0
command_function	equ 0x4
command_nextLink	equ 0x8

iConsole2.BUFFER_SIZE	equ 500