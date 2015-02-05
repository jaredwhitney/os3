Jtest.compiler.1.main :
pusha
push eax
call Jtest.compiler.1.sayhello
mov eax, [retval]
mov [Jtest.compiler.1.x], eax
pop eax
push ebx
mov ebx, Jtest.compiler.1.x
call console.num_out
pop ebx
mov eax, 0
mov [retval], eax
popa
ret
Jtest.compiler.1.sayhello :
pusha
push ebx
mov ebx, Jtest.compiler.1.var_0
call console.print
pop ebx
mov eax, 0
mov [retval], eax
popa
ret

Jtest.compiler.1.x :
db 0, 0, 0, 0
Jtest.compiler.1.var_0 :
db "Hello world.", 0

