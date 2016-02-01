taskswapHandler :
		call IRQ_FINISH
		cmp byte [INTERRUPT_DISABLE], 0xFF
			je taskswapHandler.ret
		mov byte [INTERRUPT_DISABLE], 0xFF
		pop dword [EIP]
		add esp, 8	; essentially 'pop'ing the EIP, cs, and stack to nowhere
		pusha
		mov ebx, [FRAME]
		shl ebx, 2	; mul by 4
		mov eax, [EIP]
		mov [EIPSTOR+ebx], eax
		mov [ESPSTOR+ebx], esp
		call taskswapHandler.auxfuncs			
		popa
		; do stuffs
			; ~~ TEMPORARY SWAPPING CODE ~~
			pusha
			mov ebx, [FRAME]
			add ebx, 1
			cmp ebx, [THREAD_COUNT]
				jl taskswapHandler.swapframe.noloopback
			mov ebx, 0x0
			taskswapHandler.swapframe.noloopback :
			mov [FRAME], ebx
			shl ebx, 2	; mul by 4
			mov eax, [EIPSTOR+ebx]
			mov [EIP], eax
			mov eax, [ESPSTOR+ebx]
			mov esp, eax
			popa
		call GetEflags
								;cmp dword [EIP], TaskSwapHandler.testfunc2
								;	je noprintx
								pusha
								call console.newline
								mov ebx, esp
								call console.numOut
								call console.newline
								mov ebx, [EFLAGS]
								call console.numOut
								call console.newline
								mov ebx, cs
								call console.numOut
								call console.newline
								mov ebx, [EIP]
								call console.numOut
								call console.newline
								mov ebx, TaskSwapHandler.testfunc2
								call console.numOut
								call console.newline
								popa
								;cli
								;hlt
								noprintx :
		push dword [EFLAGS]
		push cs
		push dword [EIP]
		mov byte [INTERRUPT_DISABLE], 0x00
	taskswapHandler.ret :
	iret
GetEflags :	; returns EFLAGS reg in ebx
	push ebx
	pushfd
	mov ebx, [esp]
	mov [EFLAGS], ebx
	popfd
	pop ebx
	ret
EIP :
	dd 0x0
ESPk :
	dd 0x0
EFLAGS :
	dd 0x0
FRAME :
	dd 0
EIPSTOR :
	dd 0, TaskSwapHandler.testfunc2
ESPSTOR :
	dd 0, 0x1200000
THREAD_COUNT :
	dd 1

taskswapHandler.auxfuncs :
		mov eax, [Clock.tics]
		add eax, 1
		mov [Clock.tics], eax
		pusha
		mov ecx, 200
		xor edx, edx
		idiv ecx
		cmp edx, 199
			jne taskswapHandler.noprint
		; call some printing function here!
		taskswapHandler.noprint :
		popa
	ret

TaskSwapHandler.doTest :
pusha
	mov eax, [THREAD_COUNT]
	shl eax, 2
	mov dword [EIPSTOR+eax], TaskSwapHandler.testfunc2
	push eax
	mov eax, 0x8
	mov ebx, 2
	call Guppy.malloc
	add ebx, 0x200*2
	pop eax
	mov [ESPSTOR+eax], ebx
	add eax, 1
;	mov [THREAD_COUNT], eax
	mov byte [INTERRUPT_DISABLE], 0x00
	jmp TaskSwapHandler.testfunc1
popa
ret

TaskSwapHandler.testfunc1 :
mov al, 0xF
mov ebx, TaskSwapHandler.testfunc1.str
call console.println
jmp TaskSwapHandler.testfunc1
TaskSwapHandler.testfunc1.str :
	db "Hello from thread 1! o.o HELLOW FROM THREAD ONE~~ \\oEo/-7", 0

TaskSwapHandler.testfunc2 :
;	cli
;	hlt
mov al, 0xF
mov ebx, TaskSwapHandler.testfunc2.str
;call console.println
jmp TaskSwapHandler.testfunc2
TaskSwapHandler.testfunc2.str :
	db "Hello from thread 2!", 0
