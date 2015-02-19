JASM.console.init :
	pusha
	
	;call console.newline
	
	mov ebx, JASM.console.full
		call fmtEBX
	mov eax, 0
	mov [ebx], eax

	call JASM.console.fullscrn

	mov ebx, retval
		call fmtEBX
	mov eax, 0
	mov [ebx], eax
	
	popa
	ret
	
		; func int fullscrn(null)
JASM.console.fullscrn :

	pusha
	
	mov ecx, JASM.console.full
	
		call fmtECX
	mov eax, [ecx]
	cmp eax, 0
		jne JASM.console.loop_8.end

	mov ebx, 0x140
	call console.setPos

	mov ebx, 40
	call console.setWidth

	mov ebx, 25
	call console.setHeight

	mov ebx, JASM.console.full
		call fmtEBX
	mov eax, 2
	mov [ebx], eax

	JASM.console.loop_8.end :

	mov ecx, JASM.console.full
		call fmtECX
	mov eax, [ecx]
	mov ebx, 1
	cmp eax, ebx
		jne JASM.console.loop_9.end

	mov ebx, 0x6460
	call console.setPos

	mov ebx, 18
	call console.setWidth

	mov ebx, 7
	call console.setHeight

	mov ebx, JASM.console.full
		call fmtEBX
	mov eax, 0
	mov [ebx], eax

JASM.console.loop_9.end :
	mov ecx, JASM.console.full
		call fmtECX
	mov eax, [ecx]
	mov ebx, 2
	cmp eax, ebx
		jne JASM.console.loop_10.end
		
	mov ebx, JASM.console.full
		call fmtEBX
	mov eax, 1
	mov [ebx], eax

JASM.console.loop_10.end :

	mov ebx, JASM.console.done
		call fmtEBX
	mov eax, 1
	mov [ebx], eax

	push debug.num
	mov ebx, 0xFACE
	call it
	
	mov ebx, retval
		call fmtEBX
	mov eax, 0
	mov [ebx], eax
	popa
	ret


	

		; func int post_init(null)
JASM.console.post_init :
pusha
		; color(0xE)
push ebx
mov ebx, 0xE
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
		; color(0xB)
push ebx
mov ebx, 0xB
call console.setColor
pop ebx
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
		; println("FULLSCRN: Toggles fullscreen mode.")
push ebx
mov ebx, JASM.console.var_5
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
mov ebx, JASM.console.var_6
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
mov ebx, JASM.console.var_7
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
		; if (inp seq_mem "FULLSCRN")
pusha
mov eax, [JASM.console.inp]
mov ebx, JASM.console.var_8
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
		; fullscrn(null)
call JASM.console.fullscrn
		; endif
jmp JASM.console.loop_6.EQend
JASM.console.loop_6.end :
popa
JASM.console.loop_6.EQend :
		; if (done = 0)
push eax
push ebx
mov eax, [JASM.console.done]
mov ebx, 0
cmp eax, ebx
pop ebx
pop eax
jne JASM.console.loop_7.end
		; color(0xC)
push ebx
mov ebx, 0xC
call console.setColor
pop ebx
		; print("Unrecognized Command: ")
push ebx
mov ebx, JASM.console.var_9
call console.print
pop ebx
		; print("'")
push ebx
mov ebx, JASM.console.var_10
call console.print
pop ebx
		; print(inp)
push ebx
mov ebx, [JASM.console.inp]
call console.print
pop ebx
		; println("'")
push ebx
mov ebx, JASM.console.var_11
call console.println
pop ebx
		; endif
JASM.console.loop_7.end :
		; color(0xE)
push ebx
mov ebx, 0xE
call console.setColor
pop ebx
		; print("Console: ")
push ebx
mov ebx, JASM.console.var_12
call console.print
pop ebx
		; return 0
mov eax, 0
mov [retval], eax
popa
ret

JASM.console.full :
db 0, 0, 0, 0
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
db "FULLSCRN: Toggles fullscreen mode.", 0
JASM.console.var_6 :
db "EXIT", 0
JASM.console.var_7 :
db "CLEAR", 0
JASM.console.var_8 :
db "FULLSCRN", 0
JASM.console.var_9 :
db "Unrecognized Command: ", 0
JASM.console.var_10 :
db "'", 0
JASM.console.var_11 :
db "'", 0
JASM.console.var_12 :
db "Console: ", 0
retval :
dd 0x0