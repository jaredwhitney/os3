[bits 32]
		; class JASM.test
		; 
		; func int main(null)
JASM.test.main :
pusha
		; cls(null)
call console.clearScreen
		; println("Booting Console...")
push ebx
mov ebx, JASM.test.var_0
call console.println
pop ebx
		; println("This was printed by a JASM program :D")
push ebx
mov ebx, JASM.test.var_1
call console.println
pop ebx
		; x = 1
push eax
mov eax, 1
mov [JASM.test.x], eax
pop eax
		; while (x < 4)
JASM.test.loop_0.start :
push eax
push ebx
mov eax, [JASM.test.x]
mov ebx, 4
cmp eax, ebx
pop ebx
pop eax
jge JASM.test.loop_0.end
		; println("        This should be printed 3x.")
push ebx
mov ebx, JASM.test.var_2
call console.println
pop ebx
		; print("           On time: ")
push ebx
mov ebx, JASM.test.var_3
call console.print
pop ebx
		; print_num(x)
push ebx
mov ebx, [JASM.test.x]
call console.numOut
pop ebx
		; newl(null)
call console.newline
		; x += 1
push eax
push ebx
mov eax, [JASM.test.x]
mov ebx, 1
add eax, ebx
mov [JASM.test.x], eax
pop ebx
pop eax
		; endwhile
jmp JASM.test.loop_0.start
JASM.test.loop_0.end :
		; emu = isEmu(null)
push eax
call JASM.test.isEmu
mov eax, [retval]
mov [JASM.test.emu], eax
pop eax
		; if (emu = 1)
push eax
push ebx
mov eax, [JASM.test.emu]
mov ebx, 1
cmp eax, ebx
pop ebx
pop eax
jne JASM.test.loop_1.end
		; println("Running on an emulator.")
push ebx
mov ebx, JASM.test.var_4
call console.println
pop ebx
		; return 0
mov eax, 0
mov [retval], eax
popa
ret
		; endif
JASM.test.loop_1.end :
		; println("Running on a real computer.")
push ebx
mov ebx, JASM.test.var_5
call console.println
pop ebx
		; return 0
mov eax, 0
mov [retval], eax
popa
ret
		; 
		; func int isEmu(null)
JASM.test.isEmu :
pusha
		; state = os.platform
push eax
mov eax, [0x1000]
mov [JASM.test.state], eax
pop eax
		; if (state = os.EMULATOR)
push eax
push ebx
mov eax, [JASM.test.state]
mov ebx, 0xF
cmp eax, ebx
pop ebx
pop eax
jne JASM.test.loop_2.end
		; return 1
mov eax, 1
mov [retval], eax
popa
ret
		; endif
JASM.test.loop_2.end :
		; return 0
mov eax, 0
mov [retval], eax
popa
ret

JASM.test.x :
db 0, 0, 0, 0
JASM.test.emu :
db 0, 0, 0, 0
JASM.test.state :
db 0, 0, 0, 0
JASM.test.var_0 :
db "Booting Console...", 0
JASM.test.var_1 :
db "This was printed by a JASM program :D", 0
JASM.test.var_2 :
db "        This should be printed 3x.", 0
JASM.test.var_3 :
db "           On time: ", 0
JASM.test.var_4 :
db "Running on an emulator.", 0
JASM.test.var_5 :
db "Running on a real computer.", 0
		; class JASM.console
		; func int init(null)
JASM.console.init :
pusha
		; newl(null)
call console.newline
		; print("Console: ")
push ebx
mov ebx, JASM.console.var_0
call console.print
pop ebx
		; catch_enter(handleEnter)
push ebx
mov ebx, JASM.console.handleEnter
call os.setEcatch
pop ebx
		; return 0
mov eax, 0
mov [retval], eax
popa
ret
		; func int handleEnter(null)
JASM.console.handleEnter :
pusha
		; done = 0
push eax
mov eax, 0
mov [JASM.console.done], eax
pop eax
		; inp = getLine(null)
push eax
call console.getLine
mov eax, [retval]
mov [JASM.console.inp], eax
pop eax
		; newl(null)
call console.newline
		; inp += 9
push eax
push ebx
mov eax, [JASM.console.inp]
mov ebx, 9
add eax, ebx
mov [JASM.console.inp], eax
pop ebx
pop eax
		; if (inp seq_mem "HELP")
pusha
mov eax, [JASM.console.inp]
mov ebx, JASM.console.var_1
JASM.console.loop_3.start :
mov cl, [eax]
mov dl, [ebx]
cmp cl, dl
jne JASM.console.loop_3.end
cmp cl, 0
je JASM.console.loop_3.go
add eax, 1
add ebx, 1
jmp JASM.console.loop_3.start
JASM.console.loop_3.go :
popa
		; println("EXIT: Exits the console.")
push ebx
mov ebx, JASM.console.var_2
call console.println
pop ebx
		; println("CLEAR: Clears the screen.")
push ebx
mov ebx, JASM.console.var_3
call console.println
pop ebx
		; println("HELP: Displays this prompt.")
push ebx
mov ebx, JASM.console.var_4
call console.println
pop ebx
		; done = 1
push eax
mov eax, 1
mov [JASM.console.done], eax
pop eax
		; endif
jmp JASM.console.loop_3.EQend
JASM.console.loop_3.end :
popa
JASM.console.loop_3.EQend :
		; if (inp seq_mem "EXIT")
pusha
mov eax, [JASM.console.inp]
mov ebx, JASM.console.var_5
JASM.console.loop_4.start :
mov cl, [eax]
mov dl, [ebx]
cmp cl, dl
jne JASM.console.loop_4.end
cmp cl, 0
je JASM.console.loop_4.go
add eax, 1
add ebx, 1
jmp JASM.console.loop_4.start
JASM.console.loop_4.go :
popa
		; catch_enter(os.return)
push ebx
mov ebx, retfunc
call os.setEcatch
pop ebx
		; return 0
mov eax, 0
mov [retval], eax
popa
ret
		; endif
jmp JASM.console.loop_4.EQend
JASM.console.loop_4.end :
popa
JASM.console.loop_4.EQend :
		; if (inp seq_mem "CLEAR")
pusha
mov eax, [JASM.console.inp]
mov ebx, JASM.console.var_6
JASM.console.loop_5.start :
mov cl, [eax]
mov dl, [ebx]
cmp cl, dl
jne JASM.console.loop_5.end
cmp cl, 0
je JASM.console.loop_5.go
add eax, 1
add ebx, 1
jmp JASM.console.loop_5.start
JASM.console.loop_5.go :
popa
		; cls(null)
call console.clearScreen
		; done = 1
push eax
mov eax, 1
mov [JASM.console.done], eax
pop eax
		; endif
jmp JASM.console.loop_5.EQend
JASM.console.loop_5.end :
popa
JASM.console.loop_5.EQend :
		; if (done = 0)
push eax
push ebx
mov eax, [JASM.console.done]
mov ebx, 0
cmp eax, ebx
pop ebx
pop eax
jne JASM.console.loop_6.end
		; print("Unrecognized Command: ")
push ebx
mov ebx, JASM.console.var_7
call console.print
pop ebx
		; print("'")
push ebx
mov ebx, JASM.console.var_8
call console.print
pop ebx
		; print(inp)
push ebx
mov ebx, [JASM.console.inp]
call console.print
pop ebx
		; println("'")
push ebx
mov ebx, JASM.console.var_9
call console.println
pop ebx
		; endif
JASM.console.loop_6.end :
		; print("Console: ")
push ebx
mov ebx, JASM.console.var_10
call console.print
pop ebx
		; return 0
mov eax, 0
mov [retval], eax
popa
ret

console.clearScreen :
console.println :
console.print :
console.numOut :
console.newline :
os.setEcatch :
console.getLine :
retfunc :
ret

JASM.console.done :
db 0, 0, 0, 0
JASM.console.inp :
db 0, 0, 0, 0
JASM.console.var_0 :
db "Console: ", 0
JASM.console.var_1 :
db "HELP", 0
JASM.console.var_2 :
db "EXIT: Exits the console.", 0
JASM.console.var_3 :
db "CLEAR: Clears the screen.", 0
JASM.console.var_4 :
db "HELP: Displays this prompt.", 0
JASM.console.var_5 :
db "EXIT", 0
JASM.console.var_6 :
db "CLEAR", 0
JASM.console.var_7 :
db "Unrecognized Command: ", 0
JASM.console.var_8 :
db "'", 0
JASM.console.var_9 :
db "'", 0
JASM.console.var_10 :
db "Console: ", 0
retval :
dd 0x0
