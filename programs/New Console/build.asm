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
		; full = 0
push eax
mov eax, 0
mov [JASM.console.full], eax
pop eax
		; fullscrn(null)
call JASM.console.fullscrn
		; draw = 1
push eax
mov eax, 1
mov [JASM.console.draw], eax
pop eax
		; file = 0
push eax
mov eax, 0
mov [JASM.console.file], eax
pop eax
		; return 0
mov eax, 0
mov [retval], eax
popa
ret
		; func int post_init(null)
JASM.console.post_init :
pusha
		; color(0xF)
push ebx
mov ebx, 0xF
call console.setColor
pop ebx
		; print("Console: ")
push ebx
mov ebx, JASM.console.var_0
call console.print
pop ebx
		; catch_enter(handleEnter)
push ebx
mov ebx, JASM.console.handleEnter
call os.setEnterSub
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
		; if (file = 1)
push eax
push ebx
mov eax, [JASM.console.file]
mov ebx, 1
cmp eax, ebx
pop ebx
pop eax
jne JASM.console.loop_3.end
		; inp += 2
push eax
push ebx
mov eax, [JASM.console.inp]
mov ebx, 2
add eax, ebx
mov [JASM.console.inp], eax
pop ebx
pop eax
		; View.file(inp)
push ebx
mov ebx, [JASM.console.inp]
call View.file
pop ebx
		; println("See debug for details.")
push ebx
mov ebx, JASM.console.var_1
call console.println
pop ebx
		; file = 0
push eax
mov eax, 0
mov [JASM.console.file], eax
pop eax
		; done = 1
push eax
mov eax, 1
mov [JASM.console.done], eax
pop eax
		; endif
JASM.console.loop_3.end :
		; if (inp seq_mem "help")
pusha
mov eax, [JASM.console.inp]
mov ebx, JASM.console.var_2
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
		; color(0x3D)
push ebx
mov ebx, 0x3D
call console.setColor
pop ebx
		; println("exit: Exits the console.")
push ebx
mov ebx, JASM.console.var_3
call console.println
pop ebx
		; println("clear: Clears the screen.")
push ebx
mov ebx, JASM.console.var_4
call console.println
pop ebx
		; println("help: Displays this prompt.")
push ebx
mov ebx, JASM.console.var_5
call console.println
pop ebx
		; println("fullscreen: Toggles fullscreen mode.")
push ebx
mov ebx, JASM.console.var_6
call console.println
pop ebx
		; println("debug: Toggles the display of debug")
push ebx
mov ebx, JASM.console.var_7
call console.println
pop ebx
		; println("view: View a file")
push ebx
mov ebx, JASM.console.var_8
call console.println
pop ebx
		; println("tree: Displays all mounted files")
push ebx
mov ebx, JASM.console.var_9
call console.println
pop ebx
		; println("memstat: Prints out the percentage of RAM in use")
push ebx
mov ebx, JASM.console.var_10
call console.println
pop ebx
		; done = 1
push eax
mov eax, 1
mov [JASM.console.done], eax
pop eax
		; endif
jmp JASM.console.loop_4.EQend
JASM.console.loop_4.end :
popa
JASM.console.loop_4.EQend :
		; if (inp seq_mem "exit")
pusha
mov eax, [JASM.console.inp]
mov ebx, JASM.console.var_11
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
		; catch_enter(os.return)
push ebx
mov ebx, retfunc
call os.setEnterSub
pop ebx
		; draw = 0
push eax
mov eax, 0
mov [JASM.console.draw], eax
pop eax
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
		; if (inp seq_mem "clear")
pusha
mov eax, [JASM.console.inp]
mov ebx, JASM.console.var_12
JASM.console.loop_6.start :
mov cl, [eax]
mov dl, [ebx]
cmp cl, dl
jne JASM.console.loop_6.end
cmp cl, 0
je JASM.console.loop_6.go
add eax, 1
add ebx, 1
jmp JASM.console.loop_6.start
JASM.console.loop_6.go :
popa
		; cls(null)
call console.clearScreen
		; done = 1
push eax
mov eax, 1
mov [JASM.console.done], eax
pop eax
		; endif
jmp JASM.console.loop_6.EQend
JASM.console.loop_6.end :
popa
JASM.console.loop_6.EQend :
		; if (inp seq_mem "fullscreen")
pusha
mov eax, [JASM.console.inp]
mov ebx, JASM.console.var_13
JASM.console.loop_7.start :
mov cl, [eax]
mov dl, [ebx]
cmp cl, dl
jne JASM.console.loop_7.end
cmp cl, 0
je JASM.console.loop_7.go
add eax, 1
add ebx, 1
jmp JASM.console.loop_7.start
JASM.console.loop_7.go :
popa
		; fullscrn(null)
call JASM.console.fullscrn
		; endif
jmp JASM.console.loop_7.EQend
JASM.console.loop_7.end :
popa
JASM.console.loop_7.EQend :
		; if (inp seq_mem "debug")
pusha
mov eax, [JASM.console.inp]
mov ebx, JASM.console.var_14
JASM.console.loop_8.start :
mov cl, [eax]
mov dl, [ebx]
cmp cl, dl
jne JASM.console.loop_8.end
cmp cl, 0
je JASM.console.loop_8.go
add eax, 1
add ebx, 1
jmp JASM.console.loop_8.start
JASM.console.loop_8.go :
popa
		; toggleDebug(null)
call debug.toggleView
		; done = 1
push eax
mov eax, 1
mov [JASM.console.done], eax
pop eax
		; endif
jmp JASM.console.loop_8.EQend
JASM.console.loop_8.end :
popa
JASM.console.loop_8.EQend :
		; if (inp seq_mem "view")
pusha
mov eax, [JASM.console.inp]
mov ebx, JASM.console.var_15
JASM.console.loop_9.start :
mov cl, [eax]
mov dl, [ebx]
cmp cl, dl
jne JASM.console.loop_9.end
cmp cl, 0
je JASM.console.loop_9.go
add eax, 1
add ebx, 1
jmp JASM.console.loop_9.start
JASM.console.loop_9.go :
popa
		; file = 1
push eax
mov eax, 1
mov [JASM.console.file], eax
pop eax
		; done = 1
push eax
mov eax, 1
mov [JASM.console.done], eax
pop eax
		; endif
jmp JASM.console.loop_9.EQend
JASM.console.loop_9.end :
popa
JASM.console.loop_9.EQend :
		; if (inp seq_mem "tree")
pusha
mov eax, [JASM.console.inp]
mov ebx, JASM.console.var_16
JASM.console.loop_10.start :
mov cl, [eax]
mov dl, [ebx]
cmp cl, dl
jne JASM.console.loop_10.end
cmp cl, 0
je JASM.console.loop_10.go
add eax, 1
add ebx, 1
jmp JASM.console.loop_10.start
JASM.console.loop_10.go :
popa
		; color(0x9)
push ebx
mov ebx, 0x9
call console.setColor
pop ebx
		; Minnow.tree(null)
call Minnow.ctree
		; done = 1
push eax
mov eax, 1
mov [JASM.console.done], eax
pop eax
		; endif
jmp JASM.console.loop_10.EQend
JASM.console.loop_10.end :
popa
JASM.console.loop_10.EQend :
		; if (inp seq_mem "test")
pusha
mov eax, [JASM.console.inp]
mov ebx, JASM.console.var_17
JASM.console.loop_11.start :
mov cl, [eax]
mov dl, [ebx]
cmp cl, dl
jne JASM.console.loop_11.end
cmp cl, 0
je JASM.console.loop_11.go
add eax, 1
add ebx, 1
jmp JASM.console.loop_11.start
JASM.console.loop_11.go :
popa
		; console.test(null)
call console.test
		; done = 1
push eax
mov eax, 1
mov [JASM.console.done], eax
pop eax
		; endif
jmp JASM.console.loop_11.EQend
JASM.console.loop_11.end :
popa
JASM.console.loop_11.EQend :
		; if (inp seq_mem "memstat")
pusha
mov eax, [JASM.console.inp]
mov ebx, JASM.console.var_18
JASM.console.loop_12.start :
mov cl, [eax]
mov dl, [ebx]
cmp cl, dl
jne JASM.console.loop_12.end
cmp cl, 0
je JASM.console.loop_12.go
add eax, 1
add ebx, 1
jmp JASM.console.loop_12.start
JASM.console.loop_12.go :
popa
		; console.memstat(null)
call console.memstat
		; done = 1
push eax
mov eax, 1
mov [JASM.console.done], eax
pop eax
		; endif
jmp JASM.console.loop_12.EQend
JASM.console.loop_12.end :
popa
JASM.console.loop_12.EQend :
		; if (done = 0)
push eax
push ebx
mov eax, [JASM.console.done]
mov ebx, 0
cmp eax, ebx
pop ebx
pop eax
jne JASM.console.loop_13.end
		; color(0x3)
push ebx
mov ebx, 0x3
call console.setColor
pop ebx
		; print("Unrecognized Command: ")
push ebx
mov ebx, JASM.console.var_19
call console.print
pop ebx
		; print("'")
push ebx
mov ebx, JASM.console.var_20
call console.print
pop ebx
		; print(inp)
push ebx
mov ebx, [JASM.console.inp]
call console.print
pop ebx
		; println("'")
push ebx
mov ebx, JASM.console.var_21
call console.println
pop ebx
		; endif
JASM.console.loop_13.end :
		; color(0xF)
push ebx
mov ebx, 0xF
call console.setColor
pop ebx
		; if (file = 0)
push eax
push ebx
mov eax, [JASM.console.file]
mov ebx, 0
cmp eax, ebx
pop ebx
pop eax
jne JASM.console.loop_14.end
		; print("Console: ")
push ebx
mov ebx, JASM.console.var_22
call console.print
pop ebx
		; return 0
mov eax, 0
mov [retval], eax
popa
ret
		; endif
JASM.console.loop_14.end :
		; print("File Name: ")
push ebx
mov ebx, JASM.console.var_23
call console.print
pop ebx
		; return 0
mov eax, 0
mov [retval], eax
popa
ret
		; func int fullscrn(null)
JASM.console.fullscrn :
pusha
		; if (full = 0)
push eax
push ebx
mov eax, [JASM.console.full]
mov ebx, 0
cmp eax, ebx
pop ebx
pop eax
jne JASM.console.loop_15.end
		; setPos(0x0)
push ebx
mov ebx, 0x0
call console.setPos
pop ebx
		; setWidth(0xa0)
push ebx
mov ebx, 0xa0
call console.setWidth
pop ebx
		; setHeight(0xc8)
push ebx
mov ebx, 0xc8
call console.setHeight
pop ebx
		; full = 2
push eax
mov eax, 2
mov [JASM.console.full], eax
pop eax
		; endif
JASM.console.loop_15.end :
		; if (full = 1)
push eax
push ebx
mov eax, [JASM.console.full]
mov ebx, 1
cmp eax, ebx
pop ebx
pop eax
jne JASM.console.loop_16.end
		; setPos(0x0)
push ebx
mov ebx, 0x0
call console.setPos
pop ebx
		; setWidth(0x140)
push ebx
mov ebx, 0x140
call console.setWidth
pop ebx
		; setHeight(0xc8)
push ebx
mov ebx, 0xc8
call console.setHeight
pop ebx
		; full = 0
push eax
mov eax, 0
mov [JASM.console.full], eax
pop eax
		; endif
JASM.console.loop_16.end :
		; if (full = 2)
push eax
push ebx
mov eax, [JASM.console.full]
mov ebx, 2
cmp eax, ebx
pop ebx
pop eax
jne JASM.console.loop_17.end
		; full = 1
push eax
mov eax, 1
mov [JASM.console.full], eax
pop eax
		; endif
JASM.console.loop_17.end :
		; done = 1
push eax
mov eax, 1
mov [JASM.console.done], eax
pop eax
		; return 0
mov eax, 0
mov [retval], eax
popa
ret

JASM.console.full :
db 0, 0, 0, 0
JASM.console.draw :
db 0, 0, 0, 0
JASM.console.file :
db 0, 0, 0, 0
JASM.console.done :
db 0, 0, 0, 0
JASM.console.inp :
db 0, 0, 0, 0
JASM.console.var_0 :
db "Console: ", 0
JASM.console.var_1 :
db "See debug for details.", 0
JASM.console.var_2 :
db "help", 0
JASM.console.var_3 :
db "exit: Exits the console.", 0
JASM.console.var_4 :
db "clear: Clears the screen.", 0
JASM.console.var_5 :
db "help: Displays this prompt.", 0
JASM.console.var_6 :
db "fullscreen: Toggles fullscreen mode.", 0
JASM.console.var_7 :
db "debug: Toggles the display of debug", 0
JASM.console.var_8 :
db "view: View a file", 0
JASM.console.var_9 :
db "tree: Displays all mounted files", 0
JASM.console.var_10 :
db "memstat: Prints out the percentage of RAM in use", 0
JASM.console.var_11 :
db "exit", 0
JASM.console.var_12 :
db "clear", 0
JASM.console.var_13 :
db "fullscreen", 0
JASM.console.var_14 :
db "debug", 0
JASM.console.var_15 :
db "view", 0
JASM.console.var_16 :
db "tree", 0
JASM.console.var_17 :
db "test", 0
JASM.console.var_18 :
db "memstat", 0
JASM.console.var_19 :
db "Unrecognized Command: ", 0
JASM.console.var_20 :
db "'", 0
JASM.console.var_21 :
db "'", 0
JASM.console.var_22 :
db "Console: ", 0
JASM.console.var_23 :
db "File Name: ", 0
retval :
dd 0x0
