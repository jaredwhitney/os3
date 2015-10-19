[bits 32]

dd TestProgram.$FILE_END - TestProgram.$FILE_START
db "OrcaHLL Class", 0
db "TestProgram", 0
TestProgram.$FILE_START :

TestProgram._init: 
pop dword [TestProgram.returnVal]
push eax
push ebx
push edx
mov ecx, [TestProgram._init.string_0]
push ecx
mov ax, 0x0101
int 0x30
pop edx
pop ebx
pop eax
push dword [TestProgram.returnVal]
ret
	;Vars:
TestProgram._init.string_0 :
	dd TestProgram._init.string_0_data
TestProgram._init.string_0_data :
	db "Hello World!", 0


TestProgram.returnVal:
	dd 0x0
TestProgram.$FILE_END :

