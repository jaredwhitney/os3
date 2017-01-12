WinMan_niceName			equ 0x00
WinMan_specVersionNumber	equ 0x04
WinMan_versionNumber		equ 0x08
WinMan_initFunc			equ 0x0C
WinMan_setBackgroundImageFunc	equ 0x10
WinMan_setPrimaryColorFunc	equ 0x14
WinMan_updateScreenFunc		equ 0x18
WinMan_handleMouseEventFunc	equ 0x1C
WinMan_handleKeyEventFunc	equ 0x20
WinMan_createWindowFunc		equ 0x24
WinMan_showLoginScreenFunc	equ 0x28
WinMan_showPrimaryMenuFunc	equ 0x2C
WinMan_showSecondaryMenuFunc	equ 0x30

WinMan.Register :
	methodTraceEnter
	enter 0, 0
	push eax
		mov eax, [ebp+8]
		mov [WinMan.modulePointer], eax
	pop eax
	leave
	methodTraceLeave
	ret 4

WinMan.GetNiceName :
	methodTraceEnter
		mov ecx, [WinMan.modulePointer]
		mov ecx, [ecx+WinMan_niceName]
	methodTraceLeave
	ret

WinMan.GetSpecVersionNumber :
	methodTraceEnter
		mov ecx, [WinMan.modulePointer]
		mov ecx, [ecx+WinMan_specVersionNumber]
	methodTraceLeave
	ret

WinMan.GetVersionNumber :
	methodTraceEnter
		mov ecx, [WinMan.modulePointer]
		mov ecx, [ecx+WinMan_versionNumber]
	methodTraceLeave
	ret

WinMan.Init :
	jmp Dolphin2.init
	push eax
		mov eax, [WinMan.modulePointer]
		cmp dword [eax+WinMan_initFunc], null
			je .funcMissing
		call [eax+WinMan_initFunc]
	.funcMissing :
	pop eax
	ret

WinMan.SetBackgroundImage :
	ret
;	enter 0, 0
;	push eax
;		mov eax, [WinMan.modulePointer]
;		cmp dword [WinMan_setBackgroundImageFunc], null
;			je .funcMissing
;		push dword [ebp+8]
;		call [eax+WinMan_setBackgroundImageFunc]
;	.funcMissing :
;	pop eax
;	leave
;	ret 4

WinMan.SetPrimaryColor :
	ret
;	enter 0, 0
;	push eax
;		mov eax, [WinMan.modulePointer]
;		cmp dword [WinMan_setPrimaryColorFunc], null
;			je .funcMissing
;		push dword [ebp+8]
;		call [eax+WinMan_setPrimaryColorFunc]
;	.funcMissing :
;	pop eax
;	leave
;	ret 4

WinMan.UpdateScreen :
	methodTraceEnter
	push eax
		mov eax, [WinMan.modulePointer]
		cmp dword [WinMan_updateScreenFunc], null
			je .funcMissing
		call [eax+WinMan_updateScreenFunc]
	.funcMissing :
	pop eax
	methodTraceLeave
	ret

WinMan.HandleMouseEvent :
	jmp Dolphin2.handleMouseEvent
	ret
;	enter 0, 0
;	push eax
;		mov eax, [WinMan.modulePointer]
;		cmp dword [WinMan_handleMouseEventFunc], null
;			je .funcMissing
;		push dword [ebp+8]
;		call [eax+WinMan_handleMouseEventFunc]
;	.funcMissing :
;	pop eax
;	leave
;	ret 4

WinMan.HandleKeyEvent :
	jmp Dolphin2.HandleKeyboardEvent
	ret
;	enter 0, 0
;	push eax
;		mov eax, [WinMan.modulePointer]
;		cmp dword [WinMan_handleKeyEventFunc], null
;			je .funcMissing
;		push dword [ebp+8]
;		call [eax+WinMan_handleKeyEventFunc]
;	.funcMissing :
;	pop eax
;	leave
;	ret 4

WinMan.CreateWindow :
	;enter 0, 0
;	push eax
		mov eax, [WinMan.modulePointer]
;		cmp dword [WinMan_createWindowFunc], null
;			je .funcMissing
;		push dword [ebp+8]
;		call [eax+WinMan_createWindowFunc]
		jmp [eax+WinMan_createWindowFunc]
;	.funcMissing :
;	pop eax
	;leave
;	ret; 4

WinMan.ShowLoginScreen :
	methodTraceEnter
	push eax
		mov eax, [WinMan.modulePointer]
		cmp dword [WinMan_showLoginScreenFunc], null
			je .funcMissing
		call [eax+WinMan_showLoginScreenFunc]
	.funcMissing :
	pop eax
	methodTraceLeave
	ret

WinMan.ShowPrimaryMenu :
	methodTraceEnter
	push eax
		mov eax, [WinMan.modulePointer]
		cmp dword [WinMan_showPrimaryMenuFunc], null
			je .funcMissing
		call [eax+WinMan_showPrimaryMenuFunc]
	.funcMissing :
	pop eax
	methodTraceLeave
	ret

WinMan.ShowSecondaryMenu :
	methodTraceEnter
	push eax
		mov eax, [WinMan.modulePointer]
		cmp dword [WinMan_showSecondaryMenuFunc], null
			je .funcMissing
		call [eax+WinMan_showSecondaryMenuFunc]
	.funcMissing :
	pop eax
	methodTraceLeave
	ret

WinMan.modulePointer :
	dd Dolphin2_WinManStruct

