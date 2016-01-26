taskswapHandler :
	pop ecx	; pop eip into ecx
		pusha
		mov ebx, [currentTaskNum]	; get the current task
		imul ebx, TASK_OBJ_SIZE
		add ebx, RunningTaskList
		mov [ebx+Task_eip], ecx
		mov [ebx+Task_stackLoc], esp	; store the relevent things
			; get the next Task object into ebx
			taskswapHandler.goLoop :
			add ebx, TASK_OBJ_SIZE
			cmp ebx, RunningTaskListEnd
				jge taskswapHandler.doneZeroing
			mov ebx, RunningTaskList
			taskswapHandler.doneZeroing :
			cmp dword [ebx+Task_id], 0
				je taskswapHandler.goLoop
			taskswapHandler.noloopback :
		mov esp, [ebx+Task_stackLoc]
		popa
	push dword [ebx+Task_eip]
	iret

currentTaskNum :
	dd 0x0
RunningTaskList :
	times 32*TASK_OBJ_SIZE db 0x0	; 32 tasks max atm
RunningTaskListEnd :

Task_id equ 0x0
Task_stackLoc equ 0x4
Task_eip equ 0x8
TASK_OBJ_SIZE equ 0xC


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
dd 0x0
TASK_STACK_SIZE equ 2
