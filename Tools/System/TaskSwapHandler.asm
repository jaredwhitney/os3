taskswapHandler :
	cmp byte [INTERRUPT_DISABLE], 0xFF
		jne taskswapHandler.cont
	call IRQ_FINISH
	iret
	taskswapHandler.cont :
		pusha
		mov ebx, [currentTaskNum]	; get the current task
		imul ebx, TASK_OBJ_SIZE
		add ebx, RunningTaskList
		;			pusha
		;			mov al, 0xF
		;			call console.numOut
		;			call console.newline
		;			mov ebx, ecx
		;			call console.numOut
		;			call console.newline
		;			popa
		;mov [ebx+Task_eip], ecx
		mov [ebx+Task_stackLoc], esp	; store the relevent things
			; get the next Task object into ebx
			taskswapHandler.goLoop :
			add ebx, TASK_OBJ_SIZE
			cmp ebx, RunningTaskListEnd
				jb taskswapHandler.doneZeroing
			mov ebx, RunningTaskList
			taskswapHandler.doneZeroing :
			cmp dword [ebx+Task_id], 0
				je taskswapHandler.goLoop
			Thread.goLoad :
		mov esp, [ebx+Task_stackLoc]
					pusha
		;			mov al, 0xF
		;			call console.numOut
		;			call console.newline
					mov ebx, [ebx+Task_eip]
					call console.numOut
					call console.newline
		;			mov ebx, TaskSwapHandler.testfunc2
		;			call console.numOut
		;			call console.newline
					popa
		popa
		;jmp $
	call IRQ_FINISH
	iret

Task_id equ 0x0
Task_stackLoc equ 0x4
Task_eip equ 0x8
TASK_OBJ_SIZE equ 0xC	

currentTaskNum :
	dd 0x0
RunningTaskList :
	times 32*TASK_OBJ_SIZE db 0x0	; 32 tasks max atm
RunningTaskListEnd :

registerTask :	; eip in ecx
	pusha
		mov ebx, RunningTaskList
		registerTask.loop :
		cmp dword [ebx+Task_id], 0
			je registerTask.foundTask
		add ebx, TASK_OBJ_SIZE
		jmp registerTask.loop
		registerTask.foundTask :
		mov eax, [currentTaskId]
		mov [ebx+Task_id], eax
		mov [ebx+Task_eip], ecx
		add eax, 1
		mov [currentTaskId], eax
		mov edx, ebx
		sub eax, 1
		mov ebx, TASK_STACK_SIZE
		call Guppy.malloc
		add ebx, TASK_STACK_SIZE*0x200
		mov [edx+Task_stackLoc], ebx
	popa
	ret
unregisterTask :	; ID in ecx
	pusha
		mov ebx, RunningTaskList
		unregisterTask.loop :
		cmp dword [ebx+Task_id], ecx
			je unregisterTask.foundTask
		unregisterTask.foundTask :
		xor ecx, ecx
		mov [ebx+Task_id], ecx
	popa
	ret
currentTaskId :
dd 0x1
TASK_STACK_SIZE equ 2

THREADSETUP :	; thread struct in ebx
mov ecx, [ebx+Task_stackLoc]
mov eax, [ebx+Task_eip]
mov [ecx], eax
mov eax, [esp+4]
mov [ecx+4], eax
mov eax, [esp+8]
mov [ecx+8], eax
mov esp, ecx
add esp, 12
pusha
mov [ebx+Task_stackLoc], esp
mov byte [INTERRUPT_DISABLE], 0x00
jmp Thread.goLoad
iret

TaskSwapHandler.doTest :
pusha
	mov ecx, TaskSwapHandler.testfunc1
	call registerTask
	mov ebx, RunningTaskList
	int 0x31
	;mov ecx, TaskSwapHandler.testfunc2
	;call registerTask
	jmp TaskSwapHandler.testfunc1
popa
ret

TaskSwapHandler.testfunc1 :
mov al, 0xF
mov ebx, TaskSwapHandler.testfunc1.str
call console.println
jmp TaskSwapHandler.testfunc1
TaskSwapHandler.testfunc1.str :
	db "Hello from thread 1!", 0

TaskSwapHandler.testfunc2 :
mov al, 0xF
mov ebx, TaskSwapHandler.testfunc2.str
call console.println
jmp TaskSwapHandler.testfunc2
TaskSwapHandler.testfunc2.str :
	db "Hello from thread 2!", 0
