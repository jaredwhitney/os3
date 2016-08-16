ProgramStruct :
	dd .helloWorld
	RELOCADDR :
	dd null 

.helloWorld
	pusha
		push dword .strdata
		call Console.Echo
	popa
	ret
	.strdata :
		db "Hello from a program external to the kernel!", 0

Console.Echo :
		mov [.stor], eax
		mov eax, 0x
		add eax, [RELOCADDR]
		int 0x30
		mov eax, [.stor]
	ret
	.stor :
		dd 0x0


