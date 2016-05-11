TextEditor.init :
	pusha
		push dword TextEditor.placeholderTitle
		push dword 0*4
		push dword 0
		push dword 300*4
		push dword 300
		call Dolphin2.makeWindow
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
		
		mov dword [ecx+Component_keyHandlerFunc], TextEditor.keyHandlerFunc
	popa
	ret
TextEditor.placeholderTitle :
	db "TextEditor- Untitled", 0x0
TextEditor.promptTitle :
	db "TextEditor", 0x0
TextEditor.promptMessage :
	db "File Name: ", 0x0
TextEditor.fileTitle :
	times 20 dq 0x0
TextEditor.window :
	dd 0x0
TextEditor.text  :
	dd 0x0
	
TextEditor.loadFile :
	pusha
		mov eax, [PromptBox.response]
		call Minnow4.getFilePointer
		;cmp ebx,  Minnow4.SUCCESS
		;	jne .fileNotFound
		mov ecx, [TextEditor.text]
		mov ecx, [ecx+Textarea_text]
		mov edx, 1000
		call Minnow4.readBuffer
		mov eax, TextEditor.fileTitle	; title changing is broken!
		mov ebx, 20*8
		call Buffer.clear
		mov eax, [PromptBox.response]
		mov ebx, [TextEditor.fileTitle]
		call String.copy
		mov ecx, [TextEditor.window]
		mov eax, [ecx+WindowGrouping_title]
		mov dword [eax], TextEditor.fileTitle
	popa
	ret
	
TextEditor.saveFile :
	pusha
		mov eax, [PromptBox.response]
		call Minnow4.getFilePointer
		cmp ebx, Minnow4.SUCCESS
			je .goon
		mov eax, [PromptBox.response]
		call Minnow4.createFile	; this does not work :/
		.goon :
		mov ecx, [TextEditor.text]
		mov ecx, [ecx+Textarea_text]
		mov edx, 1000
		call Minnow4.writeBuffer
		mov eax, TextEditor.fileTitle	; title changing is broken!
		mov ebx, 20*8
		call Buffer.clear
		mov eax, [PromptBox.response]
		mov ebx, [TextEditor.fileTitle]
		call String.copy
		mov ecx, [TextEditor.window]
		mov eax, [ecx+WindowGrouping_title]
		mov dword [eax], TextEditor.fileTitle
	popa
	ret

TextEditor.getFileName :
		push dword TextEditor.promptTitle
		push dword TextEditor.promptMessage
		push dword [TextEditor.callbackFunc]
		call PromptBox.PromptForString
	ret
	
TextEditor.keyHandlerFunc :
	pusha
		mov al, [Component.keyChar]
		cmp al, '1'	; just for now, replace with F1 later
			jne .dontLoadFile
		mov dword [TextEditor.callbackFunc], TextEditor.loadFile
		call TextEditor.getFileName
		jmp .ret
		.dontLoadFile :
		cmp al, '2'	; just for now, replace with F2 later
			jne .dontSaveFile
		mov dword [TextEditor.callbackFunc], TextEditor.saveFile
		call TextEditor.getFileName
		jmp .ret
		.dontSaveFile :
		call TextArea.onKeyboardEvent.handle
	.ret :
	popa
	ret
TextEditor.callbackFunc :
	dd 0x0