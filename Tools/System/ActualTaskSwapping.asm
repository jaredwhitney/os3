TaskSwitch :
	pushad
		mov ebx, [TaskSwitch.currentTask]
		mov edx, [ebx+Task_regs]
		; need to save current task state here!
		mov ecx, [ebx+Task_nextLinked]
		mov eax, [ecx+Task_regs]
		mov edx, [eax+Regs_edi]
		mov [esp+Regs_edi], edx
		mov edx, [eax+Regs_esi]
		mov [esp+Regs_esi], edx
		mov edx, [eax+Regs_ebp]
		mov [esp+Regs_ebp], edx
		mov edx, [eax+Regs_esp]
		mov [esp+Regs_esp], edx
		mov edx, [eax+Regs_ebx]
		mov [esp+Regs_ebx], edx
		mov edx, [eax+Regs_edx]
		mov [esp+Regs_edx], edx
		mov edx, [eax+Regs_ecx]
		mov [esp+Regs_ecx], edx
		mov edx, [eax+Regs_eax]
		mov [esp+Regs_eax], edx
		mov edx, [eax+Regs_eip]
		mov [esp+Regs_eip], edx
		mov edx, [eax+Regs_cs]
		mov [esp+Regs_cs], edx
		mov edx, [eax+Regs_eflags]
		mov [esp+Regs_eflags], edx
		mov edx, [eax+Regs_uesp]
		mov [esp+Regs_uesp], edx
		mov edx, [eax+Regs_ss]
		mov [esp+Regs_ss], edx
		
	iret
	
TaskSwitch.isSubTask :
	dd false

; len = 0x38 [last pushed -> first pushed]
Regs_edi	equ 0x0		; pushed by pusha
Regs_esi	equ 0x4
Regs_ebp	equ 0x8
Regs_esp	equ 0xC
Regs_ebx	equ 0x10
Regs_edx	equ 0x14
Regs_ecx	equ 0x18
Regs_eax	equ 0x1C
Regs_eip	equ 0x20	; pushed by IRQ
Regs_cs		equ 0x24
Regs_eflags	equ 0x28
Regs_uesp	equ 0x2C
Regs_ss		equ 0x30

