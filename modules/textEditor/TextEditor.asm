TextEditor.COMMAND_RUN :
	dd TextEditor.STR_TEXTEDITORNAME
	dd TextEditor.main
	dd null
;TextEditor.BINDING_RAWTEXT :
;	dd TextEditor.STR_RAWTEXTTYPE
;	dd TextEditor.mainFromConsoleFile
;	dd null
TextEditor.init :
	methodTraceEnter
	pusha
		push dword TextEditor.COMMAND_RUN
		call iConsole2.RegisterCommand
;		push dword TextEditor.BINDING_RAWTEXT
;		call iConsole2.RegisterFiletypeBinding
	popa
	methodTraceLeave
	ret
TextEditor.STR_TEXTEDITORNAME :
	db "textedit", 0x0
TextEditor.STR_RAWTEXTTYPE :
	db "rawtext", 0x0

TextEditor.main :
	methodTraceEnter
	pusha
		push dword TextEditor.placeholderTitle
		push dword 0*4
		push dword 0
		push dword 300*4
		push dword 400
		call WinMan.CreateWindow;Dolphin2.makeWindow
		mov [TextEditor.window], ecx
		mov ebx, ecx
		
		push dword 1000
		push dword 0*4
		push dword 0
		push dword 300*4
		push dword 300
		push dword FALSE
		call TextArea.Create
		mov eax, ecx
		call Grouping.Add
		mov [TextEditor.text], ecx
		;mov dword [ecx+Component_keyHandlerFunc], TextEditor.keyHandlerFunc
		
		push dword TextEditor.doLoadFile.loadButtonMessage
		push dword TextEditor.doLoadFile
		push dword 150*4
		push dword 300
		push dword 50*4
		push dword 100
		call Button.Create
		mov eax, ecx
		call Grouping.Add
		
		push dword TextEditor.doSaveFile.saveButtonMessage
		push dword TextEditor.doSaveFile
		push dword 0*4
		push dword 300
		push dword 50*4
		push dword 100
		call Button.Create
		mov eax, ecx
		call Grouping.Add
		
	popa
	methodTraceLeave
	ret
TextEditor.placeholderTitle :
	db "TextEditor- Untitled", 0x0
TextEditor.fileTitle :
	times 20 dq 0x0
TextEditor.window :
	dd 0x0
TextEditor.text  :
	dd 0x0

;TextEditor.mainFromConsoleFile :	; until reimplemented
;	methodTraceEnter
;	pusha
;		mov eax, iConsole2.commandStore
;		mov [FileChooser.fileName], eax
;		call TextEditor.main
;		call TextEditor.loadFile
;	popa
;	methodTraceLeave
;	ret

TextEditor.loadFile :
	methodTraceEnter
	pusha
		mov eax, [FileChooser.file]
		mov ebx, [TextEditor.text]
		mov ebx, [ebx+Textarea_text]
		mov ecx, 1000
		mov edx, 0
		call Minnow5.readBuffer
;		mov eax, TextEditor.fileTitle	; title changing is broken!
;		mov ebx, 20*8
;		call Buffer.clear
;		mov eax, [FileChooser.fileName]
;		mov ebx, TextEditor.fileTitle
;		call String.copy
;		mov ecx, [TextEditor.window]
;		mov eax, [ecx+WindowGrouping_title]
;		mov dword [eax], TextEditor.fileTitle
	popa
	methodTraceLeave
	ret
	
TextEditor.saveFile :
	methodTraceEnter
	pusha
		mov eax, [FileChooser.file]
		mov ebx, [TextEditor.text]
		mov ebx, [ebx+Textarea_text]
		call String.getLength
		mov ecx, edx
		mov edx, 0
		call Minnow5.writeBuffer
;		mov eax, TextEditor.fileTitle	; title changing is broken!
;		mov ebx, 20*8
;		call Buffer.clear
;		mov eax, [FileChooser.fileName]
;		mov ebx, [TextEditor.fileTitle]
;		call String.copy
;		mov ecx, [TextEditor.window]
;		mov eax, [ecx+WindowGrouping_title]
;		mov dword [eax], TextEditor.fileTitle
	popa
	methodTraceLeave
	ret

TextEditor.doSaveFile :
	methodTraceEnter
		push dword iConsole2.currentFolder
		push dword .savePromptTitle
		push dword .saveButtonMessage
		push dword TextEditor.saveFile
		call FileChooser.Prompt
	methodTraceLeave
	ret
	.savePromptTitle :
		db "Save a File", 0
	.saveButtonMessage :
		db "Save", 0x0

TextEditor.doLoadFile :
	methodTraceEnter
		push dword iConsole2.currentFolder
		push dword .loadPromptTitle
		push dword .loadButtonMessage
		push dword TextEditor.loadFile
		call FileChooser.Prompt
	methodTraceLeave
	ret
.loadPromptTitle :
	db "Open a File", 0
.loadButtonMessage :
	db "Open", 0
	
TextEditor.keyHandlerFunc :
	methodTraceEnter
	pusha
		call TextArea.onKeyboardEvent.handle
	popa
	methodTraceLeave
	ret
TextEditor.callbackFunc :
	dd 0x0
