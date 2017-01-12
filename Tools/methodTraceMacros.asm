%macro methodTraceEnter 0
	cmp byte [IN_INT_CALL], false
		jne %%traceInt
	push eax
	mov eax, [Debug.methodTraceStack]
	mov dword [eax], $
	pop eax
	add dword [Debug.methodTraceStack], 4
	jmp %%done
	%%traceInt :
	push eax
	mov eax, [Debug.methodTraceStack2]
	mov dword [eax], $
	pop eax
	add dword [Debug.methodTraceStack2], 4
	%%done :
%endmacro

%macro methodTraceLeave 0
	cmp byte [IN_INT_CALL], false
		jne %%traceInt
	sub dword [Debug.methodTraceStack], 4
	jmp %%done
	%%traceInt :
	sub dword [Debug.methodTraceStack2], 4
	%%done :
%endmacro
