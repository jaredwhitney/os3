PromptBox.WaitForResponse :	; String name, String prompt, String callback
	enter 0, 0
		pusha
		push dword [ebp+12]
		push dword 0*4
		push dword 0
		push dword 300*4
		push dword 300
		call Dolphin2.makeWindow
		mov dword [ecx+Grouping_backingColor], 0xFF03010C
		mov ebx, ecx
		push dword [ebp+8]
		push dword 10*4
		push dword 10
		push dword 300*4
		push dword FONTHEIGHT
		call TextLine.Create
		mov eax, ecx
		call Grouping.Add
		push dword 256
		push dword 10*4
		push dword 10+FONTHEIGHT
		push dword 300*4
		push dword FONTHEIGHT
		push dword FALSE
		call TextArea.Create
		mov eax, ecx
		call Grouping.Add
		mov dword [PromptBox.hasResponse], false
		mov edx, [ecx+Textarea_text]
		mov [Dolphin2.focusedComponent], ecx
		mov [PromptBox.str], edx
		push dword PromptBox.STR_DONE
		push dword [ebp+16]
		push dword 10*4
		push dword 20+2*FONTHEIGHT
		push dword 4*FONTWIDTH*4
		push dword FONTHEIGHT+4
		call Button.Create
		mov eax, ecx
		call Grouping.Add
		popa
	leave
	ret 12
PromptBox.GotResponse :
	mov dword [PromptBox.hasResponse], true
	ret
PromptBox.hasResponse :
	dd 0x0
PromptBox.window :
	dd 0x0
PromptBox.str :
	dd 0x0
PromptBox.STR_DONE :
	db "DONE", 0
	