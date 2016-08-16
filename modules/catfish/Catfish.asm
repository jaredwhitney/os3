Catfish.COMMAND_NOTIFY :
	dd .STR_NOTIFY
	dd Catfish.notify
	dd null
	.STR_NOTIFY :
		db "notify", 0x0

Catfish.TASK_UPDATE_WINDOWS :
	dd Catfish.loop
	dd null

Catfish.init :
	pusha
		
		push dword Catfish.TASK_UPDATE_WINDOWS
		call iConsole2.RegisterTask
		
		push dword Catfish.COMMAND_NOTIFY
		call iConsole2.RegisterCommand
		
	popa
	ret

Catfish.notify :
	enter 0, 0
	
		mov dword [.x], 0
		mov dword [.y], 0
		mov dword [.w], 200*4
		mov dword [.h], 50
			
		mov eax, [Graphics.SCREEN_WIDTH]
		sub eax, [.w]
		sub eax, 8*4	; window trim width
		mov [.x], eax
		mov ebx, [Graphics.SCREEN_HEIGHT]
		sub ebx, [.h]
		mov [.y], ebx
		
		push dword .title
		push dword [.x]
		push dword [.y]
		push dword [.w]
		push dword [.h]
		call WinMan.CreateWindow;call Dolphin2.makeWindow
		
			push ecx
		push dword 0
		push dword 0*4
		push dword 0
		push dword [.w]
		push dword [.h]
		push dword FALSE
		call TextArea.Create
				mov ebx, [ebp+8]
				call String.getLength
				mov eax, ebx
				mov ebx, edx
				call Guppy2.malloc
				call String.copy
		mov [ecx+Textarea_text], ebx
		call String.getLength
		mov [ecx+Textarea_len], edx
		mov eax, ecx
			pop ecx
		mov ebx, ecx
		call Grouping.Add
		
			pusha
				mov edx, 0
				mov eax, Catfish.notiData
				.loop :
				cmp eax, Catfish.notiData+Catfish.MAX_ALIVE*Catfish.STRUCT_SIZE
					jb .noFlip
				popa
				leave
				ret 4	; for now, abort (do not show notification)
				.noFlip :
				cmp dword [eax], null
					je .found
				add eax, Catfish.STRUCT_SIZE
				inc edx
				jmp .loop
				.found :
				mov [Catfish.index], edx
			popa
		
		mov edx, [Catfish.index]
		imul edx, Catfish.STRUCT_SIZE
		add edx, Catfish.notiData
		
		mov [edx+CatfishStruct_window], ecx
		mov ebx, ecx
		call WindowGrouping.getBoundingWindow
		mov [edx+CatfishStruct_realWindow], ecx
		
		mov eax, [Clock.tics]
		mov [edx+CatfishStruct_lastTime], eax
		
	leave
	ret 4
	.title :
		db "Notification", 0x0
	.x :
		dd 0x0
	.y :
		dd 0x0
	.w :
		dd 200*4
	.h :
		dd 50

Catfish.window :
	dd 0x0
Catfish.realWindow :
	dd 0x0

Catfish.loop :
	pusha
		
		.repeat :
		mov ebx, [Catfish.index]
		imul ebx, Catfish.STRUCT_SIZE
		add ebx, Catfish.notiData
		
		cmp dword [ebx], null
			je .kret

		mov edx, [Clock.tics]
		mov ecx, edx
		sub edx, [ebx+CatfishStruct_lastTime]
		shr edx, 6
		cmp edx, 0
			je .keepGoing
		mov [ebx+CatfishStruct_lastTime], ecx
		mov eax, [ebx+CatfishStruct_realWindow]
		sub dword [eax+WindowGrouping_y], edx
		cmp dword [eax+WindowGrouping_y], 0
			jge .keepGoing
		push ebx
			mov ebx, [ebx+CatfishStruct_window]
			call WindowGrouping.closeCallback
		pop ebx
		;mov dword [ebx+CatfishStruct_realWindow], 0x0
		mov dword [ebx], null

		.keepGoing :
		.kret :
		inc dword [Catfish.index]
		cmp dword [Catfish.index], Catfish.MAX_ALIVE
			jb .noFlip
		mov dword [Catfish.index], 0
		jmp .ret
		.noFlip :
		jmp .repeat
		
	.ret :
	popa
	ret


Catfish.MAX_ALIVE		equ 10
Catfish.STRUCT_DWORDSIZE	equ 3
Catfish.STRUCT_SIZE		equ Catfish.STRUCT_DWORDSIZE*4

Catfish.notiData :
	times Catfish.MAX_ALIVE * Catfish.STRUCT_DWORDSIZE dd null

Catfish.index :
	dd 0

CatfishStruct_window		equ 0
CatfishStruct_realWindow	equ 4
CatfishStruct_lastTime		equ 8

; Catfish_struct :
; 	Grouping* window
; 	Grouping* realWindow
; 	int lastTime
; 	
; 	3 dword size
; 	lets say max 10 noti's alive before they begin being overwritten


