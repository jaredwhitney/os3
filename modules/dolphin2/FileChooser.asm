FileChooser.Prompt :	; file base, String title, String buttonText, String callback
	methodTraceEnter
	enter 0, 0
	
		cmp dword [FileChooser.nameBuffer], null
			jne .noAlloc
		mov ebx, 0x1000
		call Guppy2.malloc
		mov [FileChooser.nameBuffer], ebx
		.noAlloc :
		
		mov eax, [ebp+8]
		mov [FileChooser.callback], eax
		
		mov eax, [ebp+20]
		mov ebx, [eax+0x0]
		mov [FileChooser.workingFolder+0x0], ebx
		mov ebx, [eax+0x4]
		mov [FileChooser.workingFolder+0x4], ebx
	
		push dword [ebp+16]
		push dword 0*4
		push dword 0
		push dword 300*4
		push dword 300
		call WinMan.CreateWindow;Dolphin2.makeWindow
		mov [.win], ecx
		
		push dword 0*4
		push dword 0
		push dword 300*4
		push dword 300
		call SelectionPanel.Create
		mov eax, ecx
		mov ebx, [.win]
		call Grouping.Add
		mov [.panel], ecx
		mov dword [ecx+SelectionPanel_backingColor], 0xFF090324
		
		push dword [ebp+12]
		push dword FileChooser.doCallback
		push dword 0*4
		push dword 250
		push dword 300*4
		push dword 50
		call Button.Create
		mov eax, ecx
		mov ebx, [.win]
		call Grouping.Add
		
		push dword .createFileStr
		push dword FileChooser.goPromptFileCreation
		push dword 250*4
		push dword 275
		push dword 50*4
		push dword 25
		call Button.Create
		mov eax, ecx
		mov ebx, [.win]
		call Grouping.Add
		mov dword [ecx+Button_backingColor], 0xFFCC00CC
		
		call FileChooser.loadFiles
		
	leave
	methodTraceLeave
	ret 16
	.win :
		dd 0x0
	.panel :
		dd 0x0
	.sampleText :
		db "[Test File Name]", 0x0
	.createFileStr :
		db "New File...", 0
FileChooser.doCallback :
	methodTraceEnter
	pusha
	
		mov eax, [FileChooser.Prompt.panel]
		mov eax, [eax+SelectionPanel_selectedComponent]
		add eax, Button_text
		mov eax, [eax]
		
		mov ebx, FileChooser.workingFolder
		call Minnow5.byName
		mov [FileChooser.file], ebx
		
		call dword [FileChooser.callback]
		
		mov ebx, [FileChooser.Prompt.win]
		call WindowGrouping.closeCallback
	
	popa
	methodTraceLeave
	ret

FileChooser.goPromptFileCreation :
	methodTraceEnter
	pusha
		
		push dword .createAfileStr
		push dword .createStr
		push dword FileChooser.createAndReloadFiles
		call PromptBox.PromptForString
		
	popa
	methodTraceLeave
	ret
	.createAfileStr :
		db "New file...", 0x0
	.createStr :
		db "File Name: ", 0x0
	
FileChooser.createAndReloadFiles :
	methodTraceEnter
	pusha
		
		mov eax, FileChooser.workingFolder
		mov ebx, [PromptBox.response]
		mov ecx, null
		call Minnow5.makeFile
		
		mov ebx, [FileChooser.Prompt.panel]
		.clearLoop :
		cmp dword [ebx+Grouping_subcomponent], null
			je .clearDone
		mov eax, [ebx+Grouping_subcomponent]
		call Grouping.Remove
		jmp .clearLoop
		.clearDone :
		
		call FileChooser.loadFiles
		
	popa
	methodTraceLeave
	ret

FileChooser.loadFiles :
	methodTraceEnter
	pusha
		
		mov eax, [FileChooser.workingFolder+0x4]
		mov ebx, [FileChooser.workingFolder+0x0]
		call Minnow5.getInner
		
		cmp eax, 0
			je .kret
			
		mov ecx, [FileChooser.nameBuffer]
		
		mov dword [.x], 0*4
		mov dword [.y], 0
		.outerLoop :
		
		; read file (get ebx = file name)
		mov ebx, [FileChooser.workingFolder+0x0]
		call Minnow5.getBlockName
		mov ebx, ecx
		
		call String.getLength
		add ecx, edx
		;
			pusha
			push ebx
			push dword [.x]
			push dword [.y]
			push dword 150*4
			push dword FONTHEIGHT+5
			call TextLine.Create
			mov eax, ecx
			mov ebx, [FileChooser.Prompt.panel]
			call SelectionPanel.Add
			add dword [.x], 150*4
			cmp dword [.x], 300*4-60*4
				jle .noworry
			mov dword [.x], 0x0
			add dword [.y], FONTHEIGHT+5
			.noworry :
			popa
			cmp dword [.y], 250-(FONTHEIGHT+5)
				jg .kret
		;
		mov ebx, [FileChooser.workingFolder+0x0]
		call Minnow5.getNext
		cmp eax, null
			jne .outerLoop
	.kret :
	popa
	methodTraceLeave
	ret
	.x :
		dd 0x0
	.y :
		dd 0x0
	.threshold :
		dd 0x0

FileChooser.workingFolder :
	dq 0x0
FileChooser.file :
	dd 0x0
FileChooser.callback :
	dd 0x0
FileChooser.nameBuffer :
	dd 0x0
