SystemMemoryMap.COMMAND_SHOW :
	dd .smmshow
	dd SystemMemoryMap.show
	dd null
	.smmshow :
		db "vmm", 0

SystemMemoryMap.init :
	pusha
		push dword SystemMemoryMap.COMMAND_SHOW
		call iConsole2.RegisterCommand
	popa
	ret

SystemMemoryMap.show :
	pusha
		push dword .sysmemmap
		push dword 0*4
		push dword 0
		push dword 50*4
		push dword 512
		call WinMan.CreateWindow
		mov [SystemMemoryMap.window], ecx
		mov ebx, ecx
		push ebx
		mov ebx, 50*4*512
		call Guppy2.malloc
		mov ecx, ebx
		pop ebx
		push ecx
		push dword 50*4
		push dword 512
		push dword 0*4
		push dword 0
		push dword 50*4
		push dword 512
		call Image.Create
		mov eax, ecx
		call Grouping.Add
		mov eax, [eax+Image_source]
		mov [SystemMemoryMap.loop.imagedata], eax
		
				
		push dword SystemMemoryMap.TASK_MAINLOOP
		call iConsole2.RegisterTask
		
		mov eax, SystemMemoryMap.exit
		mov ebx, [SystemMemoryMap.window]
		call WindowGrouping.RegisterCloseCallback
		
	popa
	ret
	.sysmemmap :
		db "MemMap", 0

SystemMemoryMap.window :
	dd 0x0

SystemMemoryMap.exit :
	pusha
		push dword SystemMemoryMap.TASK_MAINLOOP
		call iConsole2.UnregisterTask
	popa
	ret
SystemMemoryMap.TASK_MAINLOOP :
	dd SystemMemoryMap.loop
	dd null

SystemMemoryMap.loop :
	pusha
		mov edx, 511
		.loop :
		mov ecx, 511
		sub ecx, edx
		imul ecx, 0x7FAAFF;0x1000000
			add ecx, 0xAA0000
		call Guppy2.getRegionEntry
		cmp ecx, null
			jne .notEmpty
		mov ecx, 0xFF000000
		jmp .colorDone
		.notEmpty :
		cmp dword [ecx+Guppy2.Entry_type], Guppy2_Entry.TYPE_UNUSABLE
			jne .notUnusable
		mov ecx, 0xFFFF0000
		jmp .colorDone
		.notUnusable :
		cmp dword [ecx+Guppy2.Entry_type], Guppy2_Entry.TYPE_SYSTEM_RESERVED
			jne .notSystem
		mov ecx, 0xFF00FF00
		jmp .colorDone
		.notSystem :
		cmp dword [ecx+Guppy2.Entry_type], Guppy2_Entry.TYPE_IN_USE
			jne .notInUse
		mov ecx, 0xFF0000FF
		jmp .colorDone
		.notInUse :
		cmp dword [ecx+Guppy2.Entry_type], Guppy2_Entry.TYPE_FREE
			jne .notFree
		mov ecx, 0xFFC0C0C0
		jmp .colorDone
		.notFree :
		.colorDone :
		mov eax, 50
		mov ebx, [.imagedata]
		push edx
			imul edx, 50*4
			add ebx, edx
		pop edx
		.innerloop :
		mov [ebx], ecx
		add ebx, 4
		dec eax
		cmp eax, 0
			ja .innerloop
		dec edx
		cmp edx, 0
			jge .loop
	popa
	ret
	.imagedata :
		dd 0x0

