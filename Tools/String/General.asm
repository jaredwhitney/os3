String.getLength :	; String in ebx, length out in edx
xor edx, edx
push ebx
push ax
String.getLength.loop :
add ebx, 1
add edx, 1
mov al, [ebx]
cmp al, 0x0
jne String.getLength.loop
pop ax
pop ebx
add edx, 1
ret
