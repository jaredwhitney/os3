HexEditor.COMMAND_RUN :
	dd .str
	dd HexEditor.main
	dd null
	.str :
		db "hexedit", 0

HexEditor.init :
	methodTraceEnter
	pusha
		push dword HexEditor.COMMAND_RUN
		call iConsole2.RegisterCommand
	popa
	methodTraceLeave
	ret
	
HexEditor.main :
	methodTraceEnter
	pusha
		push dword .title
		push dword 0*4
		push dword 0
		push dword 16*(3*(FONTWIDTH*4))
		push dword 400
		call WinMan.CreateWindow
		mov [HexEditor.window], ecx
		mov ebx, ecx
		
		push dword 3*0x200
		push dword 0*4
		push dword 22
		push dword 16*(3*(FONTWIDTH*4))
		push dword 378
		push dword FALSE
		call TextArea.Create
		mov eax, ecx
		call Grouping.Add
		mov [HexEditor.text], ecx
		mov dword [ecx+Component_keyHandlerFunc], HexEditor.swapMode
		
		push dword 40
		push dword 0*4
		push dword 0
		push dword 16*(3*(FONTWIDTH*4))
		push dword 20
		push dword FALSE
		call TextArea.Create
		mov eax, ecx
		call Grouping.Add
		mov [HexEditor.location], ecx
		mov dword [ecx+Component_keyHandlerFunc], HexEditor.locationHandlerFunc
		
	popa
	methodTraceLeave
	ret
	.title :
		db "HexEditor [DevBuild]", 0

HexEditor.location :
	dd 0x0
HexEditor.text :
	dd 0x0
HexEditor.window :
	dd 0x0
HexEditor.mode :
	db 0x0

HexEditor.swapMode :
	methodTraceEnter
	pusha
		xor byte [HexEditor.mode], 0x1
		call HexEditor.goPopulate
	popa
	methodTraceLeave
	ret

HexEditor.locationHandlerFunc :
	methodTraceEnter
	pusha
		mov al, [Component.keyChar]
		cmp al, 0xFE
			jne .aret
		call HexEditor.goPopulate
		jmp .ret
		.aret :
		call TextArea.onKeyboardEvent.handle
	.ret :
	popa
	methodTraceLeave
	ret

HexEditor.goPopulate :
	methodTraceEnter
	pusha
	
		mov ebx, [HexEditor.text]
		mov dword [ebx+Textarea_cursorPos], 0
		mov eax, [ebx+Textarea_text]
		mov ebx, 3*0x200
		call Buffer.clear
		
		mov ebx, [HexEditor.location]
		mov ebx, [ebx+Textarea_text]
		call Integer.hexFromString
		;mov [.loc], ecx
		mov eax, ecx
		xor ebx, ebx
		mov edx, 0x200
		mov ecx, [Minnow5._dat]
		call AHCI.DMAreadToBuffer
		
		xor edx, edx
		.printLoop :
		
			mov eax, .strdata
			mov ebx, 10
			call Buffer.clear
			xor ebx, ebx
			mov bl, [ecx]
			cmp byte [HexEditor.mode], 1
				jne .asHex
			mov [eax], bl
			jmp .getOutDone
			.asHex :
			call String.fromHex
			.getOutDone :
			
		cmp byte [HexEditor.mode], 1
			jne .noEnterFix
		cmp byte [eax], 0xFE
			jne .noEnterFix
		mov byte [eax], 0x0
		.noEnterFix :
			
		pusha
			mov ebx, eax
			call String.getLength
			cmp edx, 3
				je .nofix
			mov ebx, [HexEditor.text]
			cmp edx, 1
				jne .noDoubleFix
			mov al, ' '
			call TextArea.AppendChar
			.noDoubleFix :
			mov al, '0'
			cmp byte [HexEditor.mode], 1
				jne .noMod
			mov al, ' '
			.noMod :
			call TextArea.AppendChar
			.nofix :
		popa
		
		mov ebx, [HexEditor.text]
		call TextArea.AppendText
		
		mov al, ' '
		call TextArea.AppendChar
		
		inc ecx
		inc edx
		cmp edx, 0x200
			jb .printLoop
	popa
	methodTraceLeave
	ret
	.strdata :
		times 5 dw 0
