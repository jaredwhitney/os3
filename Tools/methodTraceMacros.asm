%macro methodTraceEnter 0
	mov ebp, [Debug.methodTraceStack]
	mov dword [ebp], $
	add dword [Debug.methodTraceStack], 4
%endmacro

%macro methodTraceLeave 0
	sub dword [Debug.methodTraceStack], 4
%endmacro
