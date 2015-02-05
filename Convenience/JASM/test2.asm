Jtest.compiler.2.main :
pusha
push eax
call Jtest.compiler.2.sayhello
mov eax, [retval]
mov [Jtest.compiler.2.x], eax
pop eax
push ebx
mov ebx, Jtest.compiler.2.x
call console.num_out
pop ebx
mov eax, 0
mov [retval], eax
popa
ret
Jtest.compiler.2.sayhello :
pusha
push ebx
mov ebx, Jtest.compiler.2.var_0
call console.print
pop ebx
mov eax, 0
mov [retval], eax
popa
ret

Jtest.compiler.2.x :
db 0, 0, 0, 0
Jtest.compiler.2.var_0 :
db "Hello world.", 0

