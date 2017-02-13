iConsole2.Init :
	methodTraceEnter
	pusha
		
		mov ebx, 0x1000
		call Guppy2.malloc
		mov [iConsole2.currentFolderNameBuffer], ebx
		
		mov ebx, 0x1000
		call Guppy2.malloc
		mov [iConsole2.tempBuffer], ebx
		
		push iConsole2.windowTitle
		push dword 0*4
		push dword 0
		push dword 300*4
		push dword 400
		
		call WinMan.CreateWindow;Dolphin2.makeWindow
		mov [iConsole2.window], ecx
		mov dword [ecx+Grouping_backingColor], 0xFF000000
		
		push dword iConsole2.BUFFER_SIZE
		push dword 0
		push dword 0
		push dword 300*4
		push dword 400
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
		
		push dword iConsole2.COMMAND_ECHO_HEX
		call iConsole2.RegisterCommand
		
		push dword iConsole2.COMMAND_ECHO_DEC
		call iConsole2.RegisterCommand
		
		push dword iConsole2.COMMAND_CLEAR
		call iConsole2.RegisterCommand
		
		push dword iConsole2.COMMAND_HELP
		call iConsole2.RegisterCommand
		
		push dword iConsole2.COMMAND_CD
		call iConsole2.RegisterCommand
		
		push dword iConsole2.COMMAND_LIST_HERE
		call iConsole2.RegisterCommand
		
		push dword iConsole2.COMMAND_MAKE_FOLDER
		call iConsole2.RegisterCommand
		
		push dword iConsole2.COMMAND_DELETE_FILE
		call iConsole2.RegisterCommand
		
		push dword iConsole2.COMMAND_RENAME_FILE
		call iConsole2.RegisterCommand
		
		push dword iConsole2.COMMAND_GUPPY5_TEST
		call iConsole2.RegisterCommand
		
	popa
	methodTraceLeave
	ret

iConsole2.runLoops :
	methodTraceEnter
	pusha
		mov ebx, [iConsole2.taskBase]
		.loop :
		cmp ebx, null
			je .ret
		call [ebx+Task_func]
		mov ebx, [ebx+Task_nextLinked]
		jmp .loop
	.ret :
	popa
	methodTraceLeave
	ret

iConsole2.RegisterTask :
	methodTraceEnter
	enter 0, 0
	
		mov ecx, [ebp+8]
		mov ebx, [iConsole2.taskBase]
		cmp ebx, null
			jne .notSpecialCase
		mov [iConsole2.taskBase], ecx
		jmp .ret
		.notSpecialCase :
		mov edx, [ebx+Task_nextLinked]
		mov [ebx+Task_nextLinked], ecx
		mov [ecx+Task_nextLinked], edx
		
	.ret :
	leave
	methodTraceLeave
	ret 4

iConsole2.UnregisterTask :
	methodTraceEnter
	enter 0, 0
		
		mov eax, [ebp+8]
		mov ecx, [iConsole2.taskBase]
		cmp ecx, 0x0
			je .ret
		cmp ecx, eax
			je .foundBase
		mov ebx, ecx
		.loop :
		mov ecx, [ebx+Task_nextLinked]
		cmp ecx, 0x0
			jmp .ret
		cmp ecx, eax
			je .foundBefore
		mov ebx, ecx
		jmp .loop
		.foundBefore :
		mov eax, [eax+Task_nextLinked]
		mov [ebx+Task_nextLinked], eax
		jmp .ret
		.foundBase :
		mov eax, [eax+Task_nextLinked]
		mov [iConsole2.taskBase], eax
		
	.ret :
	leave
	methodTraceLeave
	ret 4
	
iConsole2.HandleKeyEventNoMod :
	methodTraceEnter
	pusha
		mov al, [Component.keyChar]
		cmp al, 0xFE
			jne .notnewl
		call TextArea.CursorToEnd
		call TextArea.onKeyboardEvent.handle
		jmp .ret
		
		.notnewl :
		cmp al, 0xFF
			je iConsole2.HandleKeyEvent.handleBackspace
		; do some other stuff?
		call TextArea.onKeyboardEvent.handle
	.ret :
	popa
	methodTraceLeave
	ret

iConsole2.HandleKeyEvent :
	cmp dword [iConsole2.keyRedirect], null
		je .noRedirect
	jmp [iConsole2.keyRedirect]
	.noRedirect :
	methodTraceEnter
	pusha
		mov [0x1000], esp
		mov al, [Component.keyChar]
		cmp al, 0xFE
			jne iConsole2.HandleKeyEvent.notnewl
		
		call TextArea.CursorToEnd
		
		call TextArea.onKeyboardEvent.handle
		
		push ebx
		mov eax, [iConsole2.commandStart]
		mov ebx, iConsole2.commandStore
		call String.copy
		pop ebx
		
		mov dword [iConsole2.argNum], 0
		
		mov dword [.instr], false
		mov eax, iConsole2.commandStore
		.loop :
		mov bl, [eax]
		add eax, 1
		cmp bl, '"'
			jne .notQuotes
		xor dword [.instr], true
		cmp dword [.instr], true
			jne .dontFixQuoteOpen
		inc dword [esp]
		.dontFixQuoteOpen :
		cmp dword [.instr], false
			jne .dontFixQuoteClose
		mov byte [eax-1], 0x0
		.dontFixQuoteClose :
		.notQuotes :
		cmp bl, ' '
			jne .notspace
		cmp dword [.instr], true
			je .notspace
		mov byte [eax-1], 0x0
		push eax
		inc dword [iConsole2.argNum]
		.notspace :
		cmp bl, endstr
			jne .loop
		
		mov byte [eax-2], null	; get rid of the trailing enter

		mov eax, [iConsole2.commandBase]
		cmp eax, null
			je uhoh...
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
	methodTraceLeave
	ret
	.instr :
		dd false
	uhoh... :	; PANIC!
		; but first check the filesystem please... [BROKEN ATM AND THERE SHOULD BE A RegisterFileExtentionToCommand THING!]
		mov eax, ebx
		mov ecx, ebx
		call Minnow4.getFilePointer
		cmp ebx, Minnow4.SUCCESS
			jne .bindingNotFound
		
		mov edx, [iConsole2.filetypeBindingBase]
		cmp edx, null
			je .bindingNotFound
		
		.fnamechckloop :
			cmp byte [ecx], '.'
				je .kcont
			cmp byte [ecx], 0
				je .bindingNotFound
			add ecx, 1
			jmp .fnamechckloop
		
		.kcont :
		add ecx, 1
		mov eax, ecx
		
		.goSearchBindingsLoop :
		push eax
		mov ebx, [edx+filetypebinding_name]
		call os.seq
		cmp al, 0x1
		pop eax
			je .kgoRun
		mov edx, [edx+filetypebinding_nextLink]
		cmp edx, null
			je .bindingNotFound
		jmp .goSearchBindingsLoop
		
		.kgoRun :
		call [edx+filetypebinding_function]	
		jmp iConsole2.returnBlind.aret
		
		.bindingNotFound :
		push dword iConsole2.INVALID_COMMAND
		call iConsole2.Echo
		iConsole2.returnBlind :
		mov esp, [0x1000]
		.aret :
		call iConsole2.PrintPrompt
		popa
		methodTraceLeave
		ret
	iConsole2.returnBlindSilent :
		call iConsole2.GoResetCommandPtr
		mov esp, [0x1000]
		popa
		methodTraceLeave
		ret
iConsole2.QUOTES :
	db '"', 0
iConsole2.INVALID_COMMAND :
	db "Command invalid.", 0
iConsole2.argNum :
	dd null
iConsole2.keyRedirect :
	dd null
iConsole2.HandleKeyEvent.notnewl :
		cmp al, 0xFF
			je iConsole2.HandleKeyEvent.handleBackspace
		; do some other stuff?
		call TextArea.onKeyboardEvent.handle
	popa
	methodTraceLeave
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
		methodTraceLeave
		jmp TextArea.onKeyboardEvent.handleBackspace
	iConsole2.HandleKeyEvent.handleBackspace.ret :
	pop ebx
	popa
	methodTraceLeave
	ret
		

iConsole2.PrintPrompt :
	methodTraceEnter
	pusha
		
		mov al, 0x0A	; newline
		mov ebx, [iConsole2.text]
		call TextArea.InsertChar
		
		cmp dword [iConsole2.currentFolder+0x0], -1
			je .noPrintFolderName
		mov eax, iConsole2.currentFolder
		mov ebx, [iConsole2.currentFolderNameBuffer]
		call Minnow5.getPathString
		mov eax, [iConsole2.text]
		xchg eax, ebx
		call TextArea.InsertText
		.noPrintFolderName :
		
		mov ebx, [iConsole2.text]
		mov eax, iConsole2.prompt
		call TextArea.InsertText
		
		call iConsole2.GoResetCommandPtr
		
	popa
	methodTraceLeave
	ret

iConsole2.GoResetCommandPtr :
	methodTraceEnter
	pusha
		mov ebx, [iConsole2.text]
		mov ebx, [ebx+Textarea_text]
		call String.getLength
		sub edx, 1
		add ebx, edx
		mov [iConsole2.commandStart], ebx
	popa
	methodTraceLeave
	ret

iConsole2.COMMAND_ECHO :
dd iConsole2.STR_ECHO
dd iConsole2.Echo
dd null
iConsole2.Echo :	; String text
	methodTraceEnter
	enter 0, 0
	pusha
		mov eax, [ebp+8]
		mov ebx, [iConsole2.text]
		call TextArea.InsertText
	popa
	leave
	methodTraceLeave
	ret 4
iConsole2.STR_ECHO :
	db "echo", 0

iConsole2.EchoChar :	; char ptr
	methodTraceEnter
	enter 0, 0
	pusha
		mov eax, [ebp+8]
		mov al, [eax]
		mov ebx, [iConsole2.text]
		call TextArea.InsertChar
	popa
	leave
	methodTraceLeave
	ret 4

iConsole2.COMMAND_ECHO_HEX :
dd iConsole2.STR_ECHO_HEX
dd iConsole2.EchoHex
dd null
iConsole2.EchoHex :
	methodTraceEnter
	enter 0, 0
	pusha
		mov eax, .strdata
		mov ebx, 12
		call Buffer.clear
		add eax, 2
		mov ebx, [ebp+8]
		call String.fromHex
		push eax
		call iConsole2.Echo
	popa
	leave
	methodTraceLeave
	ret 4
	.strdata :
		db "0x"
		times 5 dw 0
iConsole2.STR_ECHO_HEX :
	db "ehex", 0

iConsole2.COMMAND_ECHO_DEC :
dd iConsole2.STR_ECHO_DEC
dd iConsole2.EchoDec
dd null
iConsole2.EchoDec :
	methodTraceEnter
	enter 0, 0
	pusha
		test dword [ebp+8], 1<<31
			jz .noNeg
		push dword .charNeg
		call iConsole2.EchoChar
		.noNeg :
		mov eax, .strdata
		mov ebx, 12
		call Buffer.clear
		add eax, 2
		fild dword [ebp+8]
		fbstp [.dat]
		mov ebx, [.dat]
		call String.fromHex
		push eax
		call iConsole2.Echo
	popa
	leave
	methodTraceLeave
	ret 4
	.strdata :
		times 3 dd 0
	.dat :
		times 3 dd 0
	.charNeg :
		db '-'
iConsole2.STR_ECHO_DEC :
	dd "edec", 0

iConsole2.COMMAND_PRINT_ARGNUM :
	dd .commandStr
	dd iConsole2.PrintNumArgs
	dd null
	.commandStr :
		db "argnum", 0
iConsole2.PrintNumArgs :
	methodTraceEnter
	enter 0, 0
		mov eax, [iConsole2.argNum]
		push dword .STR_PREFACE
		call iConsole2.Echo
		push eax
		call iConsole2.EchoHex
	leave
	methodTraceLeave
	jmp iConsole2.returnBlind
	.STR_PREFACE :
		db "args: ", 0

nowhere :
	times 4 dq null

iConsole2.COMMAND_CLEAR :
dd iConsole2.STR_CLEAR
dd iConsole2.ClearScreen
dd null
iConsole2.ClearScreen :
	methodTraceEnter
	enter 0, 0
		mov ebx, iConsole2.BUFFER_SIZE
		mov eax, [iConsole2.text]
		mov dword [eax+Textarea_cursorPos], 0
		mov eax, [eax+Textarea_text]
		call Buffer.clear
	leave
	methodTraceLeave
	ret 0
iConsole2.STR_CLEAR :
	db "clear", 0

iConsole2.COMMAND_HELP :
dd iConsole2.STR_HELP
dd iConsole2.DisplayHelp
dd null
iConsole2.DisplayHelp :
	methodTraceEnter
	enter 0, 0
		mov ebx, [iConsole2.text]
		mov eax, [iConsole2.commandBase]
		.loop :
		mov ecx, eax
		mov eax, [eax+command_name]
		call TextArea.InsertText
		mov eax, iConsole2.STR_SEPERATOR
		call TextArea.InsertText
		mov eax, [ecx+command_nextLink]
		cmp eax, null
			jne .loop
	leave
	methodTraceLeave
	ret 0
iConsole2.STR_SEPERATOR :
	db ", ", newline, null
iConsole2.STR_HELP :
	db "help", 0

iConsole2.COMMAND_CD :
	dd .str
	dd iConsole2.ChangeDirectory
	dd null
	.str :
		db "cd", 0
iConsole2.ChangeDirectory :
	methodTraceEnter
	enter 0, 0
	pusha
		mov eax, [ebp+8]
		mov ebx, iConsole2.currentFolder
		mov ecx, [ebx+0x0]
		mov edx, [ebx+0x4]
		call Minnow5.byName
		cmp dword [iConsole2.currentFolder+0x0], -1
			je .needsFix
		cmp dword [iConsole2.currentFolder+0x4], -1
			jne .noFix
		.needsFix :
		mov [iConsole2.currentFolder+0x0], ecx
		mov [iConsole2.currentFolder+0x4], edx
		push dword .errorStr
		call iConsole2.Echo
	.noFix :
	popa
	leave
	methodTraceLeave
	ret 4
.errorStr :
	db "The specified location could not be found.", 0

iConsole2.COMMAND_LIST_HERE :
	dd .str
	dd iConsole2.ListHere
	dd null
	.str :
		db "ld", 0
iConsole2.ListHere :
	methodTraceEnter
	enter 0, 0
	pusha
		mov eax, [iConsole2.currentFolder+0x4]
		mov ebx, [iConsole2.currentFolder+0x0]
		call Minnow5.getInner
		cmp eax, null
			je .noloop
		.loop :
		mov ecx, [iConsole2.tempBuffer]
		call Minnow5.getBlockName
		push ecx
		call iConsole2.Echo
		push iConsole2.STR_SEPERATOR
		call iConsole2.Echo
		call Minnow5.getNext
		cmp eax, null
			jne .loop
	.noloop :
	popa
	leave
	methodTraceLeave
	ret 0

iConsole2.COMMAND_MAKE_FOLDER :
	dd .str
	dd iConsole2.MakeFolder
	dd null
	.str :
		db "mkd", 0
iConsole2.MakeFolder :
	methodTraceEnter
	enter 0, 0
	pusha
		mov eax, iConsole2.currentFolder
		mov ebx, [ebp+8]
		mov ecx, null
		call Minnow5.makeFolder	; qword buffer (file) in eax, nameptr in ebx, attribs in ecx, returns eax = folderptr
	popa
	leave
	methodTraceLeave
	ret 4

iConsole2.COMMAND_DELETE_FILE :
	dd .str
	dd iConsole2.DeleteFile
	dd null
	.str :
		db "del", 0
iConsole2.DeleteFile :
	methodTraceEnter
	enter 0, 0
	pusha
		mov eax, [iConsole2.currentFolder+0x0]
		mov [iConsole2.workingFile+0x0], eax
		mov eax, [iConsole2.currentFolder+0x4]
		mov [iConsole2.workingFile+0x4], eax
		mov eax, [ebp+8]
		mov ebx, iConsole2.workingFile
		call Minnow5.byName
		mov eax, iConsole2.workingFile
		call Minnow5.deleteFile
	popa
	leave
	methodTraceLeave
	ret 4

iConsole2.COMMAND_RENAME_FILE :
	dd .str
	dd iConsole2.RenameFile
	dd null
	.str :
		db "ren", 0
iConsole2.RenameFile :
	methodTraceEnter
	enter 0, 0
	pusha
		mov eax, [iConsole2.currentFolder+0x0]
		mov [iConsole2.workingFile+0x0], eax
		mov eax, [iConsole2.currentFolder+0x4]
		mov [iConsole2.workingFile+0x4], eax
		mov eax, [ebp+12]
		mov ebx, iConsole2.workingFile
		call Minnow5.byName
		mov eax, iConsole2.workingFile
		mov ebx, [ebp+8]
		call Minnow5.nameFile
	popa
	leave
	methodTraceLeave
	ret 8

iConsole2.COMMAND_GUPPY5_TEST :
	dd .str
	dd iConsole2.DoGuppy5Test
	dd null
	.str :
		db "5test", 0
iConsole2.DoGuppy5Test :
	methodTraceEnter
	enter 0, 0
	pusha
		mov eax, [iConsole2.currentFolder+0x0]
		mov [iConsole2.workingFile+0x0], eax
		mov eax, [iConsole2.currentFolder+0x4]
		mov [iConsole2.workingFile+0x4], eax

		mov eax, [ebp+8]
		mov ebx, iConsole2.workingFile
		call Minnow5.byName
		
		mov eax, [iConsole2.currentFolder+0x4]
		mov ebx, [iConsole2.currentFolder+0x0]
		call Minnow5.getSize
		PUSH eax
		call iConsole2.EchoDec
		
	popa
	leave
	methodTraceLeave
	ret 4

iConsole2.RegisterCommand :	; Command command
	methodTraceEnter
	enter 0, 0
	pusha
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
	popa
	leave
	methodTraceLeave
	ret 4
	.setbase :
			mov [iConsole2.commandBase], eax
		leave
		methodTraceLeave
		ret 4

iConsole2.RegisterFiletypeBinding :	; FiletypeBinding binding
	methodTraceEnter
	enter 0, 0
		mov eax, [ebp+8]
		mov ebx, [iConsole2.filetypeBindingBase]
		cmp ebx, 0
			je .setbase
		.loop :
		mov ecx, ebx
		mov ebx, [ebx+filetypebinding_nextLink]
		cmp ebx, null
			jne .loop
		mov [ecx+filetypebinding_nextLink], eax
	
	leave
	methodTraceLeave
	ret 4
	.setbase :
			mov [iConsole2.filetypeBindingBase], eax
		leave
		methodTraceLeave
		ret 4
	
iConsole2.window :
	dd 0x0
iConsole2.text :
	dd 0x0
iConsole2.currentFolder :
	dd -1
	dd null
iConsole2.workingFile :
	dq 0
iConsole2.currentFolderNameBuffer :
	dd 0x0
iConsole2.tempBuffer :
	dd 0x0
iConsole2.windowTitle :
	db "Console", 0
iConsole2.welcomeText :
	db "Os3 Internal Development Build", 0x0A, "Built: "
	incbin "../$Emulator/build_time.log"
	db 0
iConsole2.prompt :
	db "> ", 0
iConsole2.commandStart :
	dd 0x0
iConsole2.invalidCommand :
	db "Command invalid: ", 0
iConsole2.commandStore :
	times 512 db 0

iConsole2.taskBase :
	dd null
iConsole2.commandBase :
	dd null
iConsole2.filetypeBindingBase :
	dd null
	
command_name		equ 0x0
command_function	equ 0x4
command_nextLink	equ 0x8

filetypebinding_name		equ 0x0
filetypebinding_function	equ 0x4
filetypebinding_nextLink	equ 0x8

Task_func			equ 0x0
Task_nextLinked		equ 0x4

iConsole2.BUFFER_SIZE	equ 1500
