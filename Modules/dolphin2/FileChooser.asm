FileChooser.Prompt :	; String title, String buttonText, String callback
	enter 0, 0
		
		mov eax, [ebp+8]
		mov [FileChooser.callback], eax
	
		push dword [ebp+16]
		push dword 0*4
		push dword 0
		push dword 300*4
		push dword 300
		call Dolphin2.makeWindow
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
		
		mov eax, 0x0
		.outerLoop :
		call Minnow4.readFileBlock
		.innerLoop :
		mov ebx, ecx
		call String.getLength
		add ecx, edx
		add ecx, 4
		;
			pusha
			push ebx
			push dword [.x]
			push dword [.y]
			push dword 150*4
			push dword FONTHEIGHT+5
			call TextLine.Create
			mov eax, ecx
			mov ebx, [.panel]
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
		cmp byte [ecx], null
			jne .innerLoop
		call Minnow4.getNextFileBlock
		cmp eax, 0x0
			jne .outerLoop
	.kret :
	leave
	ret 12
	.win :
		dd 0x0
	.panel :
		dd 0x0
	.x :
		dd 0x0
	.y :
		dd 0x0
	.sampleText :
		db "[Test File Name]", 0x0
FileChooser.doCallback :
	pusha
	
		mov eax, [FileChooser.Prompt.panel]
		mov eax, [eax+SelectionPanel_selectedComponent]
		add eax, Button_text
		mov eax, [eax]
		mov [FileChooser.fileName], eax
		
		call dword [FileChooser.callback]
		
		mov eax, [FileChooser.Prompt.win]
		call WindowGrouping.closeCallback
	
	popa
	ret

FileChooser.fileName :
	dd 0x0
FileChooser.callback :
	dd 0x0
